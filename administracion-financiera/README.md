# Administración Financiera Gubernamental

Sistema de gestión del ciclo completo del gasto público, conducido por agentes de IA.

## Descripción

Cubre desde la formulación presupuestaria hasta el pago y la rendición de cuentas:
- Solicitudes y notas de pedido por voz/texto
- Proceso de compras y contrataciones
- Devengado automático por procesamiento de facturas
- Órdenes de pago y conciliación bancaria
- Sueldos y liquidación de haberes
- Contabilidad general y reportes de gestión

## Base de datos origen: PROGRAM (PGM)

| Módulo | Prefijo | Tablas | Filas | Descripción |
|--------|---------|--------|-------|-------------|
| Afectaciones y Compromisos | CP_ | 122 | 2.1M | Ciclo presupuestario completo |
| Compras / Proveedores | CO_ | 45 | 387K | Abastecimiento, facturas, proveedores |
| Proceso de Compras | CM_ | 27 | ~0 | Licitaciones, actas, modalidades |
| Sueldos | SLD_ | 96 | 2.4M | Liquidación de haberes, AFIP |
| Contabilidad General | CG_ | 13 | 7 | Asientos, plan de cuentas |
| Operaciones Bancarias | OPERACIONES_ | 9 | 505K | Pagos, conciliación |
| Mensajería Masiva | MM_ | 31 | 1.6M | Emails a proveedores/contribuyentes |
| Inventario / Artículos | IN_ | 4 | 6.6K | Catálogo de bienes y servicios |
| Recibos / Tickets | RD_ | 7 | 1.35M | Comprobantes de cobro |
| Cuentas Bancarias | CUENTAS_ | 3 | 103 | Cuentas oficiales |
| Cheques | CHEQUES_CARTERA | 1 | 9.3K | Cartera de cheques |

## Estructura del proyecto

```
administracion-financiera/
├── investigacion/      # Mapeo de BD, esquemas, flujos
├── documentos/         # Documentos conceptuales y specs
├── modelos/            # Esquemas de datos del nuevo sistema
├── agentes/            # Agentes de IA (Pedidos, Compras, Devengado, etc.)
├── api/                # Backend / endpoints
├── frontend/           # Interfaz de usuario
└── tests/              # Tests
```

## Stack propuesto

- **Backend:** FastAPI + SQLAlchemy
- **Base de datos nueva:** PostgreSQL
- **Agentes:** Claude API (claude-sonnet-4-6)
- **Frontend:** React + Vite + TypeScript + Tailwind
- **Voz:** Transcripción → modelo de lenguaje → intención

## Ciclo del gasto (etapas)

```
Solicitud → Afectación → Compromiso → Proceso de Compra → Devengado → Orden de Pago → Pago
```

## Fuentes de referencia

Ver `documentos/Sistema_AdmFin_Gubernamental_IA.docx` e `Ideas administración financiera con ia.docx`
