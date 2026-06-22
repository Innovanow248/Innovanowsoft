# Administración Tributaria

Sistema de gestión tributaria municipal: padrón de contribuyentes, liquidación de tributos, cobranza y gestión de deuda.

## Descripción

Cubre el ciclo tributario completo:
- Padrón de bienes/contribuyentes (inmuebles, automotores, comercios, telefonía)
- Liquidación y facturación de tributos
- Emisión de cedulones y notificaciones
- Cobro en caja y canales digitales
- Gestión de deuda (planes de pago, intereses, prescripción)
- Detección de evasión asistida por IA

## Base de datos origen: PROGRAM (PGM)

| Módulo | Prefijo | Tablas | Filas | Descripción |
|--------|---------|--------|-------|-------------|
| Rentas / Tributos | RT_ | 507 | 260M | CORE: padrones, facturas, cobros |
| Caja / Cedulones | CJC_ | 39 | 37M | Cajeros, imputaciones, documentos |
| Notificaciones | NT_ | 28 | 38M | Cedulones masivos, avisos |
| Registro Propiedades | RNPA_ | 24 | 13M | Alta impositiva, titulares |
| Multas / Matrículas | MAL_ | 120 | 1.1M | Multas administrativas, matrículas |
| Juzgado de Faltas | JF_ | 43 | ~1K | Actas, causas, estados |
| Portal Ciudadano | egov_ | 6 | 750K | CFM web, historial claves |

## Tributos gestionados

| Tipo | Identificador | Volumen |
|------|---------------|---------|
| Inmobiliario | TIPO_BIEN = INMO | mayor por filas |
| Automotores / Patentes | RT_AUTOMOTORES | 1.7M valuaciones |
| Comercio / Ingresos Brutos | RT_COMERCIO | - |
| Telefonía | RT_TELEFONIA_MEDICION | 34.2M mediciones |
| Cementerio | - | - |

## Estructura del proyecto

```
administracion-tributaria/
├── investigacion/      # Mapeo de BD, esquemas, flujos
├── documentos/         # Documentos conceptuales y specs
├── modelos/            # Esquemas de datos del nuevo sistema
├── agentes/            # Agente de Recaudación, Evasión, Planes de Pago
├── api/                # Backend / endpoints
├── frontend/           # Portal ciudadano + backoffice
└── tests/              # Tests
```

## Stack propuesto

- **Backend:** FastAPI + SQLAlchemy
- **Base de datos nueva:** PostgreSQL
- **Agentes:** Claude API (claude-sonnet-4-6)
- **Frontend:** React + Vite + TypeScript + Tailwind

## Ciclo tributario

```
Alta de bien → Liquidación → Cedulón/Notificación → Cobro → Rendición → Gestión de deuda
```
