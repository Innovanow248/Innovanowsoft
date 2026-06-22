using PGM.API.Models;

namespace PGM.API.Repositories;

public interface IFinancieraRepository
{
    Task<List<CuentaErogacion>> ObtenerCuentasConSaldo(string anoEro);
    Task<PagedResult<OrdenPago>> ObtenerOrdenesPago(string anoOpago, string? estadoOpago, int page, int pageSize);
    Task<List<FacturaCompra>> ObtenerFacturasPorProveedor(string identificador);
    Task<string> CrearOrdenPago(string ano, NuevaOrdenPagoRequest req);
    Task CambiarEstadoOrdenPago(string tipo, string ano, string nro, string nuevoEstado);
    Task CrearFactura(string identificador, NuevaFacturaRequest req);
    Task AjustarPresupuesto(string ano, string nroCta, decimal nuevoMonto);
}
