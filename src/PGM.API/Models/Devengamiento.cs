namespace PGM.API.Models;

// ── Catálogos ──────────────────────────────────────────────────────────────────

public class TipoTributo
{
    public int    IdTipoTributo      { get; set; }
    public string TipoTributo_       { get; set; } = "";   // alias para no colisionar con el nombre de clase
    public string Concepto           { get; set; } = "";
    public string? ConceptoAbreviado { get; set; }
}

public class ZonaInmueble
{
    public int    IdZonas            { get; set; }
    public string Concepto           { get; set; } = "";
    public string ConceptoAbreviado  { get; set; } = "";
}

// ── Conceptos ──────────────────────────────────────────────────────────────────

public class ConceptoDevengamiento
{
    public int     IdTipoConcepto    { get; set; }
    public int?    IdTipoTributo     { get; set; }
    public string  Concepto          { get; set; } = "";
    public string? Descripcion       { get; set; }
    public string? Impacto           { get; set; }
    public decimal? Porcentaje       { get; set; }
    public decimal? Valor            { get; set; }
    public string? ObjetoRef         { get; set; }
    public int?    Orden             { get; set; }
    public string? TipoCuota         { get; set; }
    public string? Masivo            { get; set; }
    public int?    IdTipoTributoAux  { get; set; }
    // auditoría
    public string   UsrIng           { get; set; } = "";
    public DateTime FecIng           { get; set; }
    public string?  UsrMod           { get; set; }
    public DateTime? FecMod          { get; set; }
    public string?  UsrBaja          { get; set; }
    public DateTime? FecBaja         { get; set; }
    // nested
    public List<ConceptoAnio> Anios  { get; set; } = [];
}

public class ConceptoAnio
{
    public int     IdTipoconAnio     { get; set; }
    public int     IdTipoConcepto    { get; set; }
    public int     AnioEjercicio     { get; set; }
    public decimal? Porcentaje       { get; set; }
    public decimal? Valor            { get; set; }
    public string   UsrIng           { get; set; } = "";
    public DateTime FecIng           { get; set; }
    public string?  UsrMod           { get; set; }
    public DateTime? FecMod          { get; set; }
    public string?  UsrBaja          { get; set; }
    public DateTime? FecBaja         { get; set; }
}

public class CrearConceptoRequest
{
    public int?    IdTipoTributo     { get; set; }
    public string  Concepto          { get; set; } = "";
    public string? Descripcion       { get; set; }
    public string? Impacto           { get; set; }
    public decimal? Porcentaje       { get; set; }
    public decimal? Valor            { get; set; }
    public string? ObjetoRef         { get; set; }
    public int?    Orden             { get; set; }
    public string? TipoCuota         { get; set; }
    public string? Masivo            { get; set; }
    public int?    IdTipoTributoAux  { get; set; }
    public string  Usuario           { get; set; } = "SISTEMA";
}

public class ActualizarConceptoRequest
{
    public int?    IdTipoTributo     { get; set; }
    public string  Concepto          { get; set; } = "";
    public string? Descripcion       { get; set; }
    public string? Impacto           { get; set; }
    public decimal? Porcentaje       { get; set; }
    public decimal? Valor            { get; set; }
    public string? ObjetoRef         { get; set; }
    public int?    Orden             { get; set; }
    public string? TipoCuota         { get; set; }
    public string? Masivo            { get; set; }
    public int?    IdTipoTributoAux  { get; set; }
    public string  Usuario           { get; set; } = "SISTEMA";
}

public class CrearConceptoAnioRequest
{
    public int     AnioEjercicio     { get; set; }
    public decimal? Porcentaje       { get; set; }
    public decimal? Valor            { get; set; }
    public string  Usuario           { get; set; } = "SISTEMA";
}

public class ActualizarConceptoAnioRequest
{
    public int     AnioEjercicio     { get; set; }
    public decimal? Porcentaje       { get; set; }
    public decimal? Valor            { get; set; }
    public string  Usuario           { get; set; } = "SISTEMA";
}

// ── Vencimientos ───────────────────────────────────────────────────────────────

public class Vencimiento
{
    public int       IdVencimientos  { get; set; }
    public int       IdTipoTributo   { get; set; }
    public int       NroCuota        { get; set; }
    public string?   Ejercicio       { get; set; }
    public string?   NTipo           { get; set; }
    public string?   NZona           { get; set; }
    public DateTime  FechaPrimerVto  { get; set; }
    public DateTime? FechaSegundoVto { get; set; }
    public DateTime? FechaTercerVto  { get; set; }
    public decimal?  DescPrimerVto   { get; set; }
    public decimal?  DescSegundoVto  { get; set; }
    public decimal?  DescTercerVto   { get; set; }
    public int?      IdObsaModalidad { get; set; }
    public string   UsrIng           { get; set; } = "";
    public string   FecIng           { get; set; } = "";
    public string?  UsrMod           { get; set; }
    public string?  FecMod           { get; set; }
    public string?  UsrBaja          { get; set; }
    public DateTime? FecBaja         { get; set; }
}

public class CrearVencimientoRequest
{
    public int       IdTipoTributo   { get; set; }
    public int       NroCuota        { get; set; }
    public string?   Ejercicio       { get; set; }
    public string?   NTipo           { get; set; }
    public string?   NZona           { get; set; }
    public DateTime  FechaPrimerVto  { get; set; }
    public DateTime? FechaSegundoVto { get; set; }
    public DateTime? FechaTercerVto  { get; set; }
    public decimal?  DescPrimerVto   { get; set; }
    public decimal?  DescSegundoVto  { get; set; }
    public decimal?  DescTercerVto   { get; set; }
    public int?      IdObsaModalidad { get; set; }
    public string    Usuario         { get; set; } = "SISTEMA";
}

public class ActualizarVencimientoRequest
{
    public int       IdTipoTributo   { get; set; }
    public int       NroCuota        { get; set; }
    public string?   Ejercicio       { get; set; }
    public string?   NTipo           { get; set; }
    public string?   NZona           { get; set; }
    public DateTime  FechaPrimerVto  { get; set; }
    public DateTime? FechaSegundoVto { get; set; }
    public DateTime? FechaTercerVto  { get; set; }
    public decimal?  DescPrimerVto   { get; set; }
    public decimal?  DescSegundoVto  { get; set; }
    public decimal?  DescTercerVto   { get; set; }
    public int?      IdObsaModalidad { get; set; }
    public string    Usuario         { get; set; } = "SISTEMA";
}

// ── Planes de Pago ─────────────────────────────────────────────────────────────

public class TipoPlanPago
{
    public int      IdTipoPlanespago        { get; set; }
    public string   CodigoPlan              { get; set; } = "";
    public string   DesignacionPlan         { get; set; } = "";
    public string?  DecretoResolucion       { get; set; }
    public string?  SoloUsoDevengamiento    { get; set; }
    public string?  Observaciones           { get; set; }
    public int?     CantidadCuotas          { get; set; }
    public int?     DiaPrimerVencimiento    { get; set; }
    public string?  Actualizable            { get; set; }
    public string?  Periodo                 { get; set; }
    public string?  UsrIng                  { get; set; }
    public DateTime? FecIng                 { get; set; }
    public string?  UsrMod                  { get; set; }
    public DateTime? FecMod                 { get; set; }
    public string?  UsrBaja                 { get; set; }
    public DateTime? FecBaja                { get; set; }
    public List<TipoPlanPagoDetalle> Detalles { get; set; } = [];
}

public class TipoPlanPagoDetalle
{
    public int      IdPlanesagoDet          { get; set; }
    public int      IdTipoPlanespago        { get; set; }
    public int?     CantidadCuotas          { get; set; }
    public DateTime? FechaDeudaDesde        { get; set; }
    public DateTime? FechaDeudaHasta        { get; set; }
    public decimal? MontoMinDeuda           { get; set; }
    public decimal? MontoMaxDeuda           { get; set; }
    public int?     CantMinCuotas           { get; set; }
    public int?     CantMaxCuotas           { get; set; }
    public decimal? MontoMinCuota           { get; set; }
    public decimal? AnticipoMinPorcentaje   { get; set; }
    public decimal? AnticipoMinMonto        { get; set; }
    public DateTime? FechaVigenteDesde      { get; set; }
    public DateTime? FechaVigenteHasta      { get; set; }
    public int?     CantCuotasSinInteres    { get; set; }
    public decimal? InteresFinanciacion     { get; set; }
    public int?     DiaSegundoVencimiento   { get; set; }
    public int?     DiaTercerVencimiento    { get; set; }
    public string?  UsrBaja                 { get; set; }
    public DateTime? FecBaja                { get; set; }
}

public class CrearPlanPagoRequest
{
    public string   CodigoPlan              { get; set; } = "";
    public string   DesignacionPlan         { get; set; } = "";
    public string?  DecretoResolucion       { get; set; }
    public string?  SoloUsoDevengamiento    { get; set; }
    public string?  Observaciones           { get; set; }
    public int?     CantidadCuotas          { get; set; }
    public int?     DiaPrimerVencimiento    { get; set; }
    public string?  Actualizable            { get; set; }
    public string?  Periodo                 { get; set; }
    public string   Usuario                 { get; set; } = "SISTEMA";
}

public class ActualizarPlanPagoRequest
{
    public string   CodigoPlan              { get; set; } = "";
    public string   DesignacionPlan         { get; set; } = "";
    public string?  DecretoResolucion       { get; set; }
    public string?  SoloUsoDevengamiento    { get; set; }
    public string?  Observaciones           { get; set; }
    public int?     CantidadCuotas          { get; set; }
    public int?     DiaPrimerVencimiento    { get; set; }
    public string?  Actualizable            { get; set; }
    public string?  Periodo                 { get; set; }
    public string   Usuario                 { get; set; } = "SISTEMA";
}

public class CrearPlanDetalleRequest
{
    public int?     CantidadCuotas          { get; set; }
    public DateTime? FechaDeudaDesde        { get; set; }
    public DateTime? FechaDeudaHasta        { get; set; }
    public decimal? MontoMinDeuda           { get; set; }
    public decimal? MontoMaxDeuda           { get; set; }
    public int?     CantMinCuotas           { get; set; }
    public int?     CantMaxCuotas           { get; set; }
    public decimal? MontoMinCuota           { get; set; }
    public decimal? AnticipoMinPorcentaje   { get; set; }
    public decimal? AnticipoMinMonto        { get; set; }
    public DateTime? FechaVigenteDesde      { get; set; }
    public DateTime? FechaVigenteHasta      { get; set; }
    public int?     CantCuotasSinInteres    { get; set; }
    public decimal? InteresFinanciacion     { get; set; }
    public int?     DiaSegundoVencimiento   { get; set; }
    public int?     DiaTercerVencimiento    { get; set; }
    public string   Usuario                 { get; set; } = "SISTEMA";
}

// ── OBSA Modalidad ─────────────────────────────────────────────────────────────

public class ObsaModalidad
{
    public int    IdObsaModalidad { get; set; }
    public string? Descripcion   { get; set; }
}

// ── Intereses ──────────────────────────────────────────────────────────────────

public class ConfigInteres
{
    public int      IdConfiguracion { get; set; }
    public int      IdTipoTributo   { get; set; }
    public decimal  Porcentual      { get; set; }
    public string?  Observacion     { get; set; }
    public DateTime FechaDesde      { get; set; }
    public DateTime? FechaHasta     { get; set; }
    public int?     IdJurisdiccion  { get; set; }
    public string   UsrIng          { get; set; } = "";
    public DateTime FecIng          { get; set; }
    public string?  UsrMod          { get; set; }
    public DateTime? FecMod         { get; set; }
    public string?  UsrBaja         { get; set; }
    public DateTime? FecBaja        { get; set; }
}

public class CrearInteresRequest
{
    public int      IdTipoTributo   { get; set; }
    public decimal  Porcentual      { get; set; }
    public string?  Observacion     { get; set; }
    public DateTime FechaDesde      { get; set; }
    public DateTime? FechaHasta     { get; set; }
    public int?     IdJurisdiccion  { get; set; }
    public string   Usuario         { get; set; } = "SISTEMA";
}

public class ActualizarInteresRequest
{
    public decimal  Porcentual      { get; set; }
    public string?  Observacion     { get; set; }
    public DateTime FechaDesde      { get; set; }
    public DateTime? FechaHasta     { get; set; }
    public string   Usuario         { get; set; } = "SISTEMA";
}

// ── Parametrica Tributos ────────────────────────────────────────────────────────

public class ParametricaTributo
{
    public int     IdParamTrib     { get; set; }
    public int     IdTipoTributo   { get; set; }
    public string  Concepto        { get; set; } = "";
    public string? TipoTributo_    { get; set; }
    public int     IdJurisdiccion  { get; set; }
    public int     Activo          { get; set; }
    public string? Masivo          { get; set; }
    public string? Declarativo     { get; set; }
    public string?  UsrIng         { get; set; }
    public DateTime? FecIng        { get; set; }
    public string?  UsrBaja        { get; set; }
    public DateTime? FecBaja       { get; set; }
}

public class CrearParametricaRequest
{
    public int     IdTipoTributo   { get; set; }
    public int     IdJurisdiccion  { get; set; }
    public string? Masivo          { get; set; }
    public string? Declarativo     { get; set; }
    public string  Usuario         { get; set; } = "SISTEMA";
}

// ── Vinculación Conceptos ───────────────────────────────────────────────────────

public class ConceptoVencimiento
{
    public int     IdConceptoVencimiento { get; set; }
    public int?    IdTipoConcepto        { get; set; }
    public int?    IdVencimiento         { get; set; }
    public string? Cumplidor             { get; set; }
    public string? Observacion           { get; set; }
    public int?    ConceptoPadre         { get; set; }
    public string? UsrIng                { get; set; }
    public DateTime? FecIng              { get; set; }
    public string?  UsrBaja              { get; set; }
    public DateTime? FecBaja             { get; set; }
    // campos calculados desde JOIN con DEV_VENCIMIENTOS + DEV_TIPOS_CONCEPTOS
    public string?  ConceptoNombre       { get; set; }
    public string?  ConceptoPadreNombre  { get; set; }
    public string?  Ejercicio            { get; set; }
    public int?     NroCuota             { get; set; }
    public string?  NZona                { get; set; }
    public int?     IdTipoTributo        { get; set; }
}

public class CrearConceptoVencimientoRequest
{
    public int?    IdTipoConcepto    { get; set; }
    public int?    IdVencimiento     { get; set; }
    public string? Cumplidor         { get; set; }
    public string? Observacion       { get; set; }
    public int?    ConceptoPadre     { get; set; }
    public string  Usuario           { get; set; } = "SISTEMA";
}

public class ClonarEjercicioRequest
{
    public string  EjercicioOrigen  { get; set; } = "";
    public string  EjercicioDestino { get; set; } = "";
    public int?    IdTipoTributo    { get; set; }
}

// ── DevengamientoV2 ────────────────────────────────────────────────────────────

public class EstadoDevengamiento
{
    public int      IdPorcentajeCarga { get; set; }
    public int      IdJurisdiccion    { get; set; }
    public int?     IdTipoTributo     { get; set; }
    public decimal  Porcentaje        { get; set; }
    public string   Estado            { get; set; } = "PENDIENTE";
    public string?  Mensaje           { get; set; }
    public DateTime? FecInicio        { get; set; }
    public DateTime? FecFin           { get; set; }
    public string?  UsrOperador       { get; set; }
    public string?  Ejercicio         { get; set; }
}

public class LogDevengamiento
{
    public int      IdLog              { get; set; }
    public int      IdJurisdiccion     { get; set; }
    public int?     IdTipoTributo      { get; set; }
    public string?  TipoTributo        { get; set; }
    public string?  Ejercicio          { get; set; }
    public string   Resultado          { get; set; } = "";
    public string?  Mensaje            { get; set; }
    public DateTime FecEjecucion       { get; set; }
    public string?  UsrOperador        { get; set; }
    public int?     CuentasProcesadas  { get; set; }
    public int?     CuentasDevengadas  { get; set; }
    public int?     CuentasError       { get; set; }
    public int?     DuracionSegundos   { get; set; }
}

public class EjecutarDevengamientoRequest
{
    public int    IdJurisdiccion { get; set; } = 1;
    public int    IdTipoTributo  { get; set; }
    public string Ejercicio      { get; set; } = "";
    public string Usuario        { get; set; } = "";
}
