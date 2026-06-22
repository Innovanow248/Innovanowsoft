-- ==========================================================================
-- SCRIPTS CRUD — ADMINISTRACIÓN FINANCIERA
-- Base de datos: PROGRAM (SQL Server 149.50.144.8)
-- Generado: 2026-06-22
-- ==========================================================================
-- CICLO DEL GASTO:
--   Afectación (AP) → Compromiso (CP) → Orden de Pago (OP) → Pago (PA)
--
-- CLAVES:
--   NRO_CTA_ERO char(?)  = cuenta presupuestaria de erogación
--   ANO_ERO char(4)      = ejercicio (ej: '2026')
--   RECONDUCIDO_ERO      = si la cuenta fue reconducida de ejercicios anteriores
--   IDENTIFICADOR char(5) = proveedor/beneficiario (FK PERSONAS)
--
-- NUMERACION DE COMPROBANTES (PK compuesta):
--   TIPO_AFECTACION char(4) + ANO_AFECTACION char(4) + NRO_AFECTACION char(8)
--   Ídem para COMPROMISOS, ORDENES_PAGO, PAGOS
--   Tipos: AP=Afectación Preventiva, XAP=Automática, CP=Compromiso, XCP=Automático
--          OP=Orden de Pago, DAC=Ajuste Contable, PA=Pago Simple, PM=Pago Múltiple
-- ==========================================================================


-- ══════════════════════════════════════════════════════════════════════════
-- CONSULTAS DE REFERENCIA — ejecutar antes de crear comprobantes
-- ══════════════════════════════════════════════════════════════════════════

-- Ver ejercicio activo y saldo disponible por cuenta presupuestaria:
SELECT
    e.ANO_ERO,
    e.RECONDUCIDO_ERO,
    e.NRO_CTA_ERO,
    e.DESIGNACION,
    e.TIPO_CTA_ERO,
    e.PRESUPUESTO_AUTORIZADO,
    e.MONTO_AFECTADO,
    e.MONTO_COMPROMETIDO,
    e.MONTO_APAGAR,
    e.MONTO_PAGADO,
    (e.PRESUPUESTO_AUTORIZADO - e.MONTO_AFECTADO) AS DISPONIBLE
FROM CP_EROGACION_CUENTAS e
WHERE e.ANO_ERO = '2026'
    AND e.TIPO_CTA_ERO IN ('PI','PT')   -- presupuestadas (I=inicial, T=total)
    AND (e.PRESUPUESTO_AUTORIZADO - e.MONTO_AFECTADO) > 0
ORDER BY e.NRO_CTA_ERO

-- Buscar proveedor por CUIT o nombre:
SELECT p.IDENTIFICADOR, p.APELLIDO, p.NOMBRE, p.CUIT_CUIL,
       c.TIPO_PROVEEDOR, c.NOMBRE_FANTASIA, c.ESTADO_AFIP
FROM PERSONAS p
JOIN CO_PROVEEDORES c ON c.IDENTIFICADOR = p.IDENTIFICADOR
WHERE p.CUIT_CUIL = '20281234567'
   OR p.APELLIDO LIKE 'GARCIA%'

-- Ver tipos de afectación habilitados para el ejercicio:
SELECT * FROM CP_AFECTACIONES_ANO WHERE ANO_AFECTACION = '2026'

-- Ver último número de afectación del ejercicio:
SELECT MAX(NRO_AFECTACION) AS ULTIMO_NRO
FROM CP_AFECTACIONES
WHERE TIPO_AFECTACION = 'AP' AND ANO_AFECTACION = '2026'

-- Ver planilla abierta de tesorería:
SELECT ANO_PLANILLA, NRO_PLANILLA, FECHA_PLANILLA, CIERRE_PLANILLA,
       SALDO_ANT, INGRESO, EGRESO, SALDO
FROM CP_PLANILLAS
WHERE CIERRE_PLANILLA = '0'    -- '0'=abierta, '1'=cerrada
ORDER BY FECHA_PLANILLA DESC


-- ══════════════════════════════════════════════════════════════════════════
-- 1. ALTA DE AFECTACIÓN PREVENTIVA (AP)
-- Reserva crédito presupuestario antes de comprometer
-- ══════════════════════════════════════════════════════════════════════════
-- Paso 1: Verificar saldo disponible (ver consulta de referencia arriba)
-- Paso 2: Insertar afectación

DECLARE @NRO_AF CHAR(8)
-- Calcular próximo número (incrementar el máximo):
SELECT @NRO_AF = RIGHT('00000000' + CAST(CAST(MAX(NRO_AFECTACION) AS INT)+1 AS VARCHAR), 8)
FROM CP_AFECTACIONES
WHERE TIPO_AFECTACION = 'AP' AND ANO_AFECTACION = '2026'

INSERT INTO CP_AFECTACIONES (
    TIPO_AFECTACION,    -- char(4): 'AP' = Afectación Preventiva
    ANO_AFECTACION,     -- char(4): ejercicio
    NRO_AFECTACION,     -- char(8): número secuencial
    IDENTIFICADOR,      -- char(5): proveedor/beneficiario (FK PERSONAS)
    FECHA_AFECTACION,   -- datetime
    CONCEPTO,           -- varchar(50): descripción
    MONTO_AFECTADO,     -- money: monto reservado
    MONTO_COMPROMETIDO, -- money: iniciar en 0
    MONTO_APAGAR,       -- money: iniciar en 0
    MONTO_PAGADO,       -- money: iniciar en 0
    MONTO_DESAFECTADO,  -- money: iniciar en 0
    ESTADO_AFECTACION,  -- char(1): estado inicial = '0' o 'A' (activa)
    historico,          -- int: 0
    USUARIO,
    FECHA_AC
)
VALUES (
    'AP  ',
    '2026',
    @NRO_AF,
    '028VB',                        -- IDENTIFICADOR del proveedor
    GETDATE(),
    'Compra de insumos de oficina',
    150000.00,
    0.00, 0.00, 0.00, 0.00,
    'A',
    0,
    'SISTEMA',
    GETDATE()
)

-- Paso 3: Registrar la imputación presupuestaria (cuenta ERO afectada):
INSERT INTO CP_AFECTACIONES_IMPUTACIONES (
    TIPO_AFECTACION, ANO_AFECTACION, NRO_AFECTACION,
    ANO_ERO, RECONDUCIDO_ERO, NRO_CTA_ERO,
    MONTO_IMPUTADO
)
VALUES (
    'AP  ', '2026', @NRO_AF,
    '2026', '0', 'CUENTA_ERO_AQUI',    -- completar con la cuenta presupuestaria
    150000.00
)

-- Paso 4: Actualizar saldo de la cuenta presupuestaria:
UPDATE CP_EROGACION_CUENTAS
SET MONTO_AFECTADO = MONTO_AFECTADO + 150000.00
WHERE ANO_ERO = '2026'
    AND RECONDUCIDO_ERO = '0'
    AND NRO_CTA_ERO = 'CUENTA_ERO_AQUI'


-- ══════════════════════════════════════════════════════════════════════════
-- 2. ALTA DE COMPROMISO (CP)
-- Formaliza la obligación con el proveedor (requiere afectación previa)
-- ══════════════════════════════════════════════════════════════════════════
DECLARE @NRO_CP CHAR(8)
SELECT @NRO_CP = RIGHT('00000000' + CAST(CAST(MAX(NRO_COMPROMISO) AS INT)+1 AS VARCHAR), 8)
FROM CP_COMPROMISOS
WHERE TIPO_COMPROMISO = 'CP  ' AND ANO_COMPROMISO = '2026'

INSERT INTO CP_COMPROMISOS (
    TIPO_COMPROMISO,    -- 'CP  ' o 'XCP '
    ANO_COMPROMISO,
    NRO_COMPROMISO,
    IDENTIFICADOR,      -- proveedor
    MONTO_COMPROMETIDO,
    MONTO_APAGAR,
    MONTO_PAGADO,
    MONTO_DESCOMPROMETIDO,
    ESTADO_COMPROMISO,  -- 'C' = comprometido
    USUARIO,
    FECHA_AC
)
VALUES (
    'CP  ',
    '2026',
    @NRO_CP,
    '028VB',
    150000.00,
    0.00, 0.00, 0.00,
    'C',
    'SISTEMA',
    GETDATE()
)

-- Imputar el compromiso a la cuenta presupuestaria:
INSERT INTO CP_COMPROMISOS_IMPUTACIONES (
    TIPO_COMPROMISO, ANO_COMPROMISO, NRO_COMPROMISO,
    ANO_ERO, RECONDUCIDO_ERO, NRO_CTA_ERO,
    MONTO_IMPUTADO
)
VALUES (
    'CP  ', '2026', @NRO_CP,
    '2026', '0', 'CUENTA_ERO_AQUI',
    150000.00
)

-- Actualizar saldo de la cuenta presupuestaria:
UPDATE CP_EROGACION_CUENTAS
SET MONTO_COMPROMETIDO = MONTO_COMPROMETIDO + 150000.00
WHERE ANO_ERO = '2026' AND RECONDUCIDO_ERO = '0' AND NRO_CTA_ERO = 'CUENTA_ERO_AQUI'

-- Actualizar el monto comprometido en la afectación origen:
UPDATE CP_AFECTACIONES
SET MONTO_COMPROMETIDO = MONTO_COMPROMETIDO + 150000.00
WHERE TIPO_AFECTACION = 'AP  ' AND ANO_AFECTACION = '2026' AND NRO_AFECTACION = @NRO_AF


-- ══════════════════════════════════════════════════════════════════════════
-- 3. INGRESO DE FACTURA DE PROVEEDOR (CO_FACTURAS_COMPRAS)
-- Se vincula al compromiso vía CO_DOCUMENTOS_FACTURA / CO_COMPROMISO_FACTURAS
-- ══════════════════════════════════════════════════════════════════════════
INSERT INTO CO_FACTURAS_COMPRAS (
    IDENTIFICADOR,          -- proveedor
    NRO_FACTURA,            -- char(13): ej '00000000001-1' (punto de venta - nro)
    TIPO_COMPROBANTE,       -- char(2): '01'=Factura A, '06'=B, '11'=C
    LETRA_COMPROBANTE,      -- char(1): 'A', 'B', 'C'
    FECHA,                  -- datetime: fecha del comprobante fiscal
    FECHA_CARGA,            -- datetime: GETDATE()
    FECHA_RECEPCION,        -- datetime: cuando ingresó
    TOTAL_FACTURA,          -- money: total con IVA
    DESCUENTO,              -- money: 0 si no hay descuento
    IC_NETO_GRAVADO1,       -- money: monto neto gravado al 21%
    IC_IVA1,                -- money: monto de IVA
    IC_ALICUOTA1,           -- real: alícuota (21 para 21%)
    IC_NETO_NOGRAVADO,      -- money: monto no gravado
    IC_PERC_IVA,            -- money: percepciones IVA
    IC_PERC_INGR_BRUTOS,    -- money: percepciones IIBB
    IC_PERC_IMP_MUNICIPALES,-- money: percepciones municipales
    ESTADO,                 -- char(1): 'E'=Emitida/Ingresada
    ESTADO_CARGA,           -- char(1): estado de carga inicial
    TIPO_OPAGO,             -- char(4): vinculación a OP (vacío al inicio)
    ANO_OPAGO,              -- char(4): vacío al inicio
    NRO_OPAGO,              -- char(8): vacío al inicio
    MANDATO_FECHA,
    MANDATO_USUARIO,
    MANDATO_IP
)
VALUES (
    '028VB',
    '00001-00000001   ',    -- 13 chars: punto de venta + nro
    '01',                   -- Factura tipo A
    'A',
    '2026-06-20',
    GETDATE(),
    GETDATE(),
    181500.00,              -- 150000 + IVA 21%
    0.00,
    150000.00,              -- neto gravado
    31500.00,               -- IVA 21%
    21,
    0.00,
    0.00, 0.00, 0.00,
    'E',
    '0',
    '    ',                 -- sin OP todavía
    '    ',
    '        ',
    GETDATE(), 'SISTEMA', '0.0.0.0'
)

-- Vincular el documento con el compromiso:
INSERT INTO CO_DOCUMENTOS_FACTURA (
    TIPO_DOCUMENTO, ANO_DOCUMENTO, NRO_DOCUMENTO,
    IDENTIFICADOR, NRO_FACTURA, TIPO_COMPROBANTE, LETRA_COMPROBANTE
)
VALUES (
    'CP  ', '2026', @NRO_CP,
    '028VB', '00001-00000001   ', '01', 'A'
)


-- ══════════════════════════════════════════════════════════════════════════
-- 4. ALTA DE ORDEN DE PAGO (OP)
-- Autoriza el pago — requiere compromiso e imputación a la planilla
-- ══════════════════════════════════════════════════════════════════════════
DECLARE @NRO_OP CHAR(8), @ANO_PLAN CHAR(4), @NRO_PLAN CHAR(8)

SELECT @NRO_OP = RIGHT('00000000' + CAST(CAST(MAX(NRO_OPAGO) AS INT)+1 AS VARCHAR), 8)
FROM CP_ORDENES_PAGO
WHERE TIPO_OPAGO = 'OP  ' AND ANO_OPAGO = '2026'

-- Obtener la planilla abierta:
SELECT TOP 1 @ANO_PLAN = ANO_PLANILLA, @NRO_PLAN = NRO_PLANILLA
FROM CP_PLANILLAS WHERE CIERRE_PLANILLA = '0'
ORDER BY FECHA_PLANILLA DESC

INSERT INTO CP_ORDENES_PAGO (
    TIPO_OPAGO,         -- 'OP  '
    ANO_OPAGO,          -- '2026'
    NRO_OPAGO,          -- secuencial
    ANO_PLANILLA,       -- planilla abierta
    NRO_PLANILLA,
    IDENTIFICADOR,      -- proveedor
    ESTADO_OPAGO,       -- 'P' = pendiente de pago
    MONTO_APAGAR,
    MONTO_PAGADO,
    MONTO_DESORDENADO,
    OBSERVACIONES,
    MANDATO_FECHA,
    MANDATO_USUARIO,
    MANDATO_IP,
    USUARIO,
    FECHA_AC
)
VALUES (
    'OP  ', '2026', @NRO_OP,
    @ANO_PLAN, @NRO_PLAN,
    '028VB',
    'P',
    181500.00,
    0.00, 0.00,
    'Pago Factura A-00001-00000001 - Insumos de oficina',
    GETDATE(), 'SISTEMA', '0.0.0.0',
    'SISTEMA', GETDATE()
)

-- Imputar la OP al compromiso:
INSERT INTO CP_ORDENES_PAGO_IMPUTACIONES (
    TIPO_OPAGO, ANO_OPAGO, NRO_OPAGO,
    TIPO_COMPROMISO, ANO_COMPROMISO, NRO_COMPROMISO,
    MONTO_IMPUTADO
)
VALUES (
    'OP  ', '2026', @NRO_OP,
    'CP  ', '2026', @NRO_CP,
    181500.00
)

-- Actualizar la factura con la OP generada:
UPDATE CO_FACTURAS_COMPRAS
SET TIPO_OPAGO = 'OP  ', ANO_OPAGO = '2026', NRO_OPAGO = @NRO_OP
WHERE IDENTIFICADOR = '028VB'
    AND NRO_FACTURA = '00001-00000001   '
    AND TIPO_COMPROBANTE = '01'
    AND LETRA_COMPROBANTE = 'A'


-- ══════════════════════════════════════════════════════════════════════════
-- 5. REGISTRO DE PAGO EFECTIVO (PA)
-- Liquida la OP — genera la operación bancaria correspondiente
-- ══════════════════════════════════════════════════════════════════════════
DECLARE @NRO_PA CHAR(8), @NRO_OPE_BAN CHAR(?)

SELECT @NRO_PA = RIGHT('00000000' + CAST(CAST(MAX(NRO_PAGO) AS INT)+1 AS VARCHAR), 8)
FROM CP_PAGOS
WHERE TIPO_PAGO = 'PA  ' AND ANO_PAGO = '2026'

INSERT INTO CP_PAGOS (
    TIPO_PAGO,      -- 'PA  '
    ANO_PAGO,       -- '2026'
    NRO_PAGO,       -- secuencial
    FECHA_PAGO,
    ESTADO_PAGO,    -- 'P' = pagado
    MONTO_PAGADO,
    IDENTIFICADOR,
    USUARIO,
    FECHA_AC
)
VALUES (
    'PA  ', '2026', @NRO_PA,
    GETDATE(),
    'P',
    181500.00,
    '028VB',
    'SISTEMA', GETDATE()
)

-- Registrar la operación bancaria (cheque emitido = tipo 101):
INSERT INTO OPERACIONES_BANCARIAS (
    TIPO_OPE_BAN,               -- '101' = Cheque emitido
    TIPO_CTA_BCO,               -- tipo de cuenta
    BANCO,                      -- código banco
    NRO_CTA_BCO,               -- número de cuenta
    NRO_OPE_BAN,               -- número secuencial
    ANO_PLANILLA, NRO_PLANILLA,
    FECHA_OPE_BAN,
    MONTO_OPE_BAN,
    ESTADO_OPE_BAN,            -- 'A' = activa
    CONCEPTO,
    IMPRESO
)
VALUES (
    '101', '01', '0020', '0001400603',  -- cheque de la cuenta principal
    @NRO_OPE_BAN,
    @ANO_PLAN, @NRO_PLAN,
    GETDATE(),
    181500.00,
    'A',
    'Pago OP ' + @NRO_OP + ' - ' + @NRO_CP,
    '0'
)

-- Vincular la OP con el Pago y la Operación Bancaria:
INSERT INTO CP_ORDENES_PAGO_PAGOS (
    TIPO_OPAGO, ANO_OPAGO, NRO_OPAGO,
    TIPO_OPE_BAN, TIPO_CTA_BCO, BANCO, NRO_CTA_BCO, NRO_OPE_BAN,
    TIPO_PAGO, ANO_PAGO, NRO_PAGO,
    MONTO
)
VALUES (
    'OP  ', '2026', @NRO_OP,
    '101', '01', '0020', '0001400603', @NRO_OPE_BAN,
    'PA  ', '2026', @NRO_PA,
    181500.00
)

-- Actualizar estados finales:
UPDATE CP_ORDENES_PAGO SET ESTADO_OPAGO='PA', MONTO_PAGADO=181500.00, MONTO_APAGAR=0
WHERE TIPO_OPAGO='OP  ' AND ANO_OPAGO='2026' AND NRO_OPAGO=@NRO_OP

UPDATE CP_EROGACION_CUENTAS
SET MONTO_APAGAR=MONTO_APAGAR-181500.00, MONTO_PAGADO=MONTO_PAGADO+181500.00
WHERE ANO_ERO='2026' AND RECONDUCIDO_ERO='0' AND NRO_CTA_ERO='CUENTA_ERO_AQUI'


-- ══════════════════════════════════════════════════════════════════════════
-- 6. REVERSO / DESAFECTACIÓN
-- Libera crédito presupuestario comprometido pero no ejecutado
-- ══════════════════════════════════════════════════════════════════════════
-- Desafectación (revierte una afectación preventiva):
INSERT INTO CP_DESAFECTACIONES (
    TIPO_AFECTACION, ANO_AFECTACION, NRO_AFECTACION,  -- la afectación que se revierte
    TIPO_DESAFECTACION, ANO_DESAFECTACION, NRO_DESAFECTACION,
    CONCEPTO, MONTO_DESAFECTADO,
    USUARIO, FECHA_AC
)
VALUES (
    'AP  ', '2026', @NRO_AF,
    'DA  ', '2026', '00000001',
    'Desafectación por anulación de compra',
    150000.00,
    'SISTEMA', GETDATE()
)

UPDATE CP_AFECTACIONES
SET ESTADO_AFECTACION='D', MONTO_DESAFECTADO=MONTO_DESAFECTADO+150000.00
WHERE TIPO_AFECTACION='AP  ' AND ANO_AFECTACION='2026' AND NRO_AFECTACION=@NRO_AF

UPDATE CP_EROGACION_CUENTAS
SET MONTO_AFECTADO=MONTO_AFECTADO-150000.00
WHERE ANO_ERO='2026' AND RECONDUCIDO_ERO='0' AND NRO_CTA_ERO='CUENTA_ERO_AQUI'


-- ══════════════════════════════════════════════════════════════════════════
-- 7. ALTA DE PROVEEDOR
-- ══════════════════════════════════════════════════════════════════════════
-- Primero crear la PERSONA (ver scripts de tributario para INSERT en PERSONAS)
-- Luego dar de alta en CO_PROVEEDORES:

INSERT INTO CO_PROVEEDORES (
    IDENTIFICADOR,          -- char(5) — debe existir en PERSONAS
    TIPO_SOCIEDAD,          -- char(4): 'UNIP','SRL ','SA  ','SAS ','COOP'
    TIPO_PROVEEDOR,         -- char(4)
    NOMBRE_FANTASIA,        -- varchar(50)
    CODIGO_POSTAL,          -- char(8)
    CALLE,                  -- varchar(30)
    NUMERACION,             -- char(5)
    PISO,                   -- char(4)
    DEPTO,                  -- char(4)
    BARRIO,                 -- varchar(30)
    CODIGO_PROVINCIA,       -- char(15)
    CODIGO_PAIS,            -- char(4)
    NRO_REGISTRO_MUNI,      -- char(20): número de inscripción municipal
    FECHA_ALTA,
    ESTADO_AFIP,            -- char(2): estado según padrón AFIP
    FECHA_ULTIMA_CONSULTA_AFIP,
    E_MAIL, TELEFONO, TELEFONO_MOVIL
)
VALUES (
    '04JND',
    'UNIP',
    '    ',
    'GARCIA JUAN C.',
    '00000453',
    'SAN MARTIN',
    '123  ', '    ', '    ',
    'MALAGUEÑO',
    'X              ', 'ARGE',
    '001-2026            ',
    GETDATE(),
    'AC',     -- AC=Activo en AFIP
    GETDATE(),
    'jgarcia@email.com', '351123456', '3511234567'
)


-- ══════════════════════════════════════════════════════════════════════════
-- 8. CONSULTA DE EJECUCIÓN PRESUPUESTARIA
-- Resumen del estado del presupuesto por cuenta de erogación
-- ══════════════════════════════════════════════════════════════════════════
-- Ejecución por cuenta presupuestaria (un ejercicio):
SELECT
    e.NRO_CTA_ERO,
    e.DESIGNACION,
    e.PRESUPUESTO_AUTORIZADO                                    AS CREDITO_TOTAL,
    e.MONTO_AFECTADO                                           AS AFECTADO,
    e.MONTO_COMPROMETIDO                                       AS COMPROMETIDO,
    e.MONTO_APAGAR                                             AS A_PAGAR,
    e.MONTO_PAGADO                                             AS PAGADO,
    (e.PRESUPUESTO_AUTORIZADO - e.MONTO_AFECTADO)              AS DISPONIBLE,
    CASE WHEN e.PRESUPUESTO_AUTORIZADO > 0
         THEN CAST(100.0 * e.MONTO_PAGADO / e.PRESUPUESTO_AUTORIZADO AS DECIMAL(5,1))
         ELSE 0 END                                            AS PCT_EJECUTADO
FROM CP_EROGACION_CUENTAS e
WHERE e.ANO_ERO = '2026'
    AND e.TIPO_CTA_ERO IN ('PI','PT')
    AND e.PRESUPUESTO_AUTORIZADO > 0
ORDER BY e.NRO_CTA_ERO

-- Balance diario consolidado:
SELECT
    b.FECHA_BALANCE,
    b.INGRESO_TOTAL,
    b.EGRESO_TOTAL,
    b.SALDO_TOTAL,
    b.INGRESO_CAJA, b.EGRESO_CAJA, b.SALDO_CAJA,
    b.INGRESO_BANCO, b.EGRESO_BANCO, b.SALDO_BANCO
FROM CP_BALANCE b
ORDER BY b.FECHA_BALANCE DESC


-- ══════════════════════════════════════════════════════════════════════════
-- 9. CONSULTA DE ÓRDENES DE PAGO POR PROVEEDOR
-- ══════════════════════════════════════════════════════════════════════════
SELECT
    op.TIPO_OPAGO, op.ANO_OPAGO, op.NRO_OPAGO,
    p.APELLIDO + ', ' + p.NOMBRE    AS PROVEEDOR,
    p.CUIT_CUIL,
    op.ESTADO_OPAGO,
    op.MONTO_APAGAR,
    op.MONTO_PAGADO,
    op.OBSERVACIONES,
    op.MANDATO_FECHA                AS FECHA_APROBACION,
    op.USUARIO,
    pl.FECHA_PLANILLA
FROM CP_ORDENES_PAGO op
JOIN PERSONAS p ON p.IDENTIFICADOR = op.IDENTIFICADOR
JOIN CP_PLANILLAS pl ON pl.ANO_PLANILLA = op.ANO_PLANILLA AND pl.NRO_PLANILLA = op.NRO_PLANILLA
WHERE op.ANO_OPAGO = '2026'
    AND op.ESTADO_OPAGO != 'AN'    -- excluir anuladas
ORDER BY op.NRO_OPAGO DESC


-- ══════════════════════════════════════════════════════════════════════════
-- 10. CONSULTA DE FACTURAS DE UN PROVEEDOR
-- ══════════════════════════════════════════════════════════════════════════
SELECT
    f.IDENTIFICADOR,
    p.APELLIDO + ', ' + p.NOMBRE    AS PROVEEDOR,
    f.TIPO_COMPROBANTE,
    f.LETRA_COMPROBANTE,
    f.NRO_FACTURA,
    f.FECHA,
    f.FECHA_CARGA,
    f.TOTAL_FACTURA,
    f.IC_NETO_GRAVADO1,
    f.IC_IVA1,
    f.ESTADO,
    f.TIPO_OPAGO + '/' + f.ANO_OPAGO + '/' + f.NRO_OPAGO   AS ORDEN_PAGO
FROM CO_FACTURAS_COMPRAS f
JOIN PERSONAS p ON p.IDENTIFICADOR = f.IDENTIFICADOR
WHERE f.IDENTIFICADOR = '028VB'    -- ← IDENTIFICADOR del proveedor
ORDER BY f.FECHA DESC


-- ══════════════════════════════════════════════════════════════════════════
-- 11. ALTA DE RECIBO DE INGRESO (RI)
-- Registra ingresos de recaudación (tasas cobradas, fondos coparticipados, etc.)
-- ══════════════════════════════════════════════════════════════════════════
DECLARE @NRO_RI CHAR(8)
SELECT @NRO_RI = RIGHT('00000000' + CAST(CAST(MAX(NRO_RECIBO) AS INT)+1 AS VARCHAR), 8)
FROM CP_RECIBOS
WHERE TIPO_RECIBO = 'RI  ' AND ANO_RECIBO = '2026'

INSERT INTO CP_RECIBOS (
    TIPO_RECIBO,    -- 'RI  '=Ingresos, 'RD  '=Disponibilidades, 'NCI '=Nota Contable
    ANO_RECIBO,
    NRO_RECIBO,
    ANO_PLANILLA, NRO_PLANILLA,
    MONTO_TOTAL,
    MONTO_COBRADO,
    ESTADO_RECIBO,  -- 'C'=cobrado, 'P'=pendiente
    USUARIO, FECHA_AC
)
VALUES (
    'RI  ', '2026', @NRO_RI,
    @ANO_PLAN, @NRO_PLAN,
    50000.00,
    50000.00,
    'C',
    'SISTEMA', GETDATE()
)

-- Imputar el ingreso a la cuenta de ingresos:
INSERT INTO CP_RECIBOS_IMPUTACIONES (
    TIPO_RECIBO, ANO_RECIBO, NRO_RECIBO,
    ANO_ING, NRO_CTA_ING,
    MONTO_IMPUTADO
)
VALUES (
    'RI  ', '2026', @NRO_RI,
    '2026', 'CUENTA_ING_AQUI',
    50000.00
)

UPDATE CP_INGRESO_CUENTAS
SET MONTO_COBRADO = MONTO_COBRADO + 50000.00
WHERE ANO_ING = '2026' AND NRO_CTA_ING = 'CUENTA_ING_AQUI'


-- ══════════════════════════════════════════════════════════════════════════
-- 12. INFORMES DE GESTIÓN — Consultas útiles para reportes
-- ══════════════════════════════════════════════════════════════════════════
-- 12.1 Pagos del período:
SELECT
    pa.ANO_PAGO, pa.NRO_PAGO,
    pa.FECHA_PAGO,
    p.APELLIDO + ', ' + p.NOMBRE    AS BENEFICIARIO,
    p.CUIT_CUIL,
    pa.MONTO_PAGADO,
    ob.TIPO_OPE_BAN, ob.CONCEPTO
FROM CP_PAGOS pa
JOIN PERSONAS p ON p.IDENTIFICADOR = pa.IDENTIFICADOR
LEFT JOIN CP_ORDENES_PAGO_PAGOS opp ON opp.TIPO_PAGO = pa.TIPO_PAGO
    AND opp.ANO_PAGO = pa.ANO_PAGO AND opp.NRO_PAGO = pa.NRO_PAGO
LEFT JOIN OPERACIONES_BANCARIAS ob ON ob.TIPO_OPE_BAN = opp.TIPO_OPE_BAN
    AND ob.NRO_OPE_BAN = opp.NRO_OPE_BAN
WHERE pa.ANO_PAGO = '2026'
ORDER BY pa.FECHA_PAGO DESC

-- 12.2 Top proveedores por monto pagado en el ejercicio:
SELECT TOP 20
    p.IDENTIFICADOR, p.APELLIDO + ', ' + p.NOMBRE AS PROVEEDOR,
    p.CUIT_CUIL,
    SUM(pa.MONTO_PAGADO) AS TOTAL_PAGADO,
    COUNT(*) AS CANTIDAD_PAGOS
FROM CP_PAGOS pa
JOIN PERSONAS p ON p.IDENTIFICADOR = pa.IDENTIFICADOR
WHERE pa.ANO_PAGO = '2026' AND pa.ESTADO_PAGO != 'AN'
GROUP BY p.IDENTIFICADOR, p.APELLIDO, p.NOMBRE, p.CUIT_CUIL
ORDER BY TOTAL_PAGADO DESC

-- 12.3 Estado de la planilla de tesorería diaria:
SELECT
    pl.ANO_PLANILLA, pl.NRO_PLANILLA, pl.FECHA_PLANILLA,
    pl.CIERRE_PLANILLA,
    pl.SALDO_ANT        AS SALDO_ANTERIOR,
    pl.INGRESO          AS TOTAL_INGRESOS,
    pl.EGRESO           AS TOTAL_EGRESOS,
    pl.SALDO            AS SALDO_FINAL,
    pl.DEPOSITADO       AS DEPOSITOS,
    pl.CHEQUE_LIB       AS CHEQUES_LIBRADOS
FROM CP_PLANILLAS pl
WHERE pl.ANO_PLANILLA = '2026'
ORDER BY pl.NRO_PLANILLA DESC

-- 12.4 Ordenes de pago pendientes de cobro por el proveedor:
SELECT op.ANO_OPAGO, op.NRO_OPAGO, p.APELLIDO, p.NOMBRE,
       op.MONTO_APAGAR, op.MANDATO_FECHA
FROM CP_ORDENES_PAGO op
JOIN PERSONAS p ON p.IDENTIFICADOR = op.IDENTIFICADOR
WHERE op.ESTADO_OPAGO = 'P'   -- pendientes
    AND op.ANO_OPAGO = '2026'
ORDER BY op.NRO_OPAGO

-- 12.5 Sueldos: resumen de liquidación del período:
SELECT
    sl.TIPO_EMP_LIQ, sl.ANO, sl.PERIODO,
    sl.DESCRIPCION, sl.DESC_PERIODO,
    sl.FECHA_LIQUIDACION, sl.FECHA_PAGO,
    sl.CERRADA,
    COUNT(DISTINCT sh.NRO_SUELDO)   AS EMPLEADOS,
    SUM(sh.REMUNERACION)            AS TOTAL_REMUNERACIONES,
    SUM(sh.DESCUENTO)               AS TOTAL_DESCUENTOS,
    SUM(sh.REMUNERACION - sh.DESCUENTO) AS NETO_TOTAL
FROM SLD_LIQUIDACION sl
JOIN SLD_SUELDO_HIST sh ON sh.TIPO_EMP_LIQ = sl.TIPO_EMP_LIQ
    AND sh.ANO = sl.ANO AND sh.PERIODO = sl.PERIODO
WHERE sl.ANO = '2026'
GROUP BY sl.TIPO_EMP_LIQ, sl.ANO, sl.PERIODO, sl.DESCRIPCION, sl.DESC_PERIODO,
         sl.FECHA_LIQUIDACION, sl.FECHA_PAGO, sl.CERRADA
ORDER BY sl.ANO, sl.PERIODO, sl.TIPO_EMP_LIQ
