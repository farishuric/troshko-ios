# Settings Feature Spec

## Intent

Profile/settings surface for Troshko. Phase 6 owns the profile entry point,
appearance preference, language display, and version/about information. Phase 9
adds the Sign in with Apple account card, StoreKit premium status, restore
purchases, logout, delete-account slots, and an explicit demo-data action for
local visual validation.

## Entry Points

- `Troshko/Modules/Main/MainView.swift` presents `SettingsView` as a sheet.
- Root tabs show `ProfileMenuButton` in the top leading toolbar slot.
- `Troshko/TroshkoApp.swift` applies the stored appearance with `preferredColorScheme`.
- Phase 9 account actions route through `Troshko/Features/Account/`.
- Demo-data seeding routes through `Troshko/Features/DemoData/`.

## Files

- `Domain/Model/AppAppearance.swift`
- `Troshko/Common/Localization/AppLanguage.swift`
- `Domain/Repository/AppearanceRepository.swift`
- `Domain/Repository/LanguageRepository.swift`
- `Domain/UseCase/GetAppearanceUseCase.swift`
- `Domain/UseCase/SetAppearanceUseCase.swift`
- `Domain/UseCase/GetLanguageUseCase.swift`
- `Domain/UseCase/SetLanguageUseCase.swift`
- `Data/Repository/UserDefaultsAppearanceRepository.swift`
- `Data/Repository/UserDefaultsLanguageRepository.swift`
- `DI/SettingsDependencyContainer.swift`
- `UI/Settings/SettingsView.swift`
- `UI/Settings/SettingsViewModel.swift`
- `UI/Settings/SettingsViewState.swift`
- `UI/Settings/SettingsViewEvent.swift`
- `UI/Settings/SettingsViewModelEvent.swift`

## Behaviour

- Appearance options: system, light, dark.
- Storage: `UserDefaults` through `AppearanceRepository`; the app root observes the same key.
- Language options: English, Bosnian, German, French, Italian, Spanish.
- Language storage: `UserDefaults` through `LanguageRepository`; the app root observes the same key, applies the selected SwiftUI locale, and resets root identity so already-open screens don't keep stale localized state.
- German, French, Italian, and Spanish currently ship English fallback strings until full translations are added.
- Version is read from the generated app info dictionary.
- Account state is read from the Account feature use cases.
- Premium state is read from the Account feature StoreKit entitlement use case.
- Demo data inserts deterministic sample records and never edits user records.
- All copy is localized in `en` and `bs-BA`; `de`, `fr`, `it`, and `es` fallback to English for now.

## Design

Uses the Phase 5 calm/floating language: ambient background, `FloatingCard`, soft
appearances, and Styleguide tokens only. Settings opens as a frosted sheet rather
than a new tab.

## Non-Goals

- No sync or cloud advisor in Settings; Phase 9 only exposes the premium gate.
