using Microsoft.IdentityModel.Tokens;
using PGM.API.Models;
using PGM.API.Repositories;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace PGM.API.Services;

public interface IAuthService
{
    Task<LoginResponse?> Login(LoginRequest request, string ipOrigen);
}

public class AuthService(
    IUsuarioRepository usuarioRepo,
    IConfiguration config) : IAuthService
{
    public async Task<LoginResponse?> Login(LoginRequest request, string ipOrigen)
    {
        // SHA-1 del password en minúsculas (igual que el sistema PGM existente)
        var hash = ComputeSha1(request.Password);

        var usuario = await usuarioRepo.ValidarCredenciales(request.Usuario, hash);
        if (usuario is null) return null;

        var permisos = await usuarioRepo.ObtenerPermisosProcesos(usuario.CodigoUsuario);

        var token = GenerarToken(usuario, permisos);

        return new LoginResponse
        {
            Token        = token,
            Usuario      = usuario.CodigoUsuario,
            Grupo        = usuario.CodigoGrupo,
            Identificador = usuario.Identificador,
            Permisos     = permisos
        };
    }

    private string GenerarToken(Usuario usuario, List<string> permisos)
    {
        var jwtSection = config.GetSection("Jwt");
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSection["Secret"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new List<Claim>
        {
            new(ClaimTypes.Name,               usuario.CodigoUsuario),
            new("grupo",                       usuario.CodigoGrupo),
            new("identificador",               usuario.Identificador),
            new(JwtRegisteredClaimNames.Jti,   Guid.NewGuid().ToString()),
        };

        // Un claim por permiso de proceso (ADMINISTRAR_PAGOS, CONTABILIDAD, etc.)
        claims.AddRange(permisos.Select(p => new Claim("permiso", p)));

        var expHours = int.Parse(jwtSection["ExpirationHours"] ?? "8");

        var token = new JwtSecurityToken(
            issuer:             jwtSection["Issuer"],
            audience:           jwtSection["Audience"],
            claims:             claims,
            expires:            DateTime.UtcNow.AddHours(expHours),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private static string ComputeSha1(string input)
    {
        var bytes = SHA1.HashData(Encoding.UTF8.GetBytes(input));
        return Convert.ToHexString(bytes).ToLower();
    }
}
