# MIGRATION.md — Troshko → Clean Architecture

Living record of the re-architecture from a simple SwiftUI + Core Data app to the Clean Architecture + MVVM stack borrowed from **Aisthesis** (`/Users/fare/Documents/aisthesis/ios-respond-app/Aisthesis/`). Read this to resume work in a fresh session.

_Branch: `feature/clean-architecture-migration` (in place)._

---

## Goal & end-state

Conform Troshko to Aisthesis's architecture (reusing its infra libs + Styleguide), then write a CURRENT-STATE product spec, then build toward an on-device AI "pocket advisor" (Apple Foundation Models). Reuse Aisthesis's local libs / networking / design system; do **not** copy Aisthesis's product features (Hero/Sensory/Wearable/Auth).

## Locked-in decisions

| Decision | Choice | Why |
|---|---|---|
| iOS minimum | **26.0** | On-device Apple Foundation Models (the AI advisor) need iOS 26 + Apple Intelligence HW; also unlocks SwiftData & `@Observable`. Libs bumped 18→26. |
| Persistence | **SwiftData** + UserDefaults (small) + Keychain (sensitive), all behind Domain `Repository` protocols | Expenses are relational/growing; SwiftData is the modern path. Drop Core Data. |
| Migration style | **Incremental strangler** | App stays runnable throughout; migrate one feature end-to-end as the template, then the rest. |
| ViewModel layer | **Keep Aisthesis's Combine `ViewModel` protocol** for now | Matches the "same design" goal; the `eventPublisher → coordinator` seam is the value. Revisit `@Observable` later as an isolated refactor. |
| Navigation | **Defer the full UIKit Coordinator**; use SwiftUI navigation + event-driven MVVM | 3-tab app; the UIKit coordinator stack is overkill initially. (Coordinator lib not yet ported.) |
| Charts | **Replace DGCharts with Apple Swift Charts** | Drops a third-party dep; Styleguide has `SparklineView` to build on. (Done in Phase 2.) |
| App target file mgmt | **Xcode 16 synchronized folder** | No per-file `.xcodeproj` edits when adding files. |

## Phase plan & status

- **Phase 0 — Foundation ✅ DONE (build verified clean):**
  - Branch created; infra libs `MVVM`/`DI`/`Networking`/`Extension` copied to `libs/`, platforms bumped to iOS 26.
  - `Styleguide` ported + reskinned (brand teal `#19C8DB` → Troshko green `#55BF8A` on `Primary`/`ButtonPrimary`/`BorderFocus`; `ButtonDisabled` desaturated to green).
  - All 5 local packages wired into `Troshko.xcodeproj` (local refs + product deps + Frameworks links + target `packageProductDependencies`). Resolve `@ local`.
  - App deployment target bumped 16.4 → 26.0 (all 4 configs).
  - DI composition root: `AppDependencies.registerAll()` in `TroshkoApp.init()`; all 5 modules imported from app code.
  - App target converted to a **synchronized folder group** (`PBXFileSystemSynchronizedRootGroup`, root `Troshko/`); Sources/Resources phases emptied (auto-managed); `EXCLUDED_SOURCE_FILE_NAMES = "*.md"` added to all 4 app configs.

- **Phase 1 — Expenses end-to-end ✅ DONE (build verified clean):** `Features/Expenses/{Domain,Data,UI,DI}` built as the reference feature.
  - **Domain:** `Expense` + `ExpenseCategory` structs (persistence-agnostic); `ExpenseRepository` protocol; use cases `Get/Add/Update/DeleteExpense` + `GetExpenseCategories` (protocol + `Standard*` impl, `@Injected` repo).
  - **Data:** SwiftData `@Model` `ExpenseEntity` + `ExpenseCategoryEntity` (with `toDomain()` mapping); `SwiftDataExpenseRepository` (all store access hops via `MainActor.run`, returns Sendable Domain structs); `ExpenseStore.container` shared `ModelContainer`.
  - **UI:** `ExpensesView<VM>` (list, grouped Today/This month/Month-Year) + `AddExpenseView<VM>` (add/edit sheet), each with `ViewModel`/`ViewState`/`ViewEvent`/`ViewModelEvent`; `BaseScreen` inside a `NavigationStack`; Styleguide tokens + `PrimaryButton`/`AppTextField`. Generic-VM + `@StateObject` ownership pattern (per Aisthesis `QuestionnaireView`/`HomeRootView`).
  - **DI:** `ExpensesDependencyContainer.register()` wired into `AppDependencies.registerAll()`.
  - **Cutover:** old `Troshko/Modules/Expenses/` deleted; `MainView` Expenses tab now `ExpensesView(vm: ExpensesViewModel())`; `CategoriesView` decoupled from the old shared `ExpensesViewModel`.
  - **Known transitional gap:** Categories/MonthlyOverview still on Core Data (Phase 2), so categories created there are **not** visible in the new SwiftData expense picker until Phase 2 unifies them. No data migration (deferred to Phase 3).

- **Phase 2 — Migrate Categories + MonthlyOverview** the same way; swap DGCharts → Swift Charts.

- **Phase 3 — Decommission Core Data:** remove `CoreDataManager` + `TroshkoData.xcdatamodeld` + old entity files; add a one-time data-migration shim only if real users must be preserved.

- **Phase 4 — Write `PRODUCT_SPEC.md`** (CURRENT STATE, Aisthesis style), then open the AI-advisor product discussion.

## Gotchas / notes (append as discovered)

- **`*.md` exclusion is required.** The synchronized folder bundles files flattened; two same-named files (e.g. multiple `SPEC.md`) would collide. `EXCLUDED_SOURCE_FILE_NAMES = "*.md"` drops all markdown from the app target. Keep top-level docs (`CLAUDE.md`, `MIGRATION.md`) at repo root. Don't remove the exclusion.
- **SourceKit "No such module 'DI'/'Styleguide'"** mid-edit is a transient analysis artifact — clears after a full build. Not a real error.
- **Stale SwiftLint phase:** the app target's `SwiftLint` run-script still references `${PODS_ROOT}/SwiftLint/swiftlint` (Pods→SPM leftover). Tolerated today; cleanup item.
- **Networking** injects `x-platform: iOS` on every request (Aisthesis backend convention). Revisit when Troshko gets its own backend.
- **Styleguide carries Aisthesis-domain leftovers** (`SensoryOptionCardView`, `QuestionnaireNavigationBar`, `CategoryStepIndicatorView`, `Face*` assets, a hardcoded "AISTHESIS Beta" string in `AppSheet.swift`). They compile; prune during feature migration.
- **Response DTOs must NOT have explicit `CodingKeys`** (Networking's `JSONDecoder.api` uses `.convertFromSnakeCase`); request DTOs always should. (From Aisthesis `DECISIONS.md`.)
- Migration-minted `.xcodeproj` UUIDs use the `C1A0DE…` prefix.
- **Legacy Core Data `Expense` class renamed to `LegacyExpense`** (Phase 1) so the new Domain `Expense` struct owns the canonical name (same-target, no namespaces → hard collision otherwise). The model **entity** is still named `"Expense"`; only `representedClassName`/`@objc` + the class changed, so existing stores still map. Legacy `GroupedExpenses` + `ExpenseItemView` (Core Data-backed) were moved to `Modules/Categories/Legacy/`. All of this is deleted in Phase 3 with the rest of Core Data.
- **SwiftData repo concurrency:** `SwiftDataExpenseRepository` wraps every `mainContext` access in `try await MainActor.run { … }` (SwiftData's `mainContext` is main-actor bound) and returns plain Sendable Domain structs — keeps the Domain `ExpenseRepository` protocol isolation-free, no `@MainActor` leak into Domain.
