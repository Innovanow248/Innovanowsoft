using System.Security.Cryptography;
using System.Text;
using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PGM.API.Models;
using PGM.API.Repositories;

namespace PGM.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class PersonasController(IPersonaRepository repo, DbConnectionFactory db) : ControllerBase
{
    [HttpGet("{identificador}")]
    public async Task<IActionResult> ObtenerPorId(string identificador)
    {
        var persona = await repo.ObtenerPorId(identificador);
        return persona is null ? NotFound() : Ok(persona);
    }

    [HttpGet("buscar")]
    public async Task<IActionResult> Buscar([FromQuery] PersonaBusqueda filtro)
    {
        if (!string.IsNullOrWhiteSpace(filtro.CuitCuil))
        {
            var p = await repo.BuscarPorCuit(filtro.CuitCuil);
            return p is null ? NotFound() : Ok(p);
        }
        if (!string.IsNullOrWhiteSpace(filtro.Documento))
        {
            var p = await repo.BuscarPorDocumento(filtro.Documento);
            return p is null ? NotFound() : Ok(p);
        }
        if (!string.IsNullOrWhiteSpace(filtro.Apellido))
        {
            var lista = await repo.BuscarPorApellido(filtro.Apellido);
            return Ok(lista);
        }
        return BadRequest("Debe indicar al menos un criterio de búsqueda.");
    }

    [HttpPost]
    public async Task<IActionResult> Crear([FromBody] Persona persona)
    {
        var nuevoId = await repo.CrearPersona(persona);
        return CreatedAtAction(nameof(ObtenerPorId), new { identificador = nuevoId },
            new { identificador = nuevoId });
    }

    [HttpPut("{identificador}")]
    public async Task<IActionResult> Actualizar(string identificador, [FromBody] Persona persona)
    {
        persona.Identificador = identificador;
        await repo.ActualizarPersona(persona);
        return NoContent();
    }

    // POST api/personas/{identificador}/portal
    [HttpPost("{identificador}/portal")]
    public async Task<IActionResult> AltaPortalWeb(string identificador, [FromBody] AltaPortalRequest req)
    {
        var hash = Convert.ToHexString(MD5.HashData(Encoding.UTF8.GetBytes(req.Password))).ToLower();
        using var conn = db.Create();

        // UPSERT: si ya existe actualiza, si no inserta
        var exists = await conn.ExecuteScalarAsync<int>(
            "SELECT COUNT(*) FROM egov_CFM WHERE Identificador = @Id",
            new { Id = identificador });

        if (exists > 0)
        {
            await conn.ExecuteAsync(
                "UPDATE egov_CFM SET Password = @Hash, Habilitado = @Hab WHERE Identificador = @Id",
                new { Hash = hash, Hab = req.Habilitado ? 1 : 0, Id = identificador });
        }
        else
        {
            await conn.ExecuteAsync(
                "INSERT INTO egov_CFM (Identificador, Habilitado, Password) VALUES (@Id, @Hab, @Hash)",
                new { Id = identificador, Hab = req.Habilitado ? 1 : 0, Hash = hash });
        }
        return NoContent();
    }
}
