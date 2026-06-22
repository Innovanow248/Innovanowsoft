using Dapper;
using SAF.API.Models;

namespace SAF.API.Repositories;

public class FacturasRepository(DbConnectionFactory db) : IFacturasRepository
{
    public async Task<List<Factura>> Listar(int? year, string? identificador, string? estado)
    {
        using var conn = db.Create();

        var where = new List<string>();
        if (year.HasValue)                             where.Add("YEAR(f.FECHA) = @Year");
        if (!string.IsNullOrWhiteSpace(identificador)) where.Add("RTRIM(f.IDENTIFICADOR) = @Identificador");
        if (!string.IsNullOrWhiteSpace(estado))        where.Add("RTRIM(f.ESTADO) = @Estado");

        var whereClause = where.Count > 0 ? "WHERE " + string.Join(" AND ", where) : "";

        var sql = $"""
            SELECT TOP 500
                RTRIM(f.IDENTIFICADOR)    AS Identificador,
                ISNULL(RTRIM(p.APELLIDO)+', '+RTRIM(p.NOMBRE),'') AS NombreProveedor,
                RTRIM(f.NRO_FACTURA)      AS NroFactura,
                f.FECHA                   AS Fecha,
                RTRIM(f.TIPO_COMPROBANTE)  AS TipoComprobante,
                RTRIM(f.LETRA_COMPROBANTE) AS LetraComprobante,
                ISNULL(f.TOTAL_FACTURA,0)  AS TotalFactura,
                ISNULL(f.IC_NETO_GRAVADO1,0) AS NetoGravado,
                ISNULL(f.IC_IVA1,0)          AS Iva,
                RTRIM(f.ESTADO)            AS Estado,
                RTRIM(f.TIPO_OPAGO)        AS TipoOpago,
                RTRIM(f.ANO_OPAGO)         AS AnoOpago,
                RTRIM(f.NRO_OPAGO)         AS NroOpago
            FROM CO_FACTURAS_COMPRAS f
            LEFT JOIN PERSONAS p ON RTRIM(p.IDENTIFICADOR) = RTRIM(f.IDENTIFICADOR)
            {whereClause}
            ORDER BY f.FECHA DESC, f.NRO_FACTURA DESC
            """;

        var result = await conn.QueryAsync<Factura>(sql, new
        {
            Year          = year,
            Identificador = identificador,
            Estado        = estado
        });
        return result.ToList();
    }

    public async Task Crear(NuevaFacturaRequest req)
    {
        using var conn = db.Create();
        const string sql = """
            INSERT INTO CO_FACTURAS_COMPRAS
                (IDENTIFICADOR, NRO_FACTURA, FECHA, TIPO_COMPROBANTE, LETRA_COMPROBANTE,
                 TOTAL_FACTURA, IC_NETO_GRAVADO1, IC_IVA1,
                 ESTADO, FECHA_CARGA, TIPO_OPAGO, ANO_OPAGO, NRO_OPAGO)
            VALUES
                (@Identificador, @NroFactura, @Fecha, @TipoComprobante, @LetraComprobante,
                 @TotalFactura, @NetoGravado, @Iva,
                 'A', GETDATE(), @TipoOpago, @AnoOpago, @NroOpago)
            """;

        await conn.ExecuteAsync(sql, new
        {
            req.Identificador,
            req.NroFactura,
            Fecha            = DateTime.Parse(req.Fecha),
            req.TipoComprobante,
            req.LetraComprobante,
            req.TotalFactura,
            req.NetoGravado,
            req.Iva,
            TipoOpago        = string.IsNullOrWhiteSpace(req.TipoOpago) ? null : req.TipoOpago,
            AnoOpago         = string.IsNullOrWhiteSpace(req.AnoOpago)  ? null : req.AnoOpago,
            NroOpago         = string.IsNullOrWhiteSpace(req.NroOpago)  ? null : req.NroOpago,
        });
    }

    public async Task<List<FacturaItem>> ObtenerItems(string identificador, string nroFactura)
    {
        using var conn = db.Create();
        const string sql = """
            SELECT
                ISNULL(RTRIM(CODIGO_ARTICULO_COD),'') AS CodigoArticulo,
                ISNULL(CANTIDAD, 0)                   AS Cantidad,
                ISNULL(PRECIO_UNITARIO, 0)            AS PrecioUnitario,
                ISNULL(RTRIM(DESIGNACION),'')         AS Designacion,
                ISNULL(CANTIDAD * PRECIO_UNITARIO, 0) AS Subtotal
            FROM CO_FACTURAS_COMPRAS_DET
            WHERE RTRIM(IDENTIFICADOR) = @Identificador
              AND RTRIM(NRO_FACTURA)   = @NroFactura
            ORDER BY CLAVE
            """;
        var result = await conn.QueryAsync<FacturaItem>(sql, new { Identificador = identificador, NroFactura = nroFactura });
        return result.ToList();
    }
}
