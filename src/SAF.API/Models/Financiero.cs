namespace SAF.API.Models;

// ── Presupuesto ──────────────────────────────────────────────────────────────
public class CuentaErogacion
{
    public string AnoEro                { get; set; } = "";
    public string NroCtaEro             { get; set; } = "";
    public string Designacion           { get; set; } = "";
    public decimal PresupuestoAutorizado { get; set; }
    public decimal MontoAfectado        { get; set; }
    public decimal MontoPagado          { get; set; }
}

public record AjustePresupuestoRequest(decimal NuevoMonto);

// ── Compromisos ──────────────────────────────────────────────────────────────
public class Compromiso
{
    public string TipoCompromiso      { get; set; } = "";
    public string AnoCompromiso       { get; set; } = "";
    public string NroCompromiso       { get; set; } = "";
    public string Identificador       { get; set; } = "";
    public string NombreProveedor     { get; set; } = "";
    public DateTime? FechaCompromiso  { get; set; }
    public string Concepto            { get; set; } = "";
    public decimal MontoComprometido  { get; set; }
    public decimal MontoAPagar        { get; set; }
    public decimal MontoPagado        { get; set; }
    public string EstadoCompromiso    { get; set; } = "";
}

public record NuevoCompromisoRequest(string Identificador, string Concepto, decimal MontoComprometido, decimal MontoAPagar, string? AnoEro, string? NroCtaEro);

// ── Áreas ─────────────────────────────────────────────────────────────────────
public class Area
{
    public int    IdArea         { get; set; }
    public string Codigo         { get; set; } = "";
    public string Descripcion    { get; set; } = "";
    public int?   IdAreaSuperior { get; set; }
}

// ── Órdenes de Pago ──────────────────────────────────────────────────────────
public class OrdenPago
{
    public string TipoOpago       { get; set; } = "";
    public string AnoOpago        { get; set; } = "";
    public string NroOpago        { get; set; } = "";
    public string Identificador   { get; set; } = "";
    public string NombreProveedor { get; set; } = "";
    public string NroCta          { get; set; } = "";
    public string AnoEro          { get; set; } = "";
    public decimal MontoAPagar    { get; set; }
    public decimal MontoPagado    { get; set; }
    public string Estado          { get; set; } = "";
    public string? Observaciones  { get; set; }
    public DateTime? FechaMandato { get; set; }
}

public record NuevaOrdenPagoRequest(string Identificador, string NroCta, string AnoEro, decimal MontoAPagar, string? Observaciones);
public record CambiarEstadoRequest(string Estado);

// ── Facturas ─────────────────────────────────────────────────────────────────
public class Factura
{
    public string Identificador     { get; set; } = "";
    public string NombreProveedor   { get; set; } = "";
    public string NroFactura        { get; set; } = "";
    public DateTime? Fecha          { get; set; }
    public string TipoComprobante   { get; set; } = "";
    public string LetraComprobante  { get; set; } = "";
    public decimal TotalFactura     { get; set; }
    public decimal NetoGravado      { get; set; }
    public decimal Iva              { get; set; }
    public string Estado            { get; set; } = "";
    public string? TipoOpago        { get; set; }
    public string? AnoOpago         { get; set; }
    public string? NroOpago         { get; set; }
}

public record NuevaFacturaRequest(string Identificador, string NroFactura, string TipoComprobante, string LetraComprobante, string Fecha, decimal TotalFactura, decimal NetoGravado, decimal Iva, string? TipoOpago, string? AnoOpago, string? NroOpago);

public class FacturaItem
{
    public string CodigoArticulo  { get; set; } = "";
    public decimal Cantidad       { get; set; }
    public decimal PrecioUnitario { get; set; }
    public string Designacion     { get; set; } = "";
    public decimal Subtotal       { get; set; }
}

// ── Proveedores ──────────────────────────────────────────────────────────────
public class Proveedor
{
    public string Identificador   { get; set; } = "";
    public string Nombre          { get; set; } = "";
    public string Apellido        { get; set; } = "";
    public string CuitCuil        { get; set; } = "";
    public string? Email          { get; set; }
    public string? Telefono       { get; set; }
    public string? TipoSociedad   { get; set; }
    public DateTime? FechaAlta    { get; set; }
    public DateTime? FechaBaja    { get; set; }
    public string? NroRegistro    { get; set; }
}

// ── Notas de Pedido ──────────────────────────────────────────────────────────
public class NotaPedido
{
    public string TipoComprobante { get; set; } = "";
    public string AnoComprobante  { get; set; } = "";
    public string NroComprobante  { get; set; } = "";
    public DateTime? FechaPedido  { get; set; }
    public string AreaSolicitante { get; set; } = "";
    public string Concepto        { get; set; } = "";
    public string Estado          { get; set; } = "";
    public List<NotaPedidoDetalle> Detalles { get; set; } = [];
}

public class NotaPedidoDetalle
{
    public int? CodigoArticulo    { get; set; }
    public decimal Cantidad       { get; set; }
    public string Unidad          { get; set; } = "";
    public string Designacion     { get; set; } = "";
    public decimal PrecioUnitario { get; set; }
}

public record NuevaNotaPedidoRequest(int? IdAreaSolicitante, string Concepto, string? LugarEntrega, List<NotaPedidoDetalleRequest> Items);
public record NotaPedidoDetalleRequest(decimal Cantidad, string Unidad, string Designacion, decimal PrecioUnitario);
