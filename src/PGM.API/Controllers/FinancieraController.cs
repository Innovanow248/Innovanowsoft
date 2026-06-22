using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PGM.API.Models;
using PGM.API.Repositories;

namespace PGM.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class FinancieraController(IFinancieraRepository repo) : ControllerBase
{
    // GET api/financiera/presupuesto/{ano}
    [HttpGet("presupuesto/{ano}")]
    public async Task<IActionResult> ObtenerPresupuesto(string ano)
    {
        var cuentas = await repo.ObtenerCuentasConSaldo(ano);
        return Ok(cuentas);
    }

    // PUT api/financiera/presupuesto/{ano}/{nroCta}
    [HttpPut("presupuesto/{ano}/{nroCta}")]
    public async Task<IActionResult> AjustarPresupuesto(string ano, string nroCta, [FromBody] AjustePresupuestoRequest req)
    {
        await repo.AjustarPresupuesto(ano, nroCta, req.NuevoMonto);
        return NoContent();
    }

    // GET api/financiera/ordenes-pago/{ano}?estado=P&page=0&pageSize=100
    [HttpGet("ordenes-pago/{ano}")]
    public async Task<IActionResult> ObtenerOrdenesPago(
        string ano,
        [FromQuery] string? estado,
        [FromQuery] int page = 0,
        [FromQuery] int pageSize = 100)
    {
        var result = await repo.ObtenerOrdenesPago(ano, estado, page, pageSize);
        return Ok(result);
    }

    // POST api/financiera/ordenes-pago/{ano}
    [HttpPost("ordenes-pago/{ano}")]
    public async Task<IActionResult> CrearOrdenPago(string ano, [FromBody] NuevaOrdenPagoRequest req)
    {
        var nro = await repo.CrearOrdenPago(ano, req);
        return Ok(new { nroOpago = nro });
    }

    // PUT api/financiera/ordenes-pago/{tipo}/{ano}/{nro}/estado
    [HttpPut("ordenes-pago/{tipo}/{ano}/{nro}/estado")]
    public async Task<IActionResult> CambiarEstado(string tipo, string ano, string nro, [FromBody] CambiarEstadoRequest req)
    {
        var estados = new[] { "P", "A", "E", "C" };
        if (!estados.Contains(req.Estado)) return BadRequest("Estado inválido.");
        await repo.CambiarEstadoOrdenPago(tipo, ano, nro, req.Estado);
        return NoContent();
    }

    // GET api/financiera/proveedores/{identificador}/facturas
    [HttpGet("proveedores/{identificador}/facturas")]
    public async Task<IActionResult> ObtenerFacturas(string identificador)
    {
        var facturas = await repo.ObtenerFacturasPorProveedor(identificador);
        return Ok(facturas);
    }

    // POST api/financiera/proveedores/{identificador}/facturas
    [HttpPost("proveedores/{identificador}/facturas")]
    public async Task<IActionResult> CrearFactura(string identificador, [FromBody] NuevaFacturaRequest req)
    {
        await repo.CrearFactura(identificador, req);
        return Created("", null);
    }
}
