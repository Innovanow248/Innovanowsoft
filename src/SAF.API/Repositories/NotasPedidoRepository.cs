using Dapper;
using SAF.API.Models;

namespace SAF.API.Repositories;

public class NotasPedidoRepository(DbConnectionFactory db) : INotasPedidoRepository
{
    private const string Tipo = "NP";

    public async Task<List<NotaPedido>> Listar(string ano, string? estado)
    {
        using var conn = db.Create();

        var where = new List<string>
        {
            "RTRIM(TIPO_COMPROBANTE) = @Tipo",
            "RTRIM(ANO_COMPROBANTE)  = @Ano"
        };
        if (!string.IsNullOrWhiteSpace(estado)) where.Add("RTRIM(ESTADO) = @Estado");

        var sql = $"""
            SELECT
                RTRIM(a.TIPO_COMPROBANTE)  AS TipoComprobante,
                RTRIM(a.ANO_COMPROBANTE)   AS AnoComprobante,
                RTRIM(a.NRO_COMPROBANTE)   AS NroComprobante,
                a.FECHA_PEDIDO             AS FechaPedido,
                ISNULL(RTRIM(ar.Descripcion), ISNULL(RTRIM(a.AREA_SOLICITANTE),'')) AS AreaSolicitante,
                ISNULL(RTRIM(a.CONCEPTO),'')          AS Concepto,
                ISNULL(RTRIM(a.ESTADO),'P')           AS Estado
            FROM CO_ABASTECIMIENTO a
            LEFT JOIN AREAS ar ON ar.IdArea = a.IdAreaSolicitante AND ar.IdArea >= 117
            WHERE {string.Join(" AND ", where.Select(w => w.Replace("TIPO_COMPROBANTE", "a.TIPO_COMPROBANTE").Replace("ANO_COMPROBANTE", "a.ANO_COMPROBANTE").Replace("ESTADO", "a.ESTADO")))}
            ORDER BY a.NRO_COMPROBANTE DESC
            """;

        var result = await conn.QueryAsync<NotaPedido>(sql, new { Tipo, Ano = ano, Estado = estado });
        return result.ToList();
    }

    public async Task<NotaPedido?> Obtener(string tipo, string ano, string nro)
    {
        using var conn = db.Create();

        const string sqlHead = """
            SELECT
                RTRIM(TIPO_COMPROBANTE)  AS TipoComprobante,
                RTRIM(ANO_COMPROBANTE)   AS AnoComprobante,
                RTRIM(NRO_COMPROBANTE)   AS NroComprobante,
                FECHA_PEDIDO             AS FechaPedido,
                ISNULL(RTRIM(AREA_SOLICITANTE),'') AS AreaSolicitante,
                ISNULL(RTRIM(CONCEPTO),'')          AS Concepto,
                ISNULL(RTRIM(ESTADO),'P')           AS Estado
            FROM CO_ABASTECIMIENTO
            WHERE RTRIM(TIPO_COMPROBANTE) = @Tipo
              AND RTRIM(ANO_COMPROBANTE)  = @Ano
              AND RTRIM(NRO_COMPROBANTE)  = @Nro
            """;

        var np = await conn.QueryFirstOrDefaultAsync<NotaPedido>(sqlHead, new { Tipo = tipo, Ano = ano, Nro = nro });
        if (np is null) return null;

        const string sqlDet = """
            SELECT
                CODIGO_ARTICULO   AS CodigoArticulo,
                ISNULL(CANTIDAD,0)        AS Cantidad,
                ISNULL(RTRIM(UNIDAD),'') AS Unidad,
                ISNULL(RTRIM(DESIGNACION),'') AS Designacion,
                ISNULL(PRECIO_UNITARIO,0)     AS PrecioUnitario
            FROM CO_ABASTECIMIENTO_DET
            WHERE RTRIM(TIPO_COMPROBANTE) = @Tipo
              AND RTRIM(ANO_COMPROBANTE)  = @Ano
              AND RTRIM(NRO_COMPROBANTE)  = @Nro
            """;

        var detalles = await conn.QueryAsync<NotaPedidoDetalle>(sqlDet, new { Tipo = tipo, Ano = ano, Nro = nro });
        np.Detalles  = detalles.ToList();

        return np;
    }

    public async Task<string> Crear(string ano, NuevaNotaPedidoRequest req)
    {
        using var conn = db.Create();

        const string nroSql = """
            SELECT ISNULL(MAX(CAST(RTRIM(NRO_COMPROBANTE) AS INT)),0)+1
            FROM CO_ABASTECIMIENTO
            WHERE RTRIM(TIPO_COMPROBANTE) = @Tipo AND RTRIM(ANO_COMPROBANTE) = @Ano
            """;

        var nroInt = await conn.QuerySingleAsync<int>(nroSql, new { Tipo, Ano = ano });
        var nro    = nroInt.ToString().PadLeft(8, '0');

        const string sqlHead = """
            INSERT INTO CO_ABASTECIMIENTO
                (TIPO_COMPROBANTE, ANO_COMPROBANTE, NRO_COMPROBANTE,
                 FECHA_PEDIDO, AREA_SOLICITANTE, AREA_DESTINO,
                 CONCEPTO, LUGAR_ENTREGA,
                 IDENT_SOLICITANTE, IDENT_AUTORIZA,
                 ESTADO, FECHA_CARGA, IdAreaSolicitante)
            VALUES
                (@Tipo, @Ano, @Nro,
                 GETDATE(), SPACE(15), SPACE(15),
                 @Concepto, ISNULL(@LugarEntrega,''),
                 '0', SPACE(5),
                 'P', GETDATE(), @IdAreaSolicitante)
            """;

        await conn.ExecuteAsync(sqlHead, new
        {
            Tipo,
            Ano  = ano,
            Nro  = nro,
            req.Concepto,
            req.LugarEntrega,
            req.IdAreaSolicitante,
        });

        if (req.Items.Count > 0)
        {
            const string sqlDet = """
                INSERT INTO CO_ABASTECIMIENTO_DET
                    (TIPO_COMPROBANTE, ANO_COMPROBANTE, NRO_COMPROBANTE,
                     CODIGO_ARTICULO_COD,
                     CANTIDAD, UNIDAD, DESIGNACION, PRECIO_UNITARIO, FECHA_HORA_CARGA)
                VALUES
                    (@Tipo, @Ano, @Nro,
                     SPACE(15),
                     @Cantidad, LEFT(@Unidad,2), @Designacion, @PrecioUnitario, GETDATE())
                """;

            foreach (var item in req.Items)
            {
                await conn.ExecuteAsync(sqlDet, new
                {
                    Tipo,
                    Ano            = ano,
                    Nro            = nro,
                    item.Cantidad,
                    item.Unidad,
                    item.Designacion,
                    item.PrecioUnitario
                });
            }
        }

        return nro;
    }

    public async Task CambiarEstado(string tipo, string ano, string nro, string nuevoEstado)
    {
        using var conn = db.Create();
        const string sql = """
            UPDATE CO_ABASTECIMIENTO
            SET ESTADO = @Estado, FECHA_AC = GETDATE()
            WHERE RTRIM(TIPO_COMPROBANTE) = @Tipo
              AND RTRIM(ANO_COMPROBANTE)  = @Ano
              AND RTRIM(NRO_COMPROBANTE)  = @Nro
            """;

        await conn.ExecuteAsync(sql, new { Estado = nuevoEstado, Tipo = tipo, Ano = ano, Nro = nro });
    }
}
