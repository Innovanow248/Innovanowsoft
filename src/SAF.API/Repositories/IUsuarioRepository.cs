using SAF.API.Models;

namespace SAF.API.Repositories;

public interface IUsuarioRepository
{
    Task<UsuarioSAF?> ValidarCredenciales(string codigoUsuario, string passwordHash);
    Task<List<string>> ObtenerPermisos(string codigoUsuario);
}
