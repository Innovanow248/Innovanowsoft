# Investigacion de Base de Datos PROGRAM
## Sistema de Administracion Financiera Gubernamental
**Servidor:** 149.50.144.8
**Base de datos:** PROGRAM
**Fecha de investigacion:** 2026-06-22

---

## 1. Resumen Ejecutivo

La base de datos PROGRAM aloja un **Sistema de Administracion Financiera Municipal** completo con los siguientes modulos principales:

| Modulo | Prefijo | Tablas | Filas totales | Descripcion |
|--------|---------|--------|---------------|-------------|
| Cuentas a Pagar / Presupuesto | CP_ | ~100 | 2,164,618 | Ciclo completo del gasto: afectaciones, compromisos, ordenes de pago, pagos |
| Compras / Contrataciones | CO_ | ~45 | 387,521 | Facturas de proveedores, pedidos de presupuesto, ordenes de compra |
| Contabilidad General | CG_ | ~14 | 7 | Plan de cuentas, asientos contables, subdiario |
| Sueldos / Liquidacion | SLD_ | ~75 | 2,465,939 | Liquidacion de haberes, personal, novedades, historia salarial |
| Tablas Bancarias | sin prefijo | ~15 | 1,225,212 | Cuentas bancarias, operaciones, resumenes, conciliacion |
| Auxiliares | AGENDA, AREAS, otros | ~5 | ~120,000 | Agenda institucional, areas administrativas |

**Total estimado de filas activas: ~6,243,000** -- sistema con mas de 15 anos de historia transaccional (ejercicios desde 2007 hasta 2025).

El sistema implementa el **flujo presupuestario de doble via** (erogaciones e ingresos) tipico de la administracion publica argentina, con control por ejercicio/anio y reconduccion de cuentas.

---

## 2. Flujo del Gasto (Ciclo Presupuestario de Erogaciones)

```
PRESUPUESTO AUTORIZADO
        |
        v
CP_EROGACION_CUENTAS (NRO_CTA_ERO)
[Cuenta presupuestaria con saldo disponible]
        |
        v
CP_AFECTACIONES  (TIPO: AP = Afectacion Preventiva | XAP = Automatica)
[Reserva de credito presupuestario]
   MONTO_AFECTADO -> reduce PRESUPUESTO_AUTORIZADO
        |
        v
CP_COMPROMISOS  (TIPO: CP = Compromiso | XCP = Automatico)
[Compromiso formal con tercero / proveedor]
   MONTO_COMPROMETIDO
        |
        |-----> CO_FACTURAS_COMPRAS (vinculado por CO_DOCUMENTOS_FACTURA / CO_COMPROMISO_FACTURAS)
        |
        v
CP_ORDENES_PAGO  (TIPO: OP = Orden de Pago | DAC = Ajuste Contable)
[Autorizacion de pago - vinculada a planilla]
   CP_ORDENES_PAGO_IMPUTACIONES -> trae la cuenta ERO + compromiso
        |
        v
OPERACIONES_BANCARIAS  (TIPO_OPE_BAN, vinculado via CP_ORDENES_PAGO_PAGOS)
[Operacion bancaria: Cheque tipo 101 / Transferencia / etc.]
        |
        v
CP_PAGOS  (TIPO: PA = Pago Simple | PM = Pago Multiple)
[Registro del pago efectivo]
   CP_ORDENES_PAGO_PAGOS liga OP -> OPE_BAN -> PA
        |
        v
CP_PLANILLAS (cierre diario de caja)
MONTO_PAGADO actualiza saldos en CP_EROGACION_CUENTAS
```

**Reversos / anulaciones:**
- CP_DESAFECTACIONES (revierte CP_AFECTACIONES)
- CP_DESCOMPROMISOS (revierte CP_COMPROMISOS)
- CP_DESORDENES_PAGO (revierte CP_ORDENES_PAGO)

**Flujo de Ingresos (paralelo):**
```
CP_INGRESO_CUENTAS (NRO_CTA_ING)
        |
        v
CP_RECIBOS (TIPO: RI = Recibo Ingresos | RD = Recibo Disponibilidades | RP = Pocket | NCI = Nota Contab.)
   CP_RECIBOS_IMPUTACIONES -> cuenta ING
        |
        v
OPERACIONES_BANCARIAS (tipo 000 Efectivo, 001 Cheques, 102 Deposito...)
        |
        v
CP_PLANILLAS (cierre diario - incluye saldo caja y banco)
```

---

## 3. Modulo CP_ - Cuentas a Pagar / Presupuesto

### 3.1 Inventario de tablas

| Tabla | Filas | Descripcion |
|-------|-------|-------------|
| CP_AFECTACIONES | 308,948 | Afectaciones preventivas del presupuesto |
| CP_AFECTACIONES_IMPUT_HIST | 184,592 | Historico de imputaciones de afectaciones |
| CP_AFECTACIONES_IMPUTACIONES | 3,498 | Imputaciones vigentes de afectaciones |
| CP_AFECTACIONES_ANO | 38 | Habilitacion de tipos por ejercicio |
| CP_AFECTACIONES_TIPOS | 2 | Catalogo: AP (Preventiva), XAP (Automatica) |
| CP_COMPROMISOS | 307,749 | Compromisos de pago |
| CP_COMPROMISOS_IMPUT_HIST | 184,868 | Historico de imputaciones de compromisos |
| CP_COMPROMISOS_IMPUTACIONES | 3,502 | Imputaciones vigentes de compromisos |
| CP_COMPROMISOS_FACTURAS | 74 | Vinculacion compromiso-factura |
| CP_COMPROMISOS_FAC_IMP | 0 | Imputaciones compromiso-factura |
| CP_COMPROMISOS_ANO | 38 | Habilitacion de tipos por ejercicio |
| CP_COMPROMISOS_TIPOS | 2 | Catalogo: CP, XCP |
| CP_ORDENES_PAGO | 120,844 | Ordenes de pago |
| CP_ORDENES_PAGO_IMPUT_HIST | 192,437 | Historico de imputaciones de OP |
| CP_ORDENES_PAGO_IMPUTACIONES | 4,128 | Imputaciones vigentes de OP |
| CP_ORDENES_PAGO_PAGOS | 4,344 | Vinculacion OP-OPE_BAN-PA |
| CP_ORDENES_PAGO_PAGOS_HIST | 210,176 | Historico pagos de OP |
| CP_ORDENES_PAGO_ANO | 21 | Habilitacion por ejercicio |
| CP_ORDENES_PAGO_TIPOS | 2 | Catalogo: OP, DAC |
| CP_ORDENES_PAGO_RESOLUCIONES_EXPEDIENTES | 0 | Resoluciones ligadas a OP |
| CP_PAGOS | 107,838 | Registros de pago |
| CP_PAGOS_ANO | 36 | Habilitacion por ejercicio |
| CP_PAGOS_TIPOS | 2 | Catalogo: PA (Pago), PM (Pago Multiple) |
| CP_PAGOS_CHEQUES_IMPRESOS_HIST | 28,273 | Historial de impresion de cheques |
| CP_PAGOS_CONFIRMACION | 0 | Confirmaciones pendientes |
| CP_RECIBOS | 28,913 | Recibos de ingresos y disponibilidades |
| CP_RECIBOS_IMPUTACIONES | 172,191 | Imputaciones de recibos |
| CP_RECIBOS_IMPUT_HIST | 0 | Historico imputaciones recibos |
| CP_RECIBOS_ANO | 57 | Habilitacion por ejercicio |
| CP_RECIBOS_TIPOS | 4 | Catalogo: RI, RD, RP, NCI |
| CP_EROGACION_CUENTAS | 14,449 | Plan de cuentas de gastos (presupuesto) |
| CP_EROGACION_CUENTAS_BORRADOR | 14,449 | Borrador del plan de cuentas |
| CP_EROGACION_CUENTAS_TIPOS | 6 | Catalogo: PI/PT (presup), CI/CT (costos), OI/OT (sin ctrl) |
| CP_INGRESO_CUENTAS | 3,202 | Plan de cuentas de ingresos |
| CP_INGRESO_CUENTAS_BORRADOR | 3,202 | Borrador plan ingresos |
| CP_INGRESO_CUENTAS_TIPOS | 6 | Idem erogaciones |
| CP_BALANCE | 197 | Balance diario consolidado (caja+banco) |
| CP_BALANCE_CUENTAS_BANCARIAS | 2,929 | Balance por cuenta bancaria |
| CP_BALANCE_EROGACION_CUENTAS | 153,249 | Balance por cuenta de erogacion |
| CP_BALANCE_INGRESO_CUENTAS | 33,935 | Balance por cuenta de ingreso |
| CP_PLANILLAS | 3,811 | Planillas diarias de tesoreria |
| CP_ORDENANZAS | 103 | Ordenanzas municipales |
| CP_ORDENANZAS_EROGACION | 17,540 | Asignaciones de credito por ordenanza (erogaciones) |
| CP_ORDENANZAS_EROGACION_HIST | 2,815 | Historial de modificaciones |
| CP_ORDENANZAS_INGRESO | 2,350 | Asignaciones por ordenanza (ingresos) |
| CP_ORDENANZAS_INGRESO_HIST | 306 | Historial de modificaciones |
| CP_ORDENANZAS_TIPOS | 3 | Catalogo de tipos de ordenanza |
| CP_DESAFECTACIONES | 8,475 | Anulaciones de afectaciones |
| CP_DESAFECTACIONES_IMPUT_HIST | 4,316 | Historico |
| CP_DESAFECTACIONES_IMPUTACIONE | 3 | Vigentes |
| CP_DESCOMPROMISOS | 8,454 | Anulaciones de compromisos |
| CP_DESCOMPROMISOS_IMPUT_HIST | 4,316 | Historico |
| CP_DESCOMPROMISOS_IMPUTACIONES | 3 | Vigentes |
| CP_DESORDENES_PAGO | 1,812 | Anulaciones de ordenes de pago |
| CP_DESORDENES_PAGO_IMP_HIST | 4,300 | Historico |
| CP_DESORDENES_PAGO_IMPUTACIONE | 3 | Vigentes |
| CP_DEVENGADOS | 0 | Devengados de ingresos |
| CP_DEVENGADOS_IMPUTACIONES | 0 | Imputaciones devengados |
| CP_DEVENGADOS_ANO | 19 | Habilitacion por ejercicio |
| CP_CONTRA_DEVENGADOS | 0 | Contra-devengados |
| CP_CONTRA_ASIENTOS | 52 | Modificaciones presupuestarias (erog+ing) |
| CP_CONTRA_ASIENTOS_ERO | 55 | Detalle erogaciones de contra-asientos |
| CP_CONTRA_ASIENTOS_ING | 59 | Detalle ingresos de contra-asientos |
| CP_RETENCIONES_TIPOS | 31 | Tipos de retencion impositiva |
| CP_RETENCIONES_ANO | 57 | Retenciones por ejercicio |
| CP_RETENCION_PAGOS | 0 | Retenciones aplicadas a pagos |
| CP_RETENCION_PAGOS_DET | 0 | Detalle |
| CP_RETENCION_VALORES | 12 | Valores de alicuotas de retencion |
| CP_RETENCIONES_ALICUOTAS | 0 | Alicuotas |
| CP_RETENCIONES_ALICUOTAS_HIST | 0 | Historico |
| CP_RETENCIONES_DGR | 0 | Retenciones DGR (Rentas) |
| CP_VINCULACION_LOG | 16,214 | Log de vinculaciones |
| CP_VINCULACION_SUELDOS | 0 | Vinculacion con modulo sueldos |
| CP_VINC_CHEQUE_SUELDOS | 0 | Vinculacion cheques con sueldos |
| CP_LOTE_PAGO_ELECTRONICO | 0 | Lotes de pago electronico |
| CP_LOTE_PAGO_ELECTRONICO_DETALLE | 0 | Detalle de lotes electronicos |
| CP_GLOBAL_CONTABILIDAD | 974 | Parametros globales de contabilidad |
| CP_AIF | 161 | Agrupadores de imputacion financiera |
| CP_AIF_CALCULO | 0 | Calculos AIF |
| CP_AIF_VINCULACION | 0 | Vinculaciones AIF |
| CP_FONDOS_GASTOS_ESPECIFICOS | 0 | Fondos para gastos especificos |
| CP_FONDOS_GASTOS_ESPECIFICOS_TESORERIA | 0 | Tesoreria de fondos especificos |
| CP_CONFIGURACION_PUBLICACIONES | 1 | Config de publicaciones web |
| CP_CONFIGURACION_PUBLICACIONES_DETALLE | 11 | Detalle de configuracion |
| CP_TRIBUNAL_CUENTAS | 0 | Resoluciones del Tribunal de Cuentas |
| CP_TRIBUNAL_CUENTAS_DOC | 0 | Documentos del Tribunal |
| CP_NOMENCLADOR | 0 | Nomenclador presupuestario |
| CP_NOMENCLADOR_CAB | 0 | Cabecera del nomenclador |

### 3.2 Columnas clave de tablas principales

#### CP_AFECTACIONES (308,948 filas)
- **PK compuesta:** TIPO_AFECTACION (char 4) + ANO_AFECTACION (char 4) + NRO_AFECTACION (char 8)
- IDENTIFICADOR (char 5) -- FK a PERSONAS (beneficiario/proveedor)
- FECHA_AFECTACION (datetime)
- CONCEPTO (varchar 50)
- MONTO_AFECTADO / MONTO_COMPROMETIDO / MONTO_APAGAR / MONTO_PAGADO / MONTO_DESAFECTADO (money)
- ESTADO_AFECTACION (char 1)
- historico (int)

#### CP_COMPROMISOS (307,749 filas)
- **PK:** TIPO_COMPROMISO + ANO_COMPROMISO + NRO_COMPROMISO
- IDENTIFICADOR (FK PERSONAS)
- MONTO_COMPROMETIDO / MONTO_APAGAR / MONTO_PAGADO / MONTO_DESCOMPROMETIDO (money)
- ESTADO_COMPROMISO (char 1)
- USUARIO / FECHA_AC -- auditoria

#### CP_ORDENES_PAGO (120,844 filas)
- **PK:** TIPO_OPAGO + ANO_OPAGO + NRO_OPAGO
- ANO_PLANILLA + NRO_PLANILLA (FK CP_PLANILLAS)
- IDENTIFICADOR (FK PERSONAS)
- ESTADO_OPAGO (char 1)
- MONTO_APAGAR / MONTO_PAGADO / MONTO_DESORDENADO (money)
- OBSERVACIONES (varchar 1000)
- USUARIO / FECHA_AC / MANDATO_FECHA / MANDATO_USUARIO / MANDATO_IP -- trazabilidad
- ID_RENDICION / UTILIZA_RENDICION

#### CP_PAGOS (107,838 filas)
- **PK:** TIPO_PAGO + ANO_PAGO + NRO_PAGO
- FECHA_PAGO / ESTADO_PAGO / MONTO_PAGADO
- IDENTIFICADOR / USUARIO / FECHA_AC

#### CP_RECIBOS (28,913 filas)
- **PK:** TIPO_RECIBO + ANO_RECIBO + NRO_RECIBO
- ANO_PLANILLA + NRO_PLANILLA (FK CP_PLANILLAS)
- MONTO_TOTAL / MONTO_COBRADO / ESTADO_RECIBO
- COD_ENCRIPTADO -- codigo QR/control
- IDENTIFICADOR_AUTORIZANTE / USUARIO_AUTORIZANTE

#### CP_EROGACION_CUENTAS (14,449 filas)
- **PK:** ANO_ERO + RECONDUCIDO_ERO + NRO_CTA_ERO
- TIPO_CTA_ERO (FK CP_EROGACION_CUENTAS_TIPOS: PI/PT/CI/CT/OI/OT)
- DESIGNACION (varchar 50) -- nombre de la cuenta
- PRESUPUESTO_AUTORIZADO (money) -- credito original
- MONTO_AFECTADO / MONTO_COMPROMETIDO / MONTO_APAGAR / MONTO_PAGADO (money) -- estado actual
- Columnas _INI (saldos iniciales del ejercicio) y _UBA (saldo ultima balance)
- CLAVE_CTA_CG (int FK CG_PLAN) -- vinculo a contabilidad
- ID_FONDO -- vinculo a fondos especificos
- NRO_CTA_ERO_VINC_PRES / NRO_CTA_ERO_CTRL_PRES -- vinculaciones internas

#### CP_PLANILLAS (3,811 filas)
- **PK:** ANO_PLANILLA + NRO_PLANILLA
- CIERRE_PLANILLA (char 1) -- estado
- FECHA_PLANILLA (datetime)
- SALDO_ANT / INGRESO / EGRESO / CHEQUE_LIB / DEPOSITADO / SALDO / CAJA_EXT / CAJA_REC (money)

### 3.3 Datos de muestra

- Ultima afectacion registrada: 17/04/2025, tipo XAP (automatica), ano 2025
- Ultima orden de pago con monto: OP/2025/3180 = $6,811,960.79 y OP/2025/3181 = $1,255,860.00 (21/03/2025)
- Balance al 31/12/2024: Cobrado acumulado $9,676,834,435.19 | Pagado acumulado $8,973,719,326.72 | Saldo $703,115,108.47
- Balance al 30/11/2024: Saldo $513,827,086.79

---

## 4. Modulo CO_ - Compras / Contrataciones

### 4.1 Inventario de tablas

| Tabla | Filas | Descripcion |
|-------|-------|-------------|
| CO_FACTURAS_COMPRAS | 127,376 | Cabecera de facturas de proveedores |
| CO_FACTURAS_COMPRAS_DET | 127,438 | Detalle de renglones de facturas |
| CO_FACTURAS_COMPRAS_ANULA | 0 | Anulaciones de facturas |
| CO_FACTURAS_COMPRAS_DET_ANULA | 0 | Detalle anulaciones |
| CO_FACTURAS_COMPRAS_RECLAMOS | 0 | Reclamos sobre facturas |
| CO_FACTURAS_COMPRAS_VARIOS | 0 | Facturas de tipo varios |
| CO_DOCUMENTOS_FACTURA | 126,786 | Vinculacion documento presupuestario hacia factura |
| CO_COMPROMISO_FACTURAS | 0 | Vinculacion compromiso hacia factura |
| CO_PROVEEDORES | 4,602 | Registro de proveedores |
| CO_PROVEEDORES_AB_AUDITORIA | 1,279 | Auditoria de proveedores |
| CO_PROVEEDORES_IMPUESTOS | 0 | Impuestos configurados por proveedor |
| CO_PROVEEDORES_RUBROS | 0 | Rubros de proveedores |
| CO_PROVEEDORES_CTA_BANCARIA | 0 | Cuentas bancarias de proveedores |
| CO_PROVEEDORES_ACTIVIDADES_AFIP | 0 | Actividades AFIP del proveedor |
| CO_PROVEEDORES_ACTIVIDADES_AFIP_HIST | 0 | Historial actividades AFIP |
| CO_REPRESENTANTES | 0 | Representantes de proveedores |
| CO_PEDIDO_PRESUPUESTO | 0 | Pedidos de presupuesto |
| CO_PEDIDO_PRESUPUESTO_DET | 0 | Detalle de pedidos |
| CO_PEDIDO_PRESUPUESTO_PROV | 0 | Pedidos por proveedor |
| CO_PEDIDO_PRESUPUESTO_ABS | 0 | Relacion pedido-abastecimiento |
| CO_PEDIDO_PRESUPUESTO_SUMINISTROS | 0 | Suministros del pedido |
| CO_ORDENES_COMPRA | 0 | Ordenes de compra |
| CO_ORDENES_ENTREGA | 0 | Ordenes de entrega |
| CO_ORDENES_ENTREGA_DET | 0 | Detalle ordenes de entrega |
| CO_ABASTECIMIENTO | 0 | Comprobantes de abastecimiento |
| CO_ABASTECIMIENTO_DET | 0 | Detalle de abastecimiento |
| CO_ABASTECIMIENTO_ESTADO | 0 | Estado de abastecimiento |
| CO_ABASTECIMIENTO_NOTAS | 0 | Notas sobre abastecimiento |
| CO_ABASTECIMIENTO_ANU_DET | 0 | Anulaciones de abastecimiento |
| CO_ABASTECIMIENTO_AREA_AUTORIZANTE | 0 | Areas autorizantes |
| CO_ABASTECIMIENTO_AREA_AUTORIZANTE_HIST | 0 | Historial |
| CO_ABASTECIMIENTO_LIBERADOS | 0 | Abastecimientos liberados |
| CO_SUMINISTRO | 0 | Suministros (vinculado a CP_AFECTACIONES) |
| CO_SUMINISTRO_DET | 0 | Detalle de suministros |
| CO_PAGO_FACTURAS | 0 | Vinculacion pago hacia factura |
| CO_COMPROBANTES_ANO | 23 | Habilitacion de tipos de comprobante por anio |
| CO_IMPUESTOS_TIPOS | 16 | Tipos de impuesto |
| CO_FORMAS_PAGO | 0 | Formas de pago |
| CO_FONDOFIJO | 0 | Fondo fijo |
| CO_FONDOFIJO_HIST | 0 | Historial fondo fijo |
| CO_FONDOFIJO_RENDICIONES | 0 | Rendiciones de fondo fijo |
| CO_FONDOFIJO_RENDICIONES_DET | 0 | Detalle rendiciones |
| CO_RUBROS_MUNICIPALES | 1 | Rubros municipales de proveedores |
| CO_TMP_COMPRAS | 0 | Temporales de compras |

### 4.2 Columnas clave

#### CO_FACTURAS_COMPRAS (127,376 filas)
- **PK:** IDENTIFICADOR (char 5) + NRO_FACTURA (char 13) + TIPO_COMPROBANTE (char 2) + LETRA_COMPROBANTE (char 1)
- IDENTIFICADOR -- FK a CO_PROVEEDORES (y a PERSONAS)
- FECHA / FECHA_CARGA / FECHA_RECEPCION / FECHA_CONTROL (datetime)
- TIPO_OPAGO + ANO_OPAGO + NRO_OPAGO (FK CP_ORDENES_PAGO -- cuando ya fue comprometida)
- TOTAL_FACTURA / DESCUENTO (money)
- Desglose IVA: IC_NETO_GRAVADO1-4, IC_IVA1-4, IC_ALICUOTA1-4
- IC_NETO_NOGRAVADO / IC_PERC_RET / IC_PERC_IVA / IC_PERC_IMP_NACIONALES / IC_PERC_INGR_BRUTOS / IC_PERC_IMP_MUNICIPALES / IC_PERC_IMP_INTERNOS
- ESTADO (char 1) / ESTADO_CARGA (char 1)
- DETALLE_QR_AFIP / PDF_FACTURA (varbinary) -- soporte documental digital
- IMPORTE_MONEDA / MONEDA / COTIZACION / IMPORTE_TOTAL -- soporte multimoneda
- MANDATO_FECHA / MANDATO_USUARIO / MANDATO_IP -- trazabilidad

#### CO_FACTURAS_COMPRAS_DET (127,438 filas)
- FK: IDENTIFICADOR + NRO_FACTURA + TIPO_COMPROBANTE + LETRA_COMPROBANTE
- CODIGO_ARTICULO_COD / CANTIDAD / PRECIO_UNITARIO / DESIGNACION
- AJUSTE (char 1)

#### CO_DOCUMENTOS_FACTURA (126,786 filas)
- **PK:** TIPO_DOCUMENTO + ANO_DOCUMENTO + NRO_DOCUMENTO
- FK: IDENTIFICADOR + NRO_FACTURA + TIPO_COMPROBANTE + LETRA_COMPROBANTE hacia CO_FACTURAS_COMPRAS
- Vincula documentos presupuestarios (compromisos/afectaciones) con facturas

#### CO_PROVEEDORES (4,602 filas)
- **PK:** IDENTIFICADOR (char 5)
- FK hacia PERSONAS (tabla maestra de personas fisicas/juridicas)
- TIPO_SOCIEDAD / TIPO_PROVEEDOR
- Domicilio completo: CODIGO_POSTAL, CALLE, NUMERACION, PISO, DEPTO, BARRIO, CODIGO_PROVINCIA, CODIGO_PAIS
- NOMBRE_FANTASIA / E_MAIL / TELEFONO / TELEFONO_MOVIL
- NRO_REGISTRO_MUNI / FECHA_ALTA / FECHA_BAJA / CAUSA_BAJA
- ESTADO_AFIP / FECHA_ULTIMA_CONSULTA_AFIP / DETALLE_ESTADO_AFIP -- integracion con AFIP

### 4.3 Datos de muestra
- Ultima factura registrada: 03/04/2025, tipo comprobante 11, $794,330.00, estado E (Emitida/Ingresada)
- Hay una factura con fecha 03/11/2041 -- dato probablemente erroneo de carga
- Los proveedores se identifican con un codigo IDENTIFICADOR de 5 caracteres (ej: 028VB, 031CL)
- La tabla CO_DOCUMENTOS_FACTURA tiene practicamente la misma cantidad de filas que CO_FACTURAS_COMPRAS, indicando una relacion 1:1 predominante

---

## 5. Modulo CG_ - Contabilidad General

### 5.1 Inventario de tablas

| Tabla | Filas | Descripcion |
|-------|-------|-------------|
| CG_ASIENTOS | 0 | Cabecera de asientos contables |
| CG_ASIENTOS_DET | 0 | Detalle (debe/haber) de asientos |
| CG_ASIENTOS_TMP | 0 | Asientos temporales |
| CG_ASIENTOS_DET_TMP | 0 | Detalle temporales |
| CG_ASIENTOS_TIPO | 0 | Tipos de asiento |
| CG_PLAN | 0 | Plan de cuentas contable |
| CG_PLAN_TMP | 0 | Plan de cuentas temporal |
| CG_SUBDIARIO | 0 | Subdiario contable |
| CG_BALANCES_PROCESADOS | 0 | Balances procesados |
| CG_TMP_BALANCES | 0 | Balances temporales |
| CG_EJERCICIO | 0 | Ejercicios contables |
| CG_GLOBAL | 7 | Configuracion global |
| CG_VINCULADOR_BANCOS | 0 | Vinculacion cuentas CG hacia cuentas bancarias |

### 5.2 Columnas clave

#### CG_ASIENTOS
- **PK:** ID_ASIENTO (int), ANO + TIPO + NRO_ASIENTO + TIPO_ASI
- CONCEPTO / FECHA / ESTADO / FECHA_BALANCE

#### CG_ASIENTOS_DET
- FK: ID_ASIENTO + CLAVE_CTA (FK CG_PLAN)
- DEBEHABER (char 1: D/H) / MONTO (money)
- TIPO_COMP / NRO_COMP / FECHA_COMP -- referencia al documento origen

#### CG_PLAN
- **PK:** CLAVE_CTA (int)
- ANO + TIPO + NRO_CTA (char 30)
- DESIGNACION / GRUPO / TIPO_CUENTA / AJUSTE
- CUENTA_MUESTRA / NRO_CTA_CP / TIPO_CTA_CP -- vinculacion con presupuesto (CP_)

#### CG_SUBDIARIO
- ID, FECHA, CLAVE_CTA, DEBEHABER, MONTO
- ID_ASIENTO, ORIGEN, TIPO_DOCUMENTO + ANO_DOCUMENTO + NRO_DOCUMENTO
- DESCRIPCION_DOCUMENTO

#### CG_VINCULADOR_BANCOS
- FK: CLAVE_CTA hacia CG_PLAN
- FK: TIPO_CTA_BCO + BANCO + NRO_CTA_BCO hacia CUENTAS_BANCARIAS

### 5.3 Observacion
El modulo CG tiene todas sus tablas con 0 filas excepto CG_GLOBAL (7 registros de configuracion). Esto indica que el modulo de contabilidad esta configurado pero **no se esta usando activamente**, o bien los asientos se generan y eliminan en procesos batch. La vinculacion con el modulo presupuestario existe via CLAVE_CTA_CG en CP_EROGACION_CUENTAS e INGRESO_CUENTAS.

---

## 6. Modulo SLD_ - Sueldos / Liquidacion de Haberes

### 6.1 Inventario de tablas

| Tabla | Filas | Descripcion |
|-------|-------|-------------|
| SLD_SUELDO_HIST | 89,039 | Historia salarial por liquidacion-empleado |
| SLD_SUELDO_HIST_DET | 890,758 | Detalle de novedades por recibo |
| SLD_SUELDO_HIST_ACUM | 484,296 | Acumuladores por recibo |
| SLD_SUELDO_HIST_FLIA | 78,040 | Cargas de familia por recibo |
| SLD_SUELDO_HIST_RECIBOS | 26,196 | Recibos de sueldo generados |
| SLD_FORMA_PAGO | 3,147 | Pagos por liquidacion |
| SLD_FORMA_PAGO_DET | 122,800 | Detalle de pago por empleado |
| SLD_LIQUIDACION | 2,373 | Cabecera de liquidaciones (periodo-tipo) |
| SLD_LIQUIDACION_ANO | 268 | Habilitacion por anio |
| SLD_LIQUIDACION_AUDITORIA | 1,715 | Auditoria de cambios en liquidaciones |
| SLD_NOVEDADES | 29,672 | Novedades permanentes/transitorias |
| SLD_NOVEDADES_TIPOS | 285 | Catalogo de conceptos salariales |
| SLD_PERSONAL | 565 | Datos laborales del empleado |
| SLD_PERSONAL_HIS | 3,205 | Historial de cambios laborales |
| SLD_PERSONAL_FLIA | 655 | Cargas de familia |
| SLD_PERSONAL_VARIOS | 0 | Datos varios del personal |
| SLD_PERSONAL_CONSENSO_FISCAL | 0 | Consenso fiscal |
| SLD_PERSONAL_GANANCIAS_649 | 0 | Formulario 649 ganancias |
| SLD_PERSONAL_GANANCIAS_ACUM | 0 | Acumuladores de ganancias |
| SLD_PERSONAL_GANANCIAS_IMP_DDJJ | 0 | DDJJ ganancias |
| SLD_PERSONAL_GANANCIAS_PRORRATEO | 0 | Prorrateo ganancias |
| SLD_PERSONAL_CUENTA_BANCO_HIST | 60 | Historial de cuentas bancarias del empleado |
| SLD_EMPLEADOS_LIQUIDACION_TIPOS | 26 | Tipos de liquidacion (plantilla, categoria) |
| SLD_ACUMULADORES_TIPOS | 32 | Tipos de acumuladores |
| SLD_FORMULAS_NOVEDAD | 353 | Formulas de calculo de novedades |
| SLD_MENSAJES_FORMULA | 10 | Mensajes de formulas |
| SLD_VINCULACION_CP | 2,370 | Vinculacion novedad hacia cuenta presupuestaria |
| SLD_SU_CUENTA | 8,065 | Sub-cuentas presupuestarias para sueldos |
| SLD_SU_CUENTA_PUNTUAL | 81,088 | Detalle puntual de sub-cuentas |
| SLD_SU_CHEQUE | 10 | Cheques emitidos para sueldos |
| SLD_TMP_IMPRESION | 353,891 | Temp. de impresion de recibos |
| SLD_EMBARGOS | 0 | Embargos sobre haberes |
| SLD_EQUIVALENCIAS_CAJA_JUBILACION | 83 | Equivalencias para caja de jubilaciones |
| SLD_GLOBAL_CAJA_JUBILACION | 129 | Valores globales de caja jubilacion |
| SLD_GLOBAL_SUELDOS | 1,216 | Parametros globales de sueldos |
| SLD_GLOBAL_PERIODOS | 0 | Periodos globales |
| SLD_NRO_INTERNO | 2 | Numeracion interna |
| SLD_PARTE_DIARIO | 0 | Parte diario de asistencia |
| SLD_RELOJ | 0 | Control de reloj fichaje |
| SLD_POLIZAS | 0 | Polizas de seguro |
| SLD_POLIZAS_BENEFICIARIOS | 0 | Beneficiarios de polizas |
| SLD_ESPECIAL_SUELDOS | 12 | Listados especiales configurados |
| SLD_ESPECIAL_SUELDOS_CAMPOS | 70 | Campos de listados especiales |
| SLD_ESPECIAL_SUELDOS_COLUMNAS | 11 | Columnas de listados |
| SLD_ESPECIAL_SUELDOS_FILTROS | 12 | Filtros de listados |
| SLD_ESPECIAL_SUELDOS_ORDEN | 19 | Ordenamiento de listados |
| SLD_ESPECIAL_SUELDOS_PARAM | 13 | Parametros de listados |
| SLD_ESPECIAL_SUELDOS_HOJAS | 0 | Hojas de listados |
| SLD_VALES | 0 | Vales de anticipo de sueldos |
| SLD_VALES_DET | 0 | Detalle de vales |
| SLD_VALES_DET_HIST | 0 | Historico de vales |
| SLD_VALES_HIST | 0 | Historico general de vales |
| SLD_TRABAJOS_REALIZADOS | 0 | Registro de trabajos adicionales |
| SLD_CJ_DIAS_HORAS_INFORMADOS | 413 | Dias/horas para caja de jubilaciones |
| SLD_CJ_LOTE_DET | 0 | Detalle de lotes CJ |
| SLD_CJ_LOTE_PROCESO | 0 | Proceso de lotes CJ |
| SLD_AREAS_PROP | 0 | Proporciones por area |
| SLD_RG_* (15 tablas) | varios | Tablas para calculo de Ganancias (Impuesto 4ta categoria) |

### 6.2 Columnas clave

#### SLD_LIQUIDACION (2,373 filas)
- **PK:** TIPO_EMP_LIQ (char 4) + ANO (char 4) + PERIODO (char 2)
- FECHA_LIQUIDACION / FECHA_PAGO / FECHA_JUBI / FECHA_VALIDEZ
- CERRADA (char 1) -- estado del periodo
- DESCRIPCION / DESC_PERIODO
- PROCESADO_CJ / EXCLUIR_DE_GANANCIAS

#### SLD_SUELDO_HIST (89,039 filas)
- **PK:** NRO_SUELDO (char 8)
- FK: TIPO_EMP_LIQ + ANO + PERIODO hacia SLD_LIQUIDACION
- NRO_LEGAJO (char 8) / CATEGORIA (char 4) / AREA_ADM (char 4)
- DIAS_TRABAJADOS / REMUNERACION / SUBSIDIO / DESCUENTO / APORTES (money)
- LIQMANUAL (char 1) / CATEGORIA_TEMPORAL / FUNCION / UBICACION

#### SLD_SUELDO_HIST_DET (890,758 filas)
- FK: NRO_SUELDO hacia SLD_SUELDO_HIST
- TIPO_NOVEDAD + NOVEDAD (FK SLD_NOVEDADES_TIPOS)
- MONTO / UNIDAD (money) / MAGNITUD (char)

#### SLD_PERSONAL (565 filas -- empleados)
- **PK:** LEGAJO (char 8)
- IDENTIFICADOR (FK PERSONAS)
- NUMERO_JUBILACION / TIPO_JUBILACION
- FECHA_ANTIGUEDAD / ACTIVO
- Cargas de familia: CONYUGE / HIJOS / FAMILIA_NUMEROSA / PRENATAL / DISCAPACITADO
- TIPO_CTA_BCO + BANCO + NRO_CTA_BCO + CBU (cuenta bancaria para acreditacion)
- Segunda cuenta: BANCO2 / TIPO_CTA_BCO2 / NRO_CTA_BCO2 / CBU2

#### SLD_NOVEDADES (29,672 filas)
- FK: LEGAJO hacia SLD_PERSONAL
- TIPO_NOVEDAD + NOVEDAD (FK SLD_NOVEDADES_TIPOS)
- ANO_DESDE + PERIODO_DESDE / ANO_HASTA + PERIODO_HASTA -- vigencia
- CANTIDAD / VALOR_1 / VALOR_2 / COD_INICIO / FECHA_HASTA

#### SLD_VINCULACION_CP (2,370 filas)
- TIPO_NOVEDAD + NOVEDAD -- tipo de concepto salarial
- AREA_ADM -- area administrativa
- ANO_ERO + RECONDUCIDO_ERO + NRO_CTA_ERO (FK CP_EROGACION_CUENTAS)
- PORC (money) -- porcentaje de imputacion al presupuesto

Tipos de liquidacion detectados: Autoridades Superiores (0101), SAC (0106), Decreto 02/2010 (0107), Personal Permanente (0202), SAC Permanente (0206), Personal Contratado (0303), entre otros (26 tipos en total).

### 6.3 Datos de muestra
- 565 empleados activos en SLD_PERSONAL
- Liquidacion mas reciente registrada: Diciembre 2025 (multiples tipos de liquidacion)
- 285 conceptos salariales distintos (novedades) en SLD_NOVEDADES_TIPOS
- Ejemplos de conceptos: Sueldo Basico (00001), SAC (00006), Inasistencia (00005), Dedicacion Exclusiva (00007)
- SLD_RG_TMP_F1357_PAPEL_DE_TRABAJO tiene 161,852 registros -- calculo de retencion Ganancias activo

---

## 7. Tablas Bancarias

### 7.1 Inventario de tablas

| Tabla | Filas | Descripcion |
|-------|-------|-------------|
| BANCOS | 216 | Catalogo de entidades bancarias |
| CUENTAS_BANCARIAS | 25 | Cuentas bancarias de la municipalidad |
| CUENTAS_BANCARIAS_TIPOS | 10 | Tipos: Caja (00), CC (01), Ahorro (02/03), PF (04), Fondo (05/06), FF (07), Lecor (08), Sueldos (20) |
| CUENTAS_BANCARIAS_TIPOS_MOVIM | 68 | Tipos de movimiento bancario |
| OPERACIONES_BANCARIAS | 294,494 | Operaciones bancarias registradas |
| OPERACIONES_BANCARIAS_NO_CONT | 211,349 | Operaciones NO contables (para conciliacion) |
| OPERACIONES_BANCARIAS_TIPOS | 40 | Tipos de operacion bancaria |
| OPERACIONES_BANCARIAS_CONC | 0 | Conciliaciones de operaciones |
| OPERACIONES_BANCARIAS_CONC_PRO | 0 | Proceso de conciliacion |
| OPERACIONES_BANCARIAS_OPE_BANC | 0 | Relaciones entre operaciones |
| OPERACIONES_BANCARIAS_NO_CONT_CONC | 0 | Conciliacion no contables |
| OPERACIONES_BANCARIAS_NO_CONT_OPE_BANC | 0 | Relacion no contables |
| OPERACIONES_BANCARIAS_NO_CONT_PRO | 0 | Proceso no contables |
| RESUMENES_BANCARIOS | 1,759 | Resumenes bancarios cargados |
| RESUMENES_BANCARIOS_DETALLE | 0 | Detalle de resumenes |
| RESUMENES_BANCARIOS_DETALLE_OPE_BANC | 0 | Relacion resumen-operacion |
| OP_BANCARIAS | 0 | Tabla alternativa (probablemente alias) |
| CJC_OPERACIONES | 717,245 | Operaciones de caja/cajero externo |

### 7.2 Columnas clave

#### CUENTAS_BANCARIAS (25 filas)
- **PK:** TIPO_CTA_BCO (char 4) + BANCO (char 15) + NRO_CTA_BCO (char 13)
- CONCEPTO (varchar 50) -- nombre de la cuenta
- SALDO_ACTUAL / SALDO_INICIAL / SALDO_FINANCIERO_INI (money)
- FECHA_APERTURA / FECHA_CIERRE
- PERMITE_NEGATIVO / PERMITE_PAGO_ELECTRONICO / PERMITE_RESTRICCION_FECHA_ACREDITACION
- RESTRICCION_DESDE / RESTRICCION_HASTA (int -- dias del mes)
- CBU (varchar 22) / ID_FORMATO_RESUMEN

#### OPERACIONES_BANCARIAS (294,494 filas)
- **PK:** TIPO_OPE_BAN + TIPO_CTA_BCO + BANCO + NRO_CTA_BCO + NRO_OPE_BAN
- FK hacia CUENTAS_BANCARIAS via TIPO_CTA_BCO + BANCO + NRO_CTA_BCO
- ANO_PLANILLA + NRO_PLANILLA (FK CP_PLANILLAS)
- TIPO_RECIBO + ANO_RECIBO + NRO_RECIBO (FK CP_RECIBOS -- ingresos)
- TIPO_CTA_BCO_CONCILIA + BANCO_CONCILIA + NRO_CTA_BCO_CONCILIA -- cuenta contraparte
- FECHA_RESUMEN_BANCARIO + FECHA_CONCILIACION -- estado conciliacion
- ANO_TRANSFERENCIA + NRO_TRANSFERENCIA -- para transferencias
- FECHA_OPE_BAN / MONTO_OPE_BAN (money) / ESTADO_OPE_BAN (char 1)
- FECHA_ACREDITACION / CONCEPTO / IMPRESO

#### OPERACIONES_BANCARIAS_NO_CONT (211,349 filas)
- **PK:** TIPO_CTA_BCO + BANCO + NRO_CTA_BCO + TIPO_OPE_BAN + NRO_OPE_BAN_NO_CONT
- Operaciones del resumen bancario que NO tienen correspondencia contable
- FECHA_RESUMEN_BANCARIO + FECHA_CONCILIACION + FECHA_OPE_BAN_NO_CONT
- MONTO_OPERACION_NO_CONT / CONCEPTO / USUARIO / DIRECCION_IP
- ID_RES_BAN_DET (int) -- vinculo al detalle del resumen

#### RESUMENES_BANCARIOS (1,759 filas)
- **PK:** TIPO_CTA_BCO + BANCO + NRO_CTA_BCO + FECHA_RESUMEN_BANCARIO
- SALDO_RESUMEN_BANCARIO / SALDO_CONCILIADO (money)
- NOMBRE_ARCHIVO / CONTENIDO_ARCHIVO (varbinary) -- archivo original del banco

#### BANCOS (216 filas)
- **PK:** BANCO (char 15)
- CONCEPTO (varchar 50) -- nombre completo
- CONCEPTO_ABREVIADO (varchar 15)

#### CJC_OPERACIONES (717,245 filas -- mayor tabla bancaria)
- Operaciones de caja/cajero externo (punto de recaudacion)
- CAJERO + FECHA_CAJA + NRO_SESSION + NRO_OPERACION
- IDENTIFICADOR (persona que paga), APELLIDO/NOMBRE, TDOC/NDOC, TELEFONO
- NRO_RECIBO / ANULACION / NRO_RECIBO_ANULADO / CAJERO_SUPERVISOR

### 7.3 Cuentas bancarias detectadas (muestra)
- 00/0000/1: EFECTIVO (saldo $151,296,340.92)
- 00/0000/1001: Cheques en Cartera ($25,679,362.67)
- 01/0011/14700002-98: Banco Nacion - GENERAL ($1,934,565.90)
- 01/0020/0001400603: Banco (ciudad/nacion) ($71,209,666.86)
- 01/0020/0001638402: saldo negativo (-$104,785.22)
- EFECTIVO, DOLARES, DOCUMENTOS -- cuentas virtuales de tesoreria

Tipos de operacion bancaria detectados (40 en total):
- 000 Recibir Efectivo | 001 Recibir Cheques | 002 Recibir Bonos
- 003 Pagar con efectivo | 004 Pagar con Bonos
- 005 Extracc. p/Banco efectivo | 007 Extracc. p/Fondo Fijo
- 101 Cheque (emitido) | 102 Deposito | 103-106 Notas de Debito bancarias
- 107-109 Notas de Credito (coparticipacion, fondo descentralizado, varia)

---

## 8. Tablas Auxiliares

### 8.1 AGENDA (118,813 filas)
Principal tabla de actividad institucional / workflow.

**Columnas:**
- ID_EVENTO (int PK), ID_GESTOR (char 5), ID_BIEN (char 5)
- FECHA / HORA_INICIO / HORA_FIN
- COD_PROCEDIMIENTO / COD_RESULTADO / POLITICA
- ASUNTO (char 100) / LUGAR (char 100) / DESCRIPCION (text)
- NRO_NOTI / ENCARGADO / CONTACTO
- CODIGO_USUARIO_BD / IDAREA (FK AREAS)
- FECHA_AC / DATO1-5 (varchar 200 c/u) -- campos libres extensibles

### 8.2 AREAS (65 filas)
Jerarquia de areas administrativas.

**Columnas:**
- IdArea (int PK) / Codigo (varchar 50) / Descripcion (varchar 50)
- Version (varchar 4)
- IdAreaSuperior (int FK AREAS) -- estructura jerarquica recursiva

### 8.3 Otras tablas
- TMP_CJC_OPERACIONES (0 filas) -- temporal de operaciones cajero
- TMP_JOSE_OPERACIONES (6 filas) -- tabla temporal de trabajo ad-hoc

---

## 9. Vistas y Stored Procedures

### 9.1 Vistas

Las vistas encontradas NO corresponden a los prefijos CP_/CO_/CG_ esperados. Se encontraron:

#### Vistas CPAR_* (4 vistas)
- CPAR_PERS -- Personas (probablemente vista de padron/catastro)
- CPAR_PLANO -- Plano (probablemente catastral)
- CPAR_PROP -- Propiedades
- CPAR_SERVICIOS -- Servicios

#### Vistas SLD_LE_* (35 vistas)
Vistas de liquidaciones especiales para reportes. Nomenclatura: SLD_LE_VI_[NOMBRE]

| Vista | Descripcion probable |
|-------|---------------------|
| SLD_LE_LIQUIDACION | Resumen de liquidaciones |
| SLD_LE_PERSONAL | Personal vigente |
| SLD_LE_PERSONAL_HIS | Historial de personal |
| SLD_LE_VI_EMPLEADOS | Listado de empleados |
| SLD_LE_VI_PERSONAL / PERSONAS | Datos personales |
| SLD_LE_VI_BASICOS / BRUTOS / NETOS | Conceptos salariales agrupados |
| SLD_LE_VI_EMBARGOS / EMABRGOS | Embargos (hay dos vistas, una con typo) |
| SLD_LE_VI_LISTADO_EMBARGOS | Listado consolidado de embargos |
| SLD_LE_VI_GANANCIAS | Calculo de ganancias |
| SLD_LE_VI_CUENTAS_BANCARIAS | Cuentas bancarias del personal |
| SLD_LE_VI_HORAS_EXTRAS | Control de horas extras |
| SLD_LE_VI_AREA_ADMINISTRATIVA | Distribucion por area |
| SLD_LE_VI_SEGURO | Polizas de seguro |
| SLD_LE_VI_LISTA_TOTALES | Totales por liquidacion |
| SLD_LE_VI_NUEVO_CAJA / NUEVO_CC | Nuevas cuentas de caja/CC |
| SLD_LE_VI_PADRON1 | Padron de empleados |
| SLD_LE_VI_UNO / DOS / TRES / CUATRO | Vistas numeradas (reportes custom) |
| SLD_LE_VI_ADRIAN / ADRIAN2 / DANIEL / FEDE / LUIS01 / ROLO | Vistas personales de usuarios ad-hoc |
| SLD_LE_VI_PRUHIST / PRUPAR | Vistas de prueba/desarrollo |

### 9.2 Stored Procedures y Funciones

| Nombre | Tipo | Modulo | Descripcion |
|--------|------|--------|-------------|
| CP_ANALISIS_BALANCE_POR_PROGRAMA | PROCEDURE | CP | Analisis del balance por programa presupuestario |
| CP_ANALISIS_PRESUP_POR_PROGRAMA | PROCEDURE | CP | Analisis presupuestario por programa |
| CP_DOCUMENTOS_POR_CUENTA | PROCEDURE | CP | Documentos vinculados a una cuenta presupuestaria |
| SLD_CAMBIO_LEGAJO | PROCEDURE | SLD | Cambio de numero de legajo a un empleado |
| SLD_GUARDAR_VINC_SUELDOS | PROCEDURE | SLD | Guardar vinculacion sueldos-presupuesto |
| SLD_LE_COLUMNAS | FUNCTION | SLD | Funcion para listados especiales (columnas) |
| SLD_LIST_ESPECIAL_SLD | PROCEDURE | SLD | Genera listados especiales de sueldos |
| SLD_TRAN_FORMULA | PROCEDURE | SLD | Ejecucion de formula de novedad salarial |
| SLD_TRAN_FORMULA_GENERAL | PROCEDURE | SLD | Formula general de liquidacion |
| SLD_TRAN_TEXTO_NOTI | PROCEDURE | SLD | Texto de notificacion de formula |
| CONSUMO_BLOQUE | PROCEDURE | otro | Consumo por bloque (catastro/servicios?) |
| CONSUMO_CONTROL | PROCEDURE | otro | Control de consumos |
| CONSUMO_CONTROL_MUNI | PROCEDURE | otro | Control municipal de consumos |
| COPIA_VINCULACION_CAJERO_ANO | PROCEDURE | CJC | Copia vinculaciones de cajero al nuevo anio |

**Observacion:** El modulo CP_ tiene muy pocos SPs -- la logica de negocio esta mayormente en la capa de aplicacion. El modulo SLD_ tiene mas logica de base de datos por la complejidad de las formulas salariales.

---

## 10. Relaciones Entre Tablas

### 10.1 Foreign Keys Explicitas Principales

#### Nucleo del ciclo del gasto (CP_)
```
CP_AFECTACIONES_TIPOS
    [referenciado por] CP_AFECTACIONES_ANO
                       [referenciado por] CP_AFECTACIONES ---> PERSONAS (IDENTIFICADOR)
                                              |
                                  CP_AFECTACIONES_IMPUTACIONES ---> CP_EROGACION_CUENTAS
                                              |
                                          CP_COMPROMISOS ---> PERSONAS
                                              |
                                  CP_COMPROMISOS_IMPUTACIONES ---> CP_EROGACION_CUENTAS
                                  CP_COMPROMISOS_FACTURAS -------> CO_FACTURAS_COMPRAS
                                              |
                                          CP_ORDENES_PAGO ---> PERSONAS, CP_PLANILLAS
                                              |
                                  CP_ORDENES_PAGO_IMPUTACIONES ---> CP_COMPROMISOS_IMPUTACIONES
                                              |
                                  CP_ORDENES_PAGO_PAGOS ---> OPERACIONES_BANCARIAS, CP_PAGOS
```

#### Cuentas presupuestarias
```
CP_EROGACION_CUENTAS_TIPOS ---> CP_EROGACION_CUENTAS ---> (self-ref: vinc_pres, ctrl_pres)
CP_INGRESO_CUENTAS_TIPOS ----> CP_INGRESO_CUENTAS ----> (self-ref: vinc_pres, ctrl_pres)

CP_BALANCE
    CP_BALANCE_CUENTAS_BANCARIAS ---> CUENTAS_BANCARIAS
    CP_BALANCE_EROGACION_CUENTAS ---> CP_EROGACION_CUENTAS
    CP_BALANCE_INGRESO_CUENTAS ----> CP_INGRESO_CUENTAS
```

#### Compras (CO_)
```
PERSONAS --> CO_PROVEEDORES --> CO_PROVEEDORES_IMPUESTOS, _RUBROS, _CTA_BANCARIA, _REPRESENTANTES
                   |
                CO_FACTURAS_COMPRAS --> CO_FACTURAS_COMPRAS_DET
                        |           --> CO_DOCUMENTOS_FACTURA
                        |           --> CO_COMPROMISO_FACTURAS
                        |
                CO_PAGO_FACTURAS --> CP_PAGOS

CO_ABASTECIMIENTO --> AREAS
CO_PEDIDO_PRESUPUESTO --> CO_PEDIDO_PRESUPUESTO_DET, _PROV, _ABS
CO_SUMINISTRO --> CP_AFECTACIONES
CO_SUMINISTRO_DET --> CP_EROGACION_CUENTAS + AREAS
```

#### Sueldos (SLD_)
```
PERSONAS --> SLD_PERSONAL --> SLD_PERSONAL_HIS (+ AREAS)
                     |    --> SLD_PERSONAL_FLIA
                     |    --> SLD_NOVEDADES --> SLD_NOVEDADES_TIPOS
                     |    --> SLD_EMBARGOS
                     |    --> SLD_PARTE_DIARIO
                     |
SLD_LIQUIDACION --> SLD_SUELDO_HIST (NRO_SUELDO)
                        |
                        --> SLD_SUELDO_HIST_DET --> SLD_NOVEDADES_TIPOS
                        --> SLD_SUELDO_HIST_ACUM --> SLD_ACUMULADORES_TIPOS
                        --> SLD_SUELDO_HIST_FLIA
                        |
                    SLD_FORMA_PAGO --> SLD_FORMA_PAGO_DET --> SLD_SUELDO_HIST

SLD_VINCULACION_CP --> CP_EROGACION_CUENTAS
SLD_SU_CUENTA ------> CP_EROGACION_CUENTAS
```

#### Bancario hacia presupuesto
```
CUENTAS_BANCARIAS <-- OPERACIONES_BANCARIAS
CUENTAS_BANCARIAS <-- CP_BALANCE_CUENTAS_BANCARIAS
CUENTAS_BANCARIAS <-- CP_FONDOS_GASTOS_ESPECIFICOS_TESORERIA
CP_ORDENES_PAGO_PAGOS --> OPERACIONES_BANCARIAS (el pago origina la operacion bancaria)
```

### 10.2 Relaciones Implicitas (sin FK formal)

| Columna comun | Tablas involucradas | Descripcion |
|---------------|---------------------|-------------|
| IDENTIFICADOR (char 5) | CP_AFECTACIONES, CP_COMPROMISOS, CP_ORDENES_PAGO, CP_PAGOS, CP_RECIBOS, CO_FACTURAS_COMPRAS, CO_PROVEEDORES, SLD_PERSONAL, SLD_PERSONAL_FLIA | Clave universal de persona hacia tabla PERSONAS |
| ANO_ERO + RECONDUCIDO_ERO + NRO_CTA_ERO | CP_AFECTACIONES_IMPUTACIONES, CP_COMPROMISOS_IMPUTACIONES, CP_ORDENES_PAGO_IMPUTACIONES, CP_BALANCE_EROGACION_CUENTAS, SLD_VINCULACION_CP, SLD_SU_CUENTA | Cuenta presupuestaria de erogacion |
| TIPO_CTA_BCO + BANCO + NRO_CTA_BCO | OPERACIONES_BANCARIAS, CP_ORDENES_PAGO_PAGOS, RESUMENES_BANCARIOS, SLD_PERSONAL | Cuenta bancaria institucional o del empleado |
| LEGAJO (char 8) | SLD_PERSONAL, SLD_NOVEDADES, SLD_SUELDO_HIST (NRO_LEGAJO), SLD_PERSONAL_HIS | Identificador de empleado en modulo de sueldos |
| NRO_SUELDO (char 8) | SLD_SUELDO_HIST, SLD_SUELDO_HIST_DET, SLD_SUELDO_HIST_ACUM, SLD_SUELDO_HIST_FLIA, SLD_FORMA_PAGO_DET | Recibo de sueldo individual |
| TIPO_EMP_LIQ + ANO + PERIODO | SLD_LIQUIDACION, SLD_SUELDO_HIST, SLD_NOVEDADES, SLD_FORMA_PAGO | Periodo de liquidacion salarial |
| ANO_PLANILLA + NRO_PLANILLA | CP_ORDENES_PAGO, CP_RECIBOS, OPERACIONES_BANCARIAS | Planilla diaria de tesoreria |
| TIPO_OPE_BAN + NRO_OPE_BAN | OPERACIONES_BANCARIAS, CP_ORDENES_PAGO_PAGOS | Operacion bancaria |

---

## 11. Preguntas Abiertas

### 11.1 Modulo CG_ (Contabilidad General) sin datos
Todas las tablas CG_ tienen 0 filas excepto la configuracion (CG_GLOBAL con 7 registros). Las preguntas son:
- Se estan generando asientos pero se borran en un proceso batch?
- El modulo de contabilidad esta inhabilitado o en fase de implementacion?
- Se usa un sistema externo de contabilidad?
- La FK CLAVE_CTA_CG en CP_EROGACION_CUENTAS existe y apunta a CG_PLAN, pero CG_PLAN tiene 0 registros -- los valores son NULL?

### 11.2 Tabla PERSONAS no investigada
Todas las FKs de IDENTIFICADOR apuntan a una tabla PERSONAS que no fue incluida en el scope de investigacion. Esta tabla es critica pues contiene los datos basicos de todos los proveedores, empleados y beneficiarios del sistema.

### 11.3 Modulos CO_ con 0 filas
Varios modulos de compras (CO_ORDENES_COMPRA, CO_PEDIDO_PRESUPUESTO, CO_ABASTECIMIENTO, CO_SUMINISTRO, CO_FONDOFIJO) tienen 0 filas. Posibles explicaciones:
- Modulos implementados pero no activados por la municipalidad
- Datos en otra base de datos
- Funcionalidades que se configuraron pero no se usan en este municipio especifico

### 11.4 Retenciones impositivas
CP_RETENCION_PAGOS y CP_RETENCION_PAGOS_DET tienen 0 filas, a pesar de tener 31 tipos de retencion configurados. La aplicacion de retenciones puede estar manejandose de otra forma o fuera del sistema.

### 11.5 Fecha erronea en facturas
Se detecta una factura CO_FACTURAS_COMPRAS con fecha 03/11/2041 -- dato claramente erroneo de carga. Pueden existir otros registros con fechas fuera de rango.

### 11.6 CJC_OPERACIONES vs OPERACIONES_BANCARIAS
CJC_OPERACIONES (717,245 filas) es la tabla mas grande del sector bancario pero no tiene FKs definidas hacia otras tablas de presupuesto. La relacion con CP_RECIBOS se hace via NRO_RECIBO pero no hay FK formal. Requiere investigacion del proceso de vinculacion entre cajero externo y tesoreria.

### 11.7 Conciliacion bancaria no activa
Las tablas de conciliacion (OPERACIONES_BANCARIAS_CONC, RESUMENES_BANCARIOS_DETALLE) tienen 0 filas, aunque OPERACIONES_BANCARIAS_NO_CONT tiene 211,349 registros. El proceso de conciliacion formal no parece estar activo o no se usa esta funcionalidad.

### 11.8 Modulos no investigados
Hay tablas con otros prefijos en la base de datos que no formaron parte de esta investigacion:
- CONSUMO_* (consumos municipales -- servicios publicos)
- GLOBAL (tabla de parametros globales)
- Otras tablas del sistema catastral/tributario vinculadas via vistas CPAR_*

---

## 12. Resumen de Conexiones Entre Modulos

```
                    PERSONAS (tabla maestra)
                   /         |         \
                  /          |          \
           CO_PROVEEDORES  CP_AFECTACIONES  SLD_PERSONAL
                |               |               |
                |           CP_COMPROMISOS  SLD_NOVEDADES
           CO_FACTURAS         |
            COMPRAS        CP_ORDENES_PAGO
                |               |
           CO_DOCUMENTOS    OPERACIONES_BANCARIAS <---> CUENTAS_BANCARIAS <---> BANCOS
            FACTURA              |
                             CP_PAGOS
                                 |
                          CP_EROGACION_CUENTAS <-----------> CG_PLAN (vinculo, CG sin datos)
                          CP_INGRESO_CUENTAS
                                 |
                           CP_BALANCE <---------> CP_PLANILLAS
                                 |
                          CP_BAL_CTA_BCO <---> CUENTAS_BANCARIAS

          SLD_VINCULACION_CP ------> CP_EROGACION_CUENTAS (vinculacion sueldos-presupuesto)
```

---
*Reporte generado el 2026-06-22 mediante inspeccion directa de la base de datos PROGRAM en servidor 149.50.144.8*
