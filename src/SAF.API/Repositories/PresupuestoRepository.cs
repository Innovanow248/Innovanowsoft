using Dapper;
using SAF.API.Models;

namespace SAF.API.Repositories;

public class PresupuestoRepository(DbConnectionFactory db) : IPresupuestoRepository
{
    public async Task<List<CuentaErogacion>> ListarCuentas(string ano)
    {
        using var conn = db.Create();
        const string sql = """
            SELECT
                RTRIM(ANO_ERO)                AS AnoEro,
                RTRIM(NRO_CTA_ERO)            AS NroCtaEro,
                ISNULL(RTRIM(DESIGNACION),'') AS Designacion,
                ISNULL(PRESUPUESTO_AUTORIZADO,0) AS PresupuestoAutorizado,
                ISNULL(MONTO_AFECTADO,0)      AS MontoAfectado,
                ISNULL(MONTO_PAGADO,0)        AS MontoPagado
            FROM CP_EROGACION_CUENTAS
            WHERE RTRIM(ANO_ERO) = @Ano
            ORDER BY NRO_CTA_ERO
            """;

        var result = await conn.QueryAsync<CuentaErogacion>(sql, new { Ano = ano });
        return result.ToList();
    }

    public async Task AjustarPresupuesto(string ano, string nroCta, decimal nuevoMonto)
    {
        using var conn = db.Create();
        const string sql = """
            UPDATE CP_EROGACION_CUENTAS
            SET PRESUPUESTO_AUTORIZADO = @NuevoMonto
            WHERE RTRIM(ANO_ERO) = @Ano AND RTRIM(NRO_CTA_ERO) = @NroCta
            """;

        await conn.ExecuteAsync(sql, new { Ano = ano, NroCta = nroCta, NuevoMonto = nuevoMonto });
    }
}
