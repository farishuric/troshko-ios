# Demo Data Feature Spec

## Intent

Provide deterministic sample financial data for local development and visual
validation without wiping, migrating, or editing user-entered data.

## Entry Points

- `DemoDataConfiguration.isEnabled` controls automatic seeding at app start.
- `SettingsView` exposes an explicit "Add demo data" action while demo data is
  enabled.

## Behaviour

- The seeder inserts demo categories, income, expenses, and a savings goal across
  the rolling month count configured in `DemoDataConfiguration`.
- All seeded records use stable UUIDs, so running the action repeatedly skips
  existing demo records rather than duplicating them.
- User-created records are never deleted or modified.
- The demo savings goal is inserted only when no savings goal exists, because the
  app currently has one active goal.

## Guardrails

- Demo record names are prefixed with "Demo" so they are recognizable in the UI.
- Amounts use integer minor units and the current device currency.
- No destructive store actions are performed.
