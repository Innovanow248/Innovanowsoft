using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SAF.API.Models;
using SAF.API.Repositories;

namespace SAF.API.Controllers;

[ApiController]
[Route("api/presupuesto")]
[Authorize]
public class PresupuestoController(IPresupuestoRepository repo) : ControllerBase
{
    [HttpGet("{ano}")]
    public async Task<IActionResult> Listar(string ano)
        => Ok(await repo.ListarCuentas(ano));

    [HttpPut("{ano}/{nroCta}")]
    public async Task<IActionResult> Ajustar(string ano, string nroCta, [FromBody] AjustePresupuestoRequest req)
    {
        await repo.AjustarPresupuesto(ano, nroCta, req.NuevoMonto);
        return NoContent();
    }
}
