using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SAF.API.Repositories;

namespace SAF.API.Controllers;

[ApiController]
[Route("api/areas")]
[Authorize]
public class AreasController(IAreasRepository repo) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Listar() => Ok(await repo.Listar());
}
