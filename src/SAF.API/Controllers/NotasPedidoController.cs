using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SAF.API.Models;
using SAF.API.Repositories;

namespace SAF.API.Controllers;

[ApiController]
[Route("api/notas-pedido")]
[Authorize]
public class NotasPedidoController(INotasPedidoRepository repo) : ControllerBase
{
    [HttpGet("{ano}")]
    public async Task<IActionResult> Listar(string ano, [FromQuery] string? estado)
        => Ok(await repo.Listar(ano, estado));

    [HttpGet("{tipo}/{ano}/{nro}")]
    public async Task<IActionResult> Obtener(string tipo, string ano, string nro)
    {
        var np = await repo.Obtener(tipo, ano, nro);
        if (np is null) return NotFound();
        return Ok(np);
    }

    [HttpPost("{ano}")]
    public async Task<IActionResult> Crear(string ano, [FromBody] NuevaNotaPedidoRequest req)
    {
        var nro = await repo.Crear(ano, req);
        return Ok(new { nro });
    }

    [HttpPut("{tipo}/{ano}/{nro}/estado")]
    public async Task<IActionResult> CambiarEstado(
        string tipo, string ano, string nro,
        [FromBody] CambiarEstadoRequest req)
    {
        var estadosValidos = new[] { "P", "A", "C", "R" };
        if (!estadosValidos.Contains(req.Estado))
            return BadRequest(new { title = $"Estado inválido. Valores: {string.Join(", ", estadosValidos)}" });

        await repo.CambiarEstado(tipo, ano, nro, req.Estado);
        return NoContent();
    }
}
