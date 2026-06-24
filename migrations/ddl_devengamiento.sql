-- ============================================================
-- DDL: Tablas de Devengamiento (DEV_*)
-- Sistema PGM - Municipalidad
-- Migracion de tablas Oracle INGRESOS al SQL Server PROGRAM
-- ============================================================

USE PROGRAM;
GO

-- ── 1. DEV_TIPOS_TRIBUTOS ──────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DEV_TIPOS_TRIBUTOS')
BEGIN
  CREATE TABLE DEV_TIPOS_TRIBUTOS (
      ID_TIPO_TRIBUTO     INT             NOT NULL,
      TIPO_TRIBUTO_       VARCHAR(10)     NOT NULL,
      CONCEPTO            VARCHAR(100)    NULL,
      CONCEPTO_ABREVIADO  VARCHAR(30)     NULL,
      ID_JURISDICCION     INT             NOT NULL DEFAULT 1,
      USR_ING             VARCHAR(50)     NULL,
      FEC_ING             DATETIME        NULL DEFAULT GETDATE(),
      USR_MOD             VARCHAR(50)     NULL,
      FEC_MOD             DATETIME        NULL,
      USR_BAJA            VARCHAR(50)     NULL,
      FEC_BAJA            DATETIME        NULL,
      CONSTRAINT PK_DEV_TIPOS_TRIBUTOS PRIMARY KEY (ID_TIPO_TRIBUTO)
  );
END
GO

-- ── 2. DEV_TIPOS_CONCEPTOS ─────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DEV_TIPOS_CONCEPTOS')
BEGIN
  CREATE TABLE DEV_TIPOS_CONCEPTOS (
      ID_TIPO_CONCEPTO    INT             NOT NULL,
      ID_TIPO_TRIBUTO     INT             NULL,
      CONCEPTO            VARCHAR(100)    NOT NULL,
      DESCRIPCION         VARCHAR(500)    NULL,
      IMPACTO             VARCHAR(10)     NULL,   -- 'SUMA' / 'RESTA'
      PORCENTAJE          DECIMAL(10,5)   NULL,
      VALOR               DECIMAL(19,5)   NULL,
      OBJETO_REF          VARCHAR(100)    NULL,
      ORDEN               INT             NULL,
      TIPO_CUOTA          VARCHAR(10)     NULL,
      MASIVO              VARCHAR(1)      NULL DEFAULT 'S',
      ID_TIPO_TRIBUTO_AUX INT             NULL,
      ID_JURISDICCION     INT             NOT NULL DEFAULT 1,
      USR_ING             VARCHAR(50)     NULL,
      FEC_ING             DATETIME        NULL DEFAULT GETDATE(),
      USR_MOD             VARCHAR(50)     NULL,
      FEC_MOD             DATETIME        NULL,
      USR_BAJA            VARCHAR(50)     NULL,
      FEC_BAJA            DATETIME        NULL,
      CONSTRAINT PK_DEV_TIPOS_CONCEPTOS PRIMARY KEY (ID_TIPO_CONCEPTO)
  );
END
GO

-- ── 3. DEV_TIPOS_CONCEPTOS_ANIO ────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DEV_TIPOS_CONCEPTOS_ANIO')
BEGIN
  CREATE TABLE DEV_TIPOS_CONCEPTOS_ANIO (
      ID_TIPOCON_ANIO     INT             NOT NULL,
      ID_TIPO_CONCEPTO    INT             NOT NULL,
      ANIO_EJERCICIO      INT             NOT NULL,
      PORCENTAJE          DECIMAL(10,5)   NULL,
      VALOR               DECIMAL(19,5)   NULL,
      ID_JURISDICCION     INT             NOT NULL DEFAULT 1,
      USR_ING             VARCHAR(50)     NULL,
      FEC_ING             DATETIME        NULL DEFAULT GETDATE(),
      USR_MOD             VARCHAR(50)     NULL,
      FEC_MOD             DATETIME        NULL,
      USR_BAJA            VARCHAR(50)     NULL,
      FEC_BAJA            DATETIME        NULL,
      CONSTRAINT PK_DEV_TIPOS_CONCEPTOS_ANIO PRIMARY KEY (ID_TIPOCON_ANIO)
  );
END
GO

-- ── 4. DEV_VENCIMIENTOS ────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DEV_VENCIMIENTOS')
BEGIN
  CREATE TABLE DEV_VENCIMIENTOS (
      ID_VENCIMIENTOS     INT             NOT NULL,
      ID_TIPO_TRIBUTO     INT             NOT NULL,
      EJERCICIO           VARCHAR(4)      NOT NULL,
      NRO_CUOTA           INT             NOT NULL,
      N_TIPO              VARCHAR(10)     NULL,
      N_ZONA              VARCHAR(10)     NULL,
      FECHA_PRIMER_VTO    DATE            NOT NULL,
      DESC_PRIMER_VTO     DECIMAL(5,2)    NULL,
      FECHA_SEGUNDO_VTO   DATE            NULL,
      DESC_SEGUNDO_VTO    DECIMAL(5,2)    NULL,
      FECHA_TERCER_VTO    DATE            NULL,
      DESC_TERCER_VTO     DECIMAL(5,2)    NULL,
      ID_JURISDICCION     INT             NOT NULL DEFAULT 1,
      USR_ING             VARCHAR(50)     NULL,
      FEC_ING             DATETIME        NULL DEFAULT GETDATE(),
      USR_MOD             VARCHAR(50)     NULL,
      FEC_MOD             DATETIME        NULL,
      USR_BAJA            VARCHAR(50)     NULL,
      FEC_BAJA            DATETIME        NULL,
      CONSTRAINT PK_DEV_VENCIMIENTOS PRIMARY KEY (ID_VENCIMIENTOS)
  );
END
GO

-- ── 5. DEV_CONCEPTOS_VENCIMIENTOS ─────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DEV_CONCEPTOS_VENCIMIENTOS')
BEGIN
  CREATE TABLE DEV_CONCEPTOS_VENCIMIENTOS (
      ID_CONCEPTO_VENCIMIENTO INT          NOT NULL,
      ID_TIPO_CONCEPTO        INT          NOT NULL,
      ID_VENCIMIENTO          INT          NOT NULL,
      CUMPLIDOR               VARCHAR(1)   NULL DEFAULT 'N',
      OBSERVACION             VARCHAR(200) NULL,
      CONCEPTO_PADRE          INT          NULL,
      ID_JURISDICCION         INT          NOT NULL DEFAULT 1,
      USR_ING                 VARCHAR(50)  NULL,
      FEC_ING                 DATETIME     NULL DEFAULT GETDATE(),
      USR_MOD                 VARCHAR(50)  NULL,
      FEC_MOD                 DATETIME     NULL,
      USR_BAJA                VARCHAR(50)  NULL,
      FEC_BAJA                DATETIME     NULL,
      CONSTRAINT PK_DEV_CONCEPTOS_VENCIMIENTOS PRIMARY KEY (ID_CONCEPTO_VENCIMIENTO)
  );
END
GO

-- ── 6. DEV_TIPOS_PLANESPAGO ────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DEV_TIPOS_PLANESPAGO')
BEGIN
  CREATE TABLE DEV_TIPOS_PLANESPAGO (
      ID_TIPO_PLANESPAGO      INT          NOT NULL,
      CODIGO_PLAN             VARCHAR(20)  NOT NULL,
      DESIGNACION_PLAN        VARCHAR(100) NOT NULL,
      DECRETO_RESOLUCION      VARCHAR(50)  NULL,
      SOLO_USO_DEVENGAMIENTO  VARCHAR(1)   NULL DEFAULT 'N',
      OBSERVACIONES           VARCHAR(500) NULL,
      CANTIDAD_CUOTAS         INT          NULL,
      DIA_PRIMER_VENCIMIENTO  INT          NULL,
      ACTUALIZABLE            VARCHAR(1)   NULL DEFAULT 'S',
      PERIODO                 VARCHAR(10)  NULL,
      ID_JURISDICCION         INT          NOT NULL DEFAULT 1,
      USR_ING                 VARCHAR(50)  NULL,
      FEC_ING                 DATETIME     NULL DEFAULT GETDATE(),
      USR_MOD                 VARCHAR(50)  NULL,
      FEC_MOD                 DATETIME     NULL,
      USR_BAJA                VARCHAR(50)  NULL,
      FEC_BAJA                DATETIME     NULL,
      CONSTRAINT PK_DEV_TIPOS_PLANESPAGO PRIMARY KEY (ID_TIPO_PLANESPAGO)
  );
END
GO

-- ── 7. DEV_PLANESAGO_DET ──────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DEV_PLANESAGO_DET')
BEGIN
  CREATE TABLE DEV_PLANESAGO_DET (
      ID_PLANESAGO_DET        INT          NOT NULL,
      ID_TIPO_PLANESPAGO      INT          NOT NULL,
      CANTIDAD_CUOTAS         INT          NULL,
      FECHA_VIGENTE_DESDE     DATE         NULL,
      FECHA_VIGENTE_HASTA     DATE         NULL,
      MONTO_MIN_DEUDA         DECIMAL(19,5) NULL,
      MONTO_MAX_DEUDA         DECIMAL(19,5) NULL,
      CANT_MIN_CUOTAS         INT          NULL,
      CANT_MAX_CUOTAS         INT          NULL,
      MONTO_MIN_CUOTA         DECIMAL(19,5) NULL,
      INTERES_FINANCIACION    DECIMAL(10,5) NULL,
      CANT_CUOTAS_SIN_INTERES INT          NULL,
      ID_JURISDICCION         INT          NOT NULL DEFAULT 1,
      USR_ING                 VARCHAR(50)  NULL,
      FEC_ING                 DATETIME     NULL DEFAULT GETDATE(),
      USR_BAJA                VARCHAR(50)  NULL,
      FEC_BAJA                DATETIME     NULL,
      CONSTRAINT PK_DEV_PLANESAGO_DET PRIMARY KEY (ID_PLANESAGO_DET)
  );
END
GO

-- ── 8. DEV_OBSA_MODALIDADES ───────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DEV_OBSA_MODALIDADES')
BEGIN
  CREATE TABLE DEV_OBSA_MODALIDADES (
      ID_OBSA_MODALIDAD   INT             NOT NULL,
      DESCRIPCION         VARCHAR(100)    NULL,
      ID_JURISDICCION     INT             NOT NULL DEFAULT 1,
      USR_ING             VARCHAR(50)     NULL,
      FEC_ING             DATETIME        NULL DEFAULT GETDATE(),
      CONSTRAINT PK_DEV_OBSA_MODALIDADES PRIMARY KEY (ID_OBSA_MODALIDAD)
  );
END
GO

-- ── 9. DEV_CONFIG_INTERESES ───────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DEV_CONFIG_INTERESES')
BEGIN
  CREATE TABLE DEV_CONFIG_INTERESES (
      ID_CONFIGURACION    INT IDENTITY(1,1) NOT NULL,
      ID_TIPO_TRIBUTO     INT             NOT NULL,
      PORCENTUAL          DECIMAL(10,5)   NOT NULL,
      OBSERVACION         VARCHAR(200)    NULL,
      FECHA_DESDE         DATE            NOT NULL,
      FECHA_HASTA         DATE            NULL,
      ID_JURISDICCION     INT             NOT NULL DEFAULT 1,
      USR_ING             VARCHAR(50)     NULL,
      FEC_ING             DATETIME        NULL DEFAULT GETDATE(),
      USR_MOD             VARCHAR(50)     NULL,
      FEC_MOD             DATETIME        NULL,
      USR_BAJA            VARCHAR(50)     NULL,
      FEC_BAJA            DATETIME        NULL,
      CONSTRAINT PK_DEV_CONFIG_INTERESES PRIMARY KEY (ID_CONFIGURACION)
  );
END
GO

-- ── 10. DEV_PARAMETRICA_TRIBUTO ───────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DEV_PARAMETRICA_TRIBUTO')
BEGIN
  CREATE TABLE DEV_PARAMETRICA_TRIBUTO (
      ID_PARAM_TRIB       INT             NOT NULL,
      ID_TIPO_TRIBUTO     INT             NOT NULL,
      CONCEPTO            VARCHAR(100)    NOT NULL,
      ID_JURISDICCION     INT             NOT NULL DEFAULT 1,
      ACTIVO              INT             NOT NULL DEFAULT 1,
      MASIVO              VARCHAR(1)      NULL DEFAULT 'S',
      DECLARATIVO         VARCHAR(1)      NULL DEFAULT 'N',
      USR_ING             VARCHAR(50)     NULL,
      FEC_ING             DATETIME        NULL DEFAULT GETDATE(),
      USR_MOD             VARCHAR(50)     NULL,
      FEC_MOD             DATETIME        NULL,
      USR_BAJA            VARCHAR(50)     NULL,
      FEC_BAJA            DATETIME        NULL,
      CONSTRAINT PK_DEV_PARAMETRICA_TRIBUTO PRIMARY KEY (ID_PARAM_TRIB)
  );
END
GO

-- ── 11. DEV_PORCENTAJE_CARGA (motor V2 — estado de ejecución) ─────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DEV_PORCENTAJE_CARGA')
BEGIN
  CREATE TABLE DEV_PORCENTAJE_CARGA (
      ID_PORCENTAJE_CARGA INT IDENTITY(1,1) NOT NULL,
      ID_JURISDICCION     INT             NOT NULL DEFAULT 1,
      ID_TIPO_TRIBUTO     INT             NULL,
      PORCENTAJE          DECIMAL(5,2)    NOT NULL DEFAULT 0,
      ESTADO              VARCHAR(20)     NOT NULL DEFAULT 'PENDIENTE',
                                          -- PENDIENTE / EN_PROCESO / COMPLETADO / ERROR / CANCELADO
      MENSAJE             VARCHAR(500)    NULL,
      FEC_INICIO          DATETIME        NULL,
      FEC_FIN             DATETIME        NULL,
      USR_OPERADOR        VARCHAR(50)     NULL,
      EJERCICIO           VARCHAR(4)      NULL,
      FEC_ING             DATETIME        NOT NULL DEFAULT GETDATE(),
      USR_ING             VARCHAR(50)     NOT NULL DEFAULT 'SISTEMA',
      CONSTRAINT PK_DEV_PORCENTAJE_CARGA PRIMARY KEY (ID_PORCENTAJE_CARGA)
  );
END
GO

-- ── 12. DEV_DEVENGAMIENTO_LOG (motor V2 — historial) ─────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DEV_DEVENGAMIENTO_LOG')
BEGIN
  CREATE TABLE DEV_DEVENGAMIENTO_LOG (
      ID_LOG              INT IDENTITY(1,1) NOT NULL,
      ID_JURISDICCION     INT             NOT NULL DEFAULT 1,
      ID_TIPO_TRIBUTO     INT             NULL,
      TIPO_TRIBUTO        VARCHAR(50)     NULL,
      EJERCICIO           VARCHAR(4)      NULL,
      RESULTADO           VARCHAR(20)     NOT NULL,   -- EXITOSO / ERROR / CANCELADO
      MENSAJE             VARCHAR(2000)   NULL,
      FEC_EJECUCION       DATETIME        NOT NULL DEFAULT GETDATE(),
      USR_OPERADOR        VARCHAR(50)     NULL,
      CUENTAS_PROCESADAS  INT             NULL,
      CUENTAS_DEVENGADAS  INT             NULL,
      CUENTAS_ERROR       INT             NULL,
      DURACION_SEGUNDOS   INT             NULL,
      CONSTRAINT PK_DEV_DEVENGAMIENTO_LOG PRIMARY KEY (ID_LOG)
  );
  CREATE INDEX IX_DEV_DEVENGAMIENTO_LOG_JUR ON DEV_DEVENGAMIENTO_LOG (ID_JURISDICCION, FEC_EJECUCION DESC);
END
GO

-- ── Índices adicionales ────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DEV_VENCIMIENTOS_TRIBUTO_EJ')
  CREATE INDEX IX_DEV_VENCIMIENTOS_TRIBUTO_EJ ON DEV_VENCIMIENTOS (ID_TIPO_TRIBUTO, EJERCICIO) WHERE USR_BAJA IS NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DEV_TIPOS_CONCEPTOS_ANIO_EJ')
  CREATE INDEX IX_DEV_TIPOS_CONCEPTOS_ANIO_EJ ON DEV_TIPOS_CONCEPTOS_ANIO (ANIO_EJERCICIO) WHERE FEC_BAJA IS NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DEV_PORCENTAJE_CARGA_ACTIVO')
  CREATE INDEX IX_DEV_PORCENTAJE_CARGA_ACTIVO ON DEV_PORCENTAJE_CARGA (ID_JURISDICCION, FEC_FIN) WHERE FEC_FIN IS NULL;
GO

PRINT 'DDL devengamiento aplicado correctamente.';
GO
