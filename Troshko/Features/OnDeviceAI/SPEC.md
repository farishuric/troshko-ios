# On-Device AI Feature Spec

## Intent

Phase 8 proves the free, private AI line with Apple Foundation Models on device.
It ships small, confirm-first helpers rather than a full advisor.

## Entry Points

- `AddExpenseView` can ask for a category suggestion from the current title,
  details, amount, date, and existing category list.
- `HomeView` surfaces a monthly insight card based on the deterministic Home
  summary numbers.

## Files

- `Domain/Model/ExpenseCategorySuggestion.swift`
- `Domain/Model/MonthlyInsight.swift` (`MonthlyInsight` + `MonthlyInsightContext`)
- `Domain/Repository/OnDeviceAIRepository.swift`
- `Domain/UseCase/SuggestExpenseCategoryUseCase.swift`
- `Domain/UseCase/GenerateMonthlyInsightUseCase.swift`
- `Data/Repository/FoundationModelsOnDeviceAIRepository.swift`
- `DI/OnDeviceAIDependencyContainer.swift`

## Behaviour

- The AI layer is local-only: no network, no backend, no analytics.
- Category suggestion is propose-then-confirm. The model never saves or mutates
  an expense; the user taps to apply the suggested category.
- The monthly insight receives a pre-computed `MonthlyInsightContext`. The model is
  instructed not to do arithmetic or invent numbers.
- If Foundation Models is unavailable or returns no usable result, Home shows a
  deterministic localized insight and all manual flows remain usable.

## Guardrails

- The model can only choose from existing categories.
- No raw data leaves the device.
- Money stays as integer minor units in app logic; formatted values are used only
  in model prompts and user-facing copy.
