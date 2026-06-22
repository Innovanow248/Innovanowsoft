using PGM.API.Models;

namespace PGM.API.Repositories;

public interface ITributariaRepository
{
    Task<List<BienPadron>> ObtenerBienesPorPersona(string identificador);
    Task<List<DeudaContribuyente>> ObtenerDeudaPendiente(string identificador);
    Task<List<DeudaResumen>> ObtenerResumenDeuda(string identificador);
    Task<List<TipoBien>> ObtenerTiposBien();
    Task<List<PlanPago>> ObtenerPlanesPorTipo(string tipoBien);
    Task<PadronPagedResult> ObtenerPadron(string? tipoBien, string? activo, string? situacion, string? titular, int page, int pageSize);

    // Altas
    Task<string> CrearBienPadron(AltaPadronRequest req);
    Task CrearAutomotor(string idBien, AltaAutomotorRequest req);
    Task CrearCatastro(string idBien, AltaCatastroRequest req);
    Task CrearComercio(string idBien, AltaComercioRequest req);

    // Modificaciones
    Task BajarBien(string idBien, string tipoBien);
    Task CambiarTitular(string idBien, string tipoBien, string nuevoIdentificador);

    // Cobro
    Task<CobroResult> RegistrarCobro(CobroRequest req);

    // Referencia — Tasas
    Task<List<TasaActualizacion>> ObtenerTasas();
    Task CrearTasa(TasaActualizacion tasa);
    Task ActualizarTasa(string interes, DateTime fecha, decimal tasaMensual);
    Task EliminarTasa(string interes, DateTime fecha);

    // Referencia — Valuación Automotores
    Task<List<ValuacionAutomotor>> ObtenerValuacionAutomotores(string? anoValuacion);
    Task<List<string>> ObtenerAnosValuacion();
    Task CrearValuacion(ValuacionAutomotor val);
    Task ActualizarValuacion(ValuacionAutomotor val);
    Task EliminarValuacion(string ano, string cip, int modelo);

    // Inmueble — Propietarios
    Task<List<PropietarioInmueble>> ObtenerPropietarios(string idBien);
    Task AgregarPropietario(string idBien, string identificador, decimal? porcentaje);
    Task EliminarPropietario(string idBien, string identificador);

    // Inmueble — Mejoras
    Task<List<MejoraInmueble>> ObtenerMejoras(string idCatastro);
    Task<int> AgregarMejora(string idCatastro, AltaMejoraRequest req);
    Task EliminarMejora(int clave);

    // Inmueble — Variables
    Task<List<VariablePadron>> ObtenerVariables(string idBien);
}
