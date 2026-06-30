using PGM.API.Models;

namespace PGM.API.Repositories;

public interface ICajaRepository
{
    Task<(string CodErr, string Msg)> AbrirSesion(string cajero, DateTime fechaCaja);
    Task<SesionCajero?> ObtenerSesionActiva(string cajero);
    Task<CobroVentanillaResult> RegistrarCobroVentanilla(CobroVentanillaRequest req);
    Task<ResumenSesion?> ObtenerResumenSesion(string cajero, DateTime fechaCaja, string nroSession);
    Task CerrarSesion(string cajero, DateTime fechaCaja, string nroSession, decimal diferencia);
    Task<List<CajeroUsuario>> ListarCajeros();
    Task CrearCajero(CrearCajeroRequest req);
    Task ToggleHabilitado(string cajero, bool habilitado);
}
