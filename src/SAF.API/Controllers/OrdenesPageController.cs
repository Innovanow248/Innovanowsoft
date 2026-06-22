using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SAF.API.Models;
using SAF.API.Repositories;

namespace SAF.API.Controllers;

[ApiController]
[Route("api/ordenes-pago")]
[Authorize]
public class OrdenesPageController(IOrdenesPageRepository repo) : ControllerBase
{
    [HttpGet("{ano}")]
    public async Task<IActionResult> Listar(string ano, [FromQuery] string? estado, [FromQuery] string? identificador)
        => Ok(await repo.Listar(ano, estado, identificador));

    [HttpPost("{ano}")]
    public async Task<IActionResult> Crear(string ano, [FromBody] NuevaOrdenPagoRequest req)
    {
        var nro = await repo.Crear(ano, req);
        return Ok(new { nro });
    }

    [HttpPut("{tipo}/{ano}/{nro}/estado")]
    public async Task<IActionResult> CambiarEstado(
        string tipo, string ano, string nro,
        [FromBody] CambiarEstadoRequest req)
    {
        var estadosValidos = new[] { "P", "A", "E", "C" };
        if (!estadosValidos.Contains(req.Estado))
            return BadRequest(new { title = $"Estado inválido. Valores: {string.Join(", ", estadosValidos)}" });

        await repo.CambiarEstado(tipo, ano, nro, req.Estado);
        return NoContent();
    }
}
