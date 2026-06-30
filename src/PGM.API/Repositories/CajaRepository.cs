using System.Data;
using Dapper;
using PGM.API.Models;

namespace PGM.API.Repositories;

public class CajaRepository(DbConnectionFactory db) : ICajaRepository
{
    // Mapeo interno: EF=04 CH=03 TJ=04 (con datos de tarjeta)
    private static string TipoMonedaDb(string tipo) => tipo switch
    {
        "CH" => "03",
        _    => "04",   // EF y TJ usan tipo 04
    };

    public async Task<(string CodErr, string Msg)> AbrirSesion(string cajero, DateTime fechaCaja)
    {
        using var conn = db.Create();

        // Verificar que el usuario esté registrado como cajero habilitado
        var cajeroId = await conn.ExecuteScalarAsync<string?>("""
            SELECT RTRIM(CAJERO) FROM CJC_USUARIOS
            WHERE UPPER(RTRIM(CAJERO)) = UPPER(@Cajero) AND HABILITADO = '1'
            """, new { Cajero = cajero });
        if (cajeroId is null)
            return ("ERROR", $"El usuario '{cajero}' no está registrado como cajero habilitado. Contacte al administrador.");

        // Usar el ID exacto de CJC_USUARIOS (preserva capitalización original)
        var cajeroExacto = cajeroId.PadRight(15);

        // Determinar próximo NRO_SESSION para hoy
        var maxSesion = await conn.ExecuteScalarAsync<int?>("""
            SELECT MAX(CAST(RTRIM(NRO_SESSION) AS INT))
            FROM CJC_CAJERO
            WHERE UPPER(RTRIM(CAJERO)) = UPPER(@Cajero)
              AND CAST(FECHA_CAJA AS DATE) = CAST(@FechaCaja AS DATE)
            """, new { Cajero = cajero, FechaCaja = fechaCaja });
        var session = ((maxSesion ?? 0) + 1).ToString().PadLeft(2, '0');

        await conn.ExecuteAsync("""
            INSERT INTO CJC_CAJERO
                (CAJERO, FECHA_CAJA, NRO_SESSION, USUARIO, CERRADO, TRANSFERIDO,
                 ANO_RECIBO, TIPO_RECIBO, NRO_RECIBO, DIFERENCIA_CIERRE)
            VALUES
                (@Cajero, @FechaCaja, @Session, @Usuario, '0', '0', '', '', '', 0)
            """, new {
                Cajero    = cajeroExacto,
                FechaCaja = fechaCaja,
                Session   = session,
                Usuario   = cajeroId.PadRight(30),
            });
        return ("BIEN", "Sesión de caja abierta");
    }

    public async Task<SesionCajero?> ObtenerSesionActiva(string cajero)
    {
        using var conn = db.Create();
        return await conn.QueryFirstOrDefaultAsync<SesionCajero>("""
            SELECT TOP 1
                RTRIM(CAJERO)      AS Cajero,
                FECHA_CAJA         AS FechaCaja,
                RTRIM(NRO_SESSION) AS NroSession,
                CASE CERRADO     WHEN '1' THEN 1 ELSE 0 END AS Cerrado,
                CASE TRANSFERIDO WHEN '1' THEN 1 ELSE 0 END AS Transferido
            FROM CJC_CAJERO
            WHERE UPPER(RTRIM(CAJERO)) = UPPER(@Cajero)
              AND CERRADO = '0'
            ORDER BY FECHA_CAJA DESC, NRO_SESSION DESC
            """, new { Cajero = cajero });
    }

    public async Task<CobroVentanillaResult> RegistrarCobroVentanilla(CobroVentanillaRequest req)
    {
        using var conn = db.Create();
        conn.Open();
        using var tx = conn.BeginTransaction();
        try
        {
            // Generar NRO_OPERACION: max actual de la sesión + 1
            var maxOp = await conn.ExecuteScalarAsync<int?>("""
                SELECT MAX(CAST(NRO_OPERACION AS INT))
                FROM CJC_PAGOS
                WHERE UPPER(RTRIM(CAJERO)) = UPPER(@Cajero)
                  AND FECHA_CAJA = @FechaCaja
                  AND RTRIM(NRO_SESSION) = RTRIM(@NroSession)
                """, new { req.Cajero, req.FechaCaja, req.NroSession }, tx);
            var nroOp = ((maxOp ?? 0) + 1).ToString().PadLeft(8, '0');

            decimal totalPagado = req.FormasPago.Sum(f => f.Importe);

            // Registrar pago por cada forma de pago en CJC_PAGOS
            foreach (var fp in req.FormasPago)
            {
                await conn.ExecuteAsync("""
                    INSERT INTO CJC_PAGOS
                        (CAJERO, FECHA_CAJA, NRO_SESSION, NRO_OPERACION, TIPO_MONEDA,
                         IMP_PAGO, IMP_VUELTO,
                         AJUSTE_REDONDEO_NEGATIVO, AJUSTE_REDONDEO_POSITIVO)
                    VALUES
                        (@Cajero, @FechaCaja, @NroSession, @NroOp, @TipoMon,
                         @ImpPago, @ImpVuelto, 0, 0)
                    """, new {
                        Cajero     = req.Cajero.PadRight(15),
                        req.FechaCaja,
                        NroSession = req.NroSession.PadLeft(2, '0'),
                        NroOp      = nroOp,
                        TipoMon    = TipoMonedaDb(fp.TipoMoneda).PadRight(2),
                        ImpPago    = fp.Importe,
                        ImpVuelto  = fp.TipoMoneda == "EF" ? req.ImpVuelto : 0m,
                    }, tx);

                // Detalle de forma de pago en CJC_PAGO_MONEDA
                await conn.ExecuteAsync("""
                    INSERT INTO CJC_PAGO_MONEDA
                        (CAJERO, FECHA_CAJA, NRO_SESSION, NRO_OPERACION, TIPO_MONEDA,
                         NRO_MONEDA, IMPORTE, IDENTIFICADOR, TDOC, NDOC,
                         APELLIDO, NOMBRE, TELEFONO, BANCO,
                         DESCRIPCION, TIPO_TARJETA, NRO_TARJETA, AUTORIZACION,
                         PLAN_TARJETA, FECHA_ACREDITACION, NRO_CUPON,
                         TIPO_MONEDA_CHEQUE, ANULACION, TIPO_RETENCION, NRO_COMPROBANTE)
                    VALUES
                        (@Cajero, @FechaCaja, @NroSession, @NroOp, @TipoMon,
                         @NroMoneda, @Importe, '     ', ' ', '           ',
                         '', '', '                              ', @Banco,
                         '', @TipoTarj, @NroTarj, @Autor,
                         @Plan, @FechaAcred, @NroCupon,
                         '  ', '0', '            ', '')
                    """, new {
                        Cajero     = req.Cajero.PadRight(15),
                        req.FechaCaja,
                        NroSession = req.NroSession.PadLeft(2, '0'),
                        NroOp      = nroOp,
                        TipoMon    = TipoMonedaDb(fp.TipoMoneda).PadRight(2),
                        NroMoneda  = (fp.TipoMoneda == "CH" ? fp.NroCheque : "1")?.PadRight(20) ?? "1".PadRight(20),
                        Importe    = fp.Importe,
                        Banco      = (fp.Banco ?? "").PadRight(4),
                        TipoTarj   = (fp.TipoTarjeta ?? "").PadRight(4),
                        NroTarj    = (fp.NroTarjeta ?? "").PadRight(30),
                        Autor      = (fp.Autorizacion ?? "").PadRight(20),
                        Plan       = (fp.PlanTarjeta ?? "").PadRight(10),
                        FechaAcred = (object?)fp.FechaAcred ?? DBNull.Value,
                        NroCupon   = (fp.NroCupon ?? "").PadRight(15),
                    }, tx);
            }

            // Cobrar cada cuota via CREA_PAGO_TOTAL
            var errores = new List<string>();
            foreach (var nroInterno in req.NrosInternos)
            {
                var p2 = new DynamicParameters();
                p2.Add("NRO_INTERNO", nroInterno.PadRight(10), DbType.AnsiStringFixedLength, size: 10);
                p2.Add("ID_PROCESS",  nroOp,                   DbType.AnsiStringFixedLength, size: 8);
                p2.Add("FECHA_PAGO",  req.FechaPago,            DbType.DateTime);
                p2.Add("CODERR",      new string(' ', 5),       DbType.AnsiString, ParameterDirection.Output, size: 5);
                p2.Add("MSG",         new string(' ', 255),     DbType.AnsiString, ParameterDirection.Output, size: 255);
                await conn.ExecuteAsync("CREA_PAGO_TOTAL", p2, tx, commandType: CommandType.StoredProcedure);
                var codErr = p2.Get<string>("CODERR").Trim();
                var msg    = p2.Get<string>("MSG").Trim();
                if (codErr != "BIEN")
                    errores.Add($"{nroInterno.Trim()}: {msg}");
            }

            if (errores.Any())
            {
                tx.Rollback();
                return new CobroVentanillaResult { Exitoso = false, Mensaje = "Error al cobrar cuotas", Errores = errores };
            }

            tx.Commit();
            return new CobroVentanillaResult { Exitoso = true, Mensaje = "Cobro registrado correctamente", NroOperacion = nroOp };
        }
        catch (Exception ex)
        {
            tx.Rollback();
            return new CobroVentanillaResult { Exitoso = false, Mensaje = ex.Message };
        }
    }

    public async Task<ResumenSesion?> ObtenerResumenSesion(string cajero, DateTime fechaCaja, string nroSession)
    {
        using var conn = db.Create();
        var sesion = await conn.QueryFirstOrDefaultAsync<SesionCajero>("""
            SELECT RTRIM(CAJERO) AS Cajero, FECHA_CAJA AS FechaCaja,
                   RTRIM(NRO_SESSION) AS NroSession,
                   CASE CERRADO WHEN '1' THEN 1 ELSE 0 END AS Cerrado,
                   CASE TRANSFERIDO WHEN '1' THEN 1 ELSE 0 END AS Transferido
            FROM CJC_CAJERO
            WHERE UPPER(RTRIM(CAJERO)) = UPPER(@Cajero)
              AND FECHA_CAJA = @FechaCaja
              AND RTRIM(NRO_SESSION) = RTRIM(@NroSession)
            """, new { Cajero = cajero, FechaCaja = fechaCaja, NroSession = nroSession });

        if (sesion is null) return null;

        var ops = await conn.QueryAsync<OperacionResumen>("""
            SELECT RTRIM(NRO_OPERACION) AS NroOperacion, FECHA_CAJA AS FechaCaja,
                   IMP_PAGO AS ImpPago, IMP_VUELTO AS ImpVuelto,
                   RTRIM(TIPO_MONEDA) AS TipoMoneda
            FROM CJC_PAGOS
            WHERE UPPER(RTRIM(CAJERO)) = UPPER(@Cajero)
              AND FECHA_CAJA = @FechaCaja
              AND RTRIM(NRO_SESSION) = RTRIM(@NroSession)
            ORDER BY NRO_OPERACION
            """, new { Cajero = cajero, FechaCaja = fechaCaja, NroSession = nroSession });

        var opList = ops.ToList();
        return new ResumenSesion
        {
            Cajero          = sesion.Cajero,
            FechaCaja       = sesion.FechaCaja,
            NroSession      = sesion.NroSession,
            Cerrado         = sesion.Cerrado,
            CantOperaciones = opList.Count,
            TotalEfectivo   = opList.Where(o => o.TipoMoneda == "04").Sum(o => o.ImpPago - o.ImpVuelto),
            TotalCheque     = opList.Where(o => o.TipoMoneda == "03").Sum(o => o.ImpPago),
            TotalTarjeta    = 0m,
            TotalGeneral    = opList.Sum(o => o.ImpPago - o.ImpVuelto),
            Operaciones     = opList,
        };
    }

    public async Task CerrarSesion(string cajero, DateTime fechaCaja, string nroSession, decimal diferencia)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE CJC_CAJERO
            SET CERRADO = '1', DIFERENCIA_CIERRE = @Diferencia
            WHERE UPPER(RTRIM(CAJERO)) = UPPER(@Cajero)
              AND FECHA_CAJA = @FechaCaja
              AND RTRIM(NRO_SESSION) = RTRIM(@NroSession)
            """, new { Cajero = cajero, FechaCaja = fechaCaja, NroSession = nroSession, Diferencia = diferencia });
    }

    public async Task<List<CajeroUsuario>> ListarCajeros()
    {
        using var conn = db.Create();
        var rows = await conn.QueryAsync<CajeroUsuario>("""
            SELECT
                RTRIM(CAJERO)      AS Cajero,
                RTRIM(DESCRIPCION) AS Descripcion,
                CASE HABILITADO WHEN '1' THEN 1 ELSE 0 END AS Habilitado,
                NIVEL,
                CASE ENC WHEN '1' THEN 1 ELSE 0 END AS EsEncargado
            FROM CJC_USUARIOS
            ORDER BY CAJERO
            """);
        return rows.ToList();
    }

    public async Task CrearCajero(CrearCajeroRequest req)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            IF NOT EXISTS (SELECT 1 FROM CJC_USUARIOS WHERE UPPER(RTRIM(CAJERO)) = UPPER(@Cajero))
                INSERT INTO CJC_USUARIOS (CAJERO, CLAVE, HABILITADO, BANCO, NIVEL, DESCRIPCION, ENC)
                VALUES (@Cajero, '               ', '1', '0', @Nivel, @Descripcion, '0')
            """, new {
                Cajero      = req.Cajero.ToUpper().PadRight(15),
                Nivel       = req.Nivel,
                Descripcion = req.Descripcion.PadRight(50),
            });
    }

    public async Task ToggleHabilitado(string cajero, bool habilitado)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE CJC_USUARIOS
            SET HABILITADO = @Hab
            WHERE UPPER(RTRIM(CAJERO)) = UPPER(@Cajero)
            """, new { Cajero = cajero, Hab = habilitado ? "1" : "0" });
    }
}
