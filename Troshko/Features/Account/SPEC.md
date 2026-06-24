# Account Feature Spec

## Intent

Phase 9 owns account identity and premium entitlement state. It keeps the app
local-first by default while creating the gate required for paid cloud features
in Phase 10.

## Entry Points

- `SettingsView` renders the account and subscription surface.
- Phase 10 premium features query `GetPremiumEntitlementUseCase` before opening
  cloud advisor, receipt scan, or sync features.

## Files

- `Domain/Model/AccountSession.swift`
- `Domain/Model/PremiumEntitlement.swift`
- `Domain/Model/SignInWithApplePayload.swift`
- `Domain/Model/SubscriptionProduct.swift`
- `Domain/Repository/AccountRepository.swift`
- `Domain/Repository/SubscriptionRepository.swift`
- `Domain/UseCase/*`
- `Data/Repository/UserDefaultsAccountRepository.swift`
- `Data/Repository/StoreKitSubscriptionRepository.swift`
- `DI/AccountDependencyContainer.swift`

## Behaviour

- Sign in uses Apple only.
- Sign in with Apple requires a paid Apple Developer team. The checked-in
  entitlement file is intentionally not active for personal-team development
  builds.
- StoreKit 2 is the billing provider.
- The app checks verified StoreKit transactions before unlocking premium.
- Restore purchases calls `AppStore.sync()` and refreshes entitlement state.
- Account deletion removes the local account session now; when the backend
  exists, the repository implementation must call the delete-account endpoint
  before clearing the local session.

## Guardrails

- Expense, income, category, and savings data are not sent to Apple sign-in,
  StoreKit, or the future account backend.
- Subscription status is represented by `PremiumEntitlement`, not raw StoreKit
  types outside the Data layer.
- Product ids live in `PremiumSubscriptionConfiguration`.
