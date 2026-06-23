# Settings Feature Spec

## Intent

Local-only profile/settings surface for Troshko. Phase 6 owns the profile entry point,
appearance preference, language display, and version/about information. No auth,
account, subscription, backend, or destructive actions live here yet.

## Entry Points

- `Troshko/Modules/Main/MainView.swift` presents `SettingsView` as a sheet.
- Root tabs show `ProfileMenuButton` in the top leading toolbar slot.
- `Troshko/TroshkoApp.swift` applies the stored appearance with `preferredColorScheme`.

## Files

- `Domain/Model/AppAppearance.swift`
- `Domain/Repository/AppearanceRepository.swift`
- `Domain/UseCase/GetAppearanceUseCase.swift`
- `Domain/UseCase/SetAppearanceUseCase.swift`
- `Data/Repository/UserDefaultsAppearanceRepository.swift`
- `DI/SettingsDependencyContainer.swift`
- `UI/Settings/SettingsView.swift`
- `UI/Settings/SettingsViewModel.swift`
- `UI/Settings/SettingsViewState.swift`
- `UI/Settings/SettingsViewEvent.swift`
- `UI/Settings/SettingsViewModelEvent.swift`

## Behaviour

- Appearance options: system, light, dark.
- Storage: `UserDefaults` through `AppearanceRepository`; the app root observes the same key.
- Language is display-only for Phase 6.
- Version is read from the generated app info dictionary.
- All copy is localized in `en` and `bs-BA`.

## Design

Uses the Phase 5 calm/floating language: ambient background, `FloatingCard`, soft
appearances, and Styleguide tokens only. Settings opens as a frosted sheet rather
than a new tab.

## Non-Goals

- No sign-in, account management, subscription state, delete-account flow, or sync.
- No in-app language switching yet.
