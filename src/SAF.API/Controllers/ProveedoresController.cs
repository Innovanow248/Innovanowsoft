using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SAF.API.Repositories;

namespace SAF.API.Controllers;

[ApiController]
[Route("api/proveedores")]
[Authorize]
public class ProveedoresController(IProveedoresRepository repo) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Buscar([FromQuery] string termino)
    {
        if (string.IsNullOrWhiteSpace(termino) || termino.Length < 2)
            return BadRequest(new { title = "Ingrese al menos 2 caracteres" });

        return Ok(await repo.Buscar(termino));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> ObtenerPorId(string id)
    {
        var prov = await repo.ObtenerPorId(id);
        if (prov is null) return NotFound();
        return Ok(prov);
    }
}
