# PHASE_5_SPEC.md — Foundations: money + motion

> **The work order for Phase 5.** Read `docs/BUILD_ROADMAP.md` (Phase 5 row) for context and `CLAUDE.md` for architecture/conventions. This phase is two independent tracks — **A (money → minor units)** and **B (design language)** — that can run in either order or in parallel. Both gate Phases 6–7.
>
> **Working agreements apply** (see `CLAUDE.md`): the user runs builds and makes commits; for design, **propose before building**. Update the Phase 5 status in `BUILD_ROADMAP.md` to 🟡 when you start.
>
> _Last updated: 2026-06-23._

---

## Track A — Money: `Double` → integer minor units

### Why
The product promises **exact** financial calculations (savings, forecasts, "can I afford X"). `Double` makes that false (`0.1 + 0.2 != 0.3`, errors compound across forecasts). Every later financial feature depends on this. It must land before Home (Phase 7) does any balance math.

### Target representation
- A single canonical **`Money`** value type (Domain or a shared module): `{ amountMinor: Int, currencyCode: String }`. `amountMinor` is the integer number of minor units (e.g. cents/feninga); `currencyCode` is ISO 4217 (e.g. `"BAM"`, `"EUR"`).
- **All money math is integer math.** Floating point appears **only** at the display boundary (formatting) and the input boundary (parsing) — never in storage, aggregation, or logic.
- **MVP is single-currency** (device locale), but store `currencyCode` explicitly on every amount so multi-currency later is non-breaking. Assume a 2-decimal minor-unit scale for MVP; centralise the scale lookup in one place (note: a few currencies are 0- or 3-decimal — out of scope now, but don't hardcode `100` in scattered call sites).

### What changes (enumerated — confirm against the tree)
- **Domain** — `Features/Expenses/Domain/Model/Expense.swift`: `amount: Double` → `amount: Money`. Add `Money.swift` (the value type + formatting/parsing helpers, or split helpers into `libs/Extension`).
- **Data** — `Features/Expenses/Data/Model/ExpenseEntity.swift`: store `amountMinor: Int` + `currencyCode: String` (SwiftData `@Model` stores the two scalars, not the struct). `SwiftDataExpenseRepository` `toDomain()` / write mapping composes/decomposes `Money`.
- **MonthlyOverview** — `Domain/Model/CategorySpending.swift`: `total: Double` → minor-unit `Int` (or `Money`). `GetMonthlyOverviewUseCase`: aggregate with integer addition. `SpendingDonutChart` + legend + `MonthlyOverviewView`: format from minor units. (Swift Charts needs a `Double`/`Plottable` for the *sector size* — convert to Double **only** at the chart-data boundary; the displayed label still formats from the exact integer.)
- **Expenses UI** — `AddExpenseView`: parse the amount field (string → minor units, locale decimal separator, ≤ 2 fraction digits; invalid → existing `amountError` path) and prefill on edit from minor units; `ExpenseRow`: display via the formatter. `ExpensesViewModel.group(_:)` is type-only affected.
- **Categories** — `CategoryExpensesViewModel` reuses `ExpensesViewModel.group` + `ExpenseRow` (display only); `AddCategory` unaffected.
- **Formatting** — one `Money.formatted()` using `NumberFormatter` currency style (replaces every `String(format: "%.2f", …)` and manual `Locale.current.currencySymbol` concatenation). One parser, one formatter — no duplicates.

### Stored-data migration — decision point
Existing SwiftData stores hold `Double` amounts. **Confirm with the user before choosing:**
- If **no real data must be preserved** (Phase 3 noted the user had none) → a fresh SwiftData schema/model version is simplest.
- If data must be kept → a lightweight migration mapping `amount` → `Int(round(amount * scale))`.
Do not silently wipe a store without confirming.

### Done when
- No `Double` exists in any money path (storage, mapping, aggregation, logic) — floats only at parse/format/chart-size boundaries.
- Add / edit / display / per-category aggregation are all exact integer math, with `currencyCode` carried through.
- Round-trip verified on a few values (e.g. user types `12.34` → stored `1234` → displays `12,34 KM`; sums add exactly).
- Build is green (user verifies).

### Guardrails
- Never use floating point for money arithmetic. One canonical `Money` type; one formatter; one parser.
- Keep the currency-scale lookup centralised (no scattered `* 100` / `/ 100`).

---

## Track B — Animated / floating design language

### Why
The product bar is "cool animated, floating UI." Establish a reusable **motion + floating visual language** in `libs/Styleguide` now, so every later screen (Home, advisor, receipts) inherits it instead of each screen reinventing motion. Must stay inside the non-negotiable token rules (`AppFont.Size`, `SemanticColor.Colors.*`, `Spacing.Semantic.*`).

### Process — propose first (do NOT pick an aesthetic unilaterally)
1. **Propose 3–4 distinct directions** to the user — each as a quick visual mockup or a tiny throwaway SwiftUI prototype screen, covering: overall mood, motion character (snappy vs. fluid), floating-card treatment (shadow/blur/elevation), and banner style.
2. **Wait for the user to choose one.** Taste can't be specified in prose — this is a gate, not a suggestion.
3. Only then build the component set.

### Build (after a direction is chosen)
- **Motion primitives** — standard duration/easing constants (so timing is consistent app-wide).
- **`FloatingCard`** — the elevated/floating container the Home cards and banners sit in.
- **`Banner`** — the animated tip/info banner (Phase 7 surfaces curated static tips in it).
- **List-item entrance** + **screen-transition** styles; consider the tab-bar treatment.
- All as Styleguide components built from existing tokens.

### Constraints
- Respect the token rules (no raw colors/fonts/spacing/sizes).
- **Honor Reduce Motion** (accessibility) — animations degrade gracefully.
- Watch performance — no jank on lists; use SwiftUI `transition`/`animation` correctly.

### Done when
- The user has approved one direction.
- A documented set of reusable animated/floating Styleguide components exists.
- One existing screen (e.g. the Expenses list) is refactored to demonstrate the language end-to-end.

---

## Sequencing note
Tracks A and B are independent. A is invisible-but-critical (correctness); B is visible (the design baseline). Neither blocks the other; both must be done before Phase 6/7 build on them. When both gates are met, flip Phase 5 to ✅ in `BUILD_ROADMAP.md` and proceed to Phase 6.
</content>
