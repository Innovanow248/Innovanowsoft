using Oracle.ManagedDataAccess.Client;
using PGM.API.Models;
using PGM.API.Repositories;

namespace PGM.API.Services;

public class OracleDevengamientoService(OracleConnectionFactory oracle, IDevengamientoRepository repo)
{
    // Mapa tipo_tributo → SP Oracle (PKG_DEVENGAMIENTO_MAL)
    private static readonly Dictionary<int, string> SpPorTributo = new()
    {
        // Agregar aquí el mapeo: idTipoTributo → "PKG_DEVENGAMIENTO_MAL.GENERA_DEVENGAMIENTO_*"
        // Ejemplo: { 1, "PKG_DEVENGAMIENTO_MAL.GENERA_DEVENGAMIENTO_AUAU_MAL" }
    };

    public async Task EjecutarDevengamiento(EjecutarDevengamientoRequest req, int idRegistro)
    {
        await repo.ActualizarEstadoDevengamiento(idRegistro, 5, "EN_PROCESO", "Obteniendo contribuyentes...");

        using var conn = oracle.Create();
        await conn.OpenAsync();

        // Obtener lista de T_TRIBUTOS_CONTRIBUYENTES para el tipo tributo y ejercicio
        var sql = """
            SELECT ID_TRIBUTO_CONTRIBUYENTE
            FROM INGRESOS.T_TRIBUTOS_CONTRIBUYENTES
            WHERE ID_TIPO_TRIBUTO = :IdTipoTributo
              AND ROWNUM <= 50000
            """;

        await using var cmd = new OracleCommand(sql, conn);
        cmd.Parameters.Add(":IdTipoTributo", req.IdTipoTributo);
        var ids = new List<string>();
        await using var rdr = await cmd.ExecuteReaderAsync();
        while (await rdr.ReadAsync()) ids.Add(rdr.GetString(0));

        var total     = ids.Count;
        var procesadas = 0;
        var devengadas = 0;
        var errores    = 0;

        if (!SpPorTributo.TryGetValue(req.IdTipoTributo, out var spName))
        {
            await repo.ActualizarEstadoDevengamiento(idRegistro, 0, "ERROR",
                $"No hay SP configurado para el tributo {req.IdTipoTributo}. Agregar mapeo en OracleDevengamientoService.SpPorTributo.");
            return;
        }

        foreach (var idContrib in ids)
        {
            try
            {
                await using var spCmd = new OracleCommand(spName, conn);
                spCmd.CommandType = System.Data.CommandType.StoredProcedure;
                spCmd.Parameters.Add("P_ID_TRIBUTO_CONTRIBUYENTE", idContrib);
                spCmd.Parameters.Add("P_EJERCICIO_LIQ",            int.Parse(req.Ejercicio));
                spCmd.Parameters.Add("P_USR_ING",                  req.Usuario);
                spCmd.Parameters.Add("P_MODO",                     "M");
                var pMsg = new OracleParameter("P_MSG", OracleDbType.Varchar2, 500)
                    { Direction = System.Data.ParameterDirection.Output };
                spCmd.Parameters.Add(pMsg);
                await spCmd.ExecuteNonQueryAsync();
                devengadas++;
            }
            catch { errores++; }

            procesadas++;
            if (procesadas % 50 == 0)
            {
                var pct = (decimal)procesadas / total * 100;
                await repo.ActualizarEstadoDevengamiento(idRegistro, pct, "EN_PROCESO",
                    $"{procesadas}/{total} procesadas");
            }
        }

        await repo.ActualizarEstadoDevengamiento(idRegistro, 100, "COMPLETADO",
            $"Completado: {devengadas} devengadas, {errores} errores de {total} cuentas.");

        var duracion = 0; // calculated externally
        await repo.RegistrarLogDevengamiento(new LogDevengamiento
        {
            IdJurisdiccion    = req.IdJurisdiccion,
            IdTipoTributo     = req.IdTipoTributo,
            Ejercicio         = req.Ejercicio,
            Resultado         = errores > 0 && devengadas == 0 ? "ERROR" : "EXITOSO",
            Mensaje           = $"{devengadas}/{total} devengadas, {errores} errores",
            UsrOperador       = req.Usuario,
            CuentasProcesadas = total,
            CuentasDevengadas = devengadas,
            CuentasError      = errores,
        });
    }
}
