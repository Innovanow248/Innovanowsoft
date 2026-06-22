using Microsoft.AspNetCore.Mvc;
using PGM.API.Models;
using PGM.API.Services;

namespace PGM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(IAuthService authService) : ControllerBase
{
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Usuario) ||
            string.IsNullOrWhiteSpace(request.Password))
            return BadRequest("Usuario y contraseña requeridos.");

        var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "";
        var response = await authService.Login(request, ip);

        if (response is null)
            return Unauthorized("Credenciales inválidas o cuenta caducada.");

        return Ok(response);
    }
}
