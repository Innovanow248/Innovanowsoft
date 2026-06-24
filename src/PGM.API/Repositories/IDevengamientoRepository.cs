using PGM.API.Models;

namespace PGM.API.Repositories;

public interface IDevengamientoRepository
{
    // Catálogos
    Task<List<TipoTributo>>   ListarTributos();
    Task<List<ZonaInmueble>>  ListarZonas();

    // Conceptos
    Task<List<ConceptoDevengamiento>> ListarConceptos(int? idTipoTributo, string? busqueda);
    Task<ConceptoDevengamiento?>      ObtenerConcepto(int id);
    Task<int>                         CrearConcepto(CrearConceptoRequest req);
    Task                              ActualizarConcepto(int id, ActualizarConceptoRequest req);
    Task                              EliminarConcepto(int id, string usuario);

    // Conceptos por año
    Task<List<ConceptoAnio>>  ListarConceptoAnios(int idConcepto);
    Task<int>                 CrearConceptoAnio(int idConcepto, CrearConceptoAnioRequest req);
    Task                      ActualizarConceptoAnio(int id, ActualizarConceptoAnioRequest req);
    Task                      EliminarConceptoAnio(int id, string usuario);

    // Vencimientos
    Task<List<Vencimiento>> ListarVencimientos(int? idTipoTributo, string? ejercicio);
    Task<Vencimiento?>      ObtenerVencimiento(int id);
    Task<int>               CrearVencimiento(CrearVencimientoRequest req);
    Task                    ActualizarVencimiento(int id, ActualizarVencimientoRequest req);
    Task                    EliminarVencimiento(int id, string usuario);

    // Planes de pago
    Task<List<TipoPlanPago>>  ListarPlanes(string? busqueda);
    Task<TipoPlanPago?>       ObtenerPlan(int id);
    Task<int>             CrearPlan(CrearPlanPagoRequest req);
    Task                  ActualizarPlan(int id, ActualizarPlanPagoRequest req);
    Task                  EliminarPlan(int id, string usuario);

    // Detalles de plan
    Task<List<TipoPlanPagoDetalle>> ListarDetallesPlan(int idPlan);
    Task<int>                   CrearDetallePlan(int idPlan, CrearPlanDetalleRequest req);
    Task                        EliminarDetallePlan(int id, string usuario);

    // OBSA Modalidades
    Task<List<ObsaModalidad>> ListarObsaModalidades();

    // Intereses
    Task<List<ConfigInteres>> ListarIntereses(int? idTipoTributo);
    Task<ConfigInteres?>      ObtenerInteres(int id);
    Task<int>                 CrearInteres(CrearInteresRequest req);
    Task                      ActualizarInteres(int id, ActualizarInteresRequest req);
    Task                      EliminarInteres(int id, string usuario);

    // Parametrica Tributos
    Task<List<ParametricaTributo>> ListarParametricaTributos();
    Task<int>                      CrearParametricaTributo(CrearParametricaRequest req);
    Task                           EliminarParametricaTributo(int id, string usuario);

    // Vinculación Conceptos
    Task<List<ConceptoVencimiento>> ListarConceptosVencimientos(int? idTipoTributo, string? ejercicio);
    Task<int>                       CrearConceptoVencimiento(CrearConceptoVencimientoRequest req);
    Task                            EliminarConceptoVencimiento(int id, string usuario);

    // Clone por año
    Task<int> ClonarVencimientos(string ejercicioOrigen, string ejercicioDestino, int? idTipoTributo, string usuario);
    Task<int> ClonarConceptosAnio(string ejercicioOrigen, string ejercicioDestino, int? idTipoTributo, string usuario);

    // DevengamientoV2
    Task<EstadoDevengamiento?> ObtenerEstadoDevengamiento(int idJurisdiccion, int? idTipoTributo);
    Task<List<LogDevengamiento>> ObtenerLogDevengamiento(int idJurisdiccion, int take = 20);
    Task<int> IniciarDevengamiento(EjecutarDevengamientoRequest req);
    Task ActualizarEstadoDevengamiento(int idPorcentajeCarga, decimal porcentaje, string estado, string? mensaje);
    Task RegistrarLogDevengamiento(LogDevengamiento log);
}
