namespace PGM.API.Models;

public class BienPadron
{
    public string  IdBien        { get; set; } = "";
    public string  TipoBien      { get; set; } = "";
    public string  Identificador { get; set; } = "";
    public string? ClaveBien     { get; set; }
    public string? CodigoImpresion { get; set; }
    public string  Activo        { get; set; } = "1";
    public string  Imprime       { get; set; } = "1";
    public string  Exencion      { get; set; } = "NOEX";
    public string  TipoPlan      { get; set; } = "1 ";
    public string? SituacionDeuda { get; set; }
    public decimal MontDeudaHistorico   { get; set; }
    public decimal MontoDeudaActualizado { get; set; }
    public string? Descripcion           { get; set; }
    public DateTime? FechaBaja           { get; set; }
}

public class DeudaContribuyente
{
    public string  Identificador   { get; set; } = "";
    public string  Contribuyente   { get; set; } = "";
    public string? CuitCuil        { get; set; }
    public string  TipoBien        { get; set; } = "";
    public string? ClaveBien       { get; set; }
    public string? SituacionDeuda  { get; set; }
    public string  NroInterno      { get; set; } = "";
    public string  Periodo         { get; set; } = "";
    public string  EstadoDeuda     { get; set; } = "";
    public decimal CapitalFacturado { get; set; }
    public decimal DeudaTotalActualizada { get; set; }
    public decimal Imp1Vence       { get; set; }
    public DateTime? FechaVencimiento1 { get; set; }
    public decimal Imp2Vence       { get; set; }
    public DateTime? FechaVencimiento2 { get; set; }
    public decimal Imp3Vence       { get; set; }
    public DateTime? FechaVencimiento3 { get; set; }
}

public class DeudaResumen
{
    public string  TipoBien        { get; set; } = "";
    public decimal MontoHistorico  { get; set; }
    public decimal MontoActualizado { get; set; }
    public DateTime? FechaActualizacion { get; set; }
}

public class TipoBien
{
    public string CodigoTipoBien { get; set; } = "";
    public string Concepto       { get; set; } = "";
}

public class PlanPago
{
    public string TipoBien       { get; set; } = "";
    public string TipoPlan       { get; set; } = "";
    public string DesignacionPlan { get; set; } = "";
    public int    CantidadCuotas { get; set; }
}

public class BienPadronDetalle
{
    public string  IdBien        { get; set; } = "";
    public string  TipoBien      { get; set; } = "";
    public string  ConceptoBien  { get; set; } = "";
    public string? ClaveBien     { get; set; }
    public string  Identificador { get; set; } = "";
    public string  Apellido      { get; set; } = "";
    public string  Nombre        { get; set; } = "";
    public string? CuitCuil      { get; set; }
    public string  Activo        { get; set; } = "1";
    public string? SituacionDeuda { get; set; }
    public decimal MontoDeudaActualizado { get; set; }
    public string  TipoPlan      { get; set; } = "";
    public string  Exencion      { get; set; } = "NOEX";
}

public class PadronPagedResult
{
    public List<BienPadronDetalle> Items { get; set; } = [];
    public int Total { get; set; }
}

// ── REQUESTS ──────────────────────────────────────────────────────────────

public class AltaPadronRequest
{
    public string  TipoBien       { get; set; } = "";
    public string  Identificador  { get; set; } = "";
    public string  ClaveBien      { get; set; } = "";
    public string? CodigoImpresion { get; set; }
    public string  Exencion       { get; set; } = "NOEX";
    public string  TipoPlan       { get; set; } = "1 ";
    public DateTime? LiquidaDesde { get; set; }
}

public class AltaAutomotorRequest
{
    public string  CategoriaAutomotor { get; set; } = "A1  ";
    public string? Cip                { get; set; }
    public string  AnoValuacion       { get; set; } = "";
    public int     ModeloAno          { get; set; }
    public string? NroMotor           { get; set; }
    public string? NroChasis          { get; set; }
    public string? Marca              { get; set; }
    public string? Descripcion        { get; set; }
    public string? Patente            { get; set; }
    public string? Vin                { get; set; }
    public string  TipoAlta           { get; set; } = "01  ";
    public decimal ValorFactura       { get; set; }
    public string? Cilindrada         { get; set; }
    public string  Importado          { get; set; } = "N";
}

public class AltaCatastroRequest
{
    public string? NroRenta            { get; set; }
    public string? Calle               { get; set; }
    public string? NumeracionCalle     { get; set; }
    public string? Barrio              { get; set; }
    public string? DesignacionOficial  { get; set; }
    public string? NroMatricula        { get; set; }
    public decimal SuperficieTerreno   { get; set; }
    public string  BaldioEdificado     { get; set; } = "01";
    public decimal MetrosFrente        { get; set; }
    public decimal BaseImponible       { get; set; }
    public string? CodigoPostal        { get; set; }
    public bool    TieneServicio       { get; set; }
    public int?    UnidadesLocativas   { get; set; }
}

// ── Inmueble: propietarios, mejoras, variables ─────────────────────────────────

public class PropietarioInmueble
{
    public string   IdBien              { get; set; } = "";
    public string   Identificador       { get; set; } = "";
    public decimal? PorcentajeAcciones  { get; set; }
    public string   Apellido            { get; set; } = "";
    public string   Nombre              { get; set; } = "";
}

public record PropietarioRequest(string Identificador, decimal? PorcentajeAcciones);

public class MejoraInmueble
{
    public int       Clave                  { get; set; }
    public DateTime? FechaMejora            { get; set; }
    public string?   AnoConstruction        { get; set; }
    public string?   EstadoConstruccion     { get; set; }
    public double    SuperficieCubierta     { get; set; }
    public decimal   ValorEdificado         { get; set; }
    public string?   IdCatastro             { get; set; }
    public string?   CodigoCategoriaPuntaje { get; set; }
    public string?   TipoDestinoCatastro    { get; set; }
    public string?   TipoConstruccion       { get; set; }
}

public class AltaMejoraRequest
{
    public string? AnoConstruction        { get; set; }
    public string? EstadoConstruccion     { get; set; }
    public double  SuperficieCubierta     { get; set; }
    public decimal ValorEdificado         { get; set; }
    public string? TipoConstruccion       { get; set; }
    public string? CodigoCategoriaPuntaje { get; set; }
    public string? TipoDestinoCatastro    { get; set; }
}

public class VariablePadron
{
    public string   CodigoVarios { get; set; } = "";
    public string?  Concepto     { get; set; }
    public decimal? Monto        { get; set; }
    public string?  Estado       { get; set; }
    public string?  TipoVarios   { get; set; }
}

public class CatastroDetalle
{
    public string  IdBien                { get; set; } = "";
    public string? ClaveBien             { get; set; }
    public string? NomenclaturaCatastral { get; set; }
    public string? NroRenta              { get; set; }
    public string? Calle                 { get; set; }
    public string? NumeracionCalle       { get; set; }
    public string? Barrio                { get; set; }
    public string? DesignacionOficial    { get; set; }
    public string? NroMatricula          { get; set; }
    public decimal SuperficieTerreno     { get; set; }
    public decimal MetrosFrente          { get; set; }
    public string? BaldioEdificado       { get; set; }
    public string? EsquinaMedial         { get; set; }
    public decimal BaseImponible         { get; set; }
    public decimal TasacionTerreno       { get; set; }
    public decimal ValorTerreno          { get; set; }
    public decimal ValorEdificado        { get; set; }
    public int?    UnidadesLocativas     { get; set; }
    public string? CodigoPostal          { get; set; }
}

public class AltaComercioRequest
{
    public string? Clasificacion           { get; set; }
    public string? NombreFantasia          { get; set; }
    public string? NombreSociedad          { get; set; }
    public string  TipoSociedad            { get; set; } = "UNIP";
    public string? Cuit                    { get; set; }
    public string? IngresosBrutos          { get; set; }
    public string? ResolucionHabilitacion  { get; set; }
    public string? Calle                   { get; set; }
    public string? NumeracionCalle         { get; set; }
    public string? Barrio                  { get; set; }
    public string? CodigoPostal            { get; set; }
    public decimal CapitalDeclarado        { get; set; }
    public int     PersonalOcupado         { get; set; }
    public string  TipoContribuyente       { get; set; } = "DDJJ";
    public string? Telefono                { get; set; }
    public string? Email                   { get; set; }
}

public class CambioTitularRequest
{
    public string NuevoIdentificador { get; set; } = "";
}

public class CobroRequest
{
    public string   NroInterno { get; set; } = "";
    public DateTime FechaPago  { get; set; }
}

public class CobroResult
{
    public string? CodErr  { get; set; }
    public string? Mensaje { get; set; }
    public bool    Exitoso => string.IsNullOrWhiteSpace(CodErr) || CodErr?.Trim() == "00000";
}

public class AltaPortalRequest
{
    public string Password    { get; set; } = "";
    public bool   Habilitado  { get; set; } = true;
}

// ── REFERENCIAS ───────────────────────────────────────────────────────────

public class TasaActualizacion
{
    public string   Interes      { get; set; } = "";
    public DateTime Fecha        { get; set; }
    public decimal  TasaMensual  { get; set; }
}

public class ValuacionAutomotor
{
    public string  AnoValuacion    { get; set; } = "";
    public string  Cip             { get; set; } = "";
    public int     ModeloValuacion { get; set; }
    public decimal BaseImponible   { get; set; }
    public decimal Alicuota        { get; set; }
}
