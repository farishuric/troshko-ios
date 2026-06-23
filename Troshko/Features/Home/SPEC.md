# Home Feature Spec

## Intent

Home is the first-tab emotional hub for Phase 7. It introduces income tracking,
a single savings goal, exact this-month saved math, curated static tips, and the
Phase 8 on-device monthly insight card.

## Entry Points

- `Troshko/Modules/Main/MainView.swift` shows `HomeView` as the first/default tab.
- `HomeView` presents `AddIncomeView` for income logging.
- `HomeView` presents `SavingsGoalView` for setting or editing the current goal.

## Files

- `Domain/Model/IncomeEntry.swift`
- `Domain/Model/SavingsGoal.swift`
- `Domain/Model/MonthlyCashflow.swift`
- `Domain/Model/HomeSummary.swift`
- `Domain/Repository/IncomeRepository.swift`
- `Domain/Repository/SavingsGoalRepository.swift`
- `Domain/UseCase/AddIncomeEntryUseCase.swift`
- `Domain/UseCase/FetchIncomeEntriesUseCase.swift`
- `Domain/UseCase/FetchSavingsGoalUseCase.swift`
- `Domain/UseCase/UpsertSavingsGoalUseCase.swift`
- `Domain/UseCase/GetHomeSummaryUseCase.swift`
- `Data/Model/HomeEntities.swift`
- `Data/Repository/SwiftDataIncomeRepository.swift`
- `Data/Repository/SwiftDataSavingsGoalRepository.swift`
- `DI/HomeDependencyContainer.swift`
- `UI/Home/*`
- `UI/AddIncome/*`
- `UI/SavingsGoal/*`
- `../OnDeviceAI/Domain/UseCase/GenerateMonthlyInsightUseCase.swift`

## Behaviour

- This-month saved is computed as this-month income minus this-month expenses.
- All amounts use `Money` integer minor units plus currency code.
- Savings goal progress compares this-month saved against the goal's monthly target.
- The app stores one active savings goal for Phase 7.
- Static tips are curated local copy, animated through Styleguide `Banner`.
- The monthly AI insight first tries on-device Foundation Models from pre-computed
  Home summary numbers, then falls back to a deterministic localized insight when
  Apple Intelligence is unavailable.

## Design

- Uses the Phase 5 calm/floating language: ambient background, `FloatingCard`,
  `Banner`, and soft appearances.
- Home is the first tab; profile/settings remains a top-corner toolbar entry.
- All user-facing copy is localized in `en` and `bs-BA`.

## Store Handling

- Phase 7 extends the existing shared SwiftData container with income and savings
  goal models.
- No destructive reset or data wipe is performed by the feature.
