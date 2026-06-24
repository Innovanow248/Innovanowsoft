using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PGM.API.Models;
using PGM.API.Repositories;
using PGM.API.Services;

namespace PGM.API.Controllers;

[ApiController]
[Route("api/devengamiento")]
[Authorize]
public class DevengamientoController(IDevengamientoRepository repo, OracleDevengamientoService oracleSvc) : ControllerBase
{
    private readonly OracleDevengamientoService _oracleSvc = oracleSvc;

    // ── Catálogos ───────────────────────────────────────────────────────────────

    [HttpGet("tributos")]
    public async Task<IActionResult> ListarTributos()
        => Ok(await repo.ListarTributos());

    [HttpGet("zonas")]
    public async Task<IActionResult> ListarZonas()
        => Ok(await repo.ListarZonas());

    // ── Conceptos ───────────────────────────────────────────────────────────────

    [HttpGet("conceptos")]
    public async Task<IActionResult> ListarConceptos(
        [FromQuery] int? idTipoTributo,
        [FromQuery] string? busqueda)
        => Ok(await repo.ListarConceptos(idTipoTributo, busqueda));

    [HttpGet("conceptos/{id:int}")]
    public async Task<IActionResult> ObtenerConcepto(int id)
    {
        var c = await repo.ObtenerConcepto(id);
        return c is null ? NotFound() : Ok(c);
    }

    [HttpPost("conceptos")]
    public async Task<IActionResult> CrearConcepto([FromBody] CrearConceptoRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Concepto))
            return BadRequest("Concepto es obligatorio.");
        var nuevoId = await repo.CrearConcepto(req);
        return Created($"/api/devengamiento/conceptos/{nuevoId}", new { id = nuevoId });
    }

    [HttpPut("conceptos/{id:int}")]
    public async Task<IActionResult> ActualizarConcepto(int id, [FromBody] ActualizarConceptoRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Concepto))
            return BadRequest("Concepto es obligatorio.");
        await repo.ActualizarConcepto(id, req);
        return NoContent();
    }

    [HttpDelete("conceptos/{id:int}")]
    public async Task<IActionResult> EliminarConcepto(int id, [FromQuery] string usuario = "SISTEMA")
    {
        await repo.EliminarConcepto(id, usuario);
        return NoContent();
    }

    // ── Conceptos por año ───────────────────────────────────────────────────────

    [HttpGet("conceptos/{id:int}/anios")]
    public async Task<IActionResult> ListarConceptoAnios(int id)
        => Ok(await repo.ListarConceptoAnios(id));

    [HttpPost("conceptos/{id:int}/anios")]
    public async Task<IActionResult> CrearConceptoAnio(int id, [FromBody] CrearConceptoAnioRequest req)
    {
        if (req.AnioEjercicio < 2000 || req.AnioEjercicio > 2100)
            return BadRequest("AnioEjercicio inválido.");
        var nuevoId = await repo.CrearConceptoAnio(id, req);
        return Created($"/api/devengamiento/conceptos-anio/{nuevoId}", new { id = nuevoId });
    }

    [HttpPut("conceptos-anio/{id:int}")]
    public async Task<IActionResult> ActualizarConceptoAnio(int id, [FromBody] ActualizarConceptoAnioRequest req)
    {
        await repo.ActualizarConceptoAnio(id, req);
        return NoContent();
    }

    [HttpDelete("conceptos-anio/{id:int}")]
    public async Task<IActionResult> EliminarConceptoAnio(int id, [FromQuery] string usuario = "SISTEMA")
    {
        await repo.EliminarConceptoAnio(id, usuario);
        return NoContent();
    }

    // ── Vencimientos ────────────────────────────────────────────────────────────

    [HttpGet("vencimientos")]
    public async Task<IActionResult> ListarVencimientos(
        [FromQuery] int? idTipoTributo,
        [FromQuery] string? ejercicio)
        => Ok(await repo.ListarVencimientos(idTipoTributo, ejercicio));

    [HttpGet("vencimientos/{id:int}")]
    public async Task<IActionResult> ObtenerVencimiento(int id)
    {
        var v = await repo.ObtenerVencimiento(id);
        return v is null ? NotFound() : Ok(v);
    }

    [HttpPost("vencimientos")]
    public async Task<IActionResult> CrearVencimiento([FromBody] CrearVencimientoRequest req)
    {
        if (req.IdTipoTributo <= 0 || req.NroCuota <= 0)
            return BadRequest("IdTipoTributo y NroCuota son obligatorios.");
        var nuevoId = await repo.CrearVencimiento(req);
        return Created($"/api/devengamiento/vencimientos/{nuevoId}", new { id = nuevoId });
    }

    [HttpPut("vencimientos/{id:int}")]
    public async Task<IActionResult> ActualizarVencimiento(int id, [FromBody] ActualizarVencimientoRequest req)
    {
        await repo.ActualizarVencimiento(id, req);
        return NoContent();
    }

    [HttpDelete("vencimientos/{id:int}")]
    public async Task<IActionResult> EliminarVencimiento(int id, [FromQuery] string usuario = "SISTEMA")
    {
        await repo.EliminarVencimiento(id, usuario);
        return NoContent();
    }

    // ── Planes de pago ──────────────────────────────────────────────────────────

    [HttpGet("planes-pago")]
    public async Task<IActionResult> ListarPlanes([FromQuery] string? busqueda)
        => Ok(await repo.ListarPlanes(busqueda));

    [HttpGet("planes-pago/{id:int}")]
    public async Task<IActionResult> ObtenerPlan(int id)
    {
        var p = await repo.ObtenerPlan(id);
        return p is null ? NotFound() : Ok(p);
    }

    [HttpPost("planes-pago")]
    public async Task<IActionResult> CrearPlan([FromBody] CrearPlanPagoRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.CodigoPlan) || string.IsNullOrWhiteSpace(req.DesignacionPlan))
            return BadRequest("CodigoPlan y DesignacionPlan son obligatorios.");
        var nuevoId = await repo.CrearPlan(req);
        return Created($"/api/devengamiento/planes-pago/{nuevoId}", new { id = nuevoId });
    }

    [HttpPut("planes-pago/{id:int}")]
    public async Task<IActionResult> ActualizarPlan(int id, [FromBody] ActualizarPlanPagoRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.CodigoPlan) || string.IsNullOrWhiteSpace(req.DesignacionPlan))
            return BadRequest("CodigoPlan y DesignacionPlan son obligatorios.");
        await repo.ActualizarPlan(id, req);
        return NoContent();
    }

    [HttpDelete("planes-pago/{id:int}")]
    public async Task<IActionResult> EliminarPlan(int id, [FromQuery] string usuario = "SISTEMA")
    {
        await repo.EliminarPlan(id, usuario);
        return NoContent();
    }

    // ── Detalles de plan ────────────────────────────────────────────────────────

    [HttpGet("planes-pago/{id:int}/detalles")]
    public async Task<IActionResult> ListarDetallesPlan(int id)
        => Ok(await repo.ListarDetallesPlan(id));

    [HttpPost("planes-pago/{id:int}/detalles")]
    public async Task<IActionResult> CrearDetallePlan(int id, [FromBody] CrearPlanDetalleRequest req)
    {
        var nuevoId = await repo.CrearDetallePlan(id, req);
        return Created($"/api/devengamiento/planes-pago/detalles/{nuevoId}", new { id = nuevoId });
    }

    [HttpDelete("planes-pago/detalles/{id:int}")]
    public async Task<IActionResult> EliminarDetallePlan(int id, [FromQuery] string usuario = "SISTEMA")
    {
        await repo.EliminarDetallePlan(id, usuario);
        return NoContent();
    }

    // ── OBSA Modalidades ────────────────────────────────────────────────────────

    [HttpGet("obsa-modalidades")]
    public async Task<IActionResult> ListarObsaModalidades()
        => Ok(await repo.ListarObsaModalidades());

    // ── Intereses ───────────────────────────────────────────────────────────────

    [HttpGet("intereses")]
    public async Task<IActionResult> ListarIntereses([FromQuery] int? idTipoTributo)
        => Ok(await repo.ListarIntereses(idTipoTributo));

    [HttpGet("intereses/{id:int}")]
    public async Task<IActionResult> ObtenerInteres(int id)
    {
        var item = await repo.ObtenerInteres(id);
        return item is null ? NotFound() : Ok(item);
    }

    [HttpPost("intereses")]
    public async Task<IActionResult> CrearInteres([FromBody] CrearInteresRequest req)
    {
        if (req.IdTipoTributo <= 0 || req.Porcentual < 0)
            return BadRequest("IdTipoTributo y Porcentual son obligatorios.");
        var nuevoId = await repo.CrearInteres(req);
        return Created($"/api/devengamiento/intereses/{nuevoId}", new { id = nuevoId });
    }

    [HttpPut("intereses/{id:int}")]
    public async Task<IActionResult> ActualizarInteres(int id, [FromBody] ActualizarInteresRequest req)
    {
        await repo.ActualizarInteres(id, req);
        return NoContent();
    }

    [HttpDelete("intereses/{id:int}")]
    public async Task<IActionResult> EliminarInteres(int id, [FromQuery] string usuario = "SISTEMA")
    {
        await repo.EliminarInteres(id, usuario);
        return NoContent();
    }

    // ── Parametrica Tributos ────────────────────────────────────────────────────

    [HttpGet("parametrica-tributos")]
    public async Task<IActionResult> ListarParametricaTributos()
        => Ok(await repo.ListarParametricaTributos());

    [HttpPost("parametrica-tributos")]
    public async Task<IActionResult> CrearParametricaTributo([FromBody] CrearParametricaRequest req)
    {
        if (req.IdTipoTributo <= 0)
            return BadRequest("IdTipoTributo es obligatorio.");
        var nuevoId = await repo.CrearParametricaTributo(req);
        return Created($"/api/devengamiento/parametrica-tributos/{nuevoId}", new { id = nuevoId });
    }

    [HttpDelete("parametrica-tributos/{id:int}")]
    public async Task<IActionResult> EliminarParametricaTributo(int id, [FromQuery] string usuario = "SISTEMA")
    {
        await repo.EliminarParametricaTributo(id, usuario);
        return NoContent();
    }

    // ── Vinculación Conceptos ───────────────────────────────────────────────────

    [HttpGet("conceptos-vencimientos")]
    public async Task<IActionResult> ListarConceptosVencimientos(
        [FromQuery] int? idTipoTributo,
        [FromQuery] string? ejercicio)
        => Ok(await repo.ListarConceptosVencimientos(idTipoTributo, ejercicio));

    [HttpPost("conceptos-vencimientos")]
    public async Task<IActionResult> CrearConceptoVencimiento([FromBody] CrearConceptoVencimientoRequest req)
    {
        var nuevoId = await repo.CrearConceptoVencimiento(req);
        return Created($"/api/devengamiento/conceptos-vencimientos/{nuevoId}", new { id = nuevoId });
    }

    [HttpDelete("conceptos-vencimientos/{id:int}")]
    public async Task<IActionResult> EliminarConceptoVencimiento(int id, [FromQuery] string usuario = "SISTEMA")
    {
        await repo.EliminarConceptoVencimiento(id, usuario);
        return NoContent();
    }

    // ── Clone ───────────────────────────────────────────────────────────────

    [HttpPost("vencimientos/clonar")]
    public async Task<IActionResult> ClonarVencimientos([FromBody] ClonarEjercicioRequest req)
    {
        var usuario = User.FindFirstValue(ClaimTypes.Name) ?? "SISTEMA";
        var result = await repo.ClonarVencimientos(req.EjercicioOrigen, req.EjercicioDestino, req.IdTipoTributo, usuario);
        if (result == -1) return BadRequest(new { mensaje = "No hay vencimientos activos en el ejercicio origen." });
        if (result == -2) return Conflict(new { mensaje = "Ya existen vencimientos para el ejercicio destino." });
        return Ok(new { insertados = result });
    }

    [HttpPost("conceptos-anio/clonar")]
    public async Task<IActionResult> ClonarConceptosAnio([FromBody] ClonarEjercicioRequest req)
    {
        var usuario = User.FindFirstValue(ClaimTypes.Name) ?? "SISTEMA";
        var result = await repo.ClonarConceptosAnio(req.EjercicioOrigen, req.EjercicioDestino, req.IdTipoTributo, usuario);
        if (result == -1) return BadRequest(new { mensaje = "No hay conceptos-año activos en el ejercicio origen." });
        if (result == -2) return Conflict(new { mensaje = "Ya existen conceptos-año para el ejercicio destino." });
        return Ok(new { insertados = result });
    }

    // ── DevengamientoV2 ────────────────────────────────────────────────────────

    [HttpGet("v2/estado")]
    public async Task<IActionResult> V2Estado([FromQuery] int idJurisdiccion = 1, [FromQuery] int? idTipoTributo = null)
    {
        var estado = await repo.ObtenerEstadoDevengamiento(idJurisdiccion, idTipoTributo);
        return Ok(estado);
    }

    [HttpGet("v2/log")]
    public async Task<IActionResult> V2Log([FromQuery] int idJurisdiccion = 1, [FromQuery] int take = 20)
    {
        var log = await repo.ObtenerLogDevengamiento(idJurisdiccion, take);
        return Ok(log);
    }

    [HttpPost("v2/ejecutar")]
    public async Task<IActionResult> V2Ejecutar([FromBody] EjecutarDevengamientoRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Ejercicio) || req.IdTipoTributo <= 0)
            return BadRequest(new { mensaje = "Tributo y ejercicio son requeridos." });

        var idRegistro = await repo.IniciarDevengamiento(req);

        // Ejecutar el SP de Oracle de forma asíncrona (fire-and-forget con tracking)
        _ = Task.Run(async () =>
        {
            var inicio = DateTime.UtcNow;
            try
            {
                await _oracleSvc.EjecutarDevengamiento(req, idRegistro);
            }
            catch (Exception ex)
            {
                await repo.ActualizarEstadoDevengamiento(idRegistro, 0, "ERROR", ex.Message);
                await repo.RegistrarLogDevengamiento(new LogDevengamiento
                {
                    IdJurisdiccion    = req.IdJurisdiccion,
                    IdTipoTributo     = req.IdTipoTributo,
                    Ejercicio         = req.Ejercicio,
                    Resultado         = "ERROR",
                    Mensaje           = ex.Message,
                    UsrOperador       = req.Usuario,
                    DuracionSegundos  = (int)(DateTime.UtcNow - inicio).TotalSeconds,
                });
            }
        });

        return Ok(new { ok = true, mensaje = $"Ejecución iniciada (ID: {idRegistro}). Monitoreá el progreso." });
    }
}
