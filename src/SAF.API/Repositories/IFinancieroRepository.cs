using SAF.API.Models;

namespace SAF.API.Repositories;

public interface IPresupuestoRepository
{
    Task<List<CuentaErogacion>> ListarCuentas(string ano);
    Task AjustarPresupuesto(string ano, string nroCta, decimal nuevoMonto);
}

public interface ICompromisosRepository
{
    Task<List<Compromiso>> Listar(string ano, string? estado, string? identificador);
    Task<string> Crear(string ano, NuevoCompromisoRequest req);
    Task CambiarEstado(string tipo, string ano, string nro, string nuevoEstado);
}

public interface IOrdenesPageRepository
{
    Task<List<OrdenPago>> Listar(string ano, string? estado, string? identificador);
    Task<string> Crear(string ano, NuevaOrdenPagoRequest req);
    Task CambiarEstado(string tipo, string ano, string nro, string nuevoEstado);
}

public interface IFacturasRepository
{
    Task<List<Factura>> Listar(int? year, string? identificador, string? estado);
    Task Crear(NuevaFacturaRequest req);
    Task<List<FacturaItem>> ObtenerItems(string identificador, string nroFactura);
}

public interface IProveedoresRepository
{
    Task<List<Proveedor>> Buscar(string termino);
    Task<Proveedor?> ObtenerPorId(string identificador);
}

public interface INotasPedidoRepository
{
    Task<List<NotaPedido>> Listar(string ano, string? estado);
    Task<NotaPedido?> Obtener(string tipo, string ano, string nro);
    Task<string> Crear(string ano, NuevaNotaPedidoRequest req);
    Task CambiarEstado(string tipo, string ano, string nro, string nuevoEstado);
}
