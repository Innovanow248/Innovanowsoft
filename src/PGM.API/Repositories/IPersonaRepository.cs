using PGM.API.Models;

namespace PGM.API.Repositories;

public interface IPersonaRepository
{
    Task<Persona?> BuscarPorCuit(string cuitCuil);
    Task<Persona?> BuscarPorDocumento(string documento);
    Task<List<Persona>> BuscarPorApellido(string apellido);
    Task<Persona?> ObtenerPorId(string identificador);
    Task<string> CrearPersona(Persona persona);
    Task ActualizarPersona(Persona persona);
}
