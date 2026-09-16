# PRD — Silenti

| Campo | Valor |
|---|---|
| Producto | Silenti — app de finanzas personales, privacy-first, offline |
| Cliente final | Usuario final de la app (dueño del producto en este proceso) |
| Estado | Borrador v1 — elicitado, pendiente de confirmación de supuestos (§8) |
| Fecha | 2026-09-16 |
| Fuente | Sesión de elicitación registrada en §9, contrastada contra `CLAUDE.md` y `BUSINESS_LOGIC_AUDIT.md` (estado real del código) |

## 1. Visión de producto

Silenti debe facilitar la administración del patrimonio personal de quien la
use, sin depender de la nube ni de telemetría. La visión completa (ver §7)
es evolucionar de una "libreta digital reactiva" a un asesor financiero
predictivo. **Este PRD define primero el MVP** — la libreta digital, hecha
bien — y documenta la visión predictiva como Fase 2, explícitamente fuera del
alcance de este release.

## 2. Problema y usuario objetivo

Usuario que maneja su propio dinero (o el de su hogar) y necesita, en un solo
lugar y sin exponerlo a terceros:
- Saber cuánto planea gastar/ingresar cada mes, por categoría.
- Registrar cada movimiento real para poder contrastarlo contra lo planeado
  ("lo que no se mide no se controla").
- No olvidar fechas límite de pagos periódicos (arriendo, servicios, cuotas).

## 3. Alcance del MVP

**Dentro de alcance (v1):**
1. **Presupuesto mensual** — categorías de gasto e ingreso, con un nivel de
   subcategoría, montos proyectados, comparación presupuestado vs. real.
2. **Registro de transacciones** — cada movimiento se asocia a una
   categoría y a un activo (cuenta bancaria o efectivo), afectando el
   balance de ese activo y el patrimonio total.
3. **Planeador de gastos periódicos** — calendario de vencimientos fijos con
   recordatorios push del sistema operativo.
4. **Gestión completa de activos financieros** (transversal a 1 y 2):
   crear, **editar** y eliminar cuentas — hoy solo existen crear/eliminar
   (`BUSINESS_LOGIC_AUDIT.md` §2.2); editar es un vacío que el MVP debe
   cerrar porque sin poder corregir un saldo o renombrar una cuenta, el
   registro de transacciones no es confiable.

**Fuera de alcance del MVP (ver §7 — Fase 2 / Visión):**
- Motor SafeToSpend / semáforo de riesgo de gasto.
- Tarjetas de crédito como pasivo, cupos, cuotas (`Scheduled_Installments`),
  patrón de reserva automática.
- Tipo de transacción `TRANSFER` entre cuentas.
- Multi-moneda, multi-usuario/multi-perfil, cifrado en reposo activo (sigue
  siendo deuda técnica conocida — ver `CLAUDE.md`, "Tech Stack" — pero no se
  bloquea el MVP por esto; queda registrado como riesgo en §8).

## 4. Épicas e historias de usuario

### Épica 1 — Presupuesto mensual

- **H1.1** Como usuario, puedo crear, editar y eliminar categorías de gasto
  (ej. Transporte, Hogar, Créditos, Inversión) con un monto proyectado.
  - *Criterio:* eliminar una categoría realmente la elimina de la base de
    datos (hoy `DeleteBudgetCategoryUseCase` es un no-op —
    `BUSINESS_LOGIC_AUDIT.md` §3.1 — debe implementarse).
  - *Criterio:* una categoría con transacciones históricas asociadas no se
    borra en silencio dejando operaciones huérfanas; al intentar eliminarla
    se le avisa al usuario y se le pide reasignar o confirmar.
- **H1.2** Como usuario, puedo agregar subcategorías a una categoría de gasto
  (ej. Hogar/Facturas, Transporte/Combustible), con su propio monto
  proyectado, hasta **un nivel** de anidamiento (categoría → subcategoría,
  sin nietos).
  - *Criterio:* el modelo usa exclusivamente el árbol `BudgetCategory.parentId`
    (2 niveles) como única fuente de verdad; se retira la tabla paralela
    `spend_sub_categories` (`BUSINESS_LOGIC_AUDIT.md` §3.9).
- **H1.3** Como usuario, puedo crear categorías de **ingreso** (ej. Salario
  quincena 1, Salario quincena 2, Arriendos, Ingresos adicionales) con un
  monto proyectado, con la misma UI de creación que las de gasto (solo
  cambia el tipo).
  - *Criterio:* existe un flujo real para crear/listar categorías `type:
    'income'` — hoy no existe ninguno (`BUSINESS_LOGIC_AUDIT.md` §2.3, §3.5).
- **H1.4** Como usuario, veo en una sola pantalla el total presupuestado de
  ingresos, el total presupuestado de gastos, y la diferencia entre ambos.
  - *Criterio:* si el gasto presupuestado supera el ingreso presupuestado,
    la app lo muestra claramente (ej. en rojo) pero **no bloquea** guardar
    el presupuesto — es solo informativo (decisión §9).
- **H1.5** Como usuario, cada vez que abro la app veo, por categoría y en
  total, cuánto llevo gastado/recibido realmente contra lo presupuestado
  ese mes.
  - *Criterio:* un mes sin transacciones en una categoría se muestra como
    "$0 gastado", nunca como un estado de error
    (`BUSINESS_LOGIC_AUDIT.md` §3.6 debe corregirse para esto).
- **H1.6** El presupuesto de una categoría, una vez definido, aplica
  automáticamente todos los meses siguientes hasta que el usuario lo
  cambie; cada mes cerrado conserva su propio snapshot de "presupuestado"
  para poder comparar meses pasados aunque el monto actual ya sea distinto
  (decisión §9).

### Épica 2 — Registro de transacciones

- **H2.1** Como usuario, al registrar un gasto o ingreso, lo asocio
  fácilmente a una categoría (y su subcategoría si aplica) y a un activo
  (cuenta bancaria o efectivo).
  - *Criterio:* el formulario de **ingreso** ofrece categorías de tipo
    `income` (H1.3), no las de gasto — corrige el bug actual donde
    `IncomeForm` usa `GetExpensesCategoriesUseCase`
    (`BUSINESS_LOGIC_AUDIT.md` §3.5).
- **H2.2** Cada transacción registrada actualiza de inmediato el saldo del
  activo afectado y el patrimonio total (suma de activos incluidos en
  balance).
  - *Criterio:* si el activo indicado no existe o la actualización de saldo
    falla, la operación **no** se reporta como exitosa
    (`BUSINESS_LOGIC_AUDIT.md` §3.2 debe corregirse).
  - *Criterio:* el registro de la operación, la actualización del saldo y el
    punto de `balance_history` ocurren de forma atómica (una falla a mitad
    de camino no deja estado parcial) — `BUSINESS_LOGIC_AUDIT.md` §3.3.
- **H2.3** Como usuario, puedo ver el historial de transacciones de una
  cuenta o de una categoría, incluso cuando está vacío (sin que se muestre
  como error).
- **H2.4** Como usuario, puedo editar el nombre/saldo/tasa de una cuenta
  existente y eliminarla, no solo crearla (cierra el vacío de §3 arriba).

### Épica 3 — Planeador de gastos periódicos

- **H3.1** Como usuario, puedo programar un gasto fijo periódico (ej.
  "Arriendo, día 5 de cada mes", ligado a una categoría/subcategoría) con un
  día de vencimiento dentro del mes.
- **H3.2** Como usuario, veo estos vencimientos en una vista de calendario
  del mes en curso.
- **H3.3** Como usuario, recibo una **notificación push del sistema
  operativo** (no solo un aviso dentro de la app) antes de la fecha límite
  de cada gasto programado (decisión §9) — plazo de aviso configurable por
  gasto (ej. "avisar 3 días antes").
- **H3.4** Cuando llega o pasa la fecha del gasto programado, la app **no
  crea la transacción automáticamente** — solo recuerda; el usuario sigue
  registrando el pago real manualmente cuando ocurre (decisión §9), pudiendo
  hacerlo desde el propio recordatorio para agilizar el flujo.

## 5. Reglas de negocio consolidadas (decididas en esta elicitación)

| Regla | Decisión |
|---|---|
| Recurrencia del presupuesto | Automática mes a mes; cada mes cerrado guarda su propio snapshot histórico |
| Déficit presupuestado (gasto > ingreso) | Solo informativo, no bloquea guardar |
| Jerarquía de categorías | Un único árbol (`BudgetCategory.parentId`), 2 niveles, válido para ingreso y gasto |
| Efectivo como activo | Es una cuenta más (`BankAccount`), no un tipo nuevo |
| Vencimientos del planeador | Solo recordatorio; el registro de la transacción sigue siendo manual |
| Notificaciones del planeador | Push nativas del SO (requiere `flutter_local_notifications` o equivalente + permisos en Android) |

## 6. Requisitos no funcionales (MVP)

- Un solo usuario por instalación, una sola moneda — sin cambios sobre lo
  que ya existe.
- Todos los datos permanecen en el dispositivo (sin cambios sobre el pitch
  de privacidad); el cifrado en reposo **no** es requisito bloqueante de
  este MVP (queda como deuda técnica conocida, ver §8).
- Plataformas objetivo: las que ya declara el proyecto (Android, Windows —
  `README.md`).

## 7. Fase 2 / Visión — Cash Flow Forecasting (fuera del alcance del MVP)

Se documenta aquí tal como fue descrita, para que quede registrada y no se
pierda, pero **ninguna historia de esta sección bloquea la liberación del
MVP**.

**Propósito:** pasar de libreta reactiva a asesor con visibilidad
predictiva: mostrarle al usuario el impacto real de un gasto sobre sus
obligaciones futuras, no decirle que no gaste.

**Motor de liquidez (SafeToSpend):**
```
SafeToSpend = Saldo_Líquido_Actual − Σ Gastos_Fijos_Pendientes_En_El_Periodo
```
- Periodo definido como: **hasta fin de mes calendario** (decisión §9;
  más simple que "hasta el próximo ingreso", que habría requerido fecha
  esperada de cobro por categoría de ingreso).
- Semáforo al registrar un gasto nuevo: Verde si el gasto es `< 20%` del
  SafeToSpend, Amarillo si consume gran parte de la liquidez, Rojo si supera
  el SafeToSpend (haría "rebotar" una factura programada).
- Umbral del 20% y definición exacta de "consume gran parte" quedan
  pendientes de afinar cuando se diseñe esta fase.

**Tipos de transacción estrictos:** `EXPENSE`, `INCOME`, `TRANSFER` (mueve
dinero entre cuentas sin tocar el presupuesto). El modelo actual
(`Operation.type` como string libre `"income"`/`"spent"`) tendría que
evolucionar a un enum cerrado con un tercer valor.

**Tarjetas de crédito y cuotas (Zero-Based Budgeting / Patrón de Reserva
Automática):**
- Las tarjetas de crédito se modelan como una **entidad nueva completa**
  (decisión §9), no como una extensión de `FinancialAsset`: pasivo con cupo
  total, saldo usado, fecha de corte y fecha límite de pago.
- Una compra a 1 cuota resta del presupuesto de la categoría, dejsa el saldo
  de la tarjeta en negativo, y "bloquea" el dinero real en una categoría
  oculta para asegurar el pago del mes siguiente.
- Las compras a plazos generan una entidad `Scheduled_Installments` que
  produce transacciones fantasma: el cupo de la tarjeta recibe el impacto
  total de la deuda, pero solo la cuota del mes actual afecta el
  presupuesto de esa categoría.

Esta fase implica una extensión significativa del modelo de datos actual
(`core/models`, tablas nuevas, migración) y debe tratarse como su propio
ciclo de diseño/PRD cuando el MVP esté liberado y estable.

## 8. Supuestos y riesgos pendientes de confirmar

Estos puntos no se cubrieron en la elicitación interactiva y quedan como
supuestos razonables tomados para poder avanzar; deben confirmarse o
ajustarse antes de darlos por definitivos:

1. **Sobregiro:** se asume que, igual que el déficit de presupuesto (§9), un
   retiro que deja el saldo de una cuenta en negativo es solo informativo
   (no se bloquea) — hoy tampoco hay ningún control
   (`BUSINESS_LOGIC_AUDIT.md` §3.4). A confirmar si alguna cuenta debería
   impedirlo.
2. **Validación de categoría obligatoria:** se asume que una transacción no
   debe poder guardarse con categoría "sin seleccionar" (hoy se acepta un
   `category = 0` que no corresponde a ninguna fila real,
   `BUSINESS_LOGIC_AUDIT.md` §4.4); el MVP debe agregar esa validación.
3. **Cifrado en reposo:** dado que el pitch del producto es "privacy-first",
   se recomienda evaluar si debe activarse antes de un release público,
   aunque no se declaró como bloqueante en esta elicitación.
4. **Notificaciones push en background:** implica pedir permisos de
   notificación en Android/iOS y probablemente un plugin nuevo
   (`flutter_local_notifications` no está hoy en `pubspec.yaml`); se marca
   como el ítem de mayor riesgo técnico del MVP por ser la única pieza que
   requiere una dependencia e integración de plataforma nuevas.

## 9. Historial de elicitación (trazabilidad)

Preguntas realizadas y decisión tomada en cada una, en el orden en que se
hicieron durante esta sesión:

1. **Alcance del MVP** → *MVP mínimo*: presupuesto + registro + planeador;
   SafeToSpend y tarjetas quedan en Fase 2 (§7).
2. **Recurrencia del presupuesto** → *Automática*, con snapshot mensual
   histórico.
3. **Definición del "periodo" en SafeToSpend** (aplica a la Fase 2) → *Fin
   de mes calendario*.
4. **Modelo de tarjetas de crédito** (aplica a la Fase 2) → *Entidad nueva
   completa* (no extensión de `FinancialAsset`).
5. **Déficit de presupuesto (gasto > ingreso presupuestado)** → *Solo
   informativo*, no bloquea.
6. **Modelo del efectivo** → *Es solo otra cuenta* (`BankAccount`), no un
   tipo nuevo.
7. **Unificación de subcategorías** → *Árbol `BudgetCategory.parentId`*, 2
   niveles, se retira `SpendSubCategories`.
8. **Comportamiento del planeador al vencer un gasto fijo** → *Solo
   recordatorio*, registro manual de la transacción.
9. **Tipo de notificación del planeador** → *Push nativa del sistema
   operativo*.

## 10. Cómo usar este PRD para medir avance del MVP

Cada historia de §4 debe marcarse como **Cumple / Cumple con bug / No
implementada**, contrastando contra el comportamiento real documentado en
`BUSINESS_LOGIC_AUDIT.md`. El MVP se considera listo para liberar cuando:
- Todas las historias de las Épicas 1, 2 y 3 están en **Cumple**.
- Los hallazgos §3.1, §3.2, §3.3, §3.5, §3.6 y §3.9 de
  `BUSINESS_LOGIC_AUDIT.md` (citados explícitamente en las historias de
  arriba) están corregidos — son bloqueantes porque las historias del MVP
  dependen directamente de ellos.
- Los hallazgos §3.7 (editar activo), §4.4 (validación de categoría) están
  resueltos como parte de H1.4/H2.1/H2.4.
- Los supuestos de §8 fueron revisados por el cliente final.

Los hallazgos §3.8, §3.10, §3.11, §3.12 y los estructurales §4.2/§4.3 de la
auditoría **no bloquean** el MVP (son deuda técnica o quedan resueltos por
diseño gracias a las decisiones de este PRD) pero deben quedar en el backlog
de calidad post-MVP.
