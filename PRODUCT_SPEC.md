# PRODUCT_SPEC.md — Troshko

> **What this doc is.** The single source of truth for *what Troshko is and why it exists* — the product layer.
> Read this first for context; read `CLAUDE.md` for *how* it's built (architecture & conventions) and `MIGRATION.md` for the re-architecture history and non-obvious gotchas.
>
> **Two-tier specs (Aisthesis pattern).** This file is the **hub/index** — product intent plus a map of where every feature lives (**§6 → Module map**). Each feature also gets a co-located **sub-spec** at `Troshko/Features/<Feature>/SPEC.md` holding the detail: entry files, behaviour, cross-module dependencies, localization, gotchas. **Working on a feature?** Read this file → find it in the Module map → open its sub-spec → touch only the files it names. Sub-specs are written **on first visit** (write-on-first-visit), not batch-authored. (Co-located `*.md` is safe — the app target excludes `*.md`; see `MIGRATION.md`.)
> This is a **living document**: when intent changes, update it here rather than letting it drift into code-only knowledge.
>
> _Last updated: 2026-06-24. Reflects the CURRENT STATE with Phase 7 implemented and pending user build validation._

---

## 1. Mission

**Troshko is a simple, private, native iOS expense tracker that helps a person see where their money goes.**

You log what you spend, organise it into your own categories, and see each month broken down by category so the picture is obvious at a glance. Everything stays on the device — no account, no backend, no sync.

**North star:** evolve Troshko into a **"pocket advisor"** — an on-device AI that understands your spending and gives private, personalised guidance. This is *why* the app targets iOS 26 (Apple Foundation Models). See §7 and §11.

> "Troshko" / "troško" plays on the Bosnian *trošak* (expense / cost) — small, friendly, everyday spending.

---

## 2. Positioning & posture

- **Category:** Personal finance / budgeting utility — a lightweight expense tracker, **not** a bank-linked PFM (no Plaid/Open Banking), **not** accounting software.
- **Privacy posture:** **Local-first, on-device only.** No account, no network calls, no analytics. All data lives in an on-device SwiftData store. This is a deliberate trust stance and the foundation for the on-device-AI direction (the advisor reasons over your data *without it leaving the phone*).
- **Manual entry:** spending is **entered by hand** today. There is no receipt scan, bank import, or auto-categorisation yet (all candidate AI features — §11).
- **Stage:** Working app in product-build phases. Single-user, single-currency-by-device-locale, two languages.

---

## 3. Who it's for — persona

Troshko is built around **one person tracking their own money** — there is no multi-user, sharing, or role model (contrast Aisthesis, which is multi-caretaker). 

- **Primary persona:** an individual who wants a frictionless, no-signup way to jot down expenses and understand monthly spending — privacy-conscious, possibly in a market where bank-linked apps are weak or untrusted.
- **Locale:** first-class **English** and **Bosnian (`bs-BA`)**. Currency follows the **device locale** (`Locale.current.currency?.identifier`) — there is no in-app currency picker.

---

## 4. Core concepts & glossary

| Term | Meaning |
|---|---|
| **Expense** | A single logged spend. Fields: `title`, `details`, `amount` (`Money`: integer minor units + currency code), `date`, optional `category`. Domain entity `Expense` (persistence-agnostic struct). |
| **Category** | A user-named bucket for expenses (e.g. "Groceries"). Fields: `name`, `createdAt`. Domain entity `ExpenseCategory`. Categories are a **shared concept** across the Expenses, Categories, and Monthly Overview features (one SwiftData store). |
| **Uncategorised** | An expense with no category. In the Monthly Overview it aggregates under `MONTHLY_OVERVIEW.UNCATEGORIZED`. |
| **Expense group** | UI grouping of the expense list under **Today / This month / "Month Year"** headings (newest first). Computed in `ExpensesViewModel.group(_:)`. |
| **Category spending** | A category's summed total over a selected month — the unit that drives the overview donut. Domain entity `CategorySpending`. |
| **Monthly overview** | Per-category spending totals for one selected month, shown as a donut chart + legend. |

---

## 5. End-to-end journey

```
Launch → Splash → Main (Home · Expenses · Monthly Overview tabs + profile/settings button)
      ├─ Home              : greeting · saved this month · savings-goal progress · static tips
      │     ├─ + Add income → Add Income sheet (source, amount, date)
      │     └─ set goal     → Savings Goal sheet (name, total target, monthly target)
      ├─ Expenses          : list grouped Today / This month / Month-Year
      │     ├─ + Add        → Add Expense sheet (title, details, amount, date, category)
      │     ├─ tap a row    → Edit Expense sheet (same form, prefilled)
      │     ├─ categories   → Categories sheet (add/delete/drill-in)
      │     └─ swipe        → delete
      └─ Monthly Overview  : month/year picker → donut of per-category spending + legend
```

No onboarding and no auth. The app opens straight onto the tab bar (after the splash); the top-corner profile icon opens local Settings for appearance, language display, and version/about. State is whatever is in the local SwiftData store plus small local preferences in UserDefaults.

---

## 6. Feature areas — intent, status & where they live

Status legend: ✅ built · 🟡 partial / in progress · ⬜ planned / not started.

| Area | Intent | Status |
|---|---|---|
| **Expenses** | Log / edit / delete expenses; list grouped by Today / This month / Month-Year (newest first); empty & error states. | ✅ |
| **Add / Edit Expense** | Sheet form: title, details, amount (decimal pad + locale currency symbol), date (graphical picker), category (menu picker incl. "None"); validation gates Save. | ✅ |
| **Categories** | Create / delete categories; list; tap to drill into that category's expenses; swipe-delete with confirmation. | ✅ |
| **Category Expenses** | Read-only list of one category's expenses (reuses the Expenses grouping + row). | ✅ |
| **Monthly Overview** | Pick a month/year; aggregate that month's expenses into per-category totals; render an Apple Swift Charts donut (`SectorMark`) + legend; uncategorised bucket. | ✅ |
| **Persistence** | On-device SwiftData store, shared across features behind Domain `Repository` protocols. | ✅ |
| **i18n** | English + Bosnian (`bs-BA`); `SCREAMING_SNAKE` keys via `"KEY".localized`; both `.lproj` kept in sync. | ✅ |
| **Splash** | Lottie splash on launch. | ✅ |
| **Settings / profile menu** | Top-corner profile entry; local settings sheet with appearance preference, language display, and version/about. | ✅ |
| **Home** | First-tab emotional hub with income, saved-this-month, savings-goal progress, and static tips. | 🟡 |
| **Currency selection** | Today: device-locale currency symbol only. A user-chosen currency is undesigned. | ⬜ |
| **Search / filter / budgets** | Find expenses; set per-category or monthly budgets; alerts when over. | ⬜ |
| **Receipt scan / auto-categorise / import** | Reduce manual entry (OCR, smart category suggestion, bank/CSV import). | ⬜ (AI candidates — §11) |
| **AI "pocket advisor"** | On-device Apple Foundation Models reasoning over the user's spending → private, personalised insight & guidance. | ⬜ (north star — §7) |
| **Multi-device / backup / export** | iCloud/SwiftData sync, export, off-device backup. | ⬜ (tension with local-only posture — §12) |

### Module map — where each feature lives

> Routing index for token-cheap navigation. Find the topic → open its module → read its sub-spec (if present) → touch only what the sub-spec names. Paths are from the repo root.
>
> **Shared infra (assumed by every feature; not repeated below):** `libs/Styleguide` (all UI tokens & components: `BaseScreen`, `PrimaryButton`, `AppTextField`, `Card`, color/spacing/font tokens), `libs/MVVM` (Combine `ViewModel` protocol), `libs/DI` (`DIContainer` + `@Injected`), `libs/Networking` (unused — no backend), `libs/Extension`; app shell `Troshko/TroshkoApp.swift` (composition root → `AppDependencies.registerAll()`) + `Troshko/Modules/Main/MainView.swift` (tab bar); UI strings in `Troshko/Resources/Localization/<lang>.lproj/Localizable.strings` (en · bs-BA; `SCREAMING_SNAKE` keys).

| Topic / feature | Module path | Sub-spec |
|---|---|---|
| App shell · tab bar · DI composition root | `Troshko/TroshkoApp.swift` · `Troshko/Modules/Main/MainView.swift` | architecture → `CLAUDE.md` |
| **Home** — income · saved-this-month · savings goal · static tips | `Troshko/Features/Home/` | `Troshko/Features/Home/SPEC.md` |
| **Expenses** — list · add/edit · delete · grouping | `Troshko/Features/Expenses/` (`Domain/ Data/ UI/ DI/`) | `Troshko/Features/Expenses/SPEC.md` |
| **Categories** — list · add · delete · drill-in | `Troshko/Features/Categories/` | _TODO_ |
| **Monthly Overview** — month picker · donut · legend | `Troshko/Features/MonthlyOverview/` | _TODO_ |
| Shared SwiftData store · `@Model` entities | `Troshko/Features/Expenses/Data/` (`ExpenseStore`, `ExpenseEntity`) | see `MIGRATION.md` (shared-container gotcha) |
| Splash | `Troshko/` (SplashScreenView) | _TODO_ |
| **Settings / profile menu** — appearance · language display · version | `Troshko/Features/Settings/` | `Troshko/Features/Settings/SPEC.md` |

> **Sub-spec policy — write-on-first-visit.** Rows above are `_TODO_` until the first time we touch that feature, when we author `Troshko/Features/<X>/SPEC.md` and flip the row. Adding a *new* feature includes writing its sub-spec + Module map row — a feature isn't "done" until it's findable from this index.

---

## 7. The advisor model (the north-star value prop)

This is where Troshko is headed and the reason the stack is what it is. **Nothing here is built yet** — it's the product thesis to design toward.

- **Why on-device:** the whole pitch is *private financial advice that never leaves your phone*. Apple Foundation Models on iOS 26 let an LLM reason over the user's full spending history locally — no upload, consistent with the local-first posture (§2).
- **What it could do (unranked candidates):**
  - **Natural-language entry** — "23 KM groceries yesterday" → a parsed, categorised expense.
  - **Auto-categorisation** — suggest a category for a new expense from its title/history.
  - **Spending insight** — summarise the month in plain language; flag changes vs. prior months; surface the biggest movers.
  - **Conversational Q&A** — "how much did I spend on eating out this month?"
  - **Gentle guidance** — budget suggestions, nudges, "you're trending higher than usual on X."
- **Design constraints this implies:** clean Domain entities the model can read (already true), a use-case seam to drop AI behind (`@Injected` use cases — already the pattern), and careful copy (guidance, not financial *advice* in the regulated sense).
- **Open product questions for this phase live in §12.**

---

## 8. The data model

- **Shared entities, one store.** `Expense` (title, details, amount, date, optional category), `ExpenseCategory` (name, createdAt), `IncomeEntry` (source, amount, date), and `SavingsGoal` (name, target amount, monthly target) live in one SwiftData container. They are exposed to the UI as persistence-agnostic Domain structs; the Data layer maps to/from SwiftData `@Model` entities.
- **One shared container.** Expenses, categories, monthly overview, and Home read/write the same `ExpenseStore.container` behind Domain `Repository` protocols, so expenses, income, and savings-goal calculations stay in sync.
- **Amounts use exact `Money` values** backed by integer minor units plus an explicit currency code. SwiftData stores `amountMinor` and `currencyCode` scalars; formatting/parsing happens through `Troshko/Common/Money/Money.swift`.
- **No migration history retained:** Core Data was removed cleanly in Phase 3 (no shim; user confirmed no real data to preserve).

---

## 9. Constraints & non-goals

**Constraints**
- **Platform:** iOS **26.0+**, SwiftUI, Swift 5, SPM. Deployment target is high *on purpose* (Apple Foundation Models). No test target.
- **Architecture:** Clean Architecture + MVVM (Combine `ViewModel` protocol), custom DI, custom Styleguide — see `CLAUDE.md`. **Design tokens are non-negotiable:** only `AppFont.Size`, `SemanticColor.Colors.*`, `Spacing.Semantic.*`; reuse `PrimaryButton`/`AppTextField`/`Card`/`BaseScreen` before building custom. No raw colors/fonts/spacing.
- **Privacy:** local-only by default; introducing any network/sync is a deliberate posture change, not an incremental feature.
- **i18n:** every user-facing string via `"KEY".localized`; keep `en` and `bs-BA` in sync; don't hardcode.
- **Persistence:** SwiftData (relational) + UserDefaults (small prefs) + Keychain (sensitive) behind Domain `Repository` protocols. Core Data is gone — don't reintroduce `NSManagedObject`.

**Non-goals (today)**
- No accounts, no backend, no analytics, no bank linking.
- No multi-user / sharing / roles.
- No third-party charting (Apple Swift Charts only; DGCharts removed).
- Not regulated financial advice.

---

## 10. Monetization, unit economics & billing model

> Forward-looking — not built yet. Records the locked monetization decisions and the billing model so the economics aren't re-derived (or re-confused) later.

**Tier split (decided):**
- **Free = on-device AI.** Apple Foundation Models running locally (NL entry, auto-categorise, basic monthly summary). **Costs us $0 per use** — it runs on the user's silicon. This is the App Store hook and the privacy story.
- **Premium = cloud + backend.** The conversational **advisor** (the hero — §7), **receipt scanning**, plus cross-device **sync/backup, budgets, export**.
- **Hero feature:** the conversational cloud advisor ("ask Troshko anything about your money" + proactive nudges).
- **Market:** global / English-first; `bs-BA` secondary (App Store regional pricing handles local purchasing power).
- **Price anchor:** ~**$40/yr** (annual-forward), 7-day advisor trial as the conversion mechanic. Not final.

**The billing model — Claude API ≠ Claude Pro.** The cloud advisor runs on the **Claude API**, *not* the ~$20/mo Claude Pro consumer chat plan. The distinction is the whole economics:
- **No per-user subscription.** One company API key, billed **per token, in arrears, pooled across all users**. The per-user figures below are *token costs*, not seat licences — 1 user or 100k users, we pay only for tokens consumed.
- It's a **wholesale-tokens / retail-convenience** model: pooled subscriber revenue pays the pooled Anthropic bill; margin is the difference. "Use the users' money for Claude" — yes, exactly that.

**Cost levers (designed in, not bolted on):**
- **Tool results are tiny.** The advisor reads *derived* numbers (`{"projected_leftover": 340}`), never raw transactions — a few dozen tokens, not thousands. This makes it *both* cheap and privacy-clean: raw data never leaves the device, only derived results transit.
- **Prompt caching** (cache reads ~0.1×) → follow-up turns ~10× cheaper than the first.
- **Batch API (50% off)** for non-real-time monthly insights.

**Per engaged premium user / month — current Claude API pricing:**

| Workload | Token cost |
|---|---|
| Haiku 4.5 ($1/$5 per 1M) — routine Q&A workhorse | ~$1–2 |
| Sonnet 4.6 ($3/$15) — real analysis | ~$2–4 |
| Opus 4.8 ($5/$25) — hardest reasoning | ~$4–6 |
| Receipt structuring (Haiku, OCR text only) | ~$0.002 / receipt |
| Monthly proactive insight (Batch) | ~$0.02–0.04 |

At ~$40/yr (~$3.33/mo), Apple takes 15% (Small Business Program, ≤ $1M/yr; 30% above) → **~$2.83 net**. Against a **Haiku-default** advisor (~$1–2) the margin is healthy; an Opus-everything advisor loses money on engaged users.

**Two non-negotiables for positive margin:**
1. **Model tiering, not one model.** Route routine asks to **Haiku 4.5**; escalate to Sonnet/Opus only when the question needs real analysis. Keeps the median subscriber near $1–2/mo.
2. **A fair-use cap is load-bearing.** A chatty power user can 10× these numbers. The relay enforces a generous per-user monthly cap, and the Anthropic account carries a hard **spend cap** so a bug or abuse can't run an unbounded bill.

**The relay (premium infra):** stateless — holds the single API key, enforces the fair-use cap, forwards messages, **stores nothing**. The device→relay request type is structurally incapable of carrying a raw transaction (privacy enforced by the type, not by policy). Standing API account set up **once** before launch — usage accrues per request; there is no "buy Claude per sale" step.

Open pricing/trial details remain in §12.

---

## 11. Roadmap

The phased build plan lives in **`docs/BUILD_ROADMAP.md`** (the living tracker — phase status, sequencing, gates). Summary:

| Phase | Theme |
|---|---|
| 5 | **Foundations** — money `Double`→minor units · animated/floating design language |
| 6 | **Profile menu** — settings · appearance · version (local, no auth) |
| 7 | **Home v1** — income model · savings goals · greeting/saved/goal chart · static tip banners |
| 8 | **Free on-device AI** — auto-categorise *or* NL entry · monthly insight |
| 9 | **Accounts + payments** — Sign in with Apple · backend · subscription · logout/delete (the premium gate) |
| 10 | **Premium cloud** — relay + advisor · receipt scanning · sync |
| 11 | **Content + hygiene** — economics news (deferred) · budgets · search · export |

Locked: tabs = **Home · Expenses · Monthly Overview** + profile menu · **income is tracked** · news deferred (static tips first). Architecture migration (Phases 0–4) is done.

---

## 12. Open questions

Things to resolve before/while building the advisor — answer them into the sections above as decided.

1. **First AI feature.** Which single capability ships first (auto-categorise vs. NL entry vs. monthly insight)? What's the success bar for "useful enough to keep"?
2. **Foundation Models reality check.** What can on-device Apple Foundation Models actually do well at this size — structured extraction? summarisation? tool/use-case calling? What's the fallback when a request is too big or the device lacks Apple Intelligence?
3. **Currency.** Stay device-locale-only, or add an explicit currency setting? Multi-currency at all?
4. **Money representation.** Resolved in Phase 5: `amount` uses integer minor units plus currency code.
5. **Privacy boundary.** Does "local-only" stay absolute, or do we allow opt-in iCloud backup/sync? How does that square with the trust pitch (§2)?
6. **Budgets.** Are budgets in scope as a non-AI feature, or do they emerge from the advisor's guidance?
7. **Guidance vs. advice.** What copy/posture keeps "pocket advisor" helpful without implying regulated financial advice?
8. **Categories taxonomy.** Stay fully user-defined, or seed a default category set (helps auto-categorisation quality)?
9. **Market & locale.** Is `bs-BA` + English the target, or is this broader? Affects currency, number formats, and example copy.
