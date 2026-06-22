using Dapper;
using SAF.API.Models;

namespace SAF.API.Repositories;

public class OrdenesPageRepository(DbConnectionFactory db) : IOrdenesPageRepository
{
    public async Task<List<OrdenPago>> Listar(string ano, string? estado, string? identificador)
    {
        using var conn = db.Create();

        var where = new List<string> { "RTRIM(o.ANO_OPAGO) = @Ano" };
        if (!string.IsNullOrWhiteSpace(estado))        where.Add("RTRIM(o.ESTADO) = @Estado");
        if (!string.IsNullOrWhiteSpace(identificador)) where.Add("RTRIM(o.IDENTIFICADOR) = @Identificador");

        var sql = $"""
            SELECT
                RTRIM(o.TIPO_OPAGO)       AS TipoOpago,
                RTRIM(o.ANO_OPAGO)        AS AnoOpago,
                RTRIM(o.NRO_OPAGO)        AS NroOpago,
                RTRIM(o.IDENTIFICADOR)    AS Identificador,
                ISNULL(RTRIM(p.APELLIDO)+', '+RTRIM(p.NOMBRE),'') AS NombreProveedor,
                ISNULL(RTRIM(o.NRO_CTA),'')  AS NroCta,
                ISNULL(RTRIM(o.ANO_ERO),'')  AS AnoEro,
                ISNULL(o.MONTO_APAGAR,0)     AS MontoAPagar,
                ISNULL(o.MONTO_PAGADO,0)     AS MontoPagado,
                RTRIM(o.ESTADO)              AS Estado,
                o.OBSERVACIONES              AS Observaciones,
                o.MANDATO_FECHA              AS FechaMandato
            FROM CP_ORDENES_PAGO o
            LEFT JOIN PERSONAS p ON RTRIM(p.IDENTIFICADOR) = RTRIM(o.IDENTIFICADOR)
            WHERE {string.Join(" AND ", where)}
            ORDER BY o.NRO_OPAGO DESC
            """;

        var result = await conn.QueryAsync<OrdenPago>(sql, new
        {
            Ano           = ano,
            Estado        = estado,
            Identificador = identificador
        });
        return result.ToList();
    }

    public async Task<string> Crear(string ano, NuevaOrdenPagoRequest req)
    {
        using var conn = db.Create();

        const string nroSql = """
            SELECT ISNULL(MAX(CAST(RTRIM(NRO_OPAGO) AS INT)),0)+1
            FROM CP_ORDENES_PAGO
            WHERE RTRIM(ANO_OPAGO) = @Ano AND RTRIM(TIPO_OPAGO) = 'CO'
            """;

        var nroInt = await conn.QuerySingleAsync<int>(nroSql, new { Ano = ano });
        var nro    = nroInt.ToString().PadLeft(8, '0');

        const string sql = """
            INSERT INTO CP_ORDENES_PAGO
                (TIPO_OPAGO, ANO_OPAGO, NRO_OPAGO, IDENTIFICADOR,
                 NRO_CTA, ANO_ERO, MONTO_APAGAR, MONTO_PAGADO,
                 ESTADO, OBSERVACIONES)
            VALUES
                ('CO', @Ano, @Nro, @Identificador,
                 @NroCta, @AnoEro, @MontoAPagar, 0,
                 'P', @Observaciones)
            """;

        await conn.ExecuteAsync(sql, new
        {
            Ano  = ano,
            Nro  = nro,
            req.Identificador,
            req.NroCta,
            req.AnoEro,
            req.MontoAPagar,
            req.Observaciones
        });

        return nro;
    }

    public async Task CambiarEstado(string tipo, string ano, string nro, string nuevoEstado)
    {
        using var conn = db.Create();

        var setExtra = nuevoEstado == "A" ? ", MANDATO_FECHA = GETDATE()" : "";

        var sql = $"""
            UPDATE CP_ORDENES_PAGO
            SET ESTADO = @Estado{setExtra}
            WHERE RTRIM(TIPO_OPAGO) = @Tipo
              AND RTRIM(ANO_OPAGO)  = @Ano
              AND RTRIM(NRO_OPAGO)  = @Nro
            """;

        await conn.ExecuteAsync(sql, new { Estado = nuevoEstado, Tipo = tipo, Ano = ano, Nro = nro });
    }
}
