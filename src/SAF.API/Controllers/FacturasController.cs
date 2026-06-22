using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SAF.API.Models;
using SAF.API.Repositories;

namespace SAF.API.Controllers;

[ApiController]
[Route("api/facturas")]
[Authorize]
public class FacturasController(IFacturasRepository repo) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Listar(
        [FromQuery] int? year,
        [FromQuery] string? identificador,
        [FromQuery] string? estado)
        => Ok(await repo.Listar(year, identificador, estado));

    [HttpPost]
    public async Task<IActionResult> Crear([FromBody] NuevaFacturaRequest req)
    {
        await repo.Crear(req);
        return StatusCode(201);
    }

    [HttpGet("items")]
    public async Task<IActionResult> ObtenerItems(
        [FromQuery] string identificador,
        [FromQuery] string nroFactura)
        => Ok(await repo.ObtenerItems(identificador, nroFactura));
}
