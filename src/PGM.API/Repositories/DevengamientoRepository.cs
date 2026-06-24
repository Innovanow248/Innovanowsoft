using Dapper;
using PGM.API.Models;

namespace PGM.API.Repositories;

public class DevengamientoRepository(DbConnectionFactory db) : IDevengamientoRepository
{
    // ── Catálogos ───────────────────────────────────────────────────────────────

    public async Task<List<TipoTributo>> ListarTributos()
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<TipoTributo>("""
            SELECT
                ID_TIPO_TIBUTO       AS IdTipoTributo,
                TIPO_TRIBUTO         AS TipoTributo_,
                CONCEPTO             AS Concepto,
                CONCEPTO_ABREVIADO   AS ConceptoAbreviado
            FROM DEV_TIPOS_TRIBUTOS
            WHERE FEC_BAJA IS NULL
            ORDER BY TIPO_TRIBUTO
            """);
        return result.ToList();
    }

    public async Task<List<ZonaInmueble>> ListarZonas()
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<ZonaInmueble>("""
            SELECT
                ID_ZONAS           AS IdZonas,
                CONCEPTO           AS Concepto,
                CONCEPTO_ABREVIADO AS ConceptoAbreviado
            FROM DEV_INMUEBLES_ZONAS
            WHERE FEC_BAJA IS NULL
            ORDER BY CONCEPTO
            """);
        return result.ToList();
    }

    // ── Conceptos ───────────────────────────────────────────────────────────────

    public async Task<List<ConceptoDevengamiento>> ListarConceptos(int? idTipoTributo, string? busqueda)
    {
        using var conn = db.Create();
        var where = "WHERE c.FEC_BAJA IS NULL";
        if (idTipoTributo.HasValue) where += " AND c.ID_TIPO_TRIBUTO = @IdTipoTributo";
        if (!string.IsNullOrWhiteSpace(busqueda))
            where += " AND (c.CONCEPTO LIKE @B OR c.DESCRIPCION LIKE @B)";

        var result = await conn.QueryAsync<ConceptoDevengamiento>($"""
            SELECT
                c.ID_TIPO_CONCEPTO    AS IdTipoConcepto,
                c.ID_TIPO_TRIBUTO     AS IdTipoTributo,
                c.CONCEPTO            AS Concepto,
                c.DESCRIPCION         AS Descripcion,
                c.IMPACTO             AS Impacto,
                c.PORCENTAJE          AS Porcentaje,
                c.VALOR               AS Valor,
                c.OBJETO_REF          AS ObjetoRef,
                c.ORDEN               AS Orden,
                c.TIPO_CUOTA          AS TipoCuota,
                c.MASIVO              AS Masivo,
                c.ID_TIPO_TRIBUTO_AUX AS IdTipoTributoAux,
                c.USR_ING             AS UsrIng,
                c.FEC_ING             AS FecIng,
                c.USR_MOD             AS UsrMod,
                c.FEC_MOD             AS FecMod,
                c.USR_BAJA            AS UsrBaja,
                c.FEC_BAJA            AS FecBaja
            FROM DEV_TIPOS_CONCEPTOS c
            {where}
            ORDER BY c.ORDEN, c.CONCEPTO
            """, new { IdTipoTributo = idTipoTributo, B = $"%{busqueda}%" });

        return result.ToList();
    }

    public async Task<ConceptoDevengamiento?> ObtenerConcepto(int id)
    {
        using var conn = db.Create();
        var concepto = await conn.QueryFirstOrDefaultAsync<ConceptoDevengamiento>("""
            SELECT
                ID_TIPO_CONCEPTO    AS IdTipoConcepto,
                ID_TIPO_TRIBUTO     AS IdTipoTributo,
                CONCEPTO            AS Concepto,
                DESCRIPCION         AS Descripcion,
                IMPACTO             AS Impacto,
                PORCENTAJE          AS Porcentaje,
                VALOR               AS Valor,
                OBJETO_REF          AS ObjetoRef,
                ORDEN               AS Orden,
                TIPO_CUOTA          AS TipoCuota,
                MASIVO              AS Masivo,
                ID_TIPO_TRIBUTO_AUX AS IdTipoTributoAux,
                USR_ING             AS UsrIng,
                FEC_ING             AS FecIng,
                USR_MOD             AS UsrMod,
                FEC_MOD             AS FecMod,
                USR_BAJA            AS UsrBaja,
                FEC_BAJA            AS FecBaja
            FROM DEV_TIPOS_CONCEPTOS
            WHERE ID_TIPO_CONCEPTO = @Id
            """, new { Id = id });

        if (concepto is null) return null;

        var anios = await conn.QueryAsync<ConceptoAnio>("""
            SELECT
                ID_TIPOCON_ANIO  AS IdTipoconAnio,
                ID_TIPO_CONCEPTO AS IdTipoConcepto,
                ANIO_EJERCICIO   AS AnioEjercicio,
                PORCENTAJE       AS Porcentaje,
                VALOR            AS Valor,
                USR_ING          AS UsrIng,
                FEC_ING          AS FecIng,
                USR_MOD          AS UsrMod,
                FEC_MOD          AS FecMod,
                USR_BAJA         AS UsrBaja,
                FEC_BAJA         AS FecBaja
            FROM DEV_TIPOS_CONCEPTOS_ANIO
            WHERE ID_TIPO_CONCEPTO = @Id AND FEC_BAJA IS NULL
            ORDER BY ANIO_EJERCICIO DESC
            """, new { Id = id });

        concepto.Anios = anios.ToList();
        return concepto;
    }

    public async Task<int> CrearConcepto(CrearConceptoRequest req)
    {
        using var conn = db.Create();
        var nuevoId = await conn.ExecuteScalarAsync<int>("""
            SELECT ISNULL(MAX(ID_TIPO_CONCEPTO), 0) + 1 FROM DEV_TIPOS_CONCEPTOS
            """);
        await conn.ExecuteAsync("""
            INSERT INTO DEV_TIPOS_CONCEPTOS
                (ID_TIPO_CONCEPTO, ID_TIPO_TRIBUTO, CONCEPTO, DESCRIPCION,
                 IMPACTO, PORCENTAJE, VALOR, OBJETO_REF, ORDEN, TIPO_CUOTA, MASIVO,
                 ID_TIPO_TRIBUTO_AUX, USR_ING, FEC_ING)
            VALUES
                (@Id, @IdTipoTributo, @Concepto, @Descripcion,
                 @Impacto, @Porcentaje, @Valor, @ObjetoRef, @Orden, @TipoCuota, @Masivo,
                 @IdTipoTributoAux, @Usuario, GETDATE())
            """, new
        {
            Id              = nuevoId,
            req.IdTipoTributo,
            req.Concepto,
            req.Descripcion,
            req.Impacto,
            req.Porcentaje,
            req.Valor,
            req.ObjetoRef,
            req.Orden,
            req.TipoCuota,
            req.Masivo,
            req.IdTipoTributoAux,
            req.Usuario,
        });
        return nuevoId;
    }

    public async Task ActualizarConcepto(int id, ActualizarConceptoRequest req)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_TIPOS_CONCEPTOS SET
                ID_TIPO_TRIBUTO     = @IdTipoTributo,
                CONCEPTO            = @Concepto,
                DESCRIPCION         = @Descripcion,
                IMPACTO             = @Impacto,
                PORCENTAJE          = @Porcentaje,
                VALOR               = @Valor,
                OBJETO_REF          = @ObjetoRef,
                ORDEN               = @Orden,
                TIPO_CUOTA          = @TipoCuota,
                MASIVO              = @Masivo,
                ID_TIPO_TRIBUTO_AUX = @IdTipoTributoAux,
                USR_MOD             = @Usuario,
                FEC_MOD             = GETDATE()
            WHERE ID_TIPO_CONCEPTO = @Id
            """, new
        {
            Id = id,
            req.IdTipoTributo,
            req.Concepto,
            req.Descripcion,
            req.Impacto,
            req.Porcentaje,
            req.Valor,
            req.ObjetoRef,
            req.Orden,
            req.TipoCuota,
            req.Masivo,
            req.IdTipoTributoAux,
            req.Usuario,
        });
    }

    public async Task EliminarConcepto(int id, string usuario)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_TIPOS_CONCEPTOS
            SET USR_BAJA = @Usuario, FEC_BAJA = GETDATE()
            WHERE ID_TIPO_CONCEPTO = @Id
            """, new { Id = id, Usuario = usuario });
    }

    // ── Conceptos por año ───────────────────────────────────────────────────────

    public async Task<List<ConceptoAnio>> ListarConceptoAnios(int idConcepto)
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<ConceptoAnio>("""
            SELECT
                ID_TIPOCON_ANIO  AS IdTipoconAnio,
                ID_TIPO_CONCEPTO AS IdTipoConcepto,
                ANIO_EJERCICIO   AS AnioEjercicio,
                PORCENTAJE       AS Porcentaje,
                VALOR            AS Valor,
                USR_ING          AS UsrIng,
                FEC_ING          AS FecIng,
                USR_MOD          AS UsrMod,
                FEC_MOD          AS FecMod,
                USR_BAJA         AS UsrBaja,
                FEC_BAJA         AS FecBaja
            FROM DEV_TIPOS_CONCEPTOS_ANIO
            WHERE ID_TIPO_CONCEPTO = @Id AND FEC_BAJA IS NULL
            ORDER BY ANIO_EJERCICIO DESC
            """, new { Id = idConcepto });
        return result.ToList();
    }

    public async Task<int> CrearConceptoAnio(int idConcepto, CrearConceptoAnioRequest req)
    {
        using var conn = db.Create();
        var nuevoId = await conn.ExecuteScalarAsync<int>("""
            SELECT ISNULL(MAX(ID_TIPOCON_ANIO), 0) + 1 FROM DEV_TIPOS_CONCEPTOS_ANIO
            """);
        await conn.ExecuteAsync("""
            INSERT INTO DEV_TIPOS_CONCEPTOS_ANIO
                (ID_TIPOCON_ANIO, ID_TIPO_CONCEPTO, ANIO_EJERCICIO, PORCENTAJE, VALOR, USR_ING, FEC_ING)
            VALUES
                (@Id, @IdConcepto, @Anio, @Porcentaje, @Valor, @Usuario, GETDATE())
            """, new
        {
            Id         = nuevoId,
            IdConcepto = idConcepto,
            Anio       = req.AnioEjercicio,
            req.Porcentaje,
            req.Valor,
            req.Usuario,
        });
        return nuevoId;
    }

    public async Task ActualizarConceptoAnio(int id, ActualizarConceptoAnioRequest req)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_TIPOS_CONCEPTOS_ANIO SET
                ANIO_EJERCICIO = @Anio,
                PORCENTAJE     = @Porcentaje,
                VALOR          = @Valor,
                USR_MOD        = @Usuario,
                FEC_MOD        = GETDATE()
            WHERE ID_TIPOCON_ANIO = @Id
            """, new { Id = id, Anio = req.AnioEjercicio, req.Porcentaje, req.Valor, req.Usuario });
    }

    public async Task EliminarConceptoAnio(int id, string usuario)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_TIPOS_CONCEPTOS_ANIO
            SET USR_BAJA = @Usuario, FEC_BAJA = GETDATE()
            WHERE ID_TIPOCON_ANIO = @Id
            """, new { Id = id, Usuario = usuario });
    }

    // ── Vencimientos ────────────────────────────────────────────────────────────

    public async Task<List<Vencimiento>> ListarVencimientos(int? idTipoTributo, string? ejercicio)
    {
        using var conn = db.Create();
        var where = "WHERE USR_BAJA IS NULL";
        if (idTipoTributo.HasValue) where += " AND ID_TIPO_TRIBUTO = @IdTipoTributo";
        if (!string.IsNullOrWhiteSpace(ejercicio)) where += " AND EJERCICIO = @Ejercicio";

        var result = await conn.QueryAsync<Vencimiento>($"""
            SELECT
                ID_VENCIMIENTOS   AS IdVencimientos,
                ID_TIPO_TRIBUTO   AS IdTipoTributo,
                NRO_CUOTA         AS NroCuota,
                EJERCICIO         AS Ejercicio,
                N_TIPO            AS NTipo,
                N_ZONA            AS NZona,
                FECHA_PRIMER_VTO  AS FechaPrimerVto,
                FECHA_SEGUNDO_VTO AS FechaSegundoVto,
                FECHA_TERCER_VTO  AS FechaTercerVto,
                DESC_PRIMER_VTO   AS DescPrimerVto,
                DESC_SEGUNDO_VTO  AS DescSegundoVto,
                DESC_TERCER_VTO   AS DescTercerVto,
                ID_OBSA_MODALIDAD AS IdObsaModalidad,
                USR_ING           AS UsrIng,
                FEC_ING           AS FecIng,
                USR_MOD           AS UsrMod,
                FEC_MOD           AS FecMod,
                USR_BAJA          AS UsrBaja,
                FEC_BAJA          AS FecBaja
            FROM DEV_VENCIMIENTOS
            {where}
            ORDER BY EJERCICIO DESC, ID_TIPO_TRIBUTO, NRO_CUOTA
            """, new { IdTipoTributo = idTipoTributo, Ejercicio = ejercicio });

        return result.ToList();
    }

    public async Task<Vencimiento?> ObtenerVencimiento(int id)
    {
        using var conn = db.Create();
        return await conn.QueryFirstOrDefaultAsync<Vencimiento>("""
            SELECT
                ID_VENCIMIENTOS   AS IdVencimientos,
                ID_TIPO_TRIBUTO   AS IdTipoTributo,
                NRO_CUOTA         AS NroCuota,
                EJERCICIO         AS Ejercicio,
                N_TIPO            AS NTipo,
                N_ZONA            AS NZona,
                FECHA_PRIMER_VTO  AS FechaPrimerVto,
                FECHA_SEGUNDO_VTO AS FechaSegundoVto,
                FECHA_TERCER_VTO  AS FechaTercerVto,
                DESC_PRIMER_VTO   AS DescPrimerVto,
                DESC_SEGUNDO_VTO  AS DescSegundoVto,
                DESC_TERCER_VTO   AS DescTercerVto,
                ID_OBSA_MODALIDAD AS IdObsaModalidad,
                USR_ING           AS UsrIng,
                FEC_ING           AS FecIng,
                USR_MOD           AS UsrMod,
                FEC_MOD           AS FecMod,
                USR_BAJA          AS UsrBaja,
                FEC_BAJA          AS FecBaja
            FROM DEV_VENCIMIENTOS
            WHERE ID_VENCIMIENTOS = @Id
            """, new { Id = id });
    }

    public async Task<int> CrearVencimiento(CrearVencimientoRequest req)
    {
        using var conn = db.Create();
        var nuevoId = await conn.ExecuteScalarAsync<int>("""
            SELECT ISNULL(MAX(ID_VENCIMIENTOS), 0) + 1 FROM DEV_VENCIMIENTOS
            """);
        var ahora = DateTime.Now.ToString("dd/MM/yyyy HH:mm");
        await conn.ExecuteAsync("""
            INSERT INTO DEV_VENCIMIENTOS
                (ID_VENCIMIENTOS, ID_TIPO_TRIBUTO, NRO_CUOTA, EJERCICIO, N_TIPO, N_ZONA,
                 FECHA_PRIMER_VTO, FECHA_SEGUNDO_VTO, FECHA_TERCER_VTO,
                 DESC_PRIMER_VTO, DESC_SEGUNDO_VTO, DESC_TERCER_VTO,
                 ID_OBSA_MODALIDAD, USR_ING, FEC_ING)
            VALUES
                (@Id, @IdTipoTributo, @NroCuota, @Ejercicio, @NTipo, @NZona,
                 @FechaPrimerVto, @FechaSegundoVto, @FechaTercerVto,
                 @DescPrimerVto, @DescSegundoVto, @DescTercerVto,
                 @IdObsaModalidad, @Usuario, @FecIng)
            """, new
        {
            Id = nuevoId,
            req.IdTipoTributo,
            req.NroCuota,
            req.Ejercicio,
            req.NTipo,
            req.NZona,
            req.FechaPrimerVto,
            req.FechaSegundoVto,
            req.FechaTercerVto,
            req.DescPrimerVto,
            req.DescSegundoVto,
            req.DescTercerVto,
            req.IdObsaModalidad,
            req.Usuario,
            FecIng = ahora,
        });
        return nuevoId;
    }

    public async Task ActualizarVencimiento(int id, ActualizarVencimientoRequest req)
    {
        using var conn = db.Create();
        var ahora = DateTime.Now.ToString("dd/MM/yyyy HH:mm");
        await conn.ExecuteAsync("""
            UPDATE DEV_VENCIMIENTOS SET
                ID_TIPO_TRIBUTO   = @IdTipoTributo,
                NRO_CUOTA         = @NroCuota,
                EJERCICIO         = @Ejercicio,
                N_TIPO            = @NTipo,
                N_ZONA            = @NZona,
                FECHA_PRIMER_VTO  = @FechaPrimerVto,
                FECHA_SEGUNDO_VTO = @FechaSegundoVto,
                FECHA_TERCER_VTO  = @FechaTercerVto,
                DESC_PRIMER_VTO   = @DescPrimerVto,
                DESC_SEGUNDO_VTO  = @DescSegundoVto,
                DESC_TERCER_VTO   = @DescTercerVto,
                ID_OBSA_MODALIDAD = @IdObsaModalidad,
                USR_MOD           = @Usuario,
                FEC_MOD           = @FecMod
            WHERE ID_VENCIMIENTOS = @Id
            """, new
        {
            Id = id,
            req.IdTipoTributo,
            req.NroCuota,
            req.Ejercicio,
            req.NTipo,
            req.NZona,
            req.FechaPrimerVto,
            req.FechaSegundoVto,
            req.FechaTercerVto,
            req.DescPrimerVto,
            req.DescSegundoVto,
            req.DescTercerVto,
            req.IdObsaModalidad,
            req.Usuario,
            FecMod = ahora,
        });
    }

    public async Task EliminarVencimiento(int id, string usuario)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_VENCIMIENTOS
            SET USR_BAJA = @Usuario, FEC_BAJA = GETDATE()
            WHERE ID_VENCIMIENTOS = @Id
            """, new { Id = id, Usuario = usuario });
    }

    // ── Planes de pago ──────────────────────────────────────────────────────────

    public async Task<List<TipoPlanPago>> ListarPlanes(string? busqueda)
    {
        using var conn = db.Create();
        var where = "WHERE USR_BAJA IS NULL";
        if (!string.IsNullOrWhiteSpace(busqueda))
            where += " AND (CODIGO_PLAN LIKE @B OR DESIGNACION_PLAN LIKE @B)";

        var result = await conn.QueryAsync<TipoPlanPago>($"""
            SELECT
                ID_TIPO_PLANESPAGO       AS IdTipoPlanespago,
                CODIGO_PLAN              AS CodigoPlan,
                DESIGNACION_PLAN         AS DesignacionPlan,
                DECRETO_RESOLUCION       AS DecretoResolucion,
                SOLO_USO_DEVENGAMIENTO   AS SoloUsoDevengamiento,
                OBSERVACIONES            AS Observaciones,
                CANTIDAD_CUOTAS          AS CantidadCuotas,
                DIA_PRIMER_VENCIMIENTO   AS DiaPrimerVencimiento,
                ACTUALIZABLE             AS Actualizable,
                PERIODO                  AS Periodo,
                USR_ING                  AS UsrIng,
                FEC_ING                  AS FecIng,
                USR_MOD                  AS UsrMod,
                FEC_MOD                  AS FecMod,
                USR_BAJA                 AS UsrBaja,
                FEC_BAJA                 AS FecBaja
            FROM DEV_TIPOS_PLANESPAGO
            {where}
            ORDER BY CODIGO_PLAN
            """, new { B = $"%{busqueda}%" });

        return result.ToList();
    }

    public async Task<TipoPlanPago?> ObtenerPlan(int id)
    {
        using var conn = db.Create();
        var plan = await conn.QueryFirstOrDefaultAsync<TipoPlanPago>("""
            SELECT
                ID_TIPO_PLANESPAGO       AS IdTipoPlanespago,
                CODIGO_PLAN              AS CodigoPlan,
                DESIGNACION_PLAN         AS DesignacionPlan,
                DECRETO_RESOLUCION       AS DecretoResolucion,
                SOLO_USO_DEVENGAMIENTO   AS SoloUsoDevengamiento,
                OBSERVACIONES            AS Observaciones,
                CANTIDAD_CUOTAS          AS CantidadCuotas,
                DIA_PRIMER_VENCIMIENTO   AS DiaPrimerVencimiento,
                ACTUALIZABLE             AS Actualizable,
                PERIODO                  AS Periodo,
                USR_ING                  AS UsrIng,
                FEC_ING                  AS FecIng,
                USR_MOD                  AS UsrMod,
                FEC_MOD                  AS FecMod,
                USR_BAJA                 AS UsrBaja,
                FEC_BAJA                 AS FecBaja
            FROM DEV_TIPOS_PLANESPAGO
            WHERE ID_TIPO_PLANESPAGO = @Id
            """, new { Id = id });

        if (plan is null) return null;
        plan.Detalles = await ListarDetallesPlan(id);
        return plan;
    }

    public async Task<int> CrearPlan(CrearPlanPagoRequest req)
    {
        using var conn = db.Create();
        var nuevoId = await conn.ExecuteScalarAsync<int>("""
            SELECT ISNULL(MAX(ID_TIPO_PLANESPAGO), 0) + 1 FROM DEV_TIPOS_PLANESPAGO
            """);
        await conn.ExecuteAsync("""
            INSERT INTO DEV_TIPOS_PLANESPAGO
                (ID_TIPO_PLANESPAGO, CODIGO_PLAN, DESIGNACION_PLAN, DECRETO_RESOLUCION,
                 SOLO_USO_DEVENGAMIENTO, OBSERVACIONES, CANTIDAD_CUOTAS,
                 DIA_PRIMER_VENCIMIENTO, ACTUALIZABLE, PERIODO, USR_ING, FEC_ING)
            VALUES
                (@Id, @CodigoPlan, @DesignacionPlan, @DecretoResolucion,
                 @SoloUsoDevengamiento, @Observaciones, @CantidadCuotas,
                 @DiaPrimerVencimiento, @Actualizable, @Periodo, @Usuario, GETDATE())
            """, new
        {
            Id = nuevoId,
            req.CodigoPlan,
            req.DesignacionPlan,
            req.DecretoResolucion,
            req.SoloUsoDevengamiento,
            req.Observaciones,
            req.CantidadCuotas,
            req.DiaPrimerVencimiento,
            req.Actualizable,
            req.Periodo,
            req.Usuario,
        });
        return nuevoId;
    }

    public async Task ActualizarPlan(int id, ActualizarPlanPagoRequest req)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_TIPOS_PLANESPAGO SET
                CODIGO_PLAN            = @CodigoPlan,
                DESIGNACION_PLAN       = @DesignacionPlan,
                DECRETO_RESOLUCION     = @DecretoResolucion,
                SOLO_USO_DEVENGAMIENTO = @SoloUsoDevengamiento,
                OBSERVACIONES          = @Observaciones,
                CANTIDAD_CUOTAS        = @CantidadCuotas,
                DIA_PRIMER_VENCIMIENTO = @DiaPrimerVencimiento,
                ACTUALIZABLE           = @Actualizable,
                PERIODO                = @Periodo,
                USR_MOD                = @Usuario,
                FEC_MOD                = GETDATE()
            WHERE ID_TIPO_PLANESPAGO = @Id
            """, new
        {
            Id = id,
            req.CodigoPlan,
            req.DesignacionPlan,
            req.DecretoResolucion,
            req.SoloUsoDevengamiento,
            req.Observaciones,
            req.CantidadCuotas,
            req.DiaPrimerVencimiento,
            req.Actualizable,
            req.Periodo,
            req.Usuario,
        });
    }

    public async Task EliminarPlan(int id, string usuario)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_TIPOS_PLANESPAGO
            SET USR_BAJA = @Usuario, FEC_BAJA = GETDATE()
            WHERE ID_TIPO_PLANESPAGO = @Id
            """, new { Id = id, Usuario = usuario });
    }

    // ── Detalles de plan ────────────────────────────────────────────────────────

    public async Task<List<TipoPlanPagoDetalle>> ListarDetallesPlan(int idPlan)
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<TipoPlanPagoDetalle>("""
            SELECT
                ID_PLANESAGO_DET            AS IdPlanesagoDet,
                ID_TIPO_PLANESPAGO          AS IdTipoPlanespago,
                CANTIDAD_CUOTAS             AS CantidadCuotas,
                FECHA_DEUDA_DESDE           AS FechaDeudaDesde,
                FECHA_DEUDA_HASTA           AS FechaDeudaHasta,
                MONTO_MINIMO_DEUDA          AS MontoMinDeuda,
                MONTO_MAXIMO_DEUDA          AS MontoMaxDeuda,
                CANTIDAD_MINIMA_CUOTAS      AS CantMinCuotas,
                CANTIDAD_MAXIMA_CUOTAS      AS CantMaxCuotas,
                MONTO_MINIMO_CUOTA          AS MontoMinCuota,
                ANTICIPO_MINIMO_PORCENTAJE  AS AnticipoMinPorcentaje,
                ANTICIPO_MINIMO_MONTO       AS AnticipoMinMonto,
                FECHA_VIGENTE_DESDE         AS FechaVigenteDesde,
                FECHA_VIGENTE_HASTA         AS FechaVigenteHasta,
                CANTIDAD_CUOTAS_SININTERES  AS CantCuotasSinInteres,
                INTERES_FINANCIACION        AS InteresFinanciacion,
                DIA_SEGUNDO_VENCIMIENTO     AS DiaSegundoVencimiento,
                DIA_TERCER_VENCIMIENTO      AS DiaTercerVencimiento,
                USR_BAJA                    AS UsrBaja,
                FEC_BAJA                    AS FecBaja
            FROM DEV_TIPOS_PLANESPAGO_DET
            WHERE ID_TIPO_PLANESPAGO = @IdPlan AND FEC_BAJA IS NULL
            ORDER BY ID_PLANESAGO_DET
            """, new { IdPlan = idPlan });
        return result.ToList();
    }

    public async Task<int> CrearDetallePlan(int idPlan, CrearPlanDetalleRequest req)
    {
        using var conn = db.Create();
        var nuevoId = await conn.ExecuteScalarAsync<int>("""
            SELECT ISNULL(MAX(ID_PLANESAGO_DET), 0) + 1 FROM DEV_TIPOS_PLANESPAGO_DET
            """);
        await conn.ExecuteAsync("""
            INSERT INTO DEV_TIPOS_PLANESPAGO_DET
                (ID_PLANESAGO_DET, ID_TIPO_PLANESPAGO, CANTIDAD_CUOTAS,
                 FECHA_DEUDA_DESDE, FECHA_DEUDA_HASTA, MONTO_MINIMO_DEUDA, MONTO_MAXIMO_DEUDA,
                 CANTIDAD_MINIMA_CUOTAS, CANTIDAD_MAXIMA_CUOTAS, MONTO_MINIMO_CUOTA,
                 ANTICIPO_MINIMO_PORCENTAJE, ANTICIPO_MINIMO_MONTO,
                 FECHA_VIGENTE_DESDE, FECHA_VIGENTE_HASTA,
                 CANTIDAD_CUOTAS_SININTERES, INTERES_FINANCIACION,
                 DIA_SEGUNDO_VENCIMIENTO, DIA_TERCER_VENCIMIENTO,
                 ID_JURISDICCION, USR_ING, FEC_ING)
            VALUES
                (@Id, @IdPlan, @CantidadCuotas,
                 @FechaDeudaDesde, @FechaDeudaHasta, @MontoMinDeuda, @MontoMaxDeuda,
                 @CantMinCuotas, @CantMaxCuotas, @MontoMinCuota,
                 @AnticipoMinPorcentaje, @AnticipoMinMonto,
                 @FechaVigenteDesde, @FechaVigenteHasta,
                 @CantCuotasSinInteres, @InteresFinanciacion,
                 @DiaSegundoVencimiento, @DiaTercerVencimiento,
                 1, @Usuario, GETDATE())
            """, new
        {
            Id     = nuevoId,
            IdPlan = idPlan,
            req.CantidadCuotas,
            req.FechaDeudaDesde,
            req.FechaDeudaHasta,
            req.MontoMinDeuda,
            req.MontoMaxDeuda,
            req.CantMinCuotas,
            req.CantMaxCuotas,
            req.MontoMinCuota,
            req.AnticipoMinPorcentaje,
            req.AnticipoMinMonto,
            req.FechaVigenteDesde,
            req.FechaVigenteHasta,
            req.CantCuotasSinInteres,
            req.InteresFinanciacion,
            req.DiaSegundoVencimiento,
            req.DiaTercerVencimiento,
            req.Usuario,
        });
        return nuevoId;
    }

    public async Task EliminarDetallePlan(int id, string usuario)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_TIPOS_PLANESPAGO_DET
            SET USR_BAJA = @Usuario, FEC_BAJA = GETDATE()
            WHERE ID_PLANESAGO_DET = @Id
            """, new { Id = id, Usuario = usuario });
    }

    // ── OBSA Modalidades ────────────────────────────────────────────────────────

    public async Task<List<ObsaModalidad>> ListarObsaModalidades()
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<ObsaModalidad>("""
            SELECT ID_OBSA_MODALIDAD AS IdObsaModalidad,
                   DESCRIPCION       AS Descripcion
            FROM DEV_OBSA_MODALIDAD
            WHERE FEC_BAJA IS NULL
            ORDER BY DESCRIPCION
            """);
        return result.ToList();
    }

    // ── Intereses ───────────────────────────────────────────────────────────────

    public async Task<List<ConfigInteres>> ListarIntereses(int? idTipoTributo)
    {
        using var conn = db.Create();
        var where = "WHERE FEC_BAJA IS NULL";
        if (idTipoTributo.HasValue) where += " AND ID_TIPO_TRIBUTO = @IdTipoTributo";

        var result = await conn.QueryAsync<ConfigInteres>($"""
            SELECT
                ID_CONFIGURACION  AS IdConfiguracion,
                ID_TIPO_TRIBUTO   AS IdTipoTributo,
                PORCENTUAL        AS Porcentual,
                OBSERVACION       AS Observacion,
                FECHA_DESDE       AS FechaDesde,
                FECHA_HASTA       AS FechaHasta,
                ID_JURISDICCION   AS IdJurisdiccion,
                USR_ING           AS UsrIng,
                FEC_ING           AS FecIng,
                USR_MOD           AS UsrMod,
                FEC_MOD           AS FecMod,
                USR_BAJA          AS UsrBaja,
                FEC_BAJA          AS FecBaja
            FROM DEV_CONFIG_INTERESES
            {where}
            ORDER BY ID_TIPO_TRIBUTO, FECHA_DESDE DESC
            """, new { IdTipoTributo = idTipoTributo });

        return result.ToList();
    }

    public async Task<ConfigInteres?> ObtenerInteres(int id)
    {
        using var conn = db.Create();
        return await conn.QueryFirstOrDefaultAsync<ConfigInteres>("""
            SELECT
                ID_CONFIGURACION  AS IdConfiguracion,
                ID_TIPO_TRIBUTO   AS IdTipoTributo,
                PORCENTUAL        AS Porcentual,
                OBSERVACION       AS Observacion,
                FECHA_DESDE       AS FechaDesde,
                FECHA_HASTA       AS FechaHasta,
                ID_JURISDICCION   AS IdJurisdiccion,
                USR_ING           AS UsrIng,
                FEC_ING           AS FecIng,
                USR_MOD           AS UsrMod,
                FEC_MOD           AS FecMod,
                USR_BAJA          AS UsrBaja,
                FEC_BAJA          AS FecBaja
            FROM DEV_CONFIG_INTERESES
            WHERE ID_CONFIGURACION = @Id
            """, new { Id = id });
    }

    public async Task<int> CrearInteres(CrearInteresRequest req)
    {
        using var conn = db.Create();
        var nuevoId = await conn.ExecuteScalarAsync<int>("""
            INSERT INTO DEV_CONFIG_INTERESES
                (ID_TIPO_TRIBUTO, PORCENTUAL, OBSERVACION, FECHA_DESDE, FECHA_HASTA,
                 ID_JURISDICCION, USR_ING, FEC_ING)
            OUTPUT INSERTED.ID_CONFIGURACION
            VALUES
                (@IdTipoTributo, @Porcentual, @Observacion, @FechaDesde, @FechaHasta,
                 @IdJurisdiccion, @Usuario, GETDATE())
            """, new
        {
            req.IdTipoTributo,
            req.Porcentual,
            req.Observacion,
            req.FechaDesde,
            req.FechaHasta,
            req.IdJurisdiccion,
            req.Usuario,
        });
        return nuevoId;
    }

    public async Task ActualizarInteres(int id, ActualizarInteresRequest req)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_CONFIG_INTERESES SET
                PORCENTUAL  = @Porcentual,
                OBSERVACION = @Observacion,
                FECHA_DESDE = @FechaDesde,
                FECHA_HASTA = @FechaHasta,
                USR_MOD     = @Usuario,
                FEC_MOD     = GETDATE()
            WHERE ID_CONFIGURACION = @Id
            """, new
        {
            Id = id,
            req.Porcentual,
            req.Observacion,
            req.FechaDesde,
            req.FechaHasta,
            req.Usuario,
        });
    }

    public async Task EliminarInteres(int id, string usuario)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_CONFIG_INTERESES
            SET USR_BAJA = @Usuario, FEC_BAJA = GETDATE()
            WHERE ID_CONFIGURACION = @Id
            """, new { Id = id, Usuario = usuario });
    }

    // ── Parametrica Tributos ────────────────────────────────────────────────────

    public async Task<List<ParametricaTributo>> ListarParametricaTributos()
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<ParametricaTributo>("""
            SELECT
                p.ID_PARAM_TRIB     AS IdParamTrib,
                p.ID_TIPO_TRIBUTO   AS IdTipoTributo,
                t.CONCEPTO          AS Concepto,
                t.TIPO_TRIBUTO      AS TipoTributo_,
                p.ID_JURISDICCION   AS IdJurisdiccion,
                p.ACTIVO            AS Activo,
                p.MASIVO            AS Masivo,
                p.DECLARATIVO       AS Declarativo,
                p.USR_ING           AS UsrIng,
                p.FEC_ING           AS FecIng,
                p.USR_BAJA          AS UsrBaja,
                p.FEC_BAJA          AS FecBaja
            FROM DEV_PARAMETRICA_TRIBUTO p
            LEFT JOIN DEV_TIPOS_TRIBUTOS t ON t.ID_TIPO_TIBUTO = p.ID_TIPO_TRIBUTO
            WHERE p.FEC_BAJA IS NULL
            ORDER BY t.TIPO_TRIBUTO
            """);
        return result.ToList();
    }

    public async Task<int> CrearParametricaTributo(CrearParametricaRequest req)
    {
        using var conn = db.Create();
        var nuevoId = await conn.ExecuteScalarAsync<int>("""
            SELECT ISNULL(MAX(ID_PARAM_TRIB), 0) + 1 FROM DEV_PARAMETRICA_TRIBUTO
            """);
        await conn.ExecuteAsync("""
            INSERT INTO DEV_PARAMETRICA_TRIBUTO
                (ID_PARAM_TRIB, ID_TIPO_TRIBUTO, ID_JURISDICCION, ACTIVO,
                 MASIVO, DECLARATIVO, USR_ING, FEC_ING)
            VALUES
                (@Id, @IdTipoTributo, @IdJurisdiccion, 1,
                 @Masivo, @Declarativo, @Usuario, GETDATE())
            """, new
        {
            Id = nuevoId,
            req.IdTipoTributo,
            req.IdJurisdiccion,
            req.Masivo,
            req.Declarativo,
            req.Usuario,
        });
        return nuevoId;
    }

    public async Task EliminarParametricaTributo(int id, string usuario)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_PARAMETRICA_TRIBUTO
            SET USR_BAJA = @Usuario, FEC_BAJA = GETDATE(), ACTIVO = 0
            WHERE ID_PARAM_TRIB = @Id
            """, new { Id = id, Usuario = usuario });
    }

    // ── Vinculación Conceptos ───────────────────────────────────────────────────

    public async Task<List<ConceptoVencimiento>> ListarConceptosVencimientos(int? idTipoTributo, string? ejercicio)
    {
        using var conn = db.Create();
        var where = "WHERE cv.FEC_BAJA IS NULL";
        if (idTipoTributo.HasValue) where += " AND v.ID_TIPO_TRIBUTO = @IdTipoTributo";
        if (!string.IsNullOrWhiteSpace(ejercicio)) where += " AND v.EJERCICIO = @Ejercicio";

        var result = await conn.QueryAsync<ConceptoVencimiento>($"""
            SELECT
                cv.ID_CONCEPTO_VENCIMIENTO  AS IdConceptoVencimiento,
                cv.ID_TIPO_CONCEPTO         AS IdTipoConcepto,
                cv.ID_VENCIMIENTO           AS IdVencimiento,
                cv.CUMPLIDOR                AS Cumplidor,
                cv.OBSERVACION              AS Observacion,
                cv.CONCEPTO_PADRE           AS ConceptoPadre,
                cv.USR_ING                  AS UsrIng,
                cv.FEC_ING                  AS FecIng,
                cv.USR_BAJA                 AS UsrBaja,
                cv.FEC_BAJA                 AS FecBaja,
                c.CONCEPTO                  AS ConceptoNombre,
                cp.CONCEPTO                 AS ConceptoPadreNombre,
                v.EJERCICIO                 AS Ejercicio,
                v.NRO_CUOTA                 AS NroCuota,
                v.N_ZONA                    AS NZona,
                v.ID_TIPO_TRIBUTO           AS IdTipoTributo
            FROM DEV_CONCEPTOS_VENCIMIENTOS cv
            LEFT JOIN DEV_TIPOS_CONCEPTOS c  ON c.ID_TIPO_CONCEPTO = cv.ID_TIPO_CONCEPTO
            LEFT JOIN DEV_TIPOS_CONCEPTOS cp ON cp.ID_TIPO_CONCEPTO = cv.CONCEPTO_PADRE
            LEFT JOIN DEV_VENCIMIENTOS v      ON v.ID_VENCIMIENTOS = cv.ID_VENCIMIENTO
            {where}
            ORDER BY v.EJERCICIO DESC, v.NRO_CUOTA, c.CONCEPTO
            """, new { IdTipoTributo = idTipoTributo, Ejercicio = ejercicio });

        return result.ToList();
    }

    public async Task<int> CrearConceptoVencimiento(CrearConceptoVencimientoRequest req)
    {
        using var conn = db.Create();
        var nuevoId = await conn.ExecuteScalarAsync<int>("""
            SELECT ISNULL(MAX(ID_CONCEPTO_VENCIMIENTO), 0) + 1 FROM DEV_CONCEPTOS_VENCIMIENTOS
            """);
        await conn.ExecuteAsync("""
            INSERT INTO DEV_CONCEPTOS_VENCIMIENTOS
                (ID_CONCEPTO_VENCIMIENTO, ID_TIPO_CONCEPTO, ID_VENCIMIENTO,
                 CUMPLIDOR, OBSERVACION, CONCEPTO_PADRE, USR_ING, FEC_ING)
            VALUES
                (@Id, @IdTipoConcepto, @IdVencimiento,
                 @Cumplidor, @Observacion, @ConceptoPadre, @Usuario, GETDATE())
            """, new
        {
            Id = nuevoId,
            req.IdTipoConcepto,
            req.IdVencimiento,
            req.Cumplidor,
            req.Observacion,
            req.ConceptoPadre,
            req.Usuario,
        });
        return nuevoId;
    }

    public async Task EliminarConceptoVencimiento(int id, string usuario)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_CONCEPTOS_VENCIMIENTOS
            SET USR_BAJA = @Usuario, FEC_BAJA = GETDATE()
            WHERE ID_CONCEPTO_VENCIMIENTO = @Id
            """, new { Id = id, Usuario = usuario });
    }

    // ── Clone por año ───────────────────────────────────────────────────────

    public async Task<int> ClonarVencimientos(string ejercicioOrigen, string ejercicioDestino, int? idTipoTributo, string usuario)
    {
        using var conn = db.Create();

        // -1 si no hay registros activos en el ejercicio origen
        var whereOrigen = "USR_BAJA IS NULL AND EJERCICIO = @EjercicioOrigen";
        if (idTipoTributo.HasValue) whereOrigen += " AND ID_TIPO_TRIBUTO = @IdTipoTributo";

        var countOrigen = await conn.ExecuteScalarAsync<int>($"""
            SELECT COUNT(*) FROM DEV_VENCIMIENTOS WHERE {whereOrigen}
            """, new { EjercicioOrigen = ejercicioOrigen, IdTipoTributo = idTipoTributo });

        if (countOrigen == 0) return -1;

        // -2 si ya existen registros en el ejercicio destino
        var whereDestino = "USR_BAJA IS NULL AND EJERCICIO = @EjercicioDestino";
        if (idTipoTributo.HasValue) whereDestino += " AND ID_TIPO_TRIBUTO = @IdTipoTributo";

        var countDestino = await conn.ExecuteScalarAsync<int>($"""
            SELECT COUNT(*) FROM DEV_VENCIMIENTOS WHERE {whereDestino}
            """, new { EjercicioDestino = ejercicioDestino, IdTipoTributo = idTipoTributo });

        if (countDestino > 0) return -2;

        // INSERT copiando todos los campos, ajustando fechas y ejercicio
        var whereInsert = "USR_BAJA IS NULL AND EJERCICIO = @EjercicioOrigen";
        if (idTipoTributo.HasValue) whereInsert += " AND ID_TIPO_TRIBUTO = @IdTipoTributo";

        var inserted = await conn.ExecuteAsync($"""
            DECLARE @baseId INT
            SELECT @baseId = ISNULL(MAX(ID_VENCIMIENTOS), 0) FROM DEV_VENCIMIENTOS

            INSERT INTO DEV_VENCIMIENTOS
                (ID_VENCIMIENTOS, ID_TIPO_TRIBUTO, EJERCICIO, NRO_CUOTA, N_TIPO, N_ZONA,
                 FECHA_PRIMER_VTO, DESC_PRIMER_VTO,
                 FECHA_SEGUNDO_VTO, DESC_SEGUNDO_VTO,
                 FECHA_TERCER_VTO, DESC_TERCER_VTO,
                 ID_JURISDICCION, USR_ING, FEC_ING,
                 USR_MOD, FEC_MOD, USR_BAJA, FEC_BAJA)
            SELECT
                @baseId + ROW_NUMBER() OVER (ORDER BY ID_VENCIMIENTOS),
                ID_TIPO_TRIBUTO,
                @EjercicioDestino,
                NRO_CUOTA,
                N_TIPO,
                N_ZONA,
                DATEADD(year, YEAR(@EjercicioDestino) - YEAR(@EjercicioOrigen), FECHA_PRIMER_VTO),
                DESC_PRIMER_VTO,
                CASE WHEN FECHA_SEGUNDO_VTO IS NULL THEN NULL
                     ELSE DATEADD(year, YEAR(@EjercicioDestino) - YEAR(@EjercicioOrigen), FECHA_SEGUNDO_VTO) END,
                DESC_SEGUNDO_VTO,
                CASE WHEN FECHA_TERCER_VTO IS NULL THEN NULL
                     ELSE DATEADD(year, YEAR(@EjercicioDestino) - YEAR(@EjercicioOrigen), FECHA_TERCER_VTO) END,
                DESC_TERCER_VTO,
                ID_JURISDICCION,
                @Usuario,
                GETDATE(),
                NULL, NULL, NULL, NULL
            FROM DEV_VENCIMIENTOS
            WHERE {whereInsert}
            """, new { EjercicioOrigen = ejercicioOrigen, EjercicioDestino = ejercicioDestino, IdTipoTributo = idTipoTributo, Usuario = usuario });

        return inserted;
    }

    public async Task<int> ClonarConceptosAnio(string ejercicioOrigen, string ejercicioDestino, int? idTipoTributo, string usuario)
    {
        using var conn = db.Create();

        // Convertir ejercicio string a int para comparar con ANIO_EJERCICIO
        if (!int.TryParse(ejercicioOrigen,  out var anioOrigen)  ||
            !int.TryParse(ejercicioDestino, out var anioDestino))
            return -1;

        // -1 si no hay registros activos en el ejercicio origen
        var joinFiltro = idTipoTributo.HasValue
            ? "JOIN DEV_TIPOS_CONCEPTOS tc ON tc.ID_TIPO_CONCEPTO = ca.ID_TIPO_CONCEPTO AND tc.ID_TIPO_TRIBUTO = @IdTipoTributo"
            : "";

        var countOrigen = await conn.ExecuteScalarAsync<int>($"""
            SELECT COUNT(*) FROM DEV_TIPOS_CONCEPTOS_ANIO ca
            {joinFiltro}
            WHERE ca.FEC_BAJA IS NULL AND ca.ANIO_EJERCICIO = @AnioOrigen
            """, new { AnioOrigen = anioOrigen, IdTipoTributo = idTipoTributo });

        if (countOrigen == 0) return -1;

        // -2 si ya existen registros en el ejercicio destino
        var countDestino = await conn.ExecuteScalarAsync<int>($"""
            SELECT COUNT(*) FROM DEV_TIPOS_CONCEPTOS_ANIO ca
            {joinFiltro}
            WHERE ca.FEC_BAJA IS NULL AND ca.ANIO_EJERCICIO = @AnioDestino
            """, new { AnioDestino = anioDestino, IdTipoTributo = idTipoTributo });

        if (countDestino > 0) return -2;

        // INSERT copiando todos los campos, cambiando ANIO_EJERCICIO
        var inserted = await conn.ExecuteAsync($"""
            DECLARE @baseId INT
            SELECT @baseId = ISNULL(MAX(ID_TIPOCON_ANIO), 0) FROM DEV_TIPOS_CONCEPTOS_ANIO

            INSERT INTO DEV_TIPOS_CONCEPTOS_ANIO
                (ID_TIPOCON_ANIO, ID_TIPO_CONCEPTO, ANIO_EJERCICIO,
                 PORCENTAJE, VALOR, ID_JURISDICCION,
                 USR_ING, FEC_ING, USR_MOD, FEC_MOD, USR_BAJA, FEC_BAJA)
            SELECT
                @baseId + ROW_NUMBER() OVER (ORDER BY ca.ID_TIPOCON_ANIO),
                ca.ID_TIPO_CONCEPTO,
                @AnioDestino,
                ca.PORCENTAJE,
                ca.VALOR,
                ca.ID_JURISDICCION,
                @Usuario,
                GETDATE(),
                NULL, NULL, NULL, NULL
            FROM DEV_TIPOS_CONCEPTOS_ANIO ca
            {joinFiltro}
            WHERE ca.FEC_BAJA IS NULL AND ca.ANIO_EJERCICIO = @AnioOrigen
            """, new { AnioOrigen = anioOrigen, AnioDestino = anioDestino, IdTipoTributo = idTipoTributo, Usuario = usuario });

        return inserted;
    }

    // ── DevengamientoV2 ────────────────────────────────────────────────────────

    public async Task<EstadoDevengamiento?> ObtenerEstadoDevengamiento(int idJurisdiccion, int? idTipoTributo)
    {
        using var conn = db.Create();
        var where = "ID_JURISDICCION = @IdJurisdiccion AND FEC_FIN IS NULL";
        if (idTipoTributo.HasValue) where += " AND ID_TIPO_TRIBUTO = @IdTipoTributo";
        var result = await conn.QueryFirstOrDefaultAsync<EstadoDevengamiento>($"""
            SELECT TOP 1
                ID_PORCENTAJE_CARGA AS IdPorcentajeCarga,
                ID_JURISDICCION     AS IdJurisdiccion,
                ID_TIPO_TRIBUTO     AS IdTipoTributo,
                PORCENTAJE,
                ESTADO,
                MENSAJE,
                FEC_INICIO          AS FecInicio,
                FEC_FIN             AS FecFin,
                USR_OPERADOR        AS UsrOperador,
                EJERCICIO
            FROM DEV_PORCENTAJE_CARGA
            WHERE {where}
            ORDER BY FEC_INICIO DESC
            """, new { IdJurisdiccion = idJurisdiccion, IdTipoTributo = idTipoTributo });
        return result;
    }

    public async Task<List<LogDevengamiento>> ObtenerLogDevengamiento(int idJurisdiccion, int take = 20)
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<LogDevengamiento>($"""
            SELECT TOP {take}
                ID_LOG              AS IdLog,
                ID_JURISDICCION     AS IdJurisdiccion,
                ID_TIPO_TRIBUTO     AS IdTipoTributo,
                TIPO_TRIBUTO        AS TipoTributo,
                EJERCICIO,
                RESULTADO,
                MENSAJE,
                FEC_EJECUCION       AS FecEjecucion,
                USR_OPERADOR        AS UsrOperador,
                CUENTAS_PROCESADAS  AS CuentasProcesadas,
                CUENTAS_DEVENGADAS  AS CuentasDevengadas,
                CUENTAS_ERROR       AS CuentasError,
                DURACION_SEGUNDOS   AS DuracionSegundos
            FROM DEV_DEVENGAMIENTO_LOG
            WHERE ID_JURISDICCION = @IdJurisdiccion
            ORDER BY FEC_EJECUCION DESC
            """, new { IdJurisdiccion = idJurisdiccion });
        return result.ToList();
    }

    public async Task<int> IniciarDevengamiento(EjecutarDevengamientoRequest req)
    {
        using var conn = db.Create();
        // Marcar como completado cualquier proceso anterior en ejecución
        await conn.ExecuteAsync("""
            UPDATE DEV_PORCENTAJE_CARGA
            SET FEC_FIN = GETDATE(), ESTADO = 'CANCELADO', MENSAJE = 'Cancelado por nueva ejecución'
            WHERE ID_JURISDICCION = @IdJurisdiccion AND FEC_FIN IS NULL AND ESTADO = 'EN_PROCESO'
            """, new { req.IdJurisdiccion });

        var id = await conn.ExecuteScalarAsync<int>("""
            INSERT INTO DEV_PORCENTAJE_CARGA
                (ID_JURISDICCION, ID_TIPO_TRIBUTO, PORCENTAJE, ESTADO, FEC_INICIO, USR_OPERADOR, EJERCICIO, FEC_ING, USR_ING)
            VALUES
                (@IdJurisdiccion, @IdTipoTributo, 0, 'EN_PROCESO', GETDATE(), @Usuario, @Ejercicio, GETDATE(), @Usuario);
            SELECT SCOPE_IDENTITY();
            """, new { req.IdJurisdiccion, req.IdTipoTributo, req.Usuario, req.Ejercicio });
        return id;
    }

    public async Task ActualizarEstadoDevengamiento(int idPorcentajeCarga, decimal porcentaje, string estado, string? mensaje)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE DEV_PORCENTAJE_CARGA
            SET PORCENTAJE = @Porcentaje, ESTADO = @Estado, MENSAJE = @Mensaje,
                FEC_FIN = CASE WHEN @Estado IN ('COMPLETADO','ERROR') THEN GETDATE() ELSE NULL END
            WHERE ID_PORCENTAJE_CARGA = @Id
            """, new { Id = idPorcentajeCarga, Porcentaje = porcentaje, Estado = estado, Mensaje = mensaje });
    }

    public async Task RegistrarLogDevengamiento(LogDevengamiento log)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            INSERT INTO DEV_DEVENGAMIENTO_LOG
                (ID_JURISDICCION, ID_TIPO_TRIBUTO, TIPO_TRIBUTO, EJERCICIO, RESULTADO, MENSAJE,
                 FEC_EJECUCION, USR_OPERADOR, CUENTAS_PROCESADAS, CUENTAS_DEVENGADAS, CUENTAS_ERROR, DURACION_SEGUNDOS)
            VALUES
                (@IdJurisdiccion, @IdTipoTributo, @TipoTributo, @Ejercicio, @Resultado, @Mensaje,
                 GETDATE(), @UsrOperador, @CuentasProcesadas, @CuentasDevengadas, @CuentasError, @DuracionSegundos)
            """, log);
    }
}
