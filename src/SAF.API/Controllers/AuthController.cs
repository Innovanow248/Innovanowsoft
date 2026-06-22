using Microsoft.AspNetCore.Mvc;
using SAF.API.Models;
using SAF.API.Services;

namespace SAF.API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(IAuthService authService) : ControllerBase
{
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var response = await authService.Login(request);
        if (response is null) return Unauthorized(new { title = "Usuario o contraseña incorrectos" });
        return Ok(response);
    }
}
