# Investigación: Flujo de Cobro — CJC_, NT_, RNPA_, egov_

## Claves de join globales

| Clave | Tipo | Descripción |
|-------|------|-------------|
| `NRO_INTERNO` | char(10) | **Clave maestra de pago** — vincula CJC_DOCUMENTOS, CJC_IMPUTACION, CJC_CEDULONES_VINC con RT_FACTURAS y RT_FACTURAS_DEUDA |
| `NRO_INTERNO_ORI` | char(10) | NRO_INTERNO del cedulón original (el comprobante que se está pagando) |
| `IDENTIFICADOR` | char(5) | Identificador de persona/ente — aparece en CJC_, NT_, egov_, RT_ |
| `ID_BIEN` | char(5) | Identificador del bien/cuenta tributaria (e.g. '01759' = TETE, AUAU, ININ, CICI) |

---

## Módulo CJC_ — Caja / Cobro (39 tablas · 37M filas)

### Flujo de cobro en caja

```
CJC_CAJERO (sesión de caja)
  └─ CJC_OPERACIONES (1 operación por sesión de pago) — 717,245 filas
       ├─ CJC_DOCUMENTOS (1 fila por cedulón pagado) — 1,572,543 filas
       │    └─ NRO_INTERNO → RT_FACTURAS.NRO_INTERNO
       ├─ CJC_IMPUTACION (imputaciones contables por cedulón) — 15,065,198 filas
       │    └─ NRO_INTERNO_ORI → RT_FACTURAS_DEUDA.NRO_INTERNO_DEUDA
       ├─ CJC_IMPUTACION_DICRI (imputaciones por tipo de ítem) — 10,683,585 filas
       ├─ CJC_CEDULONES_VINC (vínculo cedulón↔pago) — 3,487,309 filas
       ├─ CJC_PAGOS (montos por moneda) — 714,004 filas
       └─ CJC_PAGO_MONEDA — 77,157 filas
```

### Tablas clave CJC_

#### CJC_CAJERO (29,368 filas)
- PK: CAJERO + FECHA_CAJA + NRO_SESSION
- Campos: USUARIO, CERRADO, TRANSFERIDO, ANO/TIPO/NRO_RECIBO, DIFERENCIA_CIERRE, COD_RECIBO (MD5)

#### CJC_DOCUMENTOS (1,572,543 filas)
- PK: CAJERO + FECHA_CAJA + NRO_SESSION + NRO_OPERACION + ORDEN
- **NRO_INTERNO** char(10) → join con RT_FACTURAS
- TIPO_CEDULON, TIPO_BIEN, MONTO, COD_BARRA, IDENTIFICADOR, ENTE_RECA

#### CJC_IMPUTACION (15,065,198 filas)
- PK: CLAVE int
- NRO_INTERNO, **NRO_INTERNO_ORI** → join con RT_FACTURAS_DEUDA
- NRO_CTA_ING (cuenta contable), CAP_REC ('C'=Capital/'R'=Recargo), IMPORTE

#### CJC_CEDULONES_VINC (3,487,309 filas)
- NRO_INTERNO (recibo generado) + NRO_INTERNO_ORI (cedulón original) + IMPORTE
- Tabla de vinculación cedulón→pago efectivo

#### CJC_AUDITORIA (4,797,479 filas)
- Registro de auditoría de todas las operaciones de caja

### Tipos de cedulón (CJC_TIPO_CEDULON — 6 tipos)
_(pendiente: hacer SELECT * FROM CJC_TIPO_CEDULON)_

---

## Módulo NT_ — Notificaciones (28 tablas · 38M filas)

### Flujo de notificación/cedulón masivo

```
NT_NOTI_LOTE (601 lotes — configuración + filtros JSON)
  └─ NT_NOTI_LOTE_CUENTAS (881,186 — 1 fila/contribuyente, 89 columnas)
       │   Contiene: TIPO_BIEN, ID_BIEN, IDENTIFICADOR, CONTRIBUYENTE,
       │   domicilios múltiples, MONTO_DEUDA, BOLETA_DEUDA, TALONARIOS
       └─ NT_NOTI_LOTE_BOLETAS (33,425,816 — 1 fila/cuota a notificar)
            Contiene: NRO_INTERNO, ANO/TIPO/NRO_CUOTA, ESTADO_DEUDA,
            MONTO_DEUDA_HISTORICO, MONTO_DEUDA_ACTUALIZADO

NT_NOTI_NUEVA (4,079,310 — notificaciones efectivamente enviadas)
  Contiene: ID_BIEN, NRO_CEDULON, NRO_INTERNO_DEUDA, IDENTIFICADOR
  Canales: NT_NOTI_LOTE_ENVIOS (email/físico), 
           NT_NOTI_LOTE_ENVIOS_CIDI (13 — CIDI/Ciudadano Digital),
           NT_NOTI_LOTE_ENVIOS_WHATSAPP (11 — WhatsApp)
```

### NT_NOTI_LOTE — campo FILTROS
JSON con criterios completos del lote: tipo_bien, tipo_plan, situacion_deuda, rangos de deuda, etc.

### NT_NOTI_LOTE_CUENTAS (89 columnas)
La tabla más rica del módulo. Contiene datos completos del contribuyente para la notificación:
- TIPO_BIEN, ID_BIEN, IDENTIFICADOR, CONTRIBUYENTE, TITULARES
- DOMI_CONTRIB_* (domicilio contribuyente), DOMI_ENVIO_* (domicilio de envío), DOMI_CATA_* (catastral)
- MONTO_DEUDA_HISTORICO, MONTO_DEUDA_ACTUALIZADO, DEUDA_CORRIENTE, DEUDA_FINANCIACION
- BOLETA_DEUDA, TALONARIOS, DEUDA_ORIGINAL_DETALLE, DEUDA_TALONARIO_DETALLE
- NRO_MEDIDOR, CANT_DDJJ_NOTIFICADAS

---

## Módulo RNPA_ — Registro Nacional del Automotor (24 tablas · 13M filas)

Implementa el protocolo de intercambio de datos del RNPA (C1–C6):

| Tipo | Tabla | Filas | Descripción |
|------|-------|-------|-------------|
| C1 | RNPA_C1_ALTA_IMPOSITIVA | 11,884 | Alta de vehículo en el sistema tributario |
| C1 | RNPA_C1_ALTA_IMPOSITIVA_TITULARES | 12,250 | Titulares del alta |
| C2 | RNPA_C2_BAJA_IMPOSITIVA | 7,183 | Baja del sistema (venta, destrucción) |
| C4 | RNPA_C4_IMPUESTO_AUTOMOTOR | 44,111 | Registros de pago de impuesto automotor |
| C5 | RNPA_C5_INFORMACION_DEL_VEHICULO | 43,654 | Datos del vehículo |
| C5 | RNPA_C5_INFORMACION_DEL_VEHICULO_TITULARES | 44,580 | Titulares |
| C6 | RNPA_C6_CAMBIO_DE_TITULARIDAD | 612 | Transferencias de dominio |
| — | RNPA_DEUDA_DET_HIST | 13,593,555 | **Histórico de deuda automotor** |
| — | RNPA_DEUDA_DET | 147,301 | Deuda automotor vigente |

### RNPA_DEUDA_DET_HIST (13.5M filas — tabla principal)
Campos clave: NroInterno, DominioNuevo/Viejo (patente), Ano, NumeroDeCuota, ImporteBonificado, ImporteComun, EstadoDeuda, SituacionDeuda, TipoDeRegistro, FechaDeProceso

Join: RNPA_DEUDA_DET_HIST.NroInterno → RT_FACTURAS.NRO_INTERNO

---

## Módulo egov_ — Portal Ciudadano (8 tablas · 750K filas)

| Tabla | Filas | Descripción |
|-------|-------|-------------|
| egov_CFM | 1,276 | Usuarios del portal (Identificador + Password MD5 + Habilitado) |
| egov_BienesCFM | 1,295 | Bienes habilitados por usuario para consulta |
| egov_CFM_Historial_Claves | 2,799 | Historial de cambios de contraseña |
| egov_Notificaciones | 745,328 | Notificaciones enviadas por el portal |
| egov_Notificaciones_Tipo | 9 | Tipos: Solicitud de Incorporación, Recibo de Haberes, Gestión de Reclamos, etc. |
| egov_ServicioseGov | 4 | CDEU (Deuda), DDJJ (Declaración Jurada + Plan), CACA (Catastral) |
| egov_vBienesCFM | — | VISTA: bienes con nombre, TIPO_BIEN, CLAVE_BIEN |
| egov_vCFM | — | VISTA: usuarios con nombre, TIPO_DOCUMENTO, DOCUMENTO, DOMICILIO |

**Clave de acceso portal:** `egov_CFM.Identificador` = mismo char(5) del sistema core.

---

## Tablas AFIP de referencia

### AFIP_TIPO_DOCUMENTOS (6 filas)
| CODIGO_PGM | DESCRIPCION | CODIGO_AFIP |
|------------|-------------|-------------|
| 0 | Pasaporte | 94 |
| 1 | DNI | 96 |
| 2 | LE | 89 |
| 3 | LC | 90 |
| 5 | CUIT | 80 |
| 6 | CI Córdoba | 3 |

### AFIP_TIPO_IVA (8 filas)
| CODIGO_AFIP | DESCRIPCION | VALOR_IVA |
|-------------|-------------|-----------|
| 3 | 0% | 0.00 |
| 4 | 10.5% | 10.50 |
| 5 | 21% | 21.00 |
| 6 | 27% | 27.00 |
| 8 | 5% | 5.00 |
| 9 | 2.5% | 2.50 |

---

## Pendientes de investigación

- [ ] SELECT * FROM CJC_TIPO_CEDULON (6 tipos de cedulón)
- [ ] SELECT DISTINCT TIPO_BIEN FROM CJC_DOCUMENTOS (tipos de bien que pasan por caja)
- [ ] SELECT DISTINCT ESTADO_DEUDA FROM RT_FACTURAS (estados de deuda)
- [ ] Estructura completa de RT_PADRON_BASE y tipos de TIPO_BIEN
- [ ] Cómo se calculan los intereses (tablas de actualización RT_ACTUALIZACION)
- [ ] Estructura de planes de pago en RT
