using PGM.API.Models;

namespace PGM.API.Repositories;

public interface IUsuarioRepository
{
    Task<Usuario?> ValidarCredenciales(string codigoUsuario, string passwordHash);
    Task<List<string>> ObtenerPermisosProcesos(string codigoUsuario);
}
