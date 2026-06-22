# Motor de Cálculo y Liquidación — PROGRAM (PGM)

## Resumen

El motor de liquidación de PGM es un sistema VB.NET compilado en runtime que ejecuta fórmulas almacenadas en la BD. El stored procedure principal `sp_rt_Liquida` delega la ejecución al objeto COM externo `wliqtasasscr.wliq_tasasscr`.

---

## 1. Flujo completo de liquidación

```
RT_CUOTAS_TIPOS (TIPO_BIEN + TIPO_PLAN + TIPO_CUOTA)
    ↓ define qué períodos existen
RT_CONDICIONES_LIQUIDACION (40,895 filas)
    ↓ define parámetros por período: fechas vencimiento, recargos, descuentos
RT_CONDICIONES_LIQUIDACION_ITEMS (24,796 filas)
    ↓ vincula período → TIPO_ITEM (conceptos que componen la cuota)
RT_ITEMS (462 ítems)
    ↓ cada ítem tiene VALOR_1/VALOR_2/CANTIDAD y fórmula
RT_FORMULAS_ITEMS_NET (513 filas VB.NET por TIPO_ITEM)
    ↓ ejecutada por COM object: wliqtasasscr.wliq_tasasscr
    ↓ → sp_rt_Liquida(@TIPO_BIEN, @TIPO_PLAN, @ANO_CUOTA, @NRO_CUOTA, @FECHA)
RT_FACTURAS (resultado: cabecera de factura por bien)
RT_FACTURAS_DETALLE (desglose por TIPO_ITEM: CAPITAL_ITEM + IVA + ACTUALIZACION)
RT_FACTURAS_ACUMULADOR (acumulado por ítem)
```

---

## 2. Configuración de tasas — RT_CONDICIONES_LIQUIDACION (40,895 filas)

**Clave compuesta:** TIPO_BIEN + TIPO_PLAN + TIPO_CUOTA + ANO_CUOTA + NRO_CUOTA

| Campo | Descripción |
|-------|-------------|
| FECHA_VENCIMIENTO1/2/3 | 3 fechas de vencimiento escalonadas |
| MONTO_RECARGO1/2/3 | Recargo por cada vencimiento |
| DTO_CTDO1/2/3 | Descuento por pago al contado |
| FECHA_VTO_CTDO1/2/3 | Fecha límite del descuento |
| CAPITAL_FACTURADO / COBRADO | Totales de facturación y cobro |
| ID_INDICE_ACTUALIZACION | FK → RT_INDICES_ACTUALIZACION |
| FECHA_LIQUIDACION | Cuándo se liquidó |

**Distribución por TIPO_BIEN:**
- PEPE (Tasa Personal): 11,191 condiciones
- ININ (Inmobiliario): 6,321
- CICI (Comercio): 4,326
- OBTE (Terrenos): 4,193
- OBSA (Agua): 2,779
- OBPV (Pavimento): 1,963
- AUAU (Automotores): 1,329
- ACTA (Juzgado): 48

---

## 3. Fórmulas de cálculo — RT_FORMULAS_ITEMS_NET (513 filas)

VB.NET compilado, ejecutado por COM. Estructura por TIPO_ITEM con ORDEN de ejecución:

| ORDEN | TIPO PASO | Ejemplo AUAU |
|-------|-----------|--------------|
| Init (XXIN) | Inicialización | Declaración de variables |
| 1-10 | Cálculo base | `VAR_BASI = BasicoTasa(ID_Bien)` |
| 11-20 | Cálculo envío | `If TieneGastosEnvio(ID_BIEN) Then VAR_ENVI = ValorENVI("Dato1")` |
| 21-30 | Cálculo admin | `$VAR_ADMI = ValorGADMI("Dato1")` |
| 29 | Débito bancario | `If TieneDebito(ID_BIEN)=1 Then VAR_DEBI=(VAR_BASI*ValorDEBI("Dato1")/100)*-1` |
| 91 | Descuento web | `ValorDWEB("Dato1")` (descuento gestión web) |
| Fin (XXFI) | Finalización | Asignación a CAPITAL en RT_FACTURAS_DETALLE |

### Fórmulas por tributo

| TIPO_ITEM | Fórmula/Función principal |
|-----------|--------------------------|
| AUAUBASI | `BasicoTasa(ID_Bien)` — base imponible del automotor |
| AUAUADMI | `ValorGADMI("Dato1")` — gastos administrativos |
| AUAUENVI | `ValorENVI("Dato1")` — gastos de envío |
| AUAUDEBI | `(VAR_BASI * ValorDEBI/100) * -1` — descuento débito automático |
| AUAU_WEB | `ValorDWEB("Dato1")` — descuento gestión web |
| OBSABASI | `VAR_BASI = VAR_BASI * RBEMISIO` — tasa básica de agua |
| ACTAMULT | `CalcularMonto(strArrayInfracciones)` — monto de multa de juzgado |
| ACTAREIN | `CalcularReincidencia(strCantReinc, VAR_MULT)` — reincidencia |

### Fórmulas legacy (RT_FORMULAS_ITEMS — 65 filas VBA)
```vba
CAPITAL = VAR_BASI * RBEMISIO   ' OBSABASI — básico agua
CAPITAL = VAR_ADMI * RBEMISIO   ' OBSA admin
```

---

## 4. Tasas de automotores — RT_AUTOMOTORES_TARIFARIA_ALICUOTAS (659 filas)

Sistema de **3 tramos progresivos** por categoría y año:

**2025 — Categoría A1 (autos particulares):**
| Hasta base imponible | Alícuota |
|----------------------|----------|
| 3,999,999 | 0.7% |
| 9,999,999 | 0.9% |
| Excedente | 1.1% |

**2017 — Categoría A1:**
| Hasta | Fijo | Alícuota excedente |
|-------|------|--------------------|
| 499,999 | — | 1.5% |
| 699,999 | $9,000 | 1.8% sobre excedente de 500K |
| Más de 700K | $16,100 | 2.3% sobre excedente de 700K |

**Categorías de vehículos:**
- A1–A5: Automóviles
- C1–C5: Camiones
- L1–L3: Livianos
- M1–M8: Motos
- O1, P1–P2, S1–S2: Otros

**RT_AUTOMOTORES_VALUACION (1,733,535 filas):**
ANO_VALUACION + CIP (código de tipo de vehículo) + MODELO_VALUACION → BASE_IMPONIBLE (money)
Ejemplo: 2008 / CIP 0000025304 / Modelo 1989 → $4,900 base imponible

**Alícuota histórica general (RT_AUTOMOTORES_TARIFARIA — 25 filas):**
1990=1.5%, 1999=4.5%, 2000–2003=variable, 2008–2025=1.5%

---

## 5. Actualización de deuda e intereses

### RT_ACTUALIZACION (7 filas)
| Método | Desde | Tasa mensual |
|--------|-------|--------------|
| A | 1980 | 3.0% |
| A | 1997 | 1.95% |
| A | 2002 | 1.2% |
| A | 2012 | 2.0% |
| A | 2015 | 3.0% |
| A | **2023** | **4.0% mensual** |

### SP_RT_VAL_DEUDA_ACT — Lógica de actualización
```
Método F (flat):
  ACTUAL = ((RESAR/30 × DIAS) / 100) × IMPORTE + IMPORTE

Método M (compuesto):
  Itera sobre rangos en RT_ACTUALIZACION
  Aplica tasa compuesta mes a mes
```
Resultado se escribe en `RT_TMP_VAL_DEUDA.IMP_ACTUALIZADO` y `ACT_PUNITORIO`.

### RT_INDICES_ACTUALIZACION (9 filas — 2022)
Factores por índice para ININ/OBSA/OBSC:
- Período 001: índice 1.00 (base)
- Período 002: índice 1.10
- Período 003: índice 1.20

---

## 6. Módulo MAL_ — Multas, Convenios y Sueldos (123 tablas)

### MAL_ agrupa tres submódulos:

| Submódulo | Tablas clave | Filas | Descripción |
|-----------|-------------|-------|-------------|
| Deuda | MAL_DEUDA | 519,000 | Deuda tributaria (OBSA, AUAU, OBPV) |
| Convenios (planes de pago) | MAL_CV_MAE, MAL_CV_DET, MAL_CUOTAS_TALO | 200K+ | Convenios de pago de deuda |
| Sueldos | MAL_SUE_MOV | 67,161 | Movimientos de liquidación de haberes |
| Contribuyentes | MAL_MAECON | 11,301 | Padrón de contribuyentes antiguo |

### MAL_DEUDA (519,000 filas) — Deuda con plan de pago
Columnas: CUENTA, TIPO_BIEN, ANO_CUOTA, TTALVENC (total al vencimiento), TTACTUAL (total actualizado), ID_BIEN, IDENTIFICADOR, TIPO_PLAN, ESTADO_PGM, SITUACION, FECHA_VENCIMIENTO1/2/3

### MAL_CV_MAE (68,917 filas) — Convenios de pago (planes)
- CVNUMER: número de convenio
- TIPO_BIEN: AUAU, OBPV, etc.
- CVIMVNC: importe al vencimiento
- CVIMACT: importe actualizado

### MAL_CUOTAS_TALO (118,863 filas) — Cuotas de convenio
- CONVENIO → MAL_CV_MAE
- NRO_INTERNO → RT_FACTURAS_DEUDA
- ESTADO_PGM, SITUACION, FECHA_VENCIMIENTO, PAGO, LIQUI

### MAL_RT_CONVENIO_TMP_MUESTRA (83,871 filas)
Simulaciones de planes de pago con: ID_BIEN, CLAVE_BIEN, MONTO_CAPITAL, ANO/TIPO/NRO_CONVENIO, conceptos como "Servicio de Agua", "Tasa por Servicio a la Propiedad"

### MAL_SUE_MOV (67,161 filas) — Movimientos de sueldos
MOLEGAJO, MOANIO, MOMES, MOCODIGO, MOIMPOR, AREA_ADM, CATEGORIA, NRO_SUELDO_PGM, FECHA_LIQUIDACION

---

## 7. Módulo JF_ — Juzgado de Faltas (43 tablas)

### JF_NOMENCLADOR (573 filas) — Catálogo de infracciones
| Campo | Descripción |
|-------|-------------|
| CODIGO | Código de infracción (ej: 804) |
| CONCEPTO | Descripción (ej: "Conducir automóvil...") |
| ARTICULO / INCISO | Base legal (Art. 39) |
| UF_MIN / UF_MAX | Rango de multa en Unidades de Falta |
| UF_SENTENCIA | UF estándar por sentencia |
| UF_ESPONTANEO | UF si el infractor paga voluntariamente |
| PUNTOS | Puntos de demerito |
| ATENUANTE / AGRAVANTE | Factores modificadores |
| ID_NORMATIVA | → JF_NORMATIVAS (ley/ordenanza base) |

### JF_UF_VALORES (4 filas) — Valor de la Unidad de Falta
| ID_UF | Desde | Valor URS |
|-------|-------|-----------|
| 1 | 1970 | 3.02 |
| 1 | 2018-08-01 | **28.58 ARS/UF** |
| 2 | — | 3.22 |
| 3 | — | 0.01 |

**Cálculo de multa:** Multa = UF_SENTENCIA × 28.58 ARS

### JF_ACTAS (12 filas activas — módulo poco usado)
- ID_ACTA, TIPO_ACTA ('TR'=tránsito), NRO_ACTA, DOMINIO (patente)
- Ejemplo: Patente AVK433, Peugeot 1996, mal estacionamiento → Multa $604.00

### JF_NORMATIVAS (11 filas)
- Ley Provincial 8560/2012
- Ordenanza 81104/2018
- Ordenanza 1034/2010

---

## 8. Stored Procedures totales: 636

### SP de liquidación core:
| SP | Parámetros | Descripción |
|----|-----------|-------------|
| `sp_rt_Liquida` | @TIPO_BIEN, @TIPO_PLAN, @ANO, @NRO_CUOTA, @FECHA | Devengamiento — delega a COM object |
| `SP_RT_LIQUIDA_APRO` | — | Aprobación de liquidación |
| `sp_rt_procesa_deuda` | — | Procesamiento de deuda |
| `SP_RT_VAL_DEUDA_ACT` | — | Actualización de deuda con intereses |
| `SP_RT_GEN_CED_DEUDA` | — | Generación de cedulones |
| `sp_rt_procesa_deuda_simular` | — | Simulación (sin grabar) |
| `CREA_PAGO_TOTAL` | — | Registro de pago total |
| `CREA_PAGO_PARCIAL` | — | Registro de pago parcial |
| `SP_SLD_LIQUIDA` / `SP_SLD_LIQUIDA2` | — | Liquidación de sueldos |

### Vistas clave:
- `VI_FACTURAS_CONDICIONES_LIQU` — condiciones de liquidación por factura
- `VI_AUTOMOTORES_DEUDA` — deuda de automotores
- `vi_Cuotas_Items_Habilitadas` — ítems activos por cuota
- `SLD_LE_LIQUIDACION` — liquidación de sueldos
- `S_JF_SENTENCIAS_SIN_PAGO` — multas sin cobrar

---

## 9. Relaciones de FK (RT_: 390 relaciones)

```
RT_CUOTAS_TIPOS → RT_PLANES_TIPO
RT_CONDICIONES_LIQUIDACION → RT_CUOTAS_TIPOS
RT_CONDICIONES_LIQUIDACION_ITEMS → RT_CONDICIONES_LIQUIDACION
RT_CONDICIONES_LIQUIDACION_ITEMS → RT_ITEMS
RT_FACTURAS → RT_PADRON_BASE (ID_BIEN)
RT_FACTURAS → RT_CONDICIONES_LIQUIDACION (TIPO_BIEN+PLAN+CUOTA+ANO+NRO)
RT_FACTURAS_DETALLE → RT_FACTURAS (NRO_INTERNO)
RT_FACTURAS_DETALLE → RT_ITEMS (TIPO_ITEM)
RT_FACTURAS_COBRO_DETALLE → RT_COBRADO + RT_FACTURAS_DEUDA_DETALLE
RT_CONVENIO_CUOTAS → RT_FACTURAS_DEUDA (NRO_INTERNO_DEUDA)
RT_AUTOMOTORES_VALUACION → RT_AUTOMOTORES_TIPOS → RT_AUTOMOTORES_TARIFARIA
RT_AUTOMOTORES_TARIFARIA_ESCALAS → RT_AUTOMOTORES_TARIFARIA
```
