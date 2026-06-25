using System.Data;
using Oracle.ManagedDataAccess.Client;
using PGM.API.Models;
using PGM.API.Repositories;

namespace PGM.API.Services;

public class OracleDevengamientoService(OracleConnectionFactory oracle, IDevengamientoRepository repo)
{
    // Tributos con firma estándar: (P_ID_TRIBUTO_CONTRIBUYENTE, P_EJERCICIO_LIQ, P_USR_ING, P_MODO, P_MSG OUT)
    private static readonly Dictionary<int, string> SpPorTributo = new()
    {
        { 2,  "PKG_DEVENGAMIENTO_MAL.GENERA_DEVENGAMIENTO_AUAU_MAL"   }, // Automotores
        { 4,  "PKG_DEVENGAMIENTO_MAL.GENERA_DEVENGAMIENTO_CECE_MAL"   }, // Cementerio
        { 6,  "PKG_DEVENGAMIENTO_MAL.GENERA_DEVENGAMIENTO_ININ_MAL"   }, // Inmobiliario (Tasa Serv. Propiedad)
        { 12, "PKG_DEVENGAMIENTO_MAL.GENERA_DEVENGAMIENTO_CLOACA_MAL" }, // Agua
        { 46, "PKG_DEVENGAMIENTO_MAL.GENERA_DEVENGAMIENTO_CLOACA_MAL" }, // Cloacas
    };

    // CICI_FIJO tiene firma extendida con parámetros OUT adicionales
    private const int    IdTributoCici = 5;
    private const string SpCiciFijo    = "PKG_DEVENGAMIENTO_MAL.GENERA_DEVENGAMIENTO_CICI_FIJO";

    public async Task EjecutarDevengamiento(EjecutarDevengamientoRequest req, int idRegistro)
    {
        // Validar SP antes de conectar a Oracle
        bool esCici = req.IdTipoTributo == IdTributoCici;
        if (!esCici && !SpPorTributo.ContainsKey(req.IdTipoTributo))
        {
            await repo.ActualizarEstadoDevengamiento(idRegistro, 0, "ERROR",
                $"No hay SP configurado para el tributo {req.IdTipoTributo}.");
            return;
        }

        await repo.ActualizarEstadoDevengamiento(idRegistro, 5, "EN_PROCESO", "Obteniendo contribuyentes...");

        using var conn = oracle.Create();
        await conn.OpenAsync();

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
        var ejercicio  = int.Parse(req.Ejercicio);

        foreach (var idContrib in ids)
        {
            try
            {
                if (esCici)
                    await CallSpCiciFijo(conn, idContrib, ejercicio, req.IdJurisdiccion, req.Usuario);
                else
                    await CallSpEstandar(conn, SpPorTributo[req.IdTipoTributo], idContrib, ejercicio, req.Usuario);

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

    // ── SPs con firma estándar: AUAU, ININ, CECE, CLOACA ─────────────────────
    private static async Task CallSpEstandar(
        OracleConnection conn, string spName, string idContrib, int ejercicio, string usuario)
    {
        await using var cmd = new OracleCommand(spName, conn)
            { CommandType = CommandType.StoredProcedure };
        cmd.Parameters.Add("P_ID_TRIBUTO_CONTRIBUYENTE", idContrib);
        cmd.Parameters.Add("P_EJERCICIO_LIQ",            ejercicio);
        cmd.Parameters.Add("P_USR_ING",                  usuario);
        cmd.Parameters.Add("P_MODO",                     "M");
        cmd.Parameters.Add(new OracleParameter("P_MSG", OracleDbType.Varchar2, 500)
            { Direction = ParameterDirection.Output });
        await cmd.ExecuteNonQueryAsync();
    }

    // ── SP CICI_FIJO: firma extendida con salidas adicionales ─────────────────
    private static async Task CallSpCiciFijo(
        OracleConnection conn, string idContrib, int ejercicio, int idJurisdiccion, string usuario)
    {
        await using var cmd = new OracleCommand(SpCiciFijo, conn)
            { CommandType = CommandType.StoredProcedure };
        cmd.Parameters.Add("P_ID_TRIBUTO_CONTRIBUYENTE", idContrib);
        cmd.Parameters.Add("P_EJERCICIO_LIQ",            ejercicio);
        cmd.Parameters.Add("P_ID_JURISDICCION",          idJurisdiccion);
        cmd.Parameters.Add("P_USR_ING",                  usuario);
        cmd.Parameters.Add(new OracleParameter("P_MSG",               OracleDbType.Varchar2, 500) { Direction = ParameterDirection.Output });
        cmd.Parameters.Add(new OracleParameter("P_CUOTA_CERO",        OracleDbType.Decimal)       { Direction = ParameterDirection.Output });
        cmd.Parameters.Add(new OracleParameter("P_CUENTAS_DEVENGADAS",OracleDbType.Decimal)       { Direction = ParameterDirection.Output });
        cmd.Parameters.Add(new OracleParameter("P_CUOTAS_GENERADAS",  OracleDbType.Decimal)       { Direction = ParameterDirection.Output });
        cmd.Parameters.Add(new OracleParameter("P_VARIABLE",          OracleDbType.Varchar2, 500) { Direction = ParameterDirection.Output });
        await cmd.ExecuteNonQueryAsync();
    }
}
