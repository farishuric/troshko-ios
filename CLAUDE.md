# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Troshko is a native iOS expense-tracker app built with SwiftUI and Core Data (local-only persistence, no backend). Three feature areas: adding expenses, organizing them into categories, and a monthly overview with charts.

## Build & Run

The project uses Swift Package Manager (migrated from CocoaPods). There are two shared schemes with separate bundle identifiers:

- `Troshko-Dev` — development build
- `Troshko-Prod` — production build

```bash
# Build the dev scheme on a simulator
xcodebuild -project Troshko.xcodeproj -scheme Troshko-Dev \
  -destination 'platform=iOS Simulator,name=iPhone 15' build

# Resolve SPM dependencies (if needed)
xcodebuild -resolvePackageDependencies -project Troshko.xcodeproj
```

There is no test target in this project, so there are no tests to run.

- Deployment target: iOS 16.4 · Swift 5
- Dependencies (SPM): `Charts` (danielgindi/Charts, used by the pie chart), `lottie-ios`, and the `SwiftLintPlugins` build-tool plugin (SwiftLint runs at build time).

### SwiftLint

Config lives at `Troshko/Config/.swiftlint.yml` and runs automatically via the SwiftLint build plugin. Several rules are intentionally disabled (`line_length`, `identifier_name`, `force_cast`, `force_try`, `trailing_whitespace`, and others) — do not assume default SwiftLint behavior.

## Architecture

MVVM throughout. The app is organized under `Troshko/Modules/<Feature>/`, each feature splitting into `Views/`, `ViewModel/`, and `Models/`. View models are `ObservableObject` classes; views observe them via `@StateObject`/`@EnvironmentObject`.

**Entry / navigation flow:** `TroshkoApp` → `SplashScreenView` (timed animation, ~2.5s) → `MainView`. `MainView` is a `TabView` with three tabs: Expenses, Categories, Monthly Overview.

**Shared expenses state:** `MainView` creates a single `ExpensesViewModel` and injects it as an `@EnvironmentObject` into both the Expenses and Categories tabs, so they share one source of truth for expenses and categories. `ExpensesViewModel` also owns the add/edit form state (title, description, price, date, selected category) and price validation — adding and editing expenses go through this same view model, not a separate one.

**Core Data:** `CoreDataManager` is a singleton (`CoreDataManager.shared`) wrapping an `NSPersistentContainer` named `TroshkoData` (model in `Troshko/CoreData/TroshkoData.xcdatamodeld`). View models are constructed with the shared `viewContext` and perform fetch/save/delete directly against it. Two entities:
- `Expense` — `id` (UUID), `title`, `desc`, `price` (Double), `date`, and a to-one `category` relationship.
- `Category` — `name`, `createdAt`, and an ordered to-many `expense` relationship.

Expenses are grouped for display by `groupExpensesByDate` into `GroupedExpenses`, bucketing into "Today", "This month", or a "MMMM yyyy" header.

## Conventions

- **Localization is mandatory for user-facing strings.** Strings are keys resolved through the `String.localized` extension (`"EXPENSES.TITLE".localized`). Two locales are maintained: `en` and `bs-BA` (`Troshko/Resources/Localization/`). Add new keys to both `.lproj` files.
- **Colors** are referenced by asset-catalog name (e.g. `Color("main")` from `Assets.xcassets/App colors`).
- Reusable cross-feature pieces live in `Troshko/Common/` — `Views/` (e.g. `EmptyStateView`, `BadgeView`, `ErrorState`) and `Extensions/` (String/Date/Double/Color helpers such as `toDouble()`, `[safe:]` collection subscript).
