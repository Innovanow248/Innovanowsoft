using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PGM.API.Models;
using PGM.API.Repositories;
using System.Security.Claims;

namespace PGM.API.Controllers;

[ApiController]
[Route("api/caja")]
[Authorize]
public class CajaController(ICajaRepository cajaRepo) : ControllerBase
{
    private string UsuarioActual =>
        User.FindFirstValue(ClaimTypes.Name) ?? "";

    // POST api/caja/sesion/abrir
    [HttpPost("sesion/abrir")]
    public async Task<IActionResult> AbrirSesion([FromBody] AbrirSesionRequest req)
    {
        // Determinar siguiente NRO_SESSION
        var sesionActiva = await cajaRepo.ObtenerSesionActiva(req.Cajero);
        if (sesionActiva is not null)
            return Conflict(new { mensaje = $"Ya existe una sesión activa ({sesionActiva.NroSession}) para el cajero {sesionActiva.Cajero}." });

        var (codErr, msg) = await cajaRepo.AbrirSesion(req.Cajero, req.FechaCaja);
        if (codErr != "BIEN" && codErr != "")
            return BadRequest(new { mensaje = msg });

        var sesion = await cajaRepo.ObtenerSesionActiva(req.Cajero);
        return Ok(sesion);
    }

    // GET api/caja/sesion/activa
    [HttpGet("sesion/activa")]
    public async Task<IActionResult> ObtenerSesionActiva()
    {
        var sesion = await cajaRepo.ObtenerSesionActiva(UsuarioActual);
        if (sesion is null) return NotFound();
        return Ok(sesion);
    }

    // POST api/caja/cobro
    [HttpPost("cobro")]
    public async Task<IActionResult> RegistrarCobro([FromBody] CobroVentanillaRequest req)
    {
        if (!req.NrosInternos.Any())
            return BadRequest(new { mensaje = "Debe seleccionar al menos una cuota." });
        if (!req.FormasPago.Any() || req.FormasPago.Sum(f => f.Importe) <= 0)
            return BadRequest(new { mensaje = "Debe ingresar al menos una forma de pago." });

        var result = await cajaRepo.RegistrarCobroVentanilla(req);
        if (!result.Exitoso)
            return BadRequest(result);
        return Ok(result);
    }

    // GET api/caja/sesion/{cajero}/{fecha}/{nroSession}/resumen
    [HttpGet("sesion/{cajero}/{fecha}/{nroSession}/resumen")]
    public async Task<IActionResult> ObtenerResumen(string cajero, string fecha, string nroSession)
    {
        if (!DateTime.TryParse(fecha, out var fechaDate))
            return BadRequest(new { mensaje = "Fecha inválida." });
        var resumen = await cajaRepo.ObtenerResumenSesion(cajero, fechaDate, nroSession);
        if (resumen is null) return NotFound();
        return Ok(resumen);
    }

    // POST api/caja/sesion/cerrar
    [HttpPost("sesion/cerrar")]
    public async Task<IActionResult> CerrarSesion([FromBody] CerrarSesionRequest req)
    {
        await cajaRepo.CerrarSesion(req.Cajero, req.FechaCaja, req.NroSession, req.DiferenciaCierre);
        return NoContent();
    }

    // GET api/caja/cajeros
    [HttpGet("cajeros")]
    public async Task<IActionResult> ListarCajeros()
    {
        var lista = await cajaRepo.ListarCajeros();
        return Ok(lista);
    }

    // POST api/caja/cajeros
    [HttpPost("cajeros")]
    public async Task<IActionResult> CrearCajero([FromBody] CrearCajeroRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Cajero))
            return BadRequest(new { mensaje = "El código de cajero es requerido." });
        await cajaRepo.CrearCajero(req);
        return Ok(new { mensaje = $"Cajero '{req.Cajero.ToUpper()}' creado correctamente." });
    }

    // PUT api/caja/cajeros/{cajero}/habilitado
    [HttpPut("cajeros/{cajero}/habilitado")]
    public async Task<IActionResult> ToggleHabilitado(string cajero, [FromBody] bool habilitado)
    {
        await cajaRepo.ToggleHabilitado(cajero, habilitado);
        return NoContent();
    }
}
