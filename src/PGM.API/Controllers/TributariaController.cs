using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PGM.API.Models;
using PGM.API.Repositories;

namespace PGM.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class TributariaController(
    IPersonaRepository personaRepo,
    ITributariaRepository tributariaRepo) : ControllerBase
{
    // GET api/tributaria/contribuyente/{identificador}/bienes
    [HttpGet("contribuyente/{identificador}/bienes")]
    public async Task<IActionResult> ObtenerBienes(string identificador)
    {
        var bienes = await tributariaRepo.ObtenerBienesPorPersona(identificador);
        return Ok(bienes);
    }

    // GET api/tributaria/contribuyente/{identificador}/deuda
    [HttpGet("contribuyente/{identificador}/deuda")]
    public async Task<IActionResult> ObtenerDeuda(string identificador)
    {
        var deuda = await tributariaRepo.ObtenerDeudaPendiente(identificador);
        return Ok(deuda);
    }

    // GET api/tributaria/contribuyente/{identificador}/deuda/resumen
    [HttpGet("contribuyente/{identificador}/deuda/resumen")]
    public async Task<IActionResult> ObtenerResumenDeuda(string identificador)
    {
        var resumen = await tributariaRepo.ObtenerResumenDeuda(identificador);
        return Ok(resumen);
    }

    // GET api/tributaria/tipos-bien
    [HttpGet("tipos-bien")]
    public async Task<IActionResult> ObtenerTiposBien()
    {
        var tipos = await tributariaRepo.ObtenerTiposBien();
        return Ok(tipos);
    }

    // GET api/tributaria/planes/{tipoBien}
    [HttpGet("planes/{tipoBien}")]
    public async Task<IActionResult> ObtenerPlanes(string tipoBien)
    {
        var planes = await tributariaRepo.ObtenerPlanesPorTipo(tipoBien.ToUpper());
        return Ok(planes);
    }

    // GET api/tributaria/padron?tipoBien=IN&activo=1&situacion=RE&page=1&pageSize=50
    [HttpGet("padron")]
    public async Task<IActionResult> ObtenerPadron(
        [FromQuery] string? tipoBien,
        [FromQuery] string? activo,
        [FromQuery] string? situacion,
        [FromQuery] string? titular,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        pageSize = Math.Min(pageSize, 200);
        var result = await tributariaRepo.ObtenerPadron(tipoBien?.ToUpper(), activo, situacion?.ToUpper(), titular, page, pageSize);
        return Ok(result);
    }

    // GET api/tributaria/buscar?cuit=...  (busca persona + deuda en un solo call)
    [HttpGet("buscar")]
    public async Task<IActionResult> BuscarContribuyente([FromQuery] string? cuit,
                                                         [FromQuery] string? documento,
                                                         [FromQuery] string? apellido,
                                                         [FromQuery] string? id,
                                                         [FromQuery] string[]? tipoBienes)
    {
        string? identificador = null;

        if (!string.IsNullOrWhiteSpace(cuit))
        {
            var p = await personaRepo.BuscarPorCuit(cuit);
            identificador = p?.Identificador;
        }
        else if (!string.IsNullOrWhiteSpace(documento))
        {
            var p = await personaRepo.BuscarPorDocumento(documento);
            identificador = p?.Identificador;
        }
        else if (!string.IsNullOrWhiteSpace(id))
        {
            identificador = id;
        }
        else if (!string.IsNullOrWhiteSpace(apellido))
        {
            var lista = await personaRepo.BuscarPorApellido(apellido, tipoBienes);
            return Ok(lista);
        }

        if (identificador is null) return NotFound();

        var persona = await personaRepo.ObtenerPorId(identificador);
        var resumen = await tributariaRepo.ObtenerResumenDeuda(identificador);
        var bienes  = await tributariaRepo.ObtenerBienesPorPersona(identificador);

        // Si hay filtro por tipo, verificar que el contribuyente tenga al menos un bien del tipo solicitado
        if (tipoBienes?.Length > 0 &&
            !bienes.Any(b => tipoBienes.Contains(b.TipoBien?.Trim(), StringComparer.OrdinalIgnoreCase)))
            return NotFound();

        return Ok(new { persona, resumen, bienes });
    }

    // ── ALTAS ───────────────────────────────────────────────────────────────

    // POST api/tributaria/padron
    [HttpPost("padron")]
    public async Task<IActionResult> AltaPadron([FromBody] AltaPadronRequest req)
    {
        var idBien = await tributariaRepo.CrearBienPadron(req);
        return Ok(new { idBien });
    }

    // POST api/tributaria/padron/{idBien}/automotor
    [HttpPost("padron/{idBien}/automotor")]
    public async Task<IActionResult> AltaAutomotor(string idBien, [FromBody] AltaAutomotorRequest req)
    {
        await tributariaRepo.CrearAutomotor(idBien, req);
        return NoContent();
    }

    // POST api/tributaria/padron/{idBien}/catastro
    [HttpPost("padron/{idBien}/catastro")]
    public async Task<IActionResult> AltaCatastro(string idBien, [FromBody] AltaCatastroRequest req)
    {
        await tributariaRepo.CrearCatastro(idBien, req);
        return NoContent();
    }

    // POST api/tributaria/padron/{idBien}/comercio
    [HttpPost("padron/{idBien}/comercio")]
    public async Task<IActionResult> AltaComercio(string idBien, [FromBody] AltaComercioRequest req)
    {
        await tributariaRepo.CrearComercio(idBien, req);
        return NoContent();
    }

    // ── MODIFICACIONES ──────────────────────────────────────────────────────

    // PUT api/tributaria/padron/{idBien}/baja?tipoBien=AUAU
    [HttpPut("padron/{idBien}/baja")]
    public async Task<IActionResult> BajaBien(string idBien, [FromQuery] string tipoBien)
    {
        await tributariaRepo.BajarBien(idBien, tipoBien);
        return NoContent();
    }

    // PUT api/tributaria/padron/{idBien}/titular?tipoBien=AUAU
    [HttpPut("padron/{idBien}/titular")]
    public async Task<IActionResult> CambiarTitular(string idBien, [FromQuery] string tipoBien,
                                                     [FromBody] CambioTitularRequest req)
    {
        await tributariaRepo.CambiarTitular(idBien, tipoBien, req.NuevoIdentificador);
        return NoContent();
    }

    // ── COBRO ───────────────────────────────────────────────────────────────

    // POST api/tributaria/cobro
    [HttpPost("cobro")]
    public async Task<IActionResult> RegistrarCobro([FromBody] CobroRequest req)
    {
        var result = await tributariaRepo.RegistrarCobro(req);
        return result.Exitoso ? Ok(result) : BadRequest(result);
    }

    // ── REFERENCIA — TASAS ─────────────────────────────────────────────────

    [HttpGet("referencia/tasas")]
    public async Task<IActionResult> ObtenerTasas()
        => Ok(await tributariaRepo.ObtenerTasas());

    [HttpPost("referencia/tasas")]
    public async Task<IActionResult> CrearTasa([FromBody] TasaActualizacion req)
    {
        await tributariaRepo.CrearTasa(req);
        return Created("", req);
    }

    [HttpPut("referencia/tasas")]
    public async Task<IActionResult> ActualizarTasa([FromBody] TasaActualizacion req)
    {
        await tributariaRepo.ActualizarTasa(req.Interes, req.Fecha, req.TasaMensual);
        return NoContent();
    }

    [HttpDelete("referencia/tasas")]
    public async Task<IActionResult> EliminarTasa([FromQuery] string interes, [FromQuery] string fecha)
    {
        if (!DateTime.TryParse(fecha, out var fechaDt)) return BadRequest("Fecha inválida.");
        await tributariaRepo.EliminarTasa(interes, fechaDt);
        return NoContent();
    }

    // ── REFERENCIA — VALUACIÓN AUTOMOTORES ─────────────────────────────────

    [HttpGet("referencia/valuacion-automotores")]
    public async Task<IActionResult> ObtenerValuacion(
        [FromQuery] string? ano, [FromQuery] string? marca, [FromQuery] string? modelo)
        => Ok(await tributariaRepo.ObtenerValuacionAutomotores(ano, marca, modelo));

    [HttpGet("referencia/valuacion-automotores/anos")]
    public async Task<IActionResult> ObtenerAnosValuacion()
        => Ok(await tributariaRepo.ObtenerAnosValuacion());

    [HttpGet("referencia/valuacion-automotores/marcas")]
    public async Task<IActionResult> ObtenerMarcas([FromQuery] string ano)
        => Ok(await tributariaRepo.ObtenerMarcasAutomotores(ano));

    [HttpGet("referencia/valuacion-automotores/modelos")]
    public async Task<IActionResult> ObtenerModelos([FromQuery] string ano, [FromQuery] string marca)
        => Ok(await tributariaRepo.ObtenerModelosAutomotores(ano, marca));

    [HttpPost("referencia/valuacion-automotores")]
    public async Task<IActionResult> CrearValuacion([FromBody] ValuacionAutomotor req)
    {
        await tributariaRepo.CrearValuacion(req);
        return Created("", req);
    }

    [HttpPut("referencia/valuacion-automotores")]
    public async Task<IActionResult> ActualizarValuacion([FromBody] ValuacionAutomotor req)
    {
        await tributariaRepo.ActualizarValuacion(req);
        return NoContent();
    }

    [HttpDelete("referencia/valuacion-automotores")]
    public async Task<IActionResult> EliminarValuacion([FromQuery] string ano, [FromQuery] string cip, [FromQuery] int modelo)
    {
        await tributariaRepo.EliminarValuacion(ano, cip, modelo);
        return NoContent();
    }

    // ── PROPIETARIOS INMUEBLE ───────────────────────────────────────────────

    [HttpGet("padron/{idBien}/propietarios")]
    public async Task<IActionResult> ObtenerPropietarios(string idBien)
        => Ok(await tributariaRepo.ObtenerPropietarios(idBien));

    [HttpPost("padron/{idBien}/propietarios")]
    public async Task<IActionResult> AgregarPropietario(string idBien, [FromBody] PropietarioRequest req)
    {
        await tributariaRepo.AgregarPropietario(idBien, req.Identificador, req.PorcentajeAcciones);
        return Ok();
    }

    [HttpDelete("padron/{idBien}/propietarios/{identificador}")]
    public async Task<IActionResult> EliminarPropietario(string idBien, string identificador)
    {
        await tributariaRepo.EliminarPropietario(idBien, identificador);
        return NoContent();
    }

    // ── MEJORAS CATASTRO ────────────────────────────────────────────────────

    [HttpGet("catastro/{idCatastro}/mejoras")]
    public async Task<IActionResult> ObtenerMejoras(string idCatastro)
        => Ok(await tributariaRepo.ObtenerMejoras(idCatastro));

    [HttpPost("catastro/{idCatastro}/mejoras")]
    public async Task<IActionResult> AgregarMejora(string idCatastro, [FromBody] AltaMejoraRequest req)
    {
        var clave = await tributariaRepo.AgregarMejora(idCatastro, req);
        return Ok(new { clave });
    }

    [HttpDelete("catastro/{idCatastro}/mejoras/{clave:int}")]
    public async Task<IActionResult> EliminarMejora(string idCatastro, int clave)
    {
        await tributariaRepo.EliminarMejora(clave);
        return NoContent();
    }

    // ── VARIABLES PARAMÉTRICAS ──────────────────────────────────────────────

    [HttpGet("padron/{idBien}/variables")]
    public async Task<IActionResult> ObtenerVariables(string idBien)
        => Ok(await tributariaRepo.ObtenerVariables(idBien));

    // ── DETALLE CATASTRO ────────────────────────────────────────────────────

    [HttpGet("catastro/{idBien}/detalle")]
    public async Task<IActionResult> ObtenerCatastroDetalle(string idBien)
    {
        var result = await tributariaRepo.ObtenerCatastroDetalle(idBien);
        if (result is null) return NotFound();
        return Ok(result);
    }

    // ── COMERCIO: DETALLE Y SUCURSALES ──────────────────────────────────────

    [HttpGet("comercio/{idBien}/detalle")]
    public async Task<IActionResult> ObtenerComercioDetalle(string idBien)
    {
        var result = await tributariaRepo.ObtenerComercioDetalle(idBien);
        if (result is null) return NotFound();
        return Ok(result);
    }

    [HttpGet("comercio/{idBien}/rubros")]
    public async Task<IActionResult> ObtenerRubrosComercio(string idBien)
        => Ok(await tributariaRepo.ObtenerRubrosComercio(idBien));

    [HttpGet("comercio/{idBien}/sucursales")]
    public async Task<IActionResult> ObtenerSucursales(string idBien)
        => Ok(await tributariaRepo.ObtenerSucursales(idBien));

    [HttpPost("comercio/{idBien}/sucursales")]
    public async Task<IActionResult> CrearSucursal(string idBien, [FromBody] AltaSucursalRequest req)
    {
        await tributariaRepo.CrearSucursal(idBien, req);
        return Ok();
    }

    [HttpDelete("comercio/{idBien}/sucursales/{nroSucursal}")]
    public async Task<IActionResult> BajarSucursal(string idBien, string nroSucursal)
    {
        await tributariaRepo.BajarSucursal(idBien, nroSucursal);
        return NoContent();
    }
}
