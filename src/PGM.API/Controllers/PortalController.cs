using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using PGM.API.Models;
using PGM.API.Repositories;

namespace PGM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PortalController(
    DbConnectionFactory db,
    IPersonaRepository personaRepo,
    ITributariaRepository tributariaRepo,
    IConfiguration config) : ControllerBase
{
    // POST api/portal/login
    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] PortalLoginRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Identificador) || string.IsNullOrWhiteSpace(req.Password))
            return BadRequest("CUIT/DNI y contraseña requeridos.");

        var hash = Convert.ToHexString(MD5.HashData(Encoding.UTF8.GetBytes(req.Password))).ToLower();

        // Resolver identificador: puede venir CUIT, DNI o el ID interno
        var input = req.Identificador.Trim().Replace("-", "").Replace(".", "");
        Persona? persona = null;
        string identificador = input;

        // Intentar directo por identificador interno
        persona = await personaRepo.ObtenerPorId(input);
        if (persona is null)
        {
            // Intentar por CUIT
            persona = await personaRepo.BuscarPorCuit(input);
            if (persona is null)
                // Intentar por DNI/documento
                persona = await personaRepo.BuscarPorDocumento(input);
        }

        if (persona is null) return Unauthorized("Credenciales inválidas.");
        identificador = persona.Identificador;

        using var conn = db.Create();
        var habilitado = await conn.ExecuteScalarAsync<int>(
            """
            SELECT COUNT(*) FROM egov_CFM
            WHERE Identificador = @Id AND Password = @Hash AND Habilitado = 1
            """,
            new { Id = identificador, Hash = hash });

        if (habilitado == 0) return Unauthorized("Credenciales inválidas o acceso deshabilitado.");

        var token = GenerarTokenCiudadano(identificador);

        return Ok(new PortalLoginResponse
        {
            Token         = token,
            Identificador = persona.Identificador,
            Nombre        = persona.Nombre,
            Apellido      = persona.Apellido,
        });
    }

    // GET api/portal/perfil
    [HttpGet("perfil")]
    [Authorize(Policy = "Ciudadano")]
    public async Task<IActionResult> Perfil()
    {
        var id = User.FindFirstValue("identificador")!;
        var persona = await personaRepo.ObtenerPorId(id);
        if (persona is null) return NotFound();

        var bienes = await tributariaRepo.ObtenerBienesPorPersona(id);
        return Ok(new { persona, bienes });
    }

    // GET api/portal/deuda
    [HttpGet("deuda")]
    [Authorize(Policy = "Ciudadano")]
    public async Task<IActionResult> Deuda()
    {
        var id = User.FindFirstValue("identificador")!;
        var resumen = await tributariaRepo.ObtenerResumenDeuda(id);
        var cuotas  = await tributariaRepo.ObtenerDeudaPendiente(id);
        return Ok(new { resumen, cuotas });
    }

    // POST api/portal/pagar
    [HttpPost("pagar")]
    [Authorize(Policy = "Ciudadano")]
    public async Task<IActionResult> Pagar([FromBody] PortalPagoRequest req)
    {
        var result = await tributariaRepo.RegistrarCobro(new CobroRequest
        {
            NroInterno = req.NroInterno,
            FechaPago  = DateTime.TryParse(req.FechaPago, out var fp) ? fp : DateTime.Today,
        });
        return result.Exitoso ? Ok(result) : BadRequest(result);
    }

    private string GenerarTokenCiudadano(string identificador)
    {
        var jwtSection = config.GetSection("Jwt");
        var key   = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSection["Secret"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.Name,               identificador),
            new Claim("identificador",               identificador),
            new Claim(ClaimTypes.Role,               "ciudadano"),
            new Claim(JwtRegisteredClaimNames.Jti,   Guid.NewGuid().ToString()),
        };

        var token = new JwtSecurityToken(
            issuer:             jwtSection["Issuer"],
            audience:           jwtSection["Audience"],
            claims:             claims,
            expires:            DateTime.UtcNow.AddHours(24),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
