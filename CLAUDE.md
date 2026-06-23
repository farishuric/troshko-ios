# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Status: architecture migration complete — now in the product-build phase.** The Clean Architecture + SwiftData migration (Phases 0–4) is done; the whole app is SwiftData-only and on the target architecture this file describes.
>
> **Where the work is tracked — read in this order:**
> 1. **`docs/BUILD_ROADMAP.md`** — the living phase tracker. Find the **current phase**, open its spec (e.g. `docs/PHASE_5_SPEC.md`), and work **only that phase** to its "done when" gate.
> 2. **`PRODUCT_SPEC.md`** — what Troshko is & why, incl. §10 monetization/unit-economics and locked product decisions.
> 3. **`docs/AI_AGENT_DESIGN.md`** — the AI "pocket advisor" / agent layer (tool contracts, guardrails, receipt pipeline).
> 4. **`MIGRATION.md`** — architecture history + gotchas.
>
> This file (`CLAUDE.md`) describes the **architecture & conventions every phase must follow**.

## Working agreements (how to operate in this repo)

- **The user runs all builds & the simulator.** Do not launch builds or the simulator — make the change, then ask the user to build and report results. (The `xcodebuild` snippet below is for reference/validation only.)
- **The user makes all git commits.** Do **not** run `git commit`. Stage or prepare changes if asked, but leave committing to the user. **Never add a `Co-Authored-By` trailer.**
- **Phase discipline.** Work only the current phase in `docs/BUILD_ROADMAP.md`; meet its "done when" gate before moving on. **No half-features** — cut scope rather than ship broken.
- **Design is taste-driven.** For visual/motion work, **propose 3–4 directions and let the user pick** before building — do not ship a default aesthetic.

## Overview

Troshko is a native iOS expense tracker (SwiftUI). Three feature areas: adding expenses, organizing them into categories, and a monthly overview with charts. Local-only today; a future direction is an on-device AI "pocket advisor" (Apple Foundation Models) — which is why the deployment target is iOS 26.

## Build & Run

SPM-based (migrated from CocoaPods). Two shared app schemes with separate bundle IDs: `Troshko-Dev` and `Troshko-Prod`. There is **no test target**.

```bash
xcodebuild -list -project Troshko.xcodeproj                      # parse/validate project, resolve packages
xcodebuild -project Troshko.xcodeproj -scheme Troshko-Dev \
  -destination 'platform=iOS Simulator,name=iPhone 16' build    # build the dev scheme
```

- **iOS minimum: 26.0** · Swift 5. (Bumped from 16.4 during migration to unlock SwiftData + Apple Foundation Models.)
- The app target is an **Xcode 16 synchronized folder group** (`PBXFileSystemSynchronizedRootGroup`, root = `Troshko/`): files under `Troshko/` are auto-included — **just create the file, no `.xcodeproj` edits needed.** (See `MIGRATION.md` gotchas for the `EXCLUDED_SOURCE_FILE_NAMES = "*.md"` rule that makes co-located `SPEC.md` files safe.)
- Third-party deps: `lottie-ios`, `SwiftLintPlugins` (DGCharts was removed in Phase 2 in favour of Apple Swift Charts). SwiftLint config at `Troshko/Config/.swiftlint.yml`. Note: the `SwiftLint` run-script build phase still points at the stale `${PODS_ROOT}` path — a known pre-existing cleanup item.

## Architecture (target state)

**Clean Architecture + MVVM**, ported from Aisthesis. Three concerns kept separate: Clean Architecture (dependency direction UI → Domain ← Data), MVVM (View↔ViewModel), and navigation. The authoritative pattern reference is `/Users/fare/Documents/aisthesis/ios-respond-app/Aisthesis/CLAUDE.md` (and its `DECISIONS.md`); Troshko follows it with the deltas recorded in `MIGRATION.md`.

### Shared infrastructure — `libs/` (ported, wired, building)
Local SPM packages, all platform iOS 26, self-contained (no cross-imports):

| Lib | What's in it |
|---|---|
| `libs/MVVM` | `ViewModel` protocol + `ViewState`/`ViewEvent`/`ViewModelEvent` marker protocols (Combine-based: `@Published` state + `AnyPublisher` event stream) |
| `libs/DI` | `DIContainer` singleton + `@Injected` property wrapper; scopes (`.shared`/`.transient`/`.featureScoped`) |
| `libs/Networking` | `NetworkProvider` (async/await), `NetworkRequest`, `APIEnvelope`, interceptors. **Unused until a backend exists.** Injects a generic `x-platform: iOS` header. |
| `libs/Extension` | Date/Data helpers |
| `libs/Styleguide` | Design system: `BaseScreen`, `PrimaryButton`, `AppTextField`, `Card`, color/spacing/font tokens. **Reskinned** to Troshko brand green `#55BF8A`. Still carries some Aisthesis-domain components (`SensoryOptionCardView`, questionnaire bits, `Face*` assets) pending pruning. |

### App composition root
`Troshko/TroshkoApp.swift` calls `AppDependencies.registerAll()` from `init()`. Each migrated feature registers its deps there via a `<Feature>DependencyContainer.register()`.

### Feature layout (per Aisthesis; established in Phase 1)
Each feature is a folder under the app target: `Troshko/Features/<Feature>/{Domain, Data, UI, DI}`.
- **Domain**: `Model/` (entities), `Repository/` (protocols only), `UseCase/`.
- **Data**: `Model/` (DTOs), `Repository/` (implementations — SwiftData / UserDefaults / Keychain).
- **UI**: `<Screen>/` with `<Name>View.swift`, `<Name>ViewModel.swift`, `<Name>ViewState.swift`, `<Name>ViewEvent.swift`, `<Name>ViewModelEvent.swift`. Every root view uses `BaseScreen { }` as its outermost container.
- **DI**: `<Feature>DependencyContainer.swift`.

### Design rules (from Styleguide — non-negotiable)
- Only `AppFont.Size` tokens (`small`/`body`/`large`/`title`/`headline`) — no invented sizes.
- Only `SemanticColor.Colors.*` tokens — no raw `Color(...)`, hex, or `UIColor`.
- Only `Spacing.Semantic.*` — no magic numbers.
- Reuse `PrimaryButton`, `AppTextField`, `Card` before building custom.
- Loading is owned by `BaseScreen(isLoading:)`, not per-screen spinners.

## Conventions

- **Localization is mandatory** for user-facing strings via `String.localized` (`"KEY".localized`). Locales: `en` and `bs-BA` (`Troshko/Resources/Localization/`). Keep both `.lproj` in sync.
- Persistence: **SwiftData** (relational expense data) + UserDefaults (small prefs) + Keychain (sensitive) — all behind Domain `Repository` protocols. Core Data was fully removed in Phase 3 (no `CoreDataManager` / `.xcdatamodeld` / `NSManagedObject` classes remain).
- Project-file UUIDs minted during migration use a recognizable `C1A0DE…` prefix.
