using Dapper;
using PGM.API.Models;

namespace PGM.API.Repositories;

public class FinancieraRepository(DbConnectionFactory db) : IFinancieraRepository
{
    public async Task<List<CuentaErogacion>> ObtenerCuentasConSaldo(string anoEro)
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<CuentaErogacion>("""
            SELECT
                RTRIM(ANO_ERO)          AS AnoEro,
                RTRIM(RECONDUCIDO_ERO)  AS ReconducidoEro,
                RTRIM(NRO_CTA_ERO)      AS NroCtaEro,
                RTRIM(ISNULL(DESIGNACION,'')) AS Designacion,
                RTRIM(TIPO_CTA_ERO)     AS TipoCtaEro,
                ISNULL(PRESUPUESTO_AUTORIZADO,0) AS PresupuestoAutorizado,
                ISNULL(MONTO_AFECTADO,0)         AS MontoAfectado,
                ISNULL(MONTO_COMPROMETIDO,0)     AS MontoComprometido,
                ISNULL(MONTO_APAGAR,0)           AS MontoAPagar,
                ISNULL(MONTO_PAGADO,0)           AS MontoPagado
            FROM CP_EROGACION_CUENTAS
            WHERE RTRIM(ANO_ERO) = @AnoEro
              AND TIPO_CTA_ERO IN ('PI','PT')
              AND PRESUPUESTO_AUTORIZADO > 0
            ORDER BY NRO_CTA_ERO
            """, new { AnoEro = anoEro });
        return result.ToList();
    }

    public async Task<PagedResult<OrdenPago>> ObtenerOrdenesPago(string anoOpago, string? estadoOpago, int page, int pageSize)
    {
        using var conn = db.Create();
        var p = new { AnoOpago = anoOpago, EstadoOpago = estadoOpago, Offset = page * pageSize, PageSize = pageSize };

        var total = await conn.QuerySingleAsync<int>("""
            SELECT COUNT(*) FROM CP_ORDENES_PAGO op
            WHERE RTRIM(op.ANO_OPAGO) = @AnoOpago
              AND (@EstadoOpago IS NULL OR RTRIM(op.ESTADO_OPAGO) = @EstadoOpago)
            """, p);

        var items = await conn.QueryAsync<OrdenPago>("""
            SELECT
                RTRIM(op.TIPO_OPAGO)    AS TipoOpago,
                RTRIM(op.ANO_OPAGO)     AS AnoOpago,
                RTRIM(op.NRO_OPAGO)     AS NroOpago,
                RTRIM(op.IDENTIFICADOR) AS Identificador,
                RTRIM(p.APELLIDO) + ', ' + RTRIM(p.NOMBRE) AS Proveedor,
                RTRIM(p.CUIT_CUIL)      AS CuitCuil,
                RTRIM(op.ESTADO_OPAGO)  AS EstadoOpago,
                ISNULL(op.MONTO_APAGAR,0)  AS MontoAPagar,
                ISNULL(op.MONTO_PAGADO,0)  AS MontoPagado,
                op.OBSERVACIONES,
                op.MANDATO_FECHA        AS FechaAprobacion
            FROM CP_ORDENES_PAGO op
            JOIN PERSONAS p ON RTRIM(p.IDENTIFICADOR) = RTRIM(op.IDENTIFICADOR)
            WHERE RTRIM(op.ANO_OPAGO) = @AnoOpago
              AND (@EstadoOpago IS NULL OR RTRIM(op.ESTADO_OPAGO) = @EstadoOpago)
            ORDER BY op.NRO_OPAGO DESC
            OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY
            """, p);

        return new PagedResult<OrdenPago> { Items = items.ToList(), Total = total };
    }

    public async Task<List<FacturaCompra>> ObtenerFacturasPorProveedor(string identificador)
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<FacturaCompra>("""
            SELECT
                RTRIM(f.IDENTIFICADOR)      AS Identificador,
                RTRIM(p.APELLIDO) + ', ' + RTRIM(p.NOMBRE) AS Proveedor,
                RTRIM(p.CUIT_CUIL)          AS CuitCuil,
                RTRIM(f.NRO_FACTURA)        AS NroFactura,
                RTRIM(f.TIPO_COMPROBANTE)   AS TipoComprobante,
                RTRIM(f.LETRA_COMPROBANTE)  AS LetraComprobante,
                f.FECHA,
                ISNULL(f.TOTAL_FACTURA,0)   AS TotalFactura,
                ISNULL(f.IC_NETO_GRAVADO1,0) AS NetoGravado,
                ISNULL(f.IC_IVA1,0)         AS Iva,
                RTRIM(f.ESTADO)             AS Estado,
                NULLIF(RTRIM(f.TIPO_OPAGO),'') + '/' +
                NULLIF(RTRIM(f.ANO_OPAGO),'') + '/' +
                NULLIF(RTRIM(f.NRO_OPAGO),'') AS OrdenPago
            FROM CO_FACTURAS_COMPRAS f
            JOIN PERSONAS p ON RTRIM(p.IDENTIFICADOR) = RTRIM(f.IDENTIFICADOR)
            WHERE RTRIM(f.IDENTIFICADOR) = @Identificador
            ORDER BY f.FECHA DESC
            """, new { Identificador = identificador });
        return result.ToList();
    }

    public async Task<string> CrearOrdenPago(string ano, NuevaOrdenPagoRequest req)
    {
        using var conn = db.Create();
        var nroNuevo = await conn.ExecuteScalarAsync<int>(
            "SELECT ISNULL(MAX(CAST(RTRIM(NRO_OPAGO) AS INT)), 0) + 1 FROM CP_ORDENES_PAGO WHERE RTRIM(ANO_OPAGO) = @Ano",
            new { Ano = ano });
        await conn.ExecuteAsync("""
            INSERT INTO CP_ORDENES_PAGO
                (TIPO_OPAGO, ANO_OPAGO, NRO_OPAGO, IDENTIFICADOR, MONTO_APAGAR, MONTO_PAGADO, ESTADO_OPAGO, OBSERVACIONES)
            VALUES ('CO', @Ano, @Nro, @Id, @Monto, 0, 'P', @Obs)
            """, new { Ano = ano, Nro = nroNuevo.ToString(), Id = req.Identificador, Monto = req.MontoAPagar, Obs = req.Observaciones });
        return nroNuevo.ToString();
    }

    public async Task CambiarEstadoOrdenPago(string tipo, string ano, string nro, string nuevoEstado)
    {
        using var conn = db.Create();
        if (nuevoEstado == "A")
            await conn.ExecuteAsync("""
                UPDATE CP_ORDENES_PAGO SET ESTADO_OPAGO = @Estado, MANDATO_FECHA = GETDATE()
                WHERE RTRIM(TIPO_OPAGO) = @Tipo AND RTRIM(ANO_OPAGO) = @Ano AND RTRIM(NRO_OPAGO) = @Nro
                """, new { Estado = nuevoEstado, Tipo = tipo, Ano = ano, Nro = nro });
        else
            await conn.ExecuteAsync("""
                UPDATE CP_ORDENES_PAGO SET ESTADO_OPAGO = @Estado
                WHERE RTRIM(TIPO_OPAGO) = @Tipo AND RTRIM(ANO_OPAGO) = @Ano AND RTRIM(NRO_OPAGO) = @Nro
                """, new { Estado = nuevoEstado, Tipo = tipo, Ano = ano, Nro = nro });
    }

    public async Task CrearFactura(string identificador, NuevaFacturaRequest req)
    {
        using var conn = db.Create();
        var fecha = DateTime.TryParse(req.Fecha, out var f) ? f : DateTime.Today;
        await conn.ExecuteAsync("""
            INSERT INTO CO_FACTURAS_COMPRAS
                (IDENTIFICADOR, NRO_FACTURA, TIPO_COMPROBANTE, LETRA_COMPROBANTE, FECHA,
                 TOTAL_FACTURA, IC_NETO_GRAVADO1, IC_IVA1, ESTADO,
                 TIPO_OPAGO, ANO_OPAGO, NRO_OPAGO)
            VALUES
                (@Id, @NroFac, @TipoComp, @LetraComp, @Fecha,
                 @Total, @Neto, @Iva, 'A',
                 @TipoOp, @AnoOp, @NroOp)
            """, new {
                Id       = identificador,
                NroFac   = req.NroFactura,
                TipoComp = req.TipoComprobante,
                LetraComp = req.LetraComprobante,
                Fecha    = fecha,
                Total    = req.TotalFactura,
                Neto     = req.NetoGravado,
                Iva      = req.Iva,
                TipoOp   = string.IsNullOrWhiteSpace(req.TipoOpago) ? (string?)null : req.TipoOpago,
                AnoOp    = string.IsNullOrWhiteSpace(req.AnoOpago)  ? (string?)null : req.AnoOpago,
                NroOp    = string.IsNullOrWhiteSpace(req.NroOpago)  ? (string?)null : req.NroOpago,
            });
    }

    public async Task AjustarPresupuesto(string ano, string nroCta, decimal nuevoMonto)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE CP_EROGACION_CUENTAS SET PRESUPUESTO_AUTORIZADO = @Monto
            WHERE RTRIM(ANO_ERO) = @Ano AND RTRIM(NRO_CTA_ERO) = @Cta
            """, new { Monto = nuevoMonto, Ano = ano, Cta = nroCta });
    }
}
