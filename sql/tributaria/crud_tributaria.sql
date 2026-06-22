-- ==========================================================================
-- SCRIPTS CRUD — ADMINISTRACIÓN TRIBUTARIA
-- Base de datos: PROGRAM (SQL Server 149.50.144.8)
-- Generado: 2026-06-22
-- ==========================================================================
-- NOMENCLATURA CLAVE:
--   IDENTIFICADOR char(5)  = ID global de persona (ej: '00002', '01TFO')
--   ID_BIEN       char(5)  = ID del bien/cuenta tributaria (ej: '04JNC')
--   TIPO_BIEN     char(4)  = tipo de tributo (AUAU, ININ, CICI, OBSA, PEPE...)
--   NRO_INTERNO   char(10) = clave de factura/cedulon (ej: '0000000001')
-- Los IDs char(5) usan codificacion base-36 (0-9 + A-Z)
-- ==========================================================================


-- ==========================================================================
-- UTILIDAD: Generacion de nuevo IDENTIFICADOR / ID_BIEN
-- El sistema usa una tabla GEN_CONTADOR para los contadores de ID de persona.
-- Para ID_BIEN se debe consultar el MAX actual por TIPO_BIEN.
-- ==========================================================================
-- Ver próximo ID de persona disponible:
SELECT CONTADOR FROM GEN_CONTADOR WHERE TIPO_CONTADOR = 'ID_PERSONA'

-- Ver máximo ID_BIEN actual por tipo (para calcular el siguiente):
SELECT TIPO_BIEN, MAX(ID_BIEN) as ULTIMO_ID, COUNT(*) as TOTAL
FROM RT_PADRON_BASE
GROUP BY TIPO_BIEN
ORDER BY TIPO_BIEN


-- ══════════════════════════════════════════════════════════════════════════
-- 1. ALTA DE PERSONA / CONTRIBUYENTE
-- Tabla: PERSONAS (66,259 registros)
-- ══════════════════════════════════════════════════════════════════════════
-- La aplicación debe generar el IDENTIFICADOR (char 5) antes de insertar.
-- El sistema usa codificación base-36 para convertir un contador secuencial.
-- Tipos de documento: 1=DNI, 2=LE, 3=LC, 5=CUIT, 6=CI Córdoba (ver AFIP_TIPO_DOCUMENTOS)
-- PAIS estándar: 'ARGE'

INSERT INTO PERSONAS (
    IDENTIFICADOR,          -- char(5) PK — generado por la app (base-36)
    TIPO_DOCUMENTO,         -- char(15) — '1'=DNI, '5'=CUIT
    DOCUMENTO,              -- char(11) — número de DNI/CUIT
    APELLIDO,               -- varchar(100)
    NOMBRE,                 -- varchar(100)
    APELLIDO_NOMBRE,        -- varchar(210) — concat 'APELLIDO NOMBRE' (para búsquedas)
    CUIT_CUIL,              -- char(11)
    SEXO,                   -- char(1) — 'M' o 'F'
    FECHA_NACIMIENTO,       -- datetime
    CALLE_NOCOD,            -- varchar(30) — nombre de calle sin codificar
    NUMERACION_CALLE,       -- char(5)
    DEPARTAMENTO,           -- char(4) — depto/oficina
    PISO,                   -- char(4)
    BARRIO,                 -- varchar(30)
    CODIGO_POSTAL_AUXILIAR, -- char(8) — ej: '00000453' para Malagueño
    CODIGO_PROVINCIA,       -- char(15) — ej: 'X' para Córdoba
    PAIS,                   -- char(4) — 'ARGE'
    TELEFONO,               -- varchar(100)
    TELEFONO_MOVIL,         -- varchar(100)
    E_MAIL,                 -- varchar(300)
    CODIGO_POSTAL_AMPLIADO, -- char(14)
    CODIGO_POSTAL_SUFIJO,   -- varchar(3) NOT NULL — usar ''
    FECHA_AC                -- datetime — GETDATE()
)
VALUES (
    '04JND',                -- REEMPLAZAR con el próximo ID generado
    '1             ',       -- DNI (notar: 15 chars, rellenar con espacios)
    '28123456789',          -- 11 dígitos, sin guiones
    'GARCIA',
    'JUAN CARLOS',
    'GARCIA                        JUAN',  -- 210 chars, apellido primero
    '20281234567',          -- CUIT sin guiones
    'M',
    '1985-03-15',
    'SAN MARTIN',           -- nombre de calle
    '123  ',                -- 5 chars
    '    ',                 -- 4 chars (vacío = espacios)
    '    ',                 -- 4 chars (vacío = espacios)
    'MALAGUEÑO',
    '00000453',             -- código postal auxiliar
    'X              ',      -- provincia Córdoba = 'X'
    'ARGE',
    '351123456',
    '3511234567',
    'jgarcia@email.com',
    'X-5101-___    ',
    '',
    GETDATE()
)


-- ══════════════════════════════════════════════════════════════════════════
-- 2. MODIFICACION DE PERSONA
-- ══════════════════════════════════════════════════════════════════════════
UPDATE PERSONAS SET
    CALLE_NOCOD         = 'BELGRANO',
    NUMERACION_CALLE    = '456  ',
    BARRIO              = 'CENTRO',
    TELEFONO_MOVIL      = '3519876543',
    E_MAIL              = 'nuevo@email.com',
    FECHA_AC            = GETDATE()
WHERE IDENTIFICADOR = '04JND'

-- Registrar el cambio de domicilio en el histórico:
INSERT INTO PERSONAS_DOMICILIO_HIST (
    IDENTIFICADOR,
    CALLE_NOCOD, CODIGO_CALLE, NUMERACION_CALLE, PISO, DEPARTAMENTO,
    TORRE, BARRIO, CODIGO_PROVINCIA, PAIS,
    TELEFONO, TELEFONO_MOVIL, E_MAIL,
    CODIGO_POSTAL_REAL, CODIGO_POSTAL_AUXILIAR, CODIGO_POSTAL_AMPLIADO,
    USUARIO, DIRECCION_IP, FECHA_HISTORICO
)
SELECT
    IDENTIFICADOR,
    CALLE_NOCOD, CODIGO_CALLE, NUMERACION_CALLE, PISO, DEPARTAMENTO,
    TORRE, BARRIO, CODIGO_PROVINCIA, PAIS,
    TELEFONO, TELEFONO_MOVIL, E_MAIL,
    CODIGO_POSTAL_AUXILIAR, CODIGO_POSTAL_AUXILIAR, CODIGO_POSTAL_AMPLIADO,
    'SISTEMA', '0.0.0.0', GETDATE()
FROM PERSONAS WHERE IDENTIFICADOR = '04JND'


-- ══════════════════════════════════════════════════════════════════════════
-- 3. ALTA DE BIEN EN EL PADRON (RT_PADRON_BASE)
-- Tabla principal que conecta persona ↔ tipo de tributo
-- ══════════════════════════════════════════════════════════════════════════
-- Debe ejecutarse DESPUÉS de crear la PERSONA (IDENTIFICADOR debe existir)
-- ID_BIEN debe ser un nuevo código base-36 único
-- TIPO_PLAN: '1 ' = plan general para la mayoría de los tipos de bien

INSERT INTO RT_PADRON_BASE (
    ID_BIEN,                    -- char(5) PK — nuevo código base-36
    TIPO_BIEN,                  -- char(4) — AUAU/ININ/CICI/OBSA/PEPE/CECE/etc.
    CODIGO_IMPRESION,           -- char(15) — código para cedulones (CLAVE_BIEN o similar)
    IDENTIFICADOR,              -- char(5) — FK → PERSONAS
    CLAVE_BIEN,                 -- char(50) — clave externa: patente/partida catastral/CUIT
    ACTIVO,                     -- char(1) — '1'=activo
    IMPRIME,                    -- char(1) — '1'=imprime cedulones
    EXENCION,                   -- char(4) — 'NOEX'=sin exención, 'EX01'=exento
    TIPO_PLAN,                  -- char(2) — '1 '=plan general
    FECHA_ALTA,                 -- datetime
    MONTO_DEUDA_HISTORICO,      -- money — iniciar en 0
    MONTO_DEUDA_ACTUALIZADO,    -- money — iniciar en 0
    LIQ_DESDE                   -- datetime — desde cuándo liquidar
)
VALUES (
    '04JNE',        -- próximo ID libre (base-36)
    'AUAU',         -- automotor en este ejemplo
    'ABX123',       -- patente como código de impresión
    '04JND',        -- IDENTIFICADOR del titular
    'ABX123     ',  -- CLAVE_BIEN = patente (50 chars)
    '1',
    '1',
    'NOEX',
    '1 ',
    GETDATE(),
    0.00,
    0.00,
    GETDATE()
)


-- ══════════════════════════════════════════════════════════════════════════
-- 4. ALTA DE AUTOMOTOR (RT_AUTOMOTORES)
-- Ejecutar junto con RT_PADRON_BASE (mismo ID_BIEN → ID_AUTOMOTOR)
-- ══════════════════════════════════════════════════════════════════════════
-- CIP: código de tipo de vehículo (ver RT_AUTOMOTORES_TIPOS)
-- ANO_VALUACION: año de la tabla de valuación (ej: '2025')
-- TIPO_CATEGORIA_AUTOMOTOR: A1=auto, C1=camión, M1=moto, L1=liviano
-- TIPO_ALTA: '01'=compra nueva, '05'=transferencia

INSERT INTO RT_AUTOMOTORES (
    ID_AUTOMOTOR,               -- char(5) = mismo ID_BIEN de RT_PADRON_BASE
    TIPO_CATEGORIA_AUTOMOTOR,   -- char(4) — A1/A2/.../C1/.../M1...
    CIP,                        -- char(10) — código interno del modelo
    ANO_VALUACION,              -- char(4) — año tabla valuación
    MODELO_AUTOMOTOR,           -- int — año de fabricación
    NRO_MOTOR,                  -- char(24)
    NRO_CHASIS,                 -- char(50)
    CERTIFICADO_FABRICACION,    -- char(30)
    NRO_ADUANA,                 -- char(20)
    MARCA_VEHICULO,             -- char(50)
    DESCRIPCION_INDIVIDUAL,     -- char(50)
    ESTADO_RENTA_AUTOMOTOR,     -- char(1) — ' '=activo
    HP_VEHICULO,                -- char(4) — caballos de fuerza
    PESO_CILINDRADA,            -- char(5) — cilindrada en cc
    IMPORTADO,                  -- char(1) — 'N' o 'S'
    PATENTE_ANTERIOR,           -- char(10)
    VIN,                        -- char(30)
    TIPO_ALTA,                  -- char(4)
    VALOR_FACTURA,              -- money
    DATO1, DATO2, DATO3,        -- char(30) — datos extra
    REN_ESTADO,                 -- char(1) — ' '
    USA_IMP_ANUAL,              -- char(1) — '0'=no usa importe anual fijo
    IMP_ANUAL,                  -- money — 0 si usa alícuota
    CARGA                       -- money
)
VALUES (
    '04JNE',        -- mismo ID que RT_PADRON_BASE
    'A1  ',         -- automóvil categoría 1
    '          ',   -- CIP (completar con código correcto)
    '2025',
    2018,           -- año de fabricación
    'ABC123DEF      ',
    'AAABBBCCC123456789         ',
    '                              ',
    '                    ',
    'VOLKSWAGEN GOLF            ',
    'VOLKSWAGEN GOLF            ',
    ' ',
    '     ',         -- HP
    '1598 ',         -- 1598cc
    'N',
    'ABX123    ',    -- patente anterior
    '                              ',
    '01  ',          -- alta nueva
    0.00,
    '                              ',
    '                              ',
    '                              ',
    ' ',
    '0',
    0.00,
    0.00
)


-- ══════════════════════════════════════════════════════════════════════════
-- 5. ALTA DE INMUEBLE (RT_PADRON_BASE + RT_CATASTRO)
-- TIPO_BIEN = 'ININ' (inmobiliario) o 'CACA' (catastro)
-- ══════════════════════════════════════════════════════════════════════════
-- Para inmuebles: RT_CATASTRO.ID_CATASTRO = RT_PADRON_BASE.ID_BIEN

INSERT INTO RT_CATASTRO (
    ID_CATASTRO,                -- char(5) = mismo ID_BIEN
    CODIGO_CALLE,               -- char(15) — código interno de la calle
    CODIGO_POSTAL_AUXILIAR,     -- char(8)
    NRO_RENTA,                  -- char(30) — número de partida catastral
    CALLE_NOCOD,                -- char(30)
    NUMERACION_CALLE,           -- char(5)
    PISO,                       -- char(4)
    BARRIO,                     -- char(40)
    DEPARTAMENTO,               -- char(4)
    ESQUINA_MEDIAL,             -- char(2) — '04'=medial típico
    SUPERFICIE_TERRENO,         -- money — m²
    COEFICIENTE_FRENTE_FONDO,   -- money — ej: 1.10
    PORCENTAJE_COPROPIEDAD,     -- money — 0=propiedad total
    DESIGNACION_OFICIAL,        -- char(40) — ej: 'MZ: A-LT: 6'
    FOLIO1,                     -- char(30)
    ANO1,                       -- char(4)
    NRO_MATRICULA_FOLIO_REAL,   -- char(30) — ej: '31-0875604-00000-00'
    BALDIO_EDIFICADO,           -- char(2) — '01'=edificado, '02'=baldío
    BASE_IMPONIBLE,             -- money — base para cálculo impositivo
    TASACION_TERRENO,           -- money
    METROS_FRENTE,              -- money
    VALOR_TERRENO,              -- money — $/m²
    VALOR_EDIFICADO,            -- money
    CODIGO_POSTAL_AMPLIADO,     -- char(14)
    CODIGO_POSTAL_SUFIJO        -- varchar(3) NOT NULL — ''
)
VALUES (
    '04JNF',
    '078            ',
    '00000453',
    '3101-0000001/1                ',
    'BELGRANO                      ',
    '456  ',
    '    ',
    'MALAGUEÑO                       ',
    '    ',
    '04',
    300.00,         -- 300 m² de terreno
    1.10,
    0.00,
    'MZ: B-LT: 5                    ',
    '12345                         ',
    '2020',
    '31-0000001-00000-00           ',
    '01',            -- edificado
    0.00,           -- base imponible (la liquida el SP)
    0.00,
    10.00,          -- metros de frente
    1.80,           -- valor terreno $/m²
    0.00,
    'X-5101-___    ',
    ''
)

-- También para OBSA/OBSC (agua/cloaca), agregar en RT_SERV_PROPIEDAD:
INSERT INTO RT_SERV_PROPIEDAD (ID_SERVICIO_PROPIEDAD, ID_CATASTRO, DATO1, DATO2, DATO3)
VALUES ('04JNF', '04JNF', NULL, NULL, NULL)


-- ══════════════════════════════════════════════════════════════════════════
-- 6. ALTA DE COMERCIO / HABILITACION COMERCIAL (RT_COMERCIO_INDUSTRIA)
-- TIPO_BIEN = 'CICI'
-- ══════════════════════════════════════════════════════════════════════════
INSERT INTO RT_COMERCIO_INDUSTRIA (
    ID_COMERCIO_INDUSTRIA,  -- char(5) = ID_BIEN
    CLASIFICACION,          -- char(4) — rubro (ver tabla de rubros)
    NOMBRE_FANTASIA,        -- char(50)
    NOMBRE_SOCIEDAD,        -- char(50)
    TIPO_SOCIEDAD,          -- char(4) — 'SAS ','SRL ','SA  ','UNIP'
    CUIT,                   -- char(11)
    INGRESOS_BRUTOS,        -- char(15) — nro ingresos brutos provincial
    IVA,                    -- char(10) — 'RESINS    '=resp. inscripto
    CALLE_NOCOD,            -- char(30)
    NUMERACION_CALLE,       -- char(5)
    PISO,                   -- char(4)
    DEPARTAMENTO,           -- char(4)
    TORRE,                  -- char(30)
    BARRIO,                 -- char(40)
    CODIGO_POSTAL_AUXILIAR,
    RESOLUCION_HABILITACION,-- char(15) — nro resolución de habilitación
    RESOLUCION_BAJA,        -- char(15) — vacío al dar de alta
    TASA_FINAL,             -- money — monto fijo para tasa (0 si por DDJJ)
    CAPITAL_DECLARADO,      -- money
    PERSONAL_OCUPADO,       -- int
    TIPO_CONTRIBUYENTE,     -- char(4) — 'DDJJ'=declaración jurada
    CODIGO_POSTAL_AMPLIADO,
    CODIGO_POSTAL_SUFIJO,
    TELEFONO, TELEFONO_MOVIL, E_MAIL
)
VALUES (
    '04JNG',
    '0001',              -- clasificación/rubro
    'FERRETERIA EL TORNILLO     ',
    'GARCIA JUAN CARLOS         ',
    'UNIP',
    '20281234567',
    '123456789      ',
    'RESINS    ',
    'SAN MARTIN                ',
    '123  ', '    ', '    ',
    '                              ',
    'MALAGUEÑO                       ',
    '00000453',
    '001/2026       ',
    '               ',
    0.00,
    50000.00,
    3,
    'DDJJ',
    'X-5101-___    ', '',
    '351123456', '3511234567', 'ferreteria@email.com'
)


-- ══════════════════════════════════════════════════════════════════════════
-- 7. CONSULTA DE DEUDA DE UN CONTRIBUYENTE
-- ══════════════════════════════════════════════════════════════════════════
-- Consulta completa: persona → bienes → facturas pendientes → cedulones
SELECT
    p.IDENTIFICADOR,
    p.APELLIDO + ', ' + p.NOMBRE         AS CONTRIBUYENTE,
    p.CUIT_CUIL,
    pb.TIPO_BIEN,
    pb.CLAVE_BIEN,
    pb.SITUACION_DEUDA,                  -- RE=regular, BL=bloqueado, JU=judicial
    f.NRO_INTERNO,
    f.ANO_CUOTA + '/' + f.NRO_CUOTA      AS PERIODO,
    f.ESTADO_DEUDA,                      -- PT=pendiente, LI=cobrado, CA=caducado
    f.CAPITAL_FACTURADO,
    f.INTERESES_FACTURADOS,
    f.CAPITAL_COBRADO,
    f.FEC_ULT_PAGO,
    fd.NRO_INTERNO_DEUDA,
    fd.MONTO_ACTUALIZADO_CAPITAL + fd.MONTO_ACTUALIZADO_INTERESES  AS DEUDA_TOTAL_ACTUALIZADA,
    fd.IMP_1VENCE                        AS MONTO_ANTES_1ER_VENCE,
    fd.FECHA_VENCIMIENTO1,
    fd.IMP_2VENCE                        AS MONTO_ANTES_2DO_VENCE,
    fd.FECHA_VENCIMIENTO2,
    fd.IMP_3VENCE                        AS MONTO_CON_RECARGO,
    fd.FECHA_VENCIMIENTO3
FROM PERSONAS p
JOIN RT_PADRON_BASE pb
    ON pb.IDENTIFICADOR = p.IDENTIFICADOR
JOIN RT_FACTURAS f
    ON f.ID_BIEN = pb.ID_BIEN
    AND f.TIPO_BIEN = pb.TIPO_BIEN
    AND f.ESTADO_DEUDA = 'PT'            -- solo pendientes
JOIN RT_FACTURAS_DEUDA_DETALLE fdd
    ON fdd.NRO_INTERNO = f.NRO_INTERNO
JOIN RT_FACTURAS_DEUDA fd
    ON fd.NRO_INTERNO_DEUDA = fdd.NRO_INTERNO_DEUDA
    AND fd.ESTADO_DEUDA = 'LI'          -- cedulón activo
WHERE p.CUIT_CUIL = '20281234567'       -- ← parámetro de búsqueda
ORDER BY pb.TIPO_BIEN, f.ANO_CUOTA, f.NRO_CUOTA

-- Consulta rápida por IDENTIFICADOR (deuda total consolidada por tipo):
SELECT
    dp.TIPO_BIEN,
    dp.MONTO_DEUDA_HISTORICO,
    dp.MONTO_DEUDA_ACTUALIZADO,
    dp.FECHA_ACTUALIZACION_DEUDA
FROM RT_DEUDA_PERSONA dp
WHERE dp.IDENTIFICADOR = '04JND'
ORDER BY dp.TIPO_BIEN


-- ══════════════════════════════════════════════════════════════════════════
-- 8. BUSQUEDA DE CONTRIBUYENTE
-- ══════════════════════════════════════════════════════════════════════════
-- Por CUIT/CUIL:
SELECT IDENTIFICADOR, APELLIDO, NOMBRE, CUIT_CUIL, E_MAIL, TELEFONO_MOVIL
FROM PERSONAS
WHERE CUIT_CUIL = '20281234567'

-- Por apellido (búsqueda parcial):
SELECT IDENTIFICADOR, APELLIDO, NOMBRE, CUIT_CUIL, DOCUMENTO
FROM PERSONAS
WHERE APELLIDO LIKE 'GARCIA%'
ORDER BY APELLIDO, NOMBRE

-- Por DNI:
SELECT IDENTIFICADOR, APELLIDO, NOMBRE, CUIT_CUIL
FROM PERSONAS
WHERE DOCUMENTO = '28123456'
AND TIPO_DOCUMENTO LIKE '1%'   -- '1' = DNI

-- Ver todos los bienes de un contribuyente:
SELECT pb.TIPO_BIEN, pb.ID_BIEN, pb.CLAVE_BIEN, pb.ACTIVO, pb.SITUACION_DEUDA,
       pb.MONTO_DEUDA_HISTORICO, pb.MONTO_DEUDA_ACTUALIZADO
FROM RT_PADRON_BASE pb
WHERE pb.IDENTIFICADOR = '04JND'
ORDER BY pb.TIPO_BIEN


-- ══════════════════════════════════════════════════════════════════════════
-- 9. REGISTRAR COBRO — via Stored Procedure existente
-- ══════════════════════════════════════════════════════════════════════════
-- El cobro se hace en 2 pasos:
-- Paso 1: Actualizar valores de deuda (calcula intereses al día)
-- Paso 2: Registrar el pago

-- PASO 1: Generar ID de proceso y actualizar deuda
DECLARE @ID_PROCESS CHAR(8)
-- (El ID de proceso se genera con sp_rt_Nro_ID_Process o similar)
-- Luego ejecutar la actualización de valores:
EXEC SP_RT_VAL_DEUDA_ACT
    @NRO_INTERNO  = '0000000001',   -- NRO_INTERNO de la factura
    @ID_PROCESS   = '00000001',     -- ID del proceso
    @FECHA_PAGO   = '2026-06-22'    -- fecha de pago para calcular intereses

-- PASO 2: Registrar el pago total
DECLARE @CODERR CHAR(5), @MSG CHAR(255)
EXEC CREA_PAGO_TOTAL
    @NRO_INTERNO = '0000000001',
    @ID_PROCESS  = '00000001',
    @FECHA_PAGO  = '2026-06-22',
    @CODERR      = @CODERR OUTPUT,
    @MSG         = @MSG OUTPUT
SELECT @CODERR AS RESULTADO, @MSG AS MENSAJE


-- ══════════════════════════════════════════════════════════════════════════
-- 10. CAMBIO DE TITULARIDAD DE UN BIEN (ej: venta de automotor)
-- ══════════════════════════════════════════════════════════════════════════
-- Solo actualizar el IDENTIFICADOR del titular en RT_PADRON_BASE
BEGIN TRANSACTION
    UPDATE RT_PADRON_BASE
    SET IDENTIFICADOR = '04JNH',    -- nuevo titular
        FECHA_AC      = GETDATE()
    WHERE ID_BIEN   = '04JNE'
    AND   TIPO_BIEN = 'AUAU'

    -- Registrar en auditoría (si existe tabla de auditoría para cambios de titular)
    -- INSERT INTO RT_PADRON_BASE_AUDITORIA ... (verificar si existe)
COMMIT TRANSACTION


-- ══════════════════════════════════════════════════════════════════════════
-- 11. BAJA DE BIEN (desactivar, no eliminar)
-- El sistema NO elimina — pone ACTIVO='0' y registra FECHA_BAJA
-- ══════════════════════════════════════════════════════════════════════════
UPDATE RT_PADRON_BASE
SET ACTIVO     = '0',
    IMPRIME    = '0',
    FECHA_BAJA = GETDATE(),
    LIQ_HASTA  = GETDATE()
WHERE ID_BIEN   = '04JNE'
AND   TIPO_BIEN = 'AUAU'

-- Para automotores: actualizar estado en RT_AUTOMOTORES también
UPDATE RT_AUTOMOTORES
SET ESTADO_RENTA_AUTOMOTOR = 'B'   -- B=Baja
WHERE ID_AUTOMOTOR = '04JNE'


-- ══════════════════════════════════════════════════════════════════════════
-- 12. ALTA DE USUARIO EN PORTAL WEB (egov_CFM)
-- Password en MD5 — el servidor debe hashear antes de insertar
-- ══════════════════════════════════════════════════════════════════════════
INSERT INTO egov_CFM (Identificador, Habilitado, Password)
VALUES (
    '04JND',    -- IDENTIFICADOR del contribuyente
    1,          -- Habilitado
    MD5('contraseña_del_usuario')  -- En SQL Server usar HASHBYTES y convertir
    -- Alternativa SQL Server:
    -- CONVERT(VARCHAR(32), HASHBYTES('MD5', 'password'), 2)
)

-- Habilitar/deshabilitar acceso al portal:
UPDATE egov_CFM SET Habilitado = 1 WHERE Identificador = '04JND'
UPDATE egov_CFM SET Habilitado = 0 WHERE Identificador = '04JND'


-- ══════════════════════════════════════════════════════════════════════════
-- 13. CONSULTAS DE APOYO — Tablas de referencia
-- ══════════════════════════════════════════════════════════════════════════
-- Ver todos los tipos de bien disponibles:
SELECT TIPO_BIEN, CONCEPTO FROM RT_BIENES ORDER BY TIPO_BIEN

-- Ver planes de pago disponibles por tipo de bien:
SELECT TIPO_BIEN, TIPO_PLAN, DESIGNACION_PLAN, CANTIDAD_CUOTAS
FROM RT_PLANES_TIPO
WHERE TIPO_BIEN = 'AUAU'
ORDER BY TIPO_PLAN

-- Ver estados de deuda de un bien:
SELECT ESTADO_DEUDA, COUNT(*) as CANTIDAD
FROM RT_FACTURAS
WHERE ID_BIEN = '04JNE' AND TIPO_BIEN = 'AUAU'
GROUP BY ESTADO_DEUDA
-- PT=Pendiente, LI=Libre/Cobrado, CA=Caducado, FI=Financiado

-- Ver tasas de actualización (intereses) vigentes:
SELECT INTERES, FECHA, RESAR as TASA_MENSUAL_PCT
FROM RT_ACTUALIZACION
ORDER BY INTERES, FECHA

-- Ver tabla de valuación de automotores (base imponible):
SELECT av.ANO_VALUACION, av.CIP, av.MODELO_VALUACION, av.BASE_IMPONIBLE,
       ta.ALICUOTA as ALICUOTA_GENERAL
FROM RT_AUTOMOTORES_VALUACION av
LEFT JOIN RT_AUTOMOTORES_TARIFARIA ta ON ta.ANO_VALUACION = av.ANO_VALUACION
WHERE av.ANO_VALUACION = '2025'
ORDER BY av.MODELO_VALUACION
