namespace PGM.API.Models;

public class CuentaErogacion
{
    public string  AnoEro              { get; set; } = "";
    public string  ReconducidoEro      { get; set; } = "0";
    public string  NroCtaEro           { get; set; } = "";
    public string? Designacion         { get; set; }
    public string? TipoCtaEro          { get; set; }
    public decimal PresupuestoAutorizado { get; set; }
    public decimal MontoAfectado       { get; set; }
    public decimal MontoComprometido   { get; set; }
    public decimal MontoAPagar         { get; set; }
    public decimal MontoPagado         { get; set; }
    public decimal Disponible          => PresupuestoAutorizado - MontoAfectado;
}

public class Afectacion
{
    public string  TipoAfectacion  { get; set; } = "AP  ";
    public string  AnoAfectacion   { get; set; } = "";
    public string  NroAfectacion   { get; set; } = "";
    public string  Identificador   { get; set; } = "";
    public DateTime FechaAfectacion { get; set; }
    public string? Concepto        { get; set; }
    public decimal MontoAfectado   { get; set; }
    public string  EstadoAfectacion { get; set; } = "A";
    public string? NroCtaEro       { get; set; }
    public string? AnoEro          { get; set; }
    public string? ReconducidoEro  { get; set; }
}

public class OrdenPago
{
    public string  TipoOpago    { get; set; } = "";
    public string  AnoOpago     { get; set; } = "";
    public string  NroOpago     { get; set; } = "";
    public string  Identificador { get; set; } = "";
    public string? Proveedor    { get; set; }
    public string? CuitCuil     { get; set; }
    public string  EstadoOpago  { get; set; } = "";
    public decimal MontoAPagar  { get; set; }
    public decimal MontoPagado  { get; set; }
    public string? Observaciones { get; set; }
    public DateTime? FechaAprobacion { get; set; }
}

public class FacturaCompra
{
    public string  Identificador      { get; set; } = "";
    public string? Proveedor          { get; set; }
    public string? CuitCuil           { get; set; }
    public string  NroFactura         { get; set; } = "";
    public string  TipoComprobante    { get; set; } = "";
    public string  LetraComprobante   { get; set; } = "";
    public DateTime Fecha             { get; set; }
    public decimal TotalFactura       { get; set; }
    public decimal NetoGravado        { get; set; }
    public decimal Iva                { get; set; }
    public string  Estado             { get; set; } = "";
    public string? OrdenPago          { get; set; }
}

public record NuevaOrdenPagoRequest(
    string Identificador,
    string NroCta,
    string AnoEro,
    decimal MontoAPagar,
    string? Observaciones
);

public record CambiarEstadoRequest(string Estado);

public record NuevaFacturaRequest(
    string NroFactura,
    string TipoComprobante,
    string LetraComprobante,
    string Fecha,
    decimal TotalFactura,
    decimal NetoGravado,
    decimal Iva,
    string? TipoOpago,
    string? AnoOpago,
    string? NroOpago
);

public record AjustePresupuestoRequest(decimal NuevoMonto);

public class CuentaIngreso
{
    public string  AnoIng               { get; set; } = "";
    public string  NroCtaIng            { get; set; } = "";
    public string  TipoCtaIng           { get; set; } = "";
    public string  Designacion          { get; set; } = "";
    public decimal PresupuestoAutorizado { get; set; }
    public decimal MontoCobrado         { get; set; }
    public decimal MontoDevengado       { get; set; }
    public decimal Diferencia           => PresupuestoAutorizado - MontoCobrado;
}

public class PagedResult<T>
{
    public List<T> Items { get; set; } = new();
    public int     Total { get; set; }
}
