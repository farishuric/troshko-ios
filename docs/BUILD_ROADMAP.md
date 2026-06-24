# BUILD_ROADMAP.md — Troshko product build

> **What this doc is.** The living phase tracker for building Troshko into the product. It owns **phase status and sequencing**; the coding agent works one phase at a time against it. Read `PRODUCT_SPEC.md` for *what & why* (incl. §10 economics), `docs/AI_AGENT_DESIGN.md` for the AI layer, `CLAUDE.md` for architecture.
>
> **Roles:** a separate agent writes the code; this doc + the product-direction owner keep the project honest — each phase is a polished vertical slice, validated against the spec before the next begins. **No half-features.**
>
> _Last updated: 2026-06-24._

Status legend: ✅ done · 🟡 in progress · ⬜ planned · ⛔ blocked.

---

## Locked product decisions (context for every phase)

- **Tabs:** **Home · Expenses · Monthly Overview**, with a **profile icon** in a top corner (menu, not a tab). Home replaces Expenses as tab 1.
- **Money model:** Troshko **tracks income** (not expenses-only). "Saved this month" = income − expenses; savings goals and the advisor's forecasts are computed against real income.
- **Money representation:** integer **minor units** (not `Double`) — exactness is a prerequisite for all financial features.
- **AI tiers:** **free = on-device** Apple Foundation Models ($0 to serve) · **premium = cloud** advisor + receipt scan + sync (Claude API, pooled per-token; see `PRODUCT_SPEC.md` §10).
- **Design:** animated, floating UI — a motion/floating design language established early and inherited by every screen.
- **News deferred:** curated **static tips** first; live economics-news feed deferred (network + content-ops + posture cost).
- **Privacy posture holds:** raw data stays on device; only derived results transit to the cloud advisor.

Architecture migration (Phases 0–4: Clean Architecture, SwiftData, spec + AI design docs) is **✅ done** and precedes everything below.

---

## Phases

### Phase 5 — Foundations: money + motion ✅
**Spec:** `docs/PHASE_5_SPEC.md` (the work order — money minor-units migration + design language, propose-first).
**Goal:** put the two cross-cutting foundations in before anything is built on top of them.
- ✅ **Track A — money `Double` → integer minor units** (+ currency code) across Domain/Data/UI. Canonical `Money` type (`Troshko/Common/Money/Money.swift`); one formatter/parser; integer aggregation throughout; floats only at parse/format/chart-size boundaries. Existing SwiftData store wiped (no real data) rather than migrated.
- ✅ **Track B — animated/floating design language** in Styleguide. Direction chosen: **Calm & fluid** (slow gentle springs, fade + 8pt rise, frosted floating cards on an ambient glow — extends the existing soft base). Built: `Motion` primitives (durations + named animations + Reduce-Motion `resolved`), `softAppear` entrance (with staggered cascade) + `AnyTransition.calm`, `FloatingCard`, `Banner`. Demo screen: Expenses list refactored (ambient background, summary card, per-row calm cascade, floating empty/error states). User approved the visual direction.
- **Done when:** all amounts are exact integers end-to-end; a documented motion/floating component set exists that later screens reuse.
- **Why first:** both are invisible but cross-cutting — retrofitting either later is far more expensive. Exact money underpins every financial number.

### Phase 6 — Profile menu + appearance ✅
**Goal:** the in-app menu shell, local-only.
- ✅ Top-corner **profile entry** → settings · **appearance** (light/dark/system) · language · version/about.
- **No auth yet.**
- **Done when:** a polished settings/menu surface ships; the nav slot for future account features exists.
- **Why here:** low-risk quick win; reserves the slot Phase 9 fills (logout, delete account, subscription).

### Phase 7 — Home v1 ✅
**Goal:** the emotional hub, built on the new income model.
- ✅ New data: **income** entries · **SavingsGoal** model · month-balance calculations (pure Swift, exact).
- ✅ **Home screen:** time-of-day greeting · this-month **saved** (income − spend) · **savings-goal progress chart** · animated banners (**curated static tips**).
- ✅ User build validation passed on 2026-06-24.
- **Done when:** Home is the default tab, shows real saved/goal data, and feels designed (uses Phase 5 motion language).
- **Depends on:** Phase 5 (money) + the income model introduced here.

### Phase 8 — First free on-device AI ✅
**Goal:** the trend hook, no backend, $0 to serve.
- ✅ Ship **one** of: **auto-categorise** a new expense · natural-language entry ("23 KM groceries yesterday") — via Apple Foundation Models behind a use-case seam. Built: Add Expense category suggestion from title/details/amount/date + existing categories, propose-then-confirm.
- ✅ Surface a monthly **insight** card on Home (on-device summary): generated from deterministic Home summary numbers, with a localized unavailable fallback.
- ✅ User accepted proceeding to the next phase on 2026-06-24.
- **Done when:** a free AI feature works on-device and is genuinely useful; the use-case seam is proven for cloud later.
- **Depends on:** Phase 7 (data to reason over).

### Phase 9 — Accounts + payments 🟡 (CURRENT)
**Goal:** the premium gate — the prerequisite for everything paid/cloud.
- 🟡 **Sign in with Apple** · backend seam · account screen (**logout, delete account**) · **subscription** (direct StoreKit 2) · entitlement check.
- **Done when:** a user can create an account, subscribe, and the app gates premium features on entitlement.
- **Why a hard gate:** payments and cloud are impossible without it; nothing in Phase 10 starts before this lands.

### Phase 10 — Premium cloud ⬜
**Goal:** the paid value.
- **Stateless relay** (holds the single Claude key, fair-use cap, stores nothing).
- **Conversational advisor** — phone-orchestrated Claude loop over the read-only tool contracts (`docs/AI_AGENT_DESIGN.md`); only derived results leave the device.
- **Receipt scanning** — on-device capture + OCR → cloud Haiku structuring (text, not image) → confidence-flagged confirm card.
- **Sync / backup** across devices.
- **Done when:** premium subscribers get the advisor + receipts; raw data never leaves the device; per-user token cost stays in the modeled range.
- **Depends on:** Phase 9 (entitlement) + Phase 5 (exact money) + the agent design.

### Phase 11 — Content + hygiene ⬜ (ongoing / optional)
**Goal:** polish and deferred extras.
- Economics **news/tips** feed (network + content source) · **budgets** · search/filter · **export**.
- Typography pass: Plus Jakarta Sans is bundled/registered, but the app still needs a full sweep to replace remaining raw/system font usage and tune type hierarchy through every screen.
- **Why last:** news carries network + content-ops + posture cost; hygiene items fold in as polish without blocking the core arc.

---

## Director principles (the quality bar)

1. **Vertical slices.** Each phase ships something a user notices, end to end — not a layer.
2. **Design-first.** Every new screen inherits the Phase 5 motion/floating language. "Cool" is a baseline, not a later pass.
3. **Phase gates.** A phase isn't done until it meets its "done when" and is validated against `PRODUCT_SPEC.md`. The next phase doesn't start early.
4. **Foundations before features.** Money exactness (Phase 5) and accounts (Phase 9) are hard gates — nothing that depends on them ships before them.
5. **No half-features.** Better to cut scope from a phase than ship a broken one.
</content>
