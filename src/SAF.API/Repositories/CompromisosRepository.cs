using Dapper;
using SAF.API.Models;

namespace SAF.API.Repositories;

public class CompromisosRepository(DbConnectionFactory db) : ICompromisosRepository
{
    public async Task<List<Compromiso>> Listar(string ano, string? estado, string? identificador)
    {
        using var conn = db.Create();

        var where = new List<string> { "RTRIM(c.ANO_COMPROMISO) = @Ano" };
        if (!string.IsNullOrWhiteSpace(estado))        where.Add("RTRIM(c.ESTADO_COMPROMISO) = @Estado");
        if (!string.IsNullOrWhiteSpace(identificador)) where.Add("RTRIM(c.IDENTIFICADOR) = @Identificador");

        var sql = $"""
            SELECT
                RTRIM(c.TIPO_COMPROMISO)      AS TipoCompromiso,
                RTRIM(c.ANO_COMPROMISO)       AS AnoCompromiso,
                RTRIM(c.NRO_COMPROMISO)       AS NroCompromiso,
                RTRIM(c.IDENTIFICADOR)        AS Identificador,
                ISNULL(RTRIM(p.APELLIDO)+', '+RTRIM(p.NOMBRE),'') AS NombreProveedor,
                c.FECHA_COMPROMISO            AS FechaCompromiso,
                ISNULL(RTRIM(c.CONCEPTO),'') AS Concepto,
                ISNULL(c.MONTO_COMPROMETIDO,0) AS MontoComprometido,
                ISNULL(c.MONTO_APAGAR,0)       AS MontoAPagar,
                ISNULL(c.MONTO_PAGADO,0)       AS MontoPagado,
                RTRIM(c.ESTADO_COMPROMISO)     AS EstadoCompromiso
            FROM CP_COMPROMISOS c
            LEFT JOIN PERSONAS p ON RTRIM(p.IDENTIFICADOR) = RTRIM(c.IDENTIFICADOR)
            WHERE {string.Join(" AND ", where)}
            ORDER BY c.NRO_COMPROMISO DESC
            """;

        var result = await conn.QueryAsync<Compromiso>(sql, new
        {
            Ano           = ano,
            Estado        = estado,
            Identificador = identificador
        });
        return result.ToList();
    }

    public async Task<string> Crear(string ano, NuevoCompromisoRequest req)
    {
        using var conn = db.Create();

        // Garantizar que el año esté dado de alta en la tabla maestra de períodos
        const string ensureAno = """
            IF NOT EXISTS (
                SELECT 1 FROM CP_COMPROMISOS_ANO
                WHERE RTRIM(TIPO_COMPROMISO) = 'XCP' AND RTRIM(ANO_COMPROMISO) = @Ano)
            INSERT INTO CP_COMPROMISOS_ANO (TIPO_COMPROMISO, ANO_COMPROMISO, CONTADOR)
            VALUES ('XCP', @Ano, 0)
            """;
        await conn.ExecuteAsync(ensureAno, new { Ano = ano });

        const string nroSql = """
            SELECT ISNULL(MAX(CAST(RTRIM(NRO_COMPROMISO) AS INT)),0)+1
            FROM CP_COMPROMISOS
            WHERE RTRIM(ANO_COMPROMISO) = @Ano AND RTRIM(TIPO_COMPROMISO) = 'XCP'
            """;

        var nroInt = await conn.QuerySingleAsync<int>(nroSql, new { Ano = ano });
        var nro    = nroInt.ToString().PadLeft(8, '0');

        const string sql = """
            INSERT INTO CP_COMPROMISOS
                (TIPO_COMPROMISO, ANO_COMPROMISO, NRO_COMPROMISO, IDENTIFICADOR,
                 FECHA_COMPROMISO, CONCEPTO, MONTO_COMPROMETIDO, MONTO_APAGAR,
                 MONTO_PAGADO, ESTADO_COMPROMISO, MONTO_DESCOMPROMETIDO)
            VALUES
                ('XCP', @Ano, @Nro, @Identificador,
                 GETDATE(), @Concepto, @MontoComprometido, @MontoAPagar,
                 0, 'P', 0)
            """;

        await conn.ExecuteAsync(sql, new
        {
            Ano              = ano,
            Nro              = nro,
            req.Identificador,
            req.Concepto,
            req.MontoComprometido,
            req.MontoAPagar
        });

        return nro;
    }

    public async Task CambiarEstado(string tipo, string ano, string nro, string nuevoEstado)
    {
        using var conn = db.Create();
        const string sql = """
            UPDATE CP_COMPROMISOS
            SET ESTADO_COMPROMISO = @Estado
            WHERE RTRIM(TIPO_COMPROMISO) = @Tipo
              AND RTRIM(ANO_COMPROMISO)  = @Ano
              AND RTRIM(NRO_COMPROMISO)  = @Nro
            """;

        await conn.ExecuteAsync(sql, new { Estado = nuevoEstado, Tipo = tipo, Ano = ano, Nro = nro });
    }
}
