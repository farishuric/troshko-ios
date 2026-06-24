# Phase 9 Spec - Accounts + payments

## Goal

Build Troshko's premium gate: Sign in with Apple, direct StoreKit 2
subscriptions, account management, and an entitlement seam that Phase 10 can
use before enabling cloud features.

## Decisions

- Billing uses **StoreKit 2 directly**, not RevenueCat.
- Premium is represented in-app as a single entitlement: `premium`.
- Initial product id placeholder: `com.troshko.premium.yearly`.
- Backend calls stay behind repository protocols until the account service URL
  and API contract are available.
- Sign in with Apple requires a paid Apple Developer team. The entitlement file
  is present for later, but it is not attached to signing settings while the app
  is built with a personal development team.

## Track A - App account shell

- Add `Troshko/Features/Account/` with Clean Architecture layout.
- Use Sign in with Apple as the only authentication entry point.
- Persist only the minimal local session needed to render the account state.
- Expose logout and delete-account use cases from the account domain.

## Track B - StoreKit premium gate

- Add a StoreKit 2 subscription repository.
- Load the premium product from App Store Connect using the centralized product
  id.
- Purchase, restore, and refresh entitlement status from verified StoreKit
  transactions.
- Keep premium checks behind `GetPremiumEntitlementUseCase` so Phase 10 does not
  depend on StoreKit APIs directly.

## Track C - Settings surface

- Extend Settings with an account card.
- Signed out: show the local privacy/account copy and Sign in with Apple.
- Signed in: show account identity, premium status, subscribe/restore actions,
  logout, and delete account.

## Backend Contract Placeholder

The backend is deliberately not hardcoded in this phase until its base URL and
API contract exist. The app-side boundary is:

- `AccountRepository.signIn(with:)`
- `AccountRepository.signOut()`
- `AccountRepository.deleteAccount()`

When the backend lands, the repository implementation exchanges the Apple
identity token/authorization code for a server session and performs server-side
account deletion. UI and domain use cases should not change.

## Done When

- The account/settings surface can sign in with Apple.
- The Sign in with Apple capability is enabled in Apple Developer / App Store
  Connect using a paid developer team.
- StoreKit can load the premium product, purchase it, restore it, and expose a
  premium entitlement.
- Premium gating uses a domain use case rather than StoreKit directly.
- Logout and delete-account slots exist.
- User builds and validates against the configured App Store Connect product and
  Sign in with Apple capability.
