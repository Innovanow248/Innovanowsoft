using PGM.API.Models;

namespace PGM.API.Repositories;

public interface ISeguridadRepository
{
    Task<List<UsuarioAdmin>> ListarUsuarios(string? busqueda);
    Task<UsuarioAdmin?> ObtenerUsuario(string codigo);
    Task CrearUsuario(CrearUsuarioRequest req, string passwordHash);
    Task ActualizarUsuario(string codigo, ActualizarUsuarioRequest req);
    Task CambiarPassword(string codigo, string passwordHash);
    Task EliminarUsuario(string codigo);
    Task<List<GrupoItem>> ListarGrupos();
    Task<List<string>> ListarProcesos();
}
