# Investigación: Base de Datos PROGRAM — Administración Tributaria
**Servidor:** 149.50.144.8 | **Base de datos:** PROGRAM  
**Fecha de investigación:** 2026-06-22  
**Total tablas en BD:** 2601 | **Módulos investigados:** RT_, CJC_, NT_, RNPA_, MAL_, JF_, egov_, AFIP_

---

## 1. Resumen del Sistema

El sistema PROGRAM es una plataforma de gestión tributaria municipal integral. Administra todos los tributos del municipio: inmuebles, automotores, comercio, obras, servicios (agua, cloaca, internet, telefonía) y multas. El módulo central es el prefijo `RT_` (Rentas/Tributos) con 507 tablas y ~260M filas históricas.

---

## 2. Tipos de Bienes/Tributos (RT_BIENES — tabla catálogo)

| TIPO_BIEN | Concepto completo | Descripción |
|-----------|-------------------|-------------|
| AUAU | Automotores | Patente de rodados |
| CACA | Catastro | Tasa de catastro |
| CECE | Cementerio | Tasa de cementerio |
| CICI | Comercio e Industria | Habilitación comercial + DDJJ |
| ININ | Tasa por Servicio a la Propiedad | Inmobiliario (principal) |
| OB05 | Mantenimiento Alumbrado Público | Contribución MAP |
| OBAG | Obra Red de Agua | Contribución por mejora |
| OBCA | Cartelería | |
| OBCL | Obra de Cloacas | |
| OBCU | Obra de Cordón Cuneta | |
| OBDE | Obra de Desagüe | |
| OBEA | Contribución por Antenas | |
| OBEL | Obra de Red Eléctrica | |
| OBFI | Fibra Óptica | |
| OBGA | Obra de Gas | |
| OBIN | Obra de Infraestructura | |
| OBME | Obra de Mejoras | |
| OBNI | Obra de Nivelación | |
| OBPA | Obra Adoquines | |
| OBPV | Obra de Pavimento | |
| OBSA | Servicio de Agua | |
| OBSC | Servicio de Cloaca | |
| OBSI | Servicio de Internet | |
| OBTE | Obra de Terrenos | |
| OBVI | Obra de Vivienda | |
| OPOP | Obras Privadas | Habilitación obras privadas |
| PEPE | Tasa Personal | |
| RPRP | Agentes Retenciones / Percepciones | |
| TETE | Telefonía | |
| ACTA | Actas | (Juzgado de Faltas) |

**Distribución por volumen de padrones:**
- PEPE (Tasa Personal): 43.765 bienes
- AUAU (Automotores): 32.222 bienes
- CACA (Catastro): 21.839 bienes
- ININ (Inmobiliario): 21.254 bienes
- OBSA (Agua): 15.547 bienes
- OBSC (Cloaca): 15.419 bienes
- OPOP (Obras Privadas): 7.289 bienes

---

## 3. Identificación de Contribuyentes

### Estructura de identificación (RT_PADRON_BASE)
El padrón usa un sistema de identificación múltiple:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `ID_BIEN` | char(5) | Identificador único del bien dentro del tipo |
| `TIPO_BIEN` | char(4) | Categoría del tributo (AUAU, ININ, CICI, etc.) |
| `IDENTIFICADOR` | char(5) | Vincula al titular (FK → tabla PERSONAS) |
| `CLAVE_BIEN` | char(50) | Clave externa (ej: nro de dominio, padrón catastral) |
| `CODIGO_IMPRESION` | char(15) | Código de impresión del cedulón |
| `ID_ENTE` | int | Referencia a entidad externa |

**La clave primaria de negocio es: `(ID_BIEN, TIPO_BIEN)`**  
El titular es `IDENTIFICADOR` → FK a tabla `PERSONAS` (tabla maestra de personas fuera del prefijo RT_)

### Columnas clave de RT_PADRON_BASE
```
ID_BIEN          char(5)    NO NULL  — ID interno del bien
TIPO_BIEN        char(4)    NO NULL  — tipo de tributo
CODIGO_IMPRESION char(15)   NO NULL  — para generación de cedulones
IDENTIFICADOR    char(5)    NO NULL  — titular (→ PERSONAS)
CLAVE_BIEN       char(50)   NO NULL  — número catastral / dominio / etc.
ACTIVO           char(1)    NO NULL  — 1=activo, 0=baja
EXENCION         char(4)    NO NULL  — código de exención (EX01=exento)
SITUACION_DEUDA  char(2)    NULL     — situación consolidada del bien
MONTO_DEUDA_HISTORICO   money      — deuda acumulada histórica
MONTO_DEUDA_ACTUALIZADO money      — deuda actualizada
FECHA_ALTA       datetime   NULL
FECHA_BAJA       datetime   NULL
LIQ_DESDE/HASTA  datetime   NULL     — rango de liquidación habilitado
TIPO_PLAN        char(2)    NO NULL  — plan de cuotas asignado
```

---

## 4. Estados de Deuda

### Estados en RT_FACTURAS (ESTADO_DEUDA)
| Código | Descripción | Cantidad |
|--------|-------------|----------|
| PT | Pendiente | 3.523.283 |
| LI | Libre (cobrado) | 1.820.868 |
| CA | Caducado | 443.834 |
| FI | Financiado | 441.414 |
| RT | Retenido | 113.329 |
| CO | Compensado | 10.402 |
| RE | Rebajado | 4 |

### Situación de Deuda en RT_FACTURAS (SITUACION_DEUDA)
| Código | Descripción | Cantidad |
|--------|-------------|----------|
| RE | Regular (normal) | 5.604.330 |
| BL | Bloqueado | 686.612 |
| JU | Judicial | 49.305 |
| DE | Demanda | 12.887 |

### Estados en RT_FACTURAS_DEUDA (ESTADO_DEUDA)
| Código | Cantidad |
|--------|----------|
| LI | Libre/Pendiente de cobro | 4.194.699 |
| PT | Pagado/Transitorio | 792.405 |
| CA | Caducado | 6.520 |

### Tipos de Deuda en RT_FACTURAS_DEUDA (TIPO_DEUDA)
| Código | Descripción | Cantidad |
|--------|-------------|----------|
| CT | Cuota tradicional | 1.898.581 |
| ED | Emisión directa | 1.760.347 |
| (vacío) | Sin tipo | 616.649 |
| IT | Intereses | 341.557 |
| NT | Nota de débito | 207.756 |
| SU | Subitem / deuda derivada | 108.434 |
| CN | Condonado | 53.800 |
| RD | Retroactivo | 3.757 |
| AC | A cuenta | 2.066 |
| VC | Vencimiento corriente | 673 |
| DJ | Declaración Jurada | 4 |

---

## 5. Tablas Clave con Columnas Principales

### 5.1 RT_PADRON_BASE — Padrón Maestro de Bienes
181.942 registros activos  
Columnas: ID_BIEN, TIPO_BIEN, CODIGO_IMPRESION, IDENTIFICADOR, CLAVE_BIEN, NRO_EXPEDIENTE, ACTIVO, IMPRIME, EXENCION, FECHA_ALTA, FECHA_BAJA, LIQ_DESDE, LIQ_HASTA, MONTO_DEUDA_HISTORICO, MONTO_DEUDA_ACTUALIZADO, FECHA_ACTUALIZACION_DEUDA, ID_PROCU, SITUACION_DEUDA, CONDICION_IVA, TIPO_PLAN, ID_BROCHE, ID_RT, MOTIVO_NOIMPRIME

### 5.2 RT_PADRON_BASE_VARIOS — Atributos Adicionales por Bien
1.788.989 registros  
Columnas: CODIGO_VARIOS (tipo de atributo), ID_BIEN, FECHA_VARIOS_DESDE, ESTADO_VARIOS, MONTO, TEXTO, TIPO_VARIOS, USUARIO, IDENTIFICADOR, TIPO_PLAN  
Ejemplo: `AUAUACTI` = actividad del automotor; permite almacenar N atributos por bien

### 5.3 RT_FACTURAS — Factura/Liquidación
6.353.134 registros  
Columnas clave: NRO_INTERNO (PK char(10)), ID_BIEN, TIPO_BIEN, TIPO_PLAN, TIPO_CUOTA, ANO_CUOTA, NRO_CUOTA, NRO_SUCURSAL, NRO_COMPROBANTE, ESTADO_DEUDA, SITUACION_DEUDA, CAPITAL_FACTURADO, INTERESES_FACTURADOS, CAPITAL_COBRADO, INTERESES_COBRADOS, CAPITAL_FINANCIADO, IDENTIFICADOR, ID_ENTE, APELLIDO, NOMBRE, FACTURA_VENCIDA, INTERRUMPE_PRESCRIPCION

**NRO_INTERNO** (ej: `0000000001`) es la clave principal de la factura en todo el sistema.

### 5.4 RT_FACTURAS_DEUDA — Cedulones/Deuda con Vencimientos
4.993.624 registros  
Columnas: NRO_INTERNO_DEUDA (PK char(10)), MONTO_ACTUALIZADO_CAPITAL, MONTO_ACTUALIZADO_INTERESES, FECHA_VENCIMIENTO1, MONTO_RECARGO1, FECHA_VENCIMIENTO2, MONTO_RECARGO2, FECHA_VENCIMIENTO3, MONTO_RECARGO3, FECHA_PRORROGA, ESTADO_DEUDA, ID_BIEN, CONCEPTO, TIPO_DEUDA, INTERESES_1ER_VENCE, IMP_1VENCE, IMP_2VENCE, IMP_3VENCE, IMP_ACTUALIZABLE, IMP_NO_ACTUALIZABLE, DESCUENTO_INTERESES, DESCUENTO_CAPITAL

**NRO_INTERNO_DEUDA** es la clave del cedulón. Tiene hasta 3 fechas/montos de vencimiento escalonados.

### 5.5 RT_FACTURAS_DEUDA_DETALLE — Composición del Cedulón
25.950.031 registros  
Columnas: NRO_INTERNO_DEUDA (→ RT_FACTURAS_DEUDA), NRO_INTERNO (→ RT_FACTURAS), MONTO_CAPITAL, MONTO_INTERESES, MONTO_GTOS_ADMIN, MONTO_TOTAL_COBRADO, PAGO_PARCIAL, A_PAGAR, UNIDADES_NOMINAL, DESCUENTO_INTERESES, DESCUENTO_CAPITAL

Un cedulón (NRO_INTERNO_DEUDA) agrupa múltiples facturas (NRO_INTERNO).

### 5.6 RT_FACTURAS_DETALLE — Composición por Ítem
17.736.927 registros  
Columnas: TIPO_ITEM (→ RT_ITEMS), NRO_INTERNO (→ RT_FACTURAS), CAPITAL_ITEM, FINANCIACION_ITEM, ACTUALIZACION_ITEM, IVA_ITEM  
Indica qué conceptos fiscales componen cada factura.

### 5.7 RT_ITEMS — Catálogo de Conceptos Fiscales
462 registros  
Columnas: TIPO_ITEM (PK char(8)), CONCEPTO (texto largo), CONCEPTO_ABREVIADO, VALOR_1, VALOR_2, CANTIDAD (fórmula/operador), CONTADOR, FECHA_GLOBAL, IVA, GRUPO, CODIGO_ACTIVIDAD, ACTIVO, FLIA_ITEM_VIRTUAL, AGRUPA_CERTIFICADO  
Ejemplos de TIPO_ITEM: `OBSABASI` (básico de agua), `AUAUADMI` (gastos admin automotores), `ACTAMULT` (multa), `AUAU_WEB` (descuento gestión web)  
El campo `CANTIDAD` es una expresión (ej: `<>` = variable, `85` = porcentaje fijo).

### 5.8 RT_COBRADO — Cabecera de Cobro
1.466.053 registros  
Columnas: NRO_OPERACION (PK char(10)), FECHA_COBRO, FECHA_CONTABILIZACION, ENTE_RECA (entidad recaudadora), CAPITAL_COBRADO, INTERESES_COBRADOS, INSTANCIA, NRO_RECIBO

### 5.9 RT_COBRADO_DETALLE — Detalle de Cobro por Ítem
9.850.695 registros  
Columnas: NRO_OPERACION (→ RT_COBRADO), TIPO_ITEM (→ RT_ITEMS), NRO_INTERNO (→ RT_FACTURAS), CAPITAL_COBRADO, FINANCIACION_COBRADO, ACTUALIZACION_COBRADO, IVA_COBRADO, TIPO_PAGO

### 5.10 RT_FACTURAS_COBRO_DETALLE — Vinculación Cobro-Deuda
3.031.834 registros  
Columnas: NRO_INTERNO_DEUDA (→ RT_FACTURAS_DEUDA), NRO_INTERNO (→ RT_FACTURAS), NRO_OPERACION (→ RT_COBRADO)  
**Esta tabla es el puente de 3 vías entre cedulón, factura y operación de cobro.**

---

## 6. Flujo Completo: Alta de Bien → Liquidación → Notificación → Cobro

```
╔══════════════════════════════════════════════════════════════════════════╗
║  1. ALTA DE BIEN                                                          ║
║                                                                           ║
║  PERSONAS (titular)         RT_BIENES (tipo de tributo)                  ║
║       ↓ IDENTIFICADOR              ↓ TIPO_BIEN                           ║
║  RT_PADRON_BASE ← FK ──── RT_PLANES_TIPO (plan de cuotas)               ║
║  (ID_BIEN, TIPO_BIEN)               ↓ TIPO_PLAN                          ║
║       ↓ atributos                RT_CUOTAS_TIPOS                         ║
║  RT_PADRON_BASE_VARIOS        (TIPO_BIEN, TIPO_PLAN, TIPO_CUOTA)         ║
║       ↓ datos fiscales específicos                                        ║
║  RT_CATASTRO (para ININ/CACA)                                            ║
║  RT_AUTOMOTORES (para AUAU)                                              ║
║  RT_COMERCIO_INDUSTRIA (para CICI)                                       ║
║  RT_SERV_PROPIEDAD (para OBSA/OBSC)                                      ║
╚══════════════════════════════════════════════════════════════════════════╝
                    ↓
╔══════════════════════════════════════════════════════════════════════════╗
║  2. LIQUIDACIÓN (sp_rt_Liquida / SP_RT_LIQUIDA_APRO)                    ║
║                                                                           ║
║  RT_CONDICIONES_LIQUIDACION ←── RT_CONDICIONES_LIQUIDACION_ITEMS        ║
║  (TIPO_BIEN, TIPO_PLAN, TIPO_CUOTA, ANO_CUOTA, NRO_CUOTA)               ║
║       ↓                              ↓ TIPO_ITEM                         ║
║  RT_ITEMS (conceptos fiscales)    Fórmulas de cálculo                   ║
║       ↓ valuaciones                                                       ║
║  RT_AUTOMOTORES_VALUACION (CIP × AÑO_MODELO → BASE_IMPONIBLE)          ║
║  RT_AUTOMOTORES_TARIFARIA_ESCALAS (escala × valuación → IMP_ANUAL)      ║
║  RT_SERV_PROPIEDAD_CATEGORIA (categoría → base de cálculo para agua)    ║
║  RT_CATASTRO + RT_CATASTRO_MEJORAS (superficie+zona → inmobiliario)      ║
║       ↓                                                                   ║
║  RT_FACTURAS ← GENERA (NRO_INTERNO, ID_BIEN, ANO_CUOTA, NRO_CUOTA)     ║
║  RT_FACTURAS_DETALLE (desglose por TIPO_ITEM)                           ║
║  RT_FACTURAS_ACUMULADOR (acumulado por ítem)                             ║
╚══════════════════════════════════════════════════════════════════════════╝
                    ↓
╔══════════════════════════════════════════════════════════════════════════╗
║  3. GENERACIÓN DE CEDULÓN/DEUDA (SP_RT_GEN_CED_DEUDA)                  ║
║                                                                           ║
║  RT_FACTURAS → selección de cuotas impagas                              ║
║       ↓                                                                   ║
║  RT_FACTURAS_DEUDA (NRO_INTERNO_DEUDA) ← genera 1 o N cedulones        ║
║       FECHA_VENCIMIENTO1 / MONTO_RECARGO1 (ej: pago antes del 15)       ║
║       FECHA_VENCIMIENTO2 / MONTO_RECARGO2 (ej: pago entre 15 y fin mes) ║
║       FECHA_VENCIMIENTO3 / MONTO_RECARGO3 (ej: pago siguiente mes)      ║
║       ↓                                                                   ║
║  RT_FACTURAS_DEUDA_DETALLE (vincula NRO_INTERNO_DEUDA → N NRO_INTERNO) ║
║  RT_FACTURAS_DEUDA_DISCRI (discriminación por TIPO_ITEM)                ║
╚══════════════════════════════════════════════════════════════════════════╝
                    ↓
╔══════════════════════════════════════════════════════════════════════════╗
║  4. NOTIFICACIÓN / LOTE DE CEDULONES                                    ║
║                                                                           ║
║  NT_NOTI_LOTE (configuración del lote: filtros JSON, tipo impresión)    ║
║       ↓ ID_LOTE                                                           ║
║  NT_NOTI_LOTE_CUENTAS (una cuenta/contribuyente por lote)               ║
║       ↓ ID_LOTE_CUENTA                                                    ║
║  NT_NOTI_LOTE_BOLETAS (boletas/cuotas incluidas, con montos actualizados)║
║       ↓                                                                   ║
║  NT_NOTI_LOTE_IMPRESIONES (registro de impresión física)                ║
║  NT_NOTI_LOTE_ENVIOS / NT_NOTI_LOTE_ENVIOS_CIDI / _WHATSAPP            ║
║                                                                           ║
║  Camino alternativo (notificación individual):                           ║
║  NT_NOTI_NUEVA (NRO_NOTIFICACION, ID_BIEN, NRO_INTERNO_DEUDA, montos)  ║
╚══════════════════════════════════════════════════════════════════════════╝
                    ↓
╔══════════════════════════════════════════════════════════════════════════╗
║  5. COBRO EN CAJA (CJC_)                                                 ║
║                                                                           ║
║  CJC_CAJERO (sesión de caja: CAJERO, FECHA_CAJA, NRO_SESSION)          ║
║       ↓ abre sesión                                                       ║
║  CJC_DOCUMENTOS (cada cedulón presentado al cobro)                      ║
║       NRO_INTERNO → enlaza con RT_FACTURAS_DEUDA                        ║
║       MONTO, TIPO_CEDULON, COD_BARRA                                     ║
║       ↓ al pagar                                                          ║
║  CJC_PAGOS (NRO_OPERACION, monto, fecha)                                ║
║  CJC_IMPUTACION (detalle de imputación contable: ANO_ING, NRO_CTA_ING) ║
║  CJC_IMPUTACION_DICRI (discriminación por ítem)                          ║
║       ↓ al cerrar caja                                                    ║
║  RT_COBRADO (NRO_OPERACION, FECHA_COBRO, CAPITAL_COBRADO)               ║
║  RT_COBRADO_DETALLE (por TIPO_ITEM y NRO_INTERNO)                      ║
║  RT_FACTURAS_COBRO_DETALLE (vincula: DEUDA ↔ FACTURA ↔ OPERACION)      ║
║       ↓                                                                   ║
║  RT_FACTURAS.ESTADO_DEUDA → cambia a 'LI' (liquidado/cobrado)          ║
║  RT_FACTURAS.CAPITAL_COBRADO / INTERESES_COBRADOS → se actualizan       ║
╚══════════════════════════════════════════════════════════════════════════╝
                    ↓
╔══════════════════════════════════════════════════════════════════════════╗
║  6. DEUDA IMPAGA → GESTIÓN JUDICIAL                                      ║
║                                                                           ║
║  RT_PROCURACION (título ejecutivo por procurador)                       ║
║  RT_PROCURACION_DET (detalle de cuotas en el título)                    ║
║  RT_PROCURACION_ESTADOS (historial de estados del proceso)              ║
║  RT_DEMANDA (inicio formal de demanda)                                  ║
║  RT_DEMANDA_CUOTAS / RT_DEMANDA_ABOGADOS                                ║
║  RT_DEMANDA_PROCESO (estados del proceso judicial)                      ║
║       ↓ si se resuelve                                                    ║
║  RT_FACTURAS.SITUACION_DEUDA → 'JU' o 'DE'                             ║
╚══════════════════════════════════════════════════════════════════════════╝
```

---

## 7. Cálculo de Deuda e Intereses

### 7.1 Cálculo de Automotores (AUAU)
```
1. RT_AUTOMOTORES_VALUACION: (CIP × MODELO_VALUACION) → BASE_IMPONIBLE
   Ej: CIP=0000025304, modelo 1989 → $4.900
2. RT_AUTOMOTORES_TARIFARIA_ESCALAS: (ANO_VALUACION × TIPO × MODELO × ESCALA)
   → IMP_ANUAL (importe anual del impuesto)
3. RT_AUTOMOTORES_TIPOS: categoría del vehículo (tipo A, B, C...)
4. SP_rt_Liquida genera RT_FACTURAS con capital calculado
```

### 7.2 Cálculo de Inmobiliario (ININ)
```
1. RT_CATASTRO: superficie, zona, frentes → base imponible catastral
2. RT_CATASTRO_MEJORAS: mejoras edilicias → ajuste de valuación
3. RT_SERV_PROPIEDAD_CATEGORIA: categoría del servicio a la propiedad
4. RT_INDICES_ACTUALIZACION: índice por TIPO_BIEN y período
   Ej: ININ 2022: período 001=1.0, 002=1.1, 003=1.2
```

### 7.3 Actualización / Intereses (RT_ACTUALIZACION)
```
Tabla RT_ACTUALIZACION: INTERES (código), FECHA, RESAR (tasa mensual)
  Tipo 'A': 3% mensual hasta 1997, 1.95% hasta 2002, 2% hasta 2015, 4% desde 2023
  
RT_TIPO_TALONARIO.METODO_ACTUALIZACION:
  'H00SA' = fórmula histórica tipo A
  Vacío = sin intereses
  
RT_TIPO_TALONARIO.INDICE_CALCULO: ej: 0.01 = 1% mensual
```

### 7.4 Vencimientos y Recargos
```
RT_FACTURAS_DEUDA tiene 3 vencimientos:
  FECHA_VENCIMIENTO1 + MONTO_RECARGO1 (= IMP_1VENCE, monto con descuento pronto pago)
  FECHA_VENCIMIENTO2 + MONTO_RECARGO2 (= IMP_2VENCE, monto base)
  FECHA_VENCIMIENTO3 + MONTO_RECARGO3 (= IMP_3VENCE, monto con recargo)
  
RT_TIPO_TALONARIO:
  VENCIMIENTO_ANTES_15: días (ej: 15) → primer vencimiento
  VENCIMIENTO_DESPUES_15: días → segundo vencimiento
  DIAS_VENCIMIENTO2/3: días adicionales para 2° y 3° vencimiento
  MONTO_RECARGO1/2/3: importes fijos de recargo
  MAX_DESCU_INT: descuento máximo de intereses (ej: -100 = 100% descuento)
```

---

## 8. Planes de Pago y Talonarios

### RT_TIPO_TALONARIO (56 planes activos)
Ejemplos encontrados:
- Plan 1: Moratorias anteriores
- Plan 2: Plan instalación servicio internet
- Plan 10: Act. Terrenos e Infr. sin interés
- Plan 12: Plan Tribunal de Faltas
- Plan 13: Ordenanza 2137/2018
- Plan 14: Act. Terreno Polo Industrial (40% anticipo, máx 24 cuotas)
- Plan 28: Plan de Pago General
- Plan 29: Financiación Obra de Gas

### Flujo de Talonario (financiación)
```
RT_TALONARIOS (cabecera del plan de pago)
  → RT_TALONARIO_CUOTAS (cuotas del plan)
    → RT_TALONARIO_CUOTAS_DET (detalle)
    → RT_TALONARIO_CUOTAS_COBRO (cobros de cuotas del plan)
  → RT_TALONARIO_FINANCIADO (capital financiado)
  → RT_TALONARIO_VINC (vinculación del talonario con facturas)
```

---

## 9. Módulo de Caja (CJC_)

### Tablas principales

| Tabla | Filas | Descripción |
|-------|-------|-------------|
| CJC_IMPUTACION | 15.065.198 | Imputación contable de cada cobro |
| CJC_IMPUTACION_DICRI | 10.683.585 | Discriminación por ítem |
| CJC_AUDITORIA | 4.797.479 | Auditoría de operaciones |
| CJC_CEDULONES_VINC | 3.487.309 | Vinculación cedulones-operaciones |
| CJC_DOCUMENTOS | 1.572.543 | Documentos presentados en caja |
| CJC_OPERACIONES | 717.245 | Operaciones de caja |
| CJC_PAGOS | 714.004 | Pagos registrados |
| CJC_CAJERO | 29.368 | Sesiones de caja |

### Flujo de caja
```
CJC_CAJERO (sesión)
  CAJERO: identificador de la caja física (ej: 'ADRIANA')
  FECHA_CAJA: fecha de la jornada
  NRO_SESSION: número de sesión
  ANO_RECIBO, TIPO_RECIBO, NRO_RECIBO: numeración del recibo
  
CJC_DOCUMENTOS (cedulones presentados)
  NRO_INTERNO: NRO_INTERNO_DEUDA del cedulón RT_FACTURAS_DEUDA
  TIPO_BIEN: 'DEUD' u otro
  TIPO_CEDULON: código de tipo
  MONTO: monto cobrado
  COD_BARRA: código de barras del cedulón
  
CJC_IMPUTACION (distribución contable)
  NRO_INTERNO → RT_FACTURAS o RT_FACTURAS_DEUDA
  NRO_INTERNO_ORI → origen
  ANO_ING, RECONDUCIDO_ING, NRO_CTA_ING: cuentas contables destino
  IMPORTE: monto imputado (C=capital, R=recargo)
  CAP_REC: 'C'=capital o 'R'=recargo
```

---

## 10. Módulo de Notificaciones (NT_)

### Tablas principales

| Tabla | Filas | Descripción |
|-------|-------|-------------|
| NT_NOTI_LOTE_BOLETAS | 33.425.816 | Boletas de deuda por lote |
| NT_NOTI_NUEVA | 4.079.310 | Notificaciones individuales |
| NT_NOTI_LOTE_CUENTAS | 881.186 | Cuentas por lote |
| NT_NOTI_LOTE_IMPRESIONES | 219.176 | Registros de impresión |
| NT_NOTI_LOTE | 601 | Lotes de notificación |

### NT_NOTI_LOTE — Lote de Notificación
Columnas clave: ID_LOTE, DESCRIPCION, FECHA_LOTE, FINALIZADO, ESTADO, TIPO_IMPRESION, BOLETA_DEUDA, FECHA_VENCIMIENTO_BOLETA_DEUDA, FILTROS (JSON con criterios de selección), CTAS_SIN_IMPRIME

**El campo FILTROS es JSON** con estructura:
```json
{
  "objetivo": 500000,
  "tipo": {"tipo_bien": ["OBSI","TETE"], "tipo_plan": [], "tipo_cuota": []},
  "situacion": {"situacion_deuda": ["RE"]},
  "general": {"activos": true, "barrios": "", "calle": ""},
  "deuda": {"control_deuda_hasta": "2018-11-12", "monto_minimo_notificar": "", "solo_vencida": false}
}
```

### NT_NOTI_LOTE_BOLETAS — Boletas por Lote
Columnas: ID_LOTE_CUENTA, NRO_INTERNO (→ RT_FACTURAS), TIPO_PLAN, DESC_PLAN, TIPO_CUOTA, ANO_CUOTA, NRO_CUOTA, ESTADO_DEUDA, SITUACION_DEUDA, FECHA_VENCIMIENTO, MONTO_DEUDA_HISTORICO, MONTO_DEUDA_ACTUALIZADO

### Canales de envío
- `NT_NOTI_LOTE_ENVIOS`: correo postal físico
- `NT_NOTI_LOTE_ENVIOS_CIDI`: CIDI (sistema provincial de identidad digital)
- `NT_NOTI_LOTE_ENVIOS_WHATSAPP`: WhatsApp

---

## 11. Módulo RNPA (Registro Nacional de la Propiedad Automotor)

### Tablas principales

| Tabla | Filas | Descripción |
|-------|-------|-------------|
| RNPA_DEUDA_DET_HIST | 13.593.555 | Historial de deuda RNPA |
| RNPA_DEUDA_DET | 147.301 | Deuda actual RNPA |
| RNPA_C5_INFORMACION_DEL_VEHICULO_TITULARES | 44.580 | Titulares de vehículos |
| RNPA_C4_IMPUESTO_AUTOMOTOR | 44.111 | Impuesto automotor para RNPA |
| RNPA_C5_INFORMACION_DEL_VEHICULO | 43.654 | Vehículos registrados |
| RNPA_C1_ALTA_IMPOSITIVA | 11.884 | Altas impositivas |
| RNPA_C2_BAJA_IMPOSITIVA | 7.183 | Bajas impositivas |
| RNPA_C6_CAMBIO_DE_TITULARIDAD | 612 | Transferencias |

**Propósito:** Integración con el RNPA nacional. Los lotes contienen registros tipo C1 (altas), C2 (bajas), C4 (impuesto a informar), C5 (información del vehículo + titulares), C6 (cambios de titularidad). Usa dominio (patente) como clave externa.

---

## 12. Módulo MAL_ (Multas/Matrículas)

### Tablas principales (top 10 por volumen)

| Tabla | Filas | Descripción |
|-------|-------|-------------|
| MAL_DEUDA | 519.000 | Deudas de matrículas |
| MAL_CUOTAS_TALO | 118.863 | Cuotas de talonario |
| MAL_RT_CONVENIO_TMP_MUESTRA | 83.871 | Temp convenios |
| MAL_CV_MAE | 68.917 | Convenios maestro |
| MAL_SUE_MOV | 67.161 | Movimientos de sueldos |
| mal_deuda_estado | 31.592 | Estados de deuda |
| MAL_PAGOS_FALT | 31.326 | Pagos de Juzgado de Faltas |
| MAL_DET_EGR_NEW | 27.013 | Detalle de egresos |
| MAL_DOMINIO | 8.517 | Dominios/patentes |
| MAL_MAEINM | 8.373 | Maestro inmuebles |

**Nota:** El módulo MAL_ tiene dos subáreas: (1) gestión de matrículas habilitacionales y (2) liquidación de sueldos/haberes municipales (MAL_SUE_, MAL_SLD_).

---

## 13. Módulo JF_ (Juzgado de Faltas)

### Tablas principales

| Tabla | Filas | Descripción |
|-------|-------|-------------|
| JF_NOMENCLADOR | 573 | Catálogo de infracciones |
| JF_ACTAS_HIST | 57 | Historial de actas |
| JF_LOTES_ACTAS | 27 | Lotes de actas |
| JF_ACTAS_ESTADOS | 26 | Estados de actas |
| JF_ACTAS_PERSONAS | 25 | Personas en actas |
| JF_ACTAS | 12 | Actas actuales |
| JF_ACTAS_MULTAS | 17 | Multas por acta |
| JF_NORMATIVAS | 11 | Marco normativo |

**Integración:** Las multas del JF se liquidan como TIPO_BIEN=`ACTA` en RT_, con TIPO_CUOTA=`MU` (multa).

---

## 14. Portal Web Contribuyente (egov_)

### Tablas

| Tabla | Filas | Descripción |
|-------|-------|-------------|
| egov_Notificaciones | 745.328 | Notificaciones al contribuyente |
| egov_CFM_Historial_Claves | 2.799 | Historial de contraseñas |
| egov_BienesCFM | 1.295 | Bienes adheridos al portal |
| egov_CFM | 1.276 | Cuentas del portal (Cuenta Fiscal Municipal) |
| egov_Notificaciones_Tipo | 9 | Tipos de notificación |
| egov_ServicioseGov | 4 | Servicios disponibles en el portal |

### Servicios del portal (egov_ServicioseGov)
1. `CDEU` — Impresión de Deuda
2. `DDJJ` — Presentación DDJJ y Adhesión a Planes de Facilidades (CICI)
3. `CACA` — Consulta Plancheta Catastral
4. (ID 4 no recuperado en muestra)

**egov_CFM** = Cuenta Fiscal Municipal: `Identificador` (contribuyente) + `Password` (hash MD5)  
**egov_BienesCFM**: vincula `Identificador` con `IdBien` y `IdServicio`

---

## 15. Tablas AFIP

### AFIP_TIPO_DOCUMENTOS
| CODIGO_PGM | Descripción | CODIGO_AFIP |
|------------|-------------|-------------|
| 0 | Pasaporte | 94 |
| 1 | DNI | 96 |
| 2 | LE | 89 |
| 3 | LC | 90 |
| 5 | CUIT | 80 |
| 6 | CI Córdoba | 3 |

### AFIP_TIPO_IVA
| CODIGO_AFIP | Descripción | VALOR_IVA |
|-------------|-------------|-----------|
| 1 | No Gravado | — |
| 2 | Exento | — |
| 3 | 0% | 0% |
| 4 | 10.5% | 10.5% |
| 5 | 21% | 21% |
| 6 | 27% | 27% |
| 8 | 5% | 5% |
| 9 | 2.5% | 2.5% |

---

## 16. Relaciones Clave Entre Tablas

```
PERSONAS (exterior RT_)
  └── IDENTIFICADOR → RT_PADRON_BASE.IDENTIFICADOR
  └── IDENTIFICADOR → RT_PROPIETARIOS.IDENTIFICADOR
  └── IDENTIFICADOR → RT_TALONARIOS.IDENTIFICADOR

RT_BIENES (catálogo de tipos)
  └── TIPO_BIEN → RT_PADRON_BASE.TIPO_BIEN
  └── TIPO_BIEN → RT_PLANES_TIPO.TIPO_BIEN
  └── TIPO_BIEN → RT_INDICES_ACTUALIZACION.TIPO_BIEN

RT_PADRON_BASE (ID_BIEN, TIPO_BIEN) = clave maestra
  └── ID_BIEN → RT_PROPIETARIOS.ID_BIEN
  └── ID_BIEN → RT_CATASTRO (para ININ/CACA)
  └── ID_BIEN → RT_PADRON_BASE_VARIOS.ID_BIEN (N atributos)
  └── ID_BIEN → RT_EXENCIONES.ID_BIEN
  └── ID_BIEN → RT_DOMICILIO_ENVIO.ID_BIEN
  └── ID_BIEN → RT_FACTURAS.ID_BIEN
  └── ID_BIEN → RT_CONVENIO_BIENES.ID_BIEN
  └── ID_BIEN → RT_PADRON_PLANES.ID_BIEN

RT_FACTURAS (NRO_INTERNO) = clave factura
  └── FK → RT_PADRON_BASE (ID_BIEN)
  └── FK → RT_CONDICIONES_LIQUIDACION (TIPO_BIEN, TIPO_PLAN, TIPO_CUOTA, ANO, NRO)
  └── NRO_INTERNO → RT_FACTURAS_DETALLE.NRO_INTERNO
  └── NRO_INTERNO → RT_FACTURAS_ACUMULADOR.NRO_INTERNO
  └── NRO_INTERNO → RT_COND_INDI_LIQUIDACION.NRO_INTERNO

RT_FACTURAS_DEUDA (NRO_INTERNO_DEUDA) = clave cedulón
  └── NRO_INTERNO_DEUDA → RT_FACTURAS_DEUDA_DETALLE.NRO_INTERNO_DEUDA
  └── NRO_INTERNO_DEUDA → RT_FACTURAS_DEUDA_DISCRI.NRO_INTERNO_DEUDA
  └── NRO_INTERNO_DEUDA → RT_FACTURAS_COBRO_DETALLE.NRO_INTERNO_DEUDA
  └── NRO_INTERNO_DEUDA → RT_CONVENIO_CUOTAS.NRO_INTERNO_DEUDA

RT_FACTURAS_DEUDA_DETALLE (puente deuda ↔ facturas)
  └── NRO_INTERNO_DEUDA → RT_FACTURAS_DEUDA
  └── NRO_INTERNO → RT_FACTURAS

RT_COBRADO (NRO_OPERACION) = clave cobro
  └── NRO_OPERACION → RT_COBRADO_DETALLE.NRO_OPERACION
  └── NRO_OPERACION → RT_FACTURAS_COBRO_DETALLE.NRO_OPERACION
  └── NRO_OPERACION → RT_TALONARIO_CUOTAS_COBRO.NRO_OPERACION

RT_FACTURAS_COBRO_DETALLE = PUENTE TRIPLE
  └── NRO_INTERNO_DEUDA + NRO_INTERNO → RT_FACTURAS_DEUDA_DETALLE
  └── NRO_OPERACION → RT_COBRADO

RT_ITEMS (TIPO_ITEM) = catálogo conceptos
  └── TIPO_ITEM → RT_FACTURAS_DETALLE.TIPO_ITEM
  └── TIPO_ITEM → RT_COBRADO_DETALLE.TIPO_ITEM
  └── TIPO_ITEM → RT_FACTURAS_DEUDA_DISCRI.TIPO_ITEM
  └── TIPO_ITEM → RT_CONDICIONES_LIQUIDACION_ITEMS.TIPO_ITEM
```

---

## 17. Stored Procedures Clave

| SP / Vista | Función |
|-----------|---------|
| `sp_rt_Liquida` | Liquidación de cuotas (motor principal) |
| `SP_RT_LIQUIDA_APRO` | Liquidación aprobada/masiva |
| `SP_RT_GEN_CED_DEUDA` | Genera cedulones de deuda |
| `sp_rt_procesa_deuda` | Procesa y actualiza estado de deuda |
| `SP_RT_VAL_DEUDA_ACT` | Actualiza valores de deuda |
| `sp_rt_cuota_a_deuda` | Convierte cuota a estado deuda |
| `SP_LIQUIDA_DDJJ` | Liquidación de DDJJ comercio |
| `SP_RT_FILTRA_DEUDA` | Filtro de deuda para cedulones |
| `sp_RT_Caducacion_Cuotas` | Proceso de caducidad |
| `SP_RT_PRESCRIBIR_CUOTAS` | Prescripción de deuda |
| `RT_SI_TIENE_DEUDA_ORIGINAL_O_FINANCIADA` | Consulta de deuda |
| `VI_FACTURAS_CONDICIONES_LIQU` | Vista deuda con condiciones |
| `vi_cobrado_fac` | Vista cobros por factura |
| `VI_AUTOMOTORES_DEUDA` | Vista deuda automotores |
| `VINCULACION_CUOTAS_ITEMS` | Vista vinculación cuotas-ítems |

---

## 18. Queries de Consulta Útiles

### Deuda activa de un contribuyente (por IDENTIFICADOR)
```sql
SELECT f.NRO_INTERNO, f.ID_BIEN, f.TIPO_BIEN, f.ANO_CUOTA, f.NRO_CUOTA,
       f.ESTADO_DEUDA, f.SITUACION_DEUDA, f.CAPITAL_FACTURADO,
       fd.MONTO_ACTUALIZADO_CAPITAL, fd.FECHA_VENCIMIENTO1, fd.IMP_1VENCE
FROM RT_FACTURAS f
JOIN RT_FACTURAS_DEUDA fd ON fd.NRO_INTERNO_DEUDA IN (
    SELECT NRO_INTERNO_DEUDA FROM RT_FACTURAS_DEUDA_DETALLE WHERE NRO_INTERNO = f.NRO_INTERNO
)
WHERE f.IDENTIFICADOR = '00001'  -- IDENTIFICADOR del titular
  AND f.ESTADO_DEUDA = 'PT'      -- pendiente
  AND f.SITUACION_DEUDA = 'RE'   -- regular
```

### Historia de cobros de un bien
```sql
SELECT c.NRO_OPERACION, c.FECHA_COBRO, c.CAPITAL_COBRADO, c.INTERESES_COBRADOS,
       cd.TIPO_ITEM, cd.NRO_INTERNO
FROM RT_COBRADO c
JOIN RT_COBRADO_DETALLE cd ON cd.NRO_OPERACION = c.NRO_OPERACION
WHERE cd.NRO_INTERNO IN (
    SELECT NRO_INTERNO FROM RT_FACTURAS WHERE ID_BIEN = '01234' AND TIPO_BIEN = 'AUAU'
)
ORDER BY c.FECHA_COBRO DESC
```

### Cedulón activo con composición
```sql
SELECT fd.NRO_INTERNO_DEUDA, fd.MONTO_ACTUALIZADO_CAPITAL, fd.IMP_1VENCE,
       fd.FECHA_VENCIMIENTO1, fdd.NRO_INTERNO, fdd.MONTO_CAPITAL, i.CONCEPTO
FROM RT_FACTURAS_DEUDA fd
JOIN RT_FACTURAS_DEUDA_DETALLE fdd ON fdd.NRO_INTERNO_DEUDA = fd.NRO_INTERNO_DEUDA
JOIN RT_FACTURAS_DETALLE ftd ON ftd.NRO_INTERNO = fdd.NRO_INTERNO
JOIN RT_ITEMS i ON i.TIPO_ITEM = ftd.TIPO_ITEM
WHERE fd.ID_BIEN = '01234' AND fd.ESTADO_DEUDA = 'LI'
```

---

## 19. Preguntas Abiertas

1. **Tabla PERSONAS**: Es referenciada por FK desde RT_ (IDENTIFICADOR) pero no tiene prefijo RT_ ni fue incluida en el scope. ¿Cuál es su estructura exacta? ¿Incluye DNI, CUIT, domicilio?

2. **Prefijos no investigados**: Existen 2601 tablas en total. Los 2038 restantes (fuera de los prefijos investigados) pueden incluir gestión de RRHH, contabilidad, catastro ampliado. ¿Qué otros módulos existen?

3. **Formato NRO_INTERNO**: Los prefijos `0000000001` (RT_FACTURAS), `8000000014` (RT_FACTURAS_DEUDA), `7000000044` (RT_COBRADO), `9000068899` (subítem) sugieren rangos reservados. ¿Hay una tabla de numeración central o es generado por cada módulo?

4. **TIPO_BIEN PEPE**: "Tasa Personal" con 43.765 registros — ¿es un tributo personal (no asociado a bien inmueble ni vehículo)? ¿Cómo se liquida sin catastro ni valuación?

5. **Integración CJC ↔ RT_COBRADO**: ¿El traspaso de CJC_PAGOS a RT_COBRADO es automático (trigger/SP) o batch nocturno? El SP `sp_cp_cobrado_cuenta_ing` parece relevante.

6. **Gestión de exenciones (RT_EXENCIONES)**: Hay un campo EXENCION en RT_PADRON_BASE (código 'EX01'). ¿Cómo se aplica la exención en el cálculo? ¿Exime total o parcialmente?

7. **RT_CONDICIONES_LIQUIDACION**: Es la tabla configuradora de cuándo y cómo se generan las cuotas. ¿Qué diferencia hay entre ANO_CUOTA + NRO_CUOTA y los campos de período? ¿Se usa para apertura/cierre de ejercicio?

8. **MAL_ duplicidad de datos**: Las tablas MAL_MAEINM y MAL_AU_MAE parecen ser copias/mirrors de datos RT_. ¿Sirven de backup para el módulo de liquidación de haberes?

9. **Bloqueos (RT_BLOQUEOS)**: 36.854 bienes bloqueados. ¿Qué significa el bloqueo en términos operacionales? ¿Impide cobrar, notificar, o transferir?

10. **Integración CIDI / WhatsApp**: NT_ tiene envíos CIDI y WhatsApp. ¿Hay una cola de procesamiento externa? ¿Cuál es el endpoint de integración?

---

## 20. Tablas RT_ Completas por Volumen

> Lista completa de las 507 tablas RT_ ordenadas por filas (top 50 activas):

| # | Tabla | Filas |
|---|-------|-------|
| 1 | RT_FACTURAS_DETALLES_HIST | 52.627.401 |
| 2 | RT_FACTURAS_DEUDA_DISCRI | 48.300.112 |
| 3 | RT_TELEFONIA_MEDICION | 34.296.018 |
| 4 | RT_FACTURAS_DEUDA_DETALLE | 25.950.031 |
| 5 | RT_FACTURAS_HIST | 23.725.407 |
| 6 | RT_FACTURAS_DETALLE | 17.736.927 |
| 7 | RT_COBRADO_DETALLE | 9.850.695 |
| 8 | RT_FACTURAS_ACUMULADOR_HIST | 8.493.846 |
| 9 | RT_FACTURAS | 6.353.134 |
| 10 | RT_FACTURAS_DEUDA | 4.993.624 |
| 11 | RT_FACTURAS_COBRO_DETALLE | 3.031.834 |
| 12 | RT_BLOQUEOS_DET | 2.726.014 |
| 13 | RT_FACTURAS_ACUMULADOR | 2.240.379 |
| 14 | RT_DEUDA_PREPROCESADA_DETALLE | 1.829.794 |
| 15 | RT_PADRON_BASE_VARIOS | 1.788.989 |
| 16 | RT_AUTOMOTORES_VALUACION | 1.733.535 |
| 17 | RT_COBRADO | 1.466.053 |
| 18 | RT_TELEFONIA_MED_RESUMEN | 942.941 |
| 19 | RT_DEBITOS_DETALLE | 694.778 |
| 20 | RT_IVA | 671.242 |
| 21 | RT_IVA_DET | 631.257 |
| 22 | RT_TALONARIO_FINANCIADO | 597.022 |
| 23 | RT_PAGOS_ESPONTANEOS_GENERACION | 460.449 |
| 24 | RT_CONDONADO_DET | 456.162 |
| 25 | RT_COND_INDI_LIQUIDACION | 434.720 |
| 26 | RT_LIQUIDACION_HISTORICO_DETALLE | 424.128 |
| 27 | RT_BOTON_PAGO_GENERACION_LOG_DETALLE | 367.366 |
| 28 | RT_PROCURACION_DET | 362.116 |
| 29 | RT_TALONARIO_CUOTAS_DET | 327.424 |
| 30 | RT_BOTON_PAGO_GENERACION_LOG | 304.915 |
| 31 | RT_AUTOMOTORES_TIPOS | 274.173 |
| 32 | RT_TALONARIO_CUOTAS_COBRO | 250.064 |
| 33 | RT_OBRAS_MEDICIONES | 249.714 |
| 34 | RT_OBRAS_LIQUIDACION_HIST_DET | 248.999 |
| 35 | RT_TALONARIO_CUOTAS | 229.433 |
| 36 | RT_OBRAS_LIQUIDACION_HIST | 211.417 |
| 37 | RT_LIQUIDACION_HISTORICO | 132.755 |
| 38 | RT_PROPIETARIOS | 113.011 |
| 39 | RT_DEMANDA_CUOTAS | 94.930 |
| 40 | RT_BOTON_PAGO_RECAUDACION_LOG | 81.441 |
| 41 | RT_HISTORICO_TRANSFERENCIA_DET | 72.969 |
| 42 | RT_HISTORICO_TRANSFERENCIA | 67.323 |
| 43 | RT_DEUDA_PERSONA | 59.745 |
| 44 | RT_OBRAS_RUBROS_ANO | 52.359 |
| 45 | RT_OBRAS | 44.047 |
| 46 | RT_PADRON_BASE | 181.942 |
| 47 | RT_AUTOMOTORES | 32.142 |
| 48 | RT_ITEMS_VINCULADOR | 305.666 |
| 49 | RT_CONDICIONES_LIQUIDACION | 40.895 |
| 50 | RT_CONVENIO | 6.915 |

---

*Investigación realizada con acceso directo a SQL Server vía pyodbc. Los datos de muestra corresponden a registros reales de producción.*
