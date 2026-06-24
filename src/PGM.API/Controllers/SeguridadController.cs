using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PGM.API.Models;
using PGM.API.Repositories;
using System.Security.Cryptography;
using System.Text;

namespace PGM.API.Controllers;

[ApiController]
[Route("api/seguridad")]
[Authorize]
public class SeguridadController(ISeguridadRepository repo) : ControllerBase
{
    // ── Usuarios ───────────────────────────────────────────────────────────────

    [HttpGet("usuarios")]
    public async Task<IActionResult> ListarUsuarios([FromQuery] string? busqueda)
        => Ok(await repo.ListarUsuarios(busqueda));

    [HttpGet("usuarios/{codigo}")]
    public async Task<IActionResult> ObtenerUsuario(string codigo)
    {
        var u = await repo.ObtenerUsuario(codigo);
        return u is null ? NotFound() : Ok(u);
    }

    [HttpPost("usuarios")]
    public async Task<IActionResult> CrearUsuario([FromBody] CrearUsuarioRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.CodigoUsuario) || string.IsNullOrWhiteSpace(req.Password))
            return BadRequest("CodigoUsuario y Password son obligatorios.");

        var hash = ComputeSha1(req.Password);
        await repo.CrearUsuario(req, hash);
        return Created($"/api/seguridad/usuarios/{req.CodigoUsuario}", null);
    }

    [HttpPut("usuarios/{codigo}")]
    public async Task<IActionResult> ActualizarUsuario(string codigo, [FromBody] ActualizarUsuarioRequest req)
    {
        await repo.ActualizarUsuario(codigo, req);
        return NoContent();
    }

    [HttpPut("usuarios/{codigo}/password")]
    public async Task<IActionResult> CambiarPassword(string codigo, [FromBody] CambiarPasswordRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.NuevoPassword))
            return BadRequest("NuevoPassword es obligatorio.");

        var hash = ComputeSha1(req.NuevoPassword);
        await repo.CambiarPassword(codigo, hash);
        return NoContent();
    }

    [HttpDelete("usuarios/{codigo}")]
    public async Task<IActionResult> EliminarUsuario(string codigo)
    {
        await repo.EliminarUsuario(codigo);
        return NoContent();
    }

    // ── Catálogos ──────────────────────────────────────────────────────────────

    [HttpGet("grupos")]
    public async Task<IActionResult> ListarGrupos()
        => Ok(await repo.ListarGrupos());

    [HttpGet("procesos")]
    public async Task<IActionResult> ListarProcesos()
        => Ok(await repo.ListarProcesos());

    // ── Helpers ────────────────────────────────────────────────────────────────

    private static string ComputeSha1(string input)
    {
        var bytes = SHA1.HashData(Encoding.UTF8.GetBytes(input));
        return Convert.ToHexString(bytes).ToLower();
    }
}
