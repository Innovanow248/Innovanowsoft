using Dapper;
using System.Data;
using PGM.API.Models;

namespace PGM.API.Repositories;

public class TributariaRepository(DbConnectionFactory db) : ITributariaRepository
{
    public async Task<List<BienPadron>> ObtenerBienesPorPersona(string identificador)
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<BienPadron>("""
            SELECT
                RTRIM(pb.ID_BIEN)          AS IdBien,
                RTRIM(pb.TIPO_BIEN)        AS TipoBien,
                RTRIM(pb.IDENTIFICADOR)    AS Identificador,
                RTRIM(ISNULL(pb.CLAVE_BIEN,''))          AS ClaveBien,
                RTRIM(ISNULL(pb.CODIGO_IMPRESION,''))     AS CodigoImpresion,
                RTRIM(pb.ACTIVO)           AS Activo,
                RTRIM(pb.IMPRIME)          AS Imprime,
                RTRIM(ISNULL(pb.EXENCION,'NOEX'))        AS Exencion,
                RTRIM(ISNULL(pb.TIPO_PLAN,'1 '))         AS TipoPlan,
                RTRIM(ISNULL(pb.SITUACION_DEUDA,'RE'))   AS SituacionDeuda,
                ISNULL(pb.MONTO_DEUDA_HISTORICO,0)       AS MontDeudaHistorico,
                ISNULL(pb.MONTO_DEUDA_ACTUALIZADO,0)     AS MontoDeudaActualizado,
                NULLIF(RTRIM(ISNULL(a.DESCRIPCION_INDIVIDUAL, ISNULL(a.MARCA_VEHICULO,''))), '') AS Descripcion,
                CASE WHEN pb.ACTIVO = '0'
                     THEN COALESCE(pb.FECHA_BAJA, pb.LIQ_HASTA)
                     ELSE NULL END                           AS FechaBaja
            FROM RT_PADRON_BASE pb
            LEFT JOIN RT_AUTOMOTORES a ON RTRIM(a.ID_AUTOMOTOR) = RTRIM(pb.ID_BIEN)
                                      AND RTRIM(pb.TIPO_BIEN) = 'AUAU'
            WHERE RTRIM(pb.IDENTIFICADOR) = @Identificador
            ORDER BY pb.TIPO_BIEN
            """, new { Identificador = identificador });
        return result.ToList();
    }

    public async Task<List<DeudaContribuyente>> ObtenerDeudaPendiente(string identificador)
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<DeudaContribuyente>("""
            SELECT
                RTRIM(p.IDENTIFICADOR)     AS Identificador,
                RTRIM(p.APELLIDO) + ', ' + RTRIM(p.NOMBRE) AS Contribuyente,
                RTRIM(p.CUIT_CUIL)         AS CuitCuil,
                RTRIM(pb.TIPO_BIEN)        AS TipoBien,
                RTRIM(pb.CLAVE_BIEN)       AS ClaveBien,
                RTRIM(pb.SITUACION_DEUDA)  AS SituacionDeuda,
                RTRIM(f.NRO_INTERNO)       AS NroInterno,
                RTRIM(f.ANO_CUOTA) + '/' + RTRIM(f.NRO_CUOTA) AS Periodo,
                RTRIM(f.ESTADO_DEUDA)      AS EstadoDeuda,
                ISNULL(f.CAPITAL_FACTURADO,0)  AS CapitalFacturado,
                ISNULL(fd.MONTO_ACTUALIZADO_CAPITAL,0)
                    + ISNULL(fd.MONTO_ACTUALIZADO_INTERESES,0) AS DeudaTotalActualizada,
                ISNULL(fd.IMP_1VENCE,0)        AS Imp1Vence,
                fd.FECHA_VENCIMIENTO1          AS FechaVencimiento1,
                ISNULL(fd.IMP_2VENCE,0)        AS Imp2Vence,
                fd.FECHA_VENCIMIENTO2          AS FechaVencimiento2,
                ISNULL(fd.IMP_3VENCE,0)        AS Imp3Vence,
                fd.FECHA_VENCIMIENTO3          AS FechaVencimiento3
            FROM PERSONAS p
            JOIN RT_PADRON_BASE pb
                ON RTRIM(pb.IDENTIFICADOR) = RTRIM(p.IDENTIFICADOR)
            JOIN RT_FACTURAS f
                ON RTRIM(f.ID_BIEN)   = RTRIM(pb.ID_BIEN)
                AND RTRIM(f.TIPO_BIEN) = RTRIM(pb.TIPO_BIEN)
                AND RTRIM(f.ESTADO_DEUDA) = 'PT'
            JOIN RT_FACTURAS_DEUDA_DETALLE fdd
                ON RTRIM(fdd.NRO_INTERNO) = RTRIM(f.NRO_INTERNO)
            JOIN RT_FACTURAS_DEUDA fd
                ON RTRIM(fd.NRO_INTERNO_DEUDA) = RTRIM(fdd.NRO_INTERNO_DEUDA)
                AND RTRIM(fd.ESTADO_DEUDA) = 'LI'
            WHERE RTRIM(p.IDENTIFICADOR) = @Identificador
            ORDER BY pb.TIPO_BIEN, f.ANO_CUOTA, f.NRO_CUOTA
            """, new { Identificador = identificador });
        return result.ToList();
    }

    public async Task<List<DeudaResumen>> ObtenerResumenDeuda(string identificador)
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<DeudaResumen>("""
            SELECT
                RTRIM(TIPO_BIEN)             AS TipoBien,
                ISNULL(MONTO_DEUDA_HISTORICO,0)    AS MontoHistorico,
                ISNULL(MONTO_DEUDA_ACTUALIZADO,0)  AS MontoActualizado,
                FECHA_ACTUALIZACION_DEUDA          AS FechaActualizacion
            FROM RT_DEUDA_PERSONA
            WHERE RTRIM(IDENTIFICADOR) = @Identificador
            ORDER BY TIPO_BIEN
            """, new { Identificador = identificador });
        return result.ToList();
    }

    public async Task<List<TipoBien>> ObtenerTiposBien()
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<TipoBien>("""
            SELECT RTRIM(TIPO_BIEN) AS CodigoTipoBien, RTRIM(CONCEPTO) AS Concepto
            FROM RT_BIENES
            ORDER BY TIPO_BIEN
            """);
        return result.ToList();
    }

    public async Task<List<PlanPago>> ObtenerPlanesPorTipo(string tipoBien)
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<PlanPago>("""
            SELECT
                RTRIM(TIPO_BIEN)         AS TipoBien,
                RTRIM(TIPO_PLAN)         AS TipoPlan,
                ISNULL(RTRIM(DESIGNACION_PLAN),'') AS DesignacionPlan,
                CANTIDAD_CUOTAS
            FROM RT_PLANES_TIPO
            WHERE RTRIM(TIPO_BIEN) = @TipoBien
            ORDER BY TIPO_PLAN
            """, new { TipoBien = tipoBien });
        return result.ToList();
    }

    public async Task<PadronPagedResult> ObtenerPadron(string? tipoBien, string? activo, string? situacion, string? titular, int page, int pageSize)
    {
        using var conn = db.Create();

        var where = new List<string>();
        if (!string.IsNullOrWhiteSpace(tipoBien))  where.Add("RTRIM(pb.TIPO_BIEN) = @TipoBien");
        if (!string.IsNullOrWhiteSpace(activo))     where.Add("RTRIM(pb.ACTIVO) = @Activo");
        if (!string.IsNullOrWhiteSpace(situacion))  where.Add("RTRIM(pb.SITUACION_DEUDA) = @Situacion");
        if (!string.IsNullOrWhiteSpace(titular))    where.Add("(RTRIM(p.APELLIDO) LIKE '%' + @Titular + '%' OR RTRIM(p.NOMBRE) LIKE '%' + @Titular + '%' OR RTRIM(p.CUIT_CUIL) LIKE '%' + @Titular + '%')");

        var whereClause = where.Count > 0 ? "WHERE " + string.Join(" AND ", where) : "";
        var offset = (page - 1) * pageSize;

        var sql = $"""
            SELECT COUNT(*)
            FROM RT_PADRON_BASE pb
            LEFT JOIN PERSONAS p ON RTRIM(p.IDENTIFICADOR) = RTRIM(pb.IDENTIFICADOR)
            {whereClause};

            SELECT
                RTRIM(pb.ID_BIEN)             AS IdBien,
                RTRIM(pb.TIPO_BIEN)           AS TipoBien,
                ISNULL(RTRIM(b.CONCEPTO),'')  AS ConceptoBien,
                ISNULL(RTRIM(pb.CLAVE_BIEN),'')   AS ClaveBien,
                RTRIM(pb.IDENTIFICADOR)        AS Identificador,
                ISNULL(RTRIM(p.APELLIDO),'')   AS Apellido,
                ISNULL(RTRIM(p.NOMBRE),'')     AS Nombre,
                ISNULL(RTRIM(p.CUIT_CUIL),'')  AS CuitCuil,
                RTRIM(pb.ACTIVO)               AS Activo,
                ISNULL(RTRIM(pb.SITUACION_DEUDA),'RE') AS SituacionDeuda,
                ISNULL(pb.MONTO_DEUDA_ACTUALIZADO,0)   AS MontoDeudaActualizado,
                ISNULL(RTRIM(pb.TIPO_PLAN),'1 ')       AS TipoPlan,
                ISNULL(RTRIM(pb.EXENCION),'NOEX')      AS Exencion
            FROM RT_PADRON_BASE pb
            LEFT JOIN RT_BIENES b ON RTRIM(b.TIPO_BIEN) = RTRIM(pb.TIPO_BIEN)
            LEFT JOIN PERSONAS p  ON RTRIM(p.IDENTIFICADOR) = RTRIM(pb.IDENTIFICADOR)
            {whereClause}
            ORDER BY pb.TIPO_BIEN, pb.ID_BIEN
            OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY
            """;

        using var multi = await conn.QueryMultipleAsync(sql,
            new { TipoBien = tipoBien, Activo = activo, Situacion = situacion, Titular = titular, Offset = offset, PageSize = pageSize });

        var total = await multi.ReadFirstAsync<int>();
        var items = (await multi.ReadAsync<BienPadronDetalle>()).ToList();

        return new PadronPagedResult { Total = total, Items = items };
    }

    // ── GENERACIÓN DE ID ─────────────────────────────────────────────────

    private async Task<string> GenerarIdBien()
    {
        using var conn = db.Create();
        return await conn.ExecuteScalarAsync<string>("""
            DECLARE @cnt INT
            UPDATE GEN_CONTADOR SET @cnt = CONTADOR = CONTADOR + 1
            WHERE TIPO_CONTADOR = 'ID_BIEN'
            SELECT dbo.fn_IntToBase36(@cnt)
            """) ?? throw new InvalidOperationException("No se pudo generar ID de bien.");
    }

    // ── ALTA EN PADRÓN ───────────────────────────────────────────────────

    public async Task<string> CrearBienPadron(AltaPadronRequest req)
    {
        var id = await GenerarIdBien();
        using var conn = db.Create();
        var tipo   = req.TipoBien.ToUpper().PadRight(4);
        var clave  = (req.ClaveBien ?? "").PadRight(50);
        var codImp = (req.CodigoImpresion ?? req.ClaveBien ?? "").PadRight(15);
        await conn.ExecuteAsync("""
            INSERT INTO RT_PADRON_BASE (
                ID_BIEN, TIPO_BIEN, CODIGO_IMPRESION, IDENTIFICADOR,
                CLAVE_BIEN, ACTIVO, IMPRIME, EXENCION, TIPO_PLAN,
                FECHA_ALTA, MONTO_DEUDA_HISTORICO, MONTO_DEUDA_ACTUALIZADO, LIQ_DESDE
            ) VALUES (
                @Id, @Tipo, @CodImp, @Identificador,
                @Clave, '1', '1', @Exencion, @TipoPlan,
                GETDATE(), 0, 0, @LiqDesde
            )
            """, new {
                Id            = id,
                Tipo          = tipo,
                CodImp        = codImp,
                Identificador = req.Identificador,
                Clave         = clave,
                Exencion      = (req.Exencion ?? "NOEX").PadRight(4),
                TipoPlan      = (req.TipoPlan ?? "1 ").PadRight(2),
                LiqDesde      = req.LiquidaDesde ?? DateTime.Today,
            });
        return id;
    }

    // ── ALTA AUTOMOTOR ───────────────────────────────────────────────────

    public async Task CrearAutomotor(string idBien, AltaAutomotorRequest req)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            INSERT INTO RT_AUTOMOTORES (
                ID_AUTOMOTOR, TIPO_CATEGORIA_AUTOMOTOR, CIP, ANO_VALUACION,
                MODELO_AUTOMOTOR, NRO_MOTOR, NRO_CHASIS, CERTIFICADO_FABRICACION,
                NRO_ADUANA, MARCA_VEHICULO, DESCRIPCION_INDIVIDUAL,
                ESTADO_RENTA_AUTOMOTOR, HP_VEHICULO, PESO_CILINDRADA,
                IMPORTADO, PATENTE_ANTERIOR, VIN, TIPO_ALTA,
                VALOR_FACTURA, DATO1, DATO2, DATO3, REN_ESTADO,
                USA_IMP_ANUAL, IMP_ANUAL, CARGA
            ) VALUES (
                @Id,
                @Categoria,
                @Cip,
                @AnoVal,
                @Modelo,
                @Motor,
                @Chasis,
                '                              ',
                '                    ',
                @Marca,
                @Desc,
                ' ',
                '     ',
                @Cilindrada,
                @Importado,
                @Patente,
                @Vin,
                @TipoAlta,
                @Valor,
                '                              ',
                '                              ',
                '                              ',
                ' ', '0', 0, 0
            )
            """, new {
                Id          = idBien,
                Categoria   = (req.CategoriaAutomotor ?? "A1  ").PadRight(4),
                Cip         = (req.Cip ?? "").PadRight(10),
                AnoVal      = (req.AnoValuacion ?? DateTime.Today.Year.ToString()).PadRight(4),
                Modelo      = req.ModeloAno,
                Motor       = (req.NroMotor ?? "").PadRight(24),
                Chasis      = (req.NroChasis ?? "").PadRight(50),
                Marca       = (req.Marca ?? "").PadRight(50),
                Desc        = (req.Descripcion ?? req.Marca ?? "").PadRight(50),
                Cilindrada  = (req.Cilindrada ?? "").PadRight(5),
                Importado   = req.Importado ?? "N",
                Patente     = (req.Patente ?? "").PadRight(10),
                Vin         = (req.Vin ?? "").PadRight(30),
                TipoAlta    = (req.TipoAlta ?? "01  ").PadRight(4),
                Valor       = req.ValorFactura,
            });
    }

    // ── ALTA CATASTRO ────────────────────────────────────────────────────

    public async Task CrearCatastro(string idBien, AltaCatastroRequest req)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            INSERT INTO RT_CATASTRO (
                ID_CATASTRO, CODIGO_CALLE, CODIGO_POSTAL_AUXILIAR, NRO_RENTA,
                CALLE_NOCOD, NUMERACION_CALLE, PISO, BARRIO, DEPARTAMENTO,
                ESQUINA_MEDIAL, SUPERFICIE_TERRENO, COEFICIENTE_FRENTE_FONDO,
                PORCENTAJE_COPROPIEDAD, DESIGNACION_OFICIAL,
                FOLIO1, ANO1, NRO_MATRICULA_FOLIO_REAL, BALDIO_EDIFICADO,
                BASE_IMPONIBLE, TASACION_TERRENO, METROS_FRENTE,
                VALOR_TERRENO, VALOR_EDIFICADO,
                CODIGO_POSTAL_AMPLIADO, CODIGO_POSTAL_SUFIJO, UNIDADES_LOCATIVAS
            ) VALUES (
                @Id, '', @CodPostal, @NroRenta,
                @Calle, @Nro, '    ', @Barrio, '    ',
                '04', @Superficie, 1.00,
                0, @Designacion,
                '', '', @Matricula, @BaldioEd,
                @BaseImp, 0, @Frente,
                0, 0,
                '', '', @UnidadLoc
            )
            """, new {
                Id          = idBien,
                CodPostal   = (req.CodigoPostal ?? "").PadRight(8),
                NroRenta    = (req.NroRenta ?? "").PadRight(30),
                Calle       = (req.Calle ?? "").PadRight(30),
                Nro         = (req.NumeracionCalle ?? "").PadRight(5),
                Barrio      = (req.Barrio ?? "").PadRight(40),
                Designacion = (req.DesignacionOficial ?? "").PadRight(40),
                Matricula   = (req.NroMatricula ?? "").PadRight(30),
                BaldioEd    = (req.BaldioEdificado ?? "01").PadRight(2),
                Superficie  = req.SuperficieTerreno,
                BaseImp     = req.BaseImponible,
                Frente      = req.MetrosFrente,
                UnidadLoc   = req.UnidadesLocativas ?? 0,
            });

        if (req.TieneServicio)
        {
            await conn.ExecuteAsync("""
                INSERT INTO RT_SERV_PROPIEDAD (ID_SERVICIO_PROPIEDAD, ID_CATASTRO, DATO1, DATO2, DATO3)
                VALUES (@Id, @Id, NULL, NULL, NULL)
                """, new { Id = idBien });
        }
    }

    // ── ALTA COMERCIO ────────────────────────────────────────────────────

    public async Task CrearComercio(string idBien, AltaComercioRequest req)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            INSERT INTO RT_COMERCIO_INDUSTRIA (
                ID_COMERCIO_INDUSTRIA, CLASIFICACION, NOMBRE_FANTASIA, NOMBRE_SOCIEDAD,
                TIPO_SOCIEDAD, CUIT, INGRESOS_BRUTOS, IVA,
                CALLE_NOCOD, NUMERACION_CALLE, PISO, DEPARTAMENTO, TORRE, BARRIO,
                CODIGO_POSTAL_AUXILIAR, RESOLUCION_HABILITACION, RESOLUCION_BAJA,
                TASA_FINAL, CAPITAL_DECLARADO, PERSONAL_OCUPADO, TIPO_CONTRIBUYENTE,
                CODIGO_POSTAL_AMPLIADO, CODIGO_POSTAL_SUFIJO,
                TELEFONO, TELEFONO_MOVIL, E_MAIL
            ) VALUES (
                @Id, @Clasif, @NomFantasia, @NomSociedad,
                @TipoSoc, @Cuit, @IIBB, 'RESINS    ',
                @Calle, @Nro, '    ', '    ', '                              ', @Barrio,
                @CodPostal, @Resolucion, '               ',
                0, @Capital, @Personal, @TipoContr,
                '', '',
                @Tel, '', @Email
            )
            """, new {
                Id          = idBien,
                Clasif      = (req.Clasificacion ?? "0001").PadRight(4),
                NomFantasia = (req.NombreFantasia ?? "").PadRight(50),
                NomSociedad = (req.NombreSociedad ?? "").PadRight(50),
                TipoSoc     = (req.TipoSociedad ?? "UNIP").PadRight(4),
                Cuit        = (req.Cuit ?? "").PadRight(11),
                IIBB        = (req.IngresosBrutos ?? "").PadRight(15),
                Calle       = (req.Calle ?? "").PadRight(30),
                Nro         = (req.NumeracionCalle ?? "").PadRight(5),
                Barrio      = (req.Barrio ?? "").PadRight(40),
                CodPostal   = (req.CodigoPostal ?? "").PadRight(8),
                Resolucion  = (req.ResolucionHabilitacion ?? "").PadRight(15),
                Capital     = req.CapitalDeclarado,
                Personal    = req.PersonalOcupado,
                TipoContr   = (req.TipoContribuyente ?? "DDJJ").PadRight(4),
                Tel         = req.Telefono ?? "",
                Email       = req.Email ?? "",
            });
    }

    // ── BAJA DE BIEN ─────────────────────────────────────────────────────

    public async Task BajarBien(string idBien, string tipoBien)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE RT_PADRON_BASE
            SET ACTIVO = '0', IMPRIME = '0', FECHA_BAJA = GETDATE(), LIQ_HASTA = GETDATE()
            WHERE RTRIM(ID_BIEN) = @IdBien AND RTRIM(TIPO_BIEN) = @TipoBien
            """, new { IdBien = idBien, TipoBien = tipoBien.ToUpper() });

        if (tipoBien.Trim().Equals("AUAU", StringComparison.OrdinalIgnoreCase))
        {
            await conn.ExecuteAsync("""
                UPDATE RT_AUTOMOTORES SET ESTADO_RENTA_AUTOMOTOR = 'B'
                WHERE RTRIM(ID_AUTOMOTOR) = @IdBien
                """, new { IdBien = idBien });
        }
    }

    // ── CAMBIO DE TITULAR ────────────────────────────────────────────────

    public async Task CambiarTitular(string idBien, string tipoBien, string nuevoIdentificador)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE RT_PADRON_BASE
            SET IDENTIFICADOR = @Nuevo, FECHA_AC = GETDATE()
            WHERE RTRIM(ID_BIEN) = @IdBien AND RTRIM(TIPO_BIEN) = @TipoBien
            """, new {
                Nuevo    = nuevoIdentificador,
                IdBien   = idBien,
                TipoBien = tipoBien.ToUpper()
            });
    }

    // ── REGISTRO DE COBRO ────────────────────────────────────────────────

    public async Task<CobroResult> RegistrarCobro(CobroRequest req)
    {
        using var conn = db.Create();
        var fechaPago = req.FechaPago.ToString("yyyy-MM-dd");

        // Generar ID de proceso
        var idProcess = await conn.ExecuteScalarAsync<string>("""
            DECLARE @id CHAR(8) = RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR), 8)
            SELECT @id
            """) ?? "00000001";

        // Paso 1: actualizar deuda
        await conn.ExecuteAsync("SP_RT_VAL_DEUDA_ACT",
            new { NRO_INTERNO = req.NroInterno.PadLeft(10, '0'), ID_PROCESS = idProcess, FECHA_PAGO = fechaPago },
            commandType: CommandType.StoredProcedure);

        // Paso 2: registrar pago
        var p = new DynamicParameters();
        p.Add("NRO_INTERNO", req.NroInterno.PadLeft(10, '0'));
        p.Add("ID_PROCESS",  idProcess);
        p.Add("FECHA_PAGO",  fechaPago);
        p.Add("CODERR", dbType: DbType.String, size: 5, direction: ParameterDirection.Output);
        p.Add("MSG",    dbType: DbType.String, size: 255, direction: ParameterDirection.Output);

        await conn.ExecuteAsync("CREA_PAGO_TOTAL", p, commandType: CommandType.StoredProcedure);

        return new CobroResult
        {
            CodErr  = p.Get<string>("CODERR"),
            Mensaje = p.Get<string>("MSG"),
        };
    }

    // ── REFERENCIA ───────────────────────────────────────────────────────

    public async Task<List<TasaActualizacion>> ObtenerTasas()
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<TasaActualizacion>("""
            SELECT RTRIM(INTERES) AS Interes, FECHA, RESAR AS TasaMensual
            FROM RT_ACTUALIZACION
            ORDER BY INTERES, FECHA DESC
            """);
        return result.ToList();
    }

    public async Task<List<ValuacionAutomotor>> ObtenerValuacionAutomotores(string? anoValuacion)
    {
        using var conn = db.Create();
        var where = string.IsNullOrWhiteSpace(anoValuacion) ? "" : "WHERE RTRIM(av.ANO_VALUACION) = @Ano";
        var result = await conn.QueryAsync<ValuacionAutomotor>($"""
            SELECT
                RTRIM(av.ANO_VALUACION)  AS AnoValuacion,
                RTRIM(av.CIP)            AS Cip,
                av.MODELO_VALUACION      AS ModeloValuacion,
                ISNULL(av.BASE_IMPONIBLE,0) AS BaseImponible,
                ISNULL(ta.ALICUOTA,0)    AS Alicuota
            FROM RT_AUTOMOTORES_VALUACION av
            LEFT JOIN RT_AUTOMOTORES_TARIFARIA ta ON RTRIM(ta.ANO_VALUACION) = RTRIM(av.ANO_VALUACION)
            {where}
            ORDER BY av.ANO_VALUACION DESC, av.CIP
            """, new { Ano = anoValuacion });
        return result.ToList();
    }

    public async Task<List<string>> ObtenerAnosValuacion()
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<string>(
            "SELECT DISTINCT RTRIM(ANO_VALUACION) FROM RT_AUTOMOTORES_VALUACION ORDER BY 1 DESC");
        return result.ToList();
    }

    public async Task CrearTasa(TasaActualizacion tasa)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync(
            "INSERT INTO RT_ACTUALIZACION (INTERES, FECHA, RESAR) VALUES (@Interes, @Fecha, @TasaMensual)",
            new { Interes = tasa.Interes.PadRight(1), tasa.Fecha, tasa.TasaMensual });
    }

    public async Task ActualizarTasa(string interes, DateTime fecha, decimal tasaMensual)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync(
            "UPDATE RT_ACTUALIZACION SET RESAR = @Tasa WHERE RTRIM(INTERES) = @Int AND FECHA = @Fecha",
            new { Tasa = tasaMensual, Int = interes.Trim(), Fecha = fecha });
    }

    public async Task EliminarTasa(string interes, DateTime fecha)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync(
            "DELETE FROM RT_ACTUALIZACION WHERE RTRIM(INTERES) = @Int AND FECHA = @Fecha",
            new { Int = interes.Trim(), Fecha = fecha });
    }

    public async Task CrearValuacion(ValuacionAutomotor val)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            INSERT INTO RT_AUTOMOTORES_VALUACION (ANO_VALUACION, CIP, MODELO_VALUACION, BASE_IMPONIBLE)
            VALUES (@Ano, @Cip, @Modelo, @Base)
            """, new { Ano = val.AnoValuacion.PadRight(4), Cip = val.Cip.PadRight(7),
                       Modelo = val.ModeloValuacion, Base = val.BaseImponible });
    }

    public async Task ActualizarValuacion(ValuacionAutomotor val)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE RT_AUTOMOTORES_VALUACION
            SET BASE_IMPONIBLE = @Base
            WHERE RTRIM(ANO_VALUACION) = @Ano AND RTRIM(CIP) = @Cip AND MODELO_VALUACION = @Modelo
            """, new { Base = val.BaseImponible, Ano = val.AnoValuacion.Trim(),
                       Cip = val.Cip.Trim(), Modelo = val.ModeloValuacion });
    }

    public async Task EliminarValuacion(string ano, string cip, int modelo)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            DELETE FROM RT_AUTOMOTORES_VALUACION
            WHERE RTRIM(ANO_VALUACION) = @Ano AND RTRIM(CIP) = @Cip AND MODELO_VALUACION = @Modelo
            """, new { Ano = ano.Trim(), Cip = cip.Trim(), Modelo = modelo });
    }

    // ── PROPIETARIOS INMUEBLE ────────────────────────────────────────────

    public async Task<List<PropietarioInmueble>> ObtenerPropietarios(string idBien)
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<PropietarioInmueble>("""
            SELECT
                RTRIM(rp.ID_BIEN)                       AS IdBien,
                RTRIM(rp.IDENTIFICADOR)                 AS Identificador,
                rp.PORCENTAJE_ACCIONES                  AS PorcentajeAcciones,
                ISNULL(RTRIM(p.APELLIDO),'')            AS Apellido,
                ISNULL(RTRIM(p.NOMBRE),'')              AS Nombre
            FROM RT_PROPIETARIOS rp
            LEFT JOIN PERSONAS p ON RTRIM(p.IDENTIFICADOR) = RTRIM(rp.IDENTIFICADOR)
            WHERE RTRIM(rp.ID_BIEN) = @IdBien
            """, new { IdBien = idBien });
        return result.ToList();
    }

    public async Task AgregarPropietario(string idBien, string identificador, decimal? porcentaje)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            IF NOT EXISTS (
                SELECT 1 FROM RT_PROPIETARIOS
                WHERE RTRIM(ID_BIEN) = @IdBien AND RTRIM(IDENTIFICADOR) = @Ident)
            INSERT INTO RT_PROPIETARIOS (ID_BIEN, IDENTIFICADOR, PORCENTAJE_ACCIONES)
            VALUES (@IdBienPad, @Ident, @Porc)
            """, new { IdBien = idBien, IdBienPad = idBien.PadRight(5), Ident = identificador, Porc = porcentaje });
    }

    public async Task EliminarPropietario(string idBien, string identificador)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            DELETE FROM RT_PROPIETARIOS
            WHERE RTRIM(ID_BIEN) = @IdBien AND RTRIM(IDENTIFICADOR) = @Ident
            """, new { IdBien = idBien, Ident = identificador });
    }

    // ── MEJORAS CATASTRO ─────────────────────────────────────────────────

    public async Task<List<MejoraInmueble>> ObtenerMejoras(string idCatastro)
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<MejoraInmueble>("""
            SELECT
                CLAVE,
                FECHA_MEJORA                                    AS FechaMejora,
                RTRIM(ISNULL(ANO_CONSTRUCCION,''))              AS AnoConstruction,
                RTRIM(ISNULL(ESTADO_CONSTRUCCION,''))           AS EstadoConstruccion,
                ISNULL(SUPERFICIE_CUBIERTA,0)                   AS SuperficieCubierta,
                ISNULL(VALOR_EDIFICADO,0)                       AS ValorEdificado,
                RTRIM(ID_CATASTRO)                              AS IdCatastro,
                RTRIM(ISNULL(CODIGO_CATEGORIA_PUNTAJE,''))      AS CodigoCategoriaPuntaje,
                RTRIM(ISNULL(TIPO_DESTINO_CATASTRO,''))         AS TipoDestinoCatastro,
                RTRIM(ISNULL(TIPO_CONSTRUCCION,''))             AS TipoConstruccion
            FROM RT_CATASTRO_MEJORAS
            WHERE RTRIM(ID_CATASTRO) = @IdCatastro
            ORDER BY CLAVE
            """, new { IdCatastro = idCatastro });
        return result.ToList();
    }

    public async Task<int> AgregarMejora(string idCatastro, AltaMejoraRequest req)
    {
        using var conn = db.Create();
        return await conn.ExecuteScalarAsync<int>("""
            DECLARE @clave INT
            SELECT @clave = ISNULL(MAX(CLAVE),0)+1 FROM RT_CATASTRO_MEJORAS WHERE RTRIM(ID_CATASTRO) = @IdCat
            INSERT INTO RT_CATASTRO_MEJORAS
                (CLAVE, FECHA_MEJORA, ANO_CONSTRUCCION, ESTADO_CONSTRUCCION,
                 SUPERFICIE_CUBIERTA, VALOR_EDIFICADO, ID_CATASTRO,
                 CODIGO_CATEGORIA_PUNTAJE, TIPO_DESTINO_CATASTRO, TIPO_CONSTRUCCION,
                 DATO1, DATO2, DATO3, DATO4)
            VALUES
                (@clave, GETDATE(), @AnoConst, @Estado,
                 @Sup, @Valor, @IdCatPad,
                 @CodCat, @TipoDest, @TipoConst,
                 '','','','')
            SELECT @clave
            """, new {
                IdCat    = idCatastro,
                IdCatPad = idCatastro.PadRight(5),
                AnoConst = (req.AnoConstruction ?? DateTime.Today.Year.ToString()).PadRight(4),
                Estado   = (req.EstadoConstruccion ?? "T").PadLeft(1),
                Sup      = req.SuperficieCubierta,
                Valor    = req.ValorEdificado,
                CodCat   = (req.CodigoCategoriaPuntaje ?? "").PadRight(4),
                TipoDest = (req.TipoDestinoCatastro ?? "").PadRight(8),
                TipoConst= (req.TipoConstruccion ?? "").PadRight(2),
            });
    }

    public async Task EliminarMejora(int clave)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync(
            "DELETE FROM RT_CATASTRO_MEJORAS WHERE CLAVE = @Clave", new { Clave = clave });
    }

    // ── VARIABLES PARAMÉTRICAS ────────────────────────────────────────────

    public async Task<List<VariablePadron>> ObtenerVariables(string idBien)
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<VariablePadron>("""
            SELECT
                RTRIM(pbv.CODIGO_VARIOS)                AS CodigoVarios,
                ISNULL(RTRIM(rv.CONCEPTO),'')           AS Concepto,
                pbv.MONTO                               AS Monto,
                RTRIM(ISNULL(pbv.ESTADO_VARIOS,''))     AS Estado,
                RTRIM(ISNULL(pbv.TIPO_VARIOS,''))       AS TipoVarios
            FROM RT_PADRON_BASE_VARIOS pbv
            LEFT JOIN RT_VARIOS rv ON RTRIM(rv.CODIGO_VARIOS) = RTRIM(pbv.CODIGO_VARIOS)
            WHERE RTRIM(pbv.ID_BIEN) = @IdBien
              AND (pbv.FECHA_VARIOS_HASTA IS NULL OR pbv.FECHA_VARIOS_HASTA > GETDATE())
            ORDER BY pbv.CODIGO_VARIOS
            """, new { IdBien = idBien });
        return result.ToList();
    }
}
