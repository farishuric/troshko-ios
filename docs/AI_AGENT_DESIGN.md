# AI_AGENT_DESIGN.md — Troshko personal-finance agent

> **What this doc is.** The design record for Troshko's AI layer — the "pocket advisor" agent, its tool contracts, guardrails, and the receipt-scanning pipeline. Read `PRODUCT_SPEC.md` first for *why* (product intent, monetization, unit economics) and `CLAUDE.md` for *how the app is built* (Clean Architecture). This doc is the *how the AI works*.
>
> **Status: forward-looking. Nothing here is built yet.** It's the thesis to design toward, captured before it drifts into code-only knowledge. Update this when a decision changes.
>
> _Last updated: 2026-06-23._

---

## 0. The one rule everything follows from

```
SwiftData / SQL  = truth
vector / memory  = context
LLM              = reasoning + explanation
The LLM must NEVER do arithmetic.
```

The thing that makes a finance agent trustworthy instead of a chatbot that guesses: **the model is forbidden from computing numbers.** It may only *call a deterministic tool that computes them* and then explain the result. "Can I afford AirPods?" produces **zero model-generated math** — every number in the answer traces to a Swift function's return value. That single constraint is what makes it safe to ship.

---

## 1. Architecture — mobile-first, not backend-first

Troshko's truth already lives on the phone in **SwiftData**. We do **not** stand up Postgres/pgvector/Qdrant to make the agent work — the agent pattern (LLM orchestrating deterministic tools) runs identically whether the LLM is on-device or in the cloud. A backend appears only for premium **sync**, later.

| Layer | Implementation |
|---|---|
| **Truth** | SwiftData (`ExpenseEntity`, `ExpenseCategoryEntity`, + new `FinancialRule`, `SavingsGoal`, `Budget`, `RecurringBill`) |
| **Calculation** | Pure Swift functions over SwiftData — cashflow, forecasts, simulations. Deterministic, testable, no model involvement. |
| **Rules** | Structured SwiftData rows (editable in settings), *not* vector memory. |
| **Semantic memory** | Plain-text monthly summaries / habit notes loaded into context. Vector DB only later, if memory overflows the context budget. |
| **Reasoning** | LLM — on-device Foundation Models (free) or Claude via relay (premium). Orchestrates tools, explains results. |
| **Writes** | **Propose-then-confirm.** The LLM never writes; it returns a proposed action, the app renders a confirmation card, the user confirms, the app writes. |
| **Sync / backend** | Postgres + pgvector — premium sync layer, **later**, not required for MVP. |

---

## 2. Prerequisite — money must stop being a `Double`

The whole pitch is "exact calculations." `Double` makes that false (`0.1 + 0.2 != 0.3`, and the error compounds across a forecast). **Before the agent ships, migrate SwiftData `amount` to integer minor units (or `Decimal`).** Every tool contract below speaks **integer minor units + a currency code**. This is open question #4 in `PRODUCT_SPEC.md` — the agent forces the answer.

---

## 3. Memory — two kinds, stored differently

1. **Structured rules** — deterministic, editable, exact. SwiftData rows, *truth*, not embeddings. Examples:
   - save ≥ X per month · no non-essentials before hitting the savings goal · max tech spend per month · emergency-fund minimum
   An embedding of "save 300/month" is strictly worse than a row you can apply exactly and let the user edit.

2. **Semantic memory** — unstructured narrative. Plain text at first. Examples:
   - "tends to overspend on tech gadgets" · "May was expensive — car repairs" · "spends more on restaurants near month-end"

   **Vector DB is deferred.** One user has dozens of rules and a few dozen summaries — that fits in the context window. Add retrieval only when semantic memory exceeds the token budget (for a single-user finance app, possibly years out).

**Habit-learning without retraining** = a periodic job writes a monthly summary and may *propose* promoting a detected pattern into a structured rule the user confirms.

---

## 4. Tool contracts

Every tool is **read-only** and returns a structured envelope `{ asOf, currency, ...payload }`, amounts as **integer minor units**. The model sees JSON; a pure Swift function over SwiftData implements it.

```
getMonthlyCashflow(month?: "2026-06")
  → { income, spentSoFar, net, daysElapsed, daysRemaining }

getUpcomingBills(throughDate?)                  // default: month end
  → { totalDue, bills: [{ name, amount, dueDate, category }] }

getSavingsGoalStatus(goalId?)
  → { goals: [{ id, name, target, saved, monthlyTarget,
               savedThisMonth, gapThisMonth, onTrack: bool }] }

getCategorySpending(category, month?)
  → { category, spent, txnCount, avgPrior3Months, vsAverage }

forecastMonthEndBalance(month?)
  → { currentBalance, projectedBalance, method,
      assumptions: { avgDailyDiscretionary, daysRemaining, billsIncluded } }

simulatePurchase(amountMinor, category?, date?)         // ← keystone
  → { projectedBalanceAfter, deltaVsNoBuy,
      savingsImpact: [{ goalId, gapAfter, breaksGoal: bool }],
      rulesViolated: [ruleId],
      categoryBudgetAfter }

getRelevantRules(context?)
  → { rules: [{ id, type, description, params, active }] }

getRecentFinancialSummaries(limit?)
  → { summaries: [{ period, text, tags }] }
```

Design decisions baked in:
- **No `getItemPrice`.** Price is user-supplied. Missing → the agent returns `need_info` (below), never invents one. ("Ask, don't guess," expressed as a missing input.)
- **`simulatePurchase` is composite and does rule-checking itself.** It re-runs the forecast *with* the purchase and returns `rulesViolated` / `savingsImpact` as deterministic facts. Swift decides whether a rule broke; the model only explains it. Judgment stays out of the LLM where it matters.
- **`forecast*` exposes `method` + `assumptions`.** The Swift function picks the formula (e.g. `currentBalance + remainingIncome − upcomingBills − avgDailyDiscretionary × daysRemaining`); the model cites the assumptions, never chooses them.

---

## 5. The final-answer contract

The agent's last turn is a **structured output**, not free prose. This is what turns the guardrails from wishes into checks.

```json
{
  "decision": "safe | risky | not_recommended | need_info",
  "headline": "Yes, but it'll put you under your savings target.",
  "explanation": "...plain-language reasoning...",
  "keyNumbers": [
    { "label": "Projected leftover after buying",
      "amountMinor": 34000, "currency": "BAM",
      "sourceTool": "simulatePurchase" }
  ],
  "citedRules": ["save_min_monthly"],
  "missingInfo": ["itemPrice"],          // only when need_info
  "proposedActions": [                    // propose-then-confirm
    { "type": "logExpense", "label": "Log AirPods 229 KM", "payload": { } }
  ]
}
```

The keystone is **`keyNumbers[].sourceTool`** — every number the user sees is tagged with the tool that produced it. **The UI renders numbers from `keyNumbers`, never from prose in `explanation`.** A hallucinated number in the prose never reaches a balance display.

---

## 6. Guardrails — enforce, don't just instruct

A system prompt is the *weakest* place to put a guardrail. Sort each one to where it's actually enforced; push everything possible down to Tier 1/2.

**Tier 1 — Structural (cannot be violated, even by a misbehaving model)**
- *No writes / payments / rule edits* → the toolset contains **no write tools**. Impossible, not forbidden.
- *Raw data never leaves the device* → the device→relay request type **cannot hold a transaction** (carries only derived tool-result DTOs). Privacy enforced by the type system.
- *Numbers come from tools* → the app renders from `keyNumbers[]`, not prose.
- *Cost control* → bounded agent loop (cap tool iterations per question) + stateless relay rate-limit + account spend cap.

**Tier 2 — Verification (cheap post-hoc checks; strongest practical anti-hallucination lever)**
- Assert each `keyNumbers[].amountMinor` **equals a value actually present in this turn's captured tool results**. Untraceable number → drop + flag.
- Consistency check: `simulatePurchase.rulesViolated` non-empty but `decision == "safe"` → contradiction → flag.

**Tier 3 — Prompt (best-effort, for what can't be mechanically checked)**
- "Never output a number not in `keyNumbers` with its `sourceTool`."
- "If price/date/category is missing, return `need_info` — never assume."
- "Cite the rule or calculation behind the decision in `citedRules`."
- "You cannot write data; to change anything, return a `proposedActions` entry for the user to confirm."

---

## 7. Free (on-device) vs premium (cloud) — split by capability

The full agentic "can I afford X" loop (8 tool calls, multi-step planning over rules) is **hard for a ~3B on-device model.** That isn't a problem — it's the free/premium line drawn by capability:

- **Free — on-device** (Apple Foundation Models): single-step jobs — NL entry, auto-categorise, "here's your month" with pre-computed inputs. $0 to serve.
- **Premium — cloud** (Claude via relay): the **agentic advisor** + **receipt scanning**. This is where a frontier model earns its price over a 3B model — the hero feature.

**Phone-orchestrated cloud loop (privacy-preserving):** the agent loop runs **on the device**. When Claude asks for a tool call, the *phone* executes it against local SwiftData and sends back only the small derived result. Raw transactions never leave the device — only numbers like `{"projected_leftover": 340}` transit (a manual agentic tool-use loop). Tiny tool results = the advisor is *both* cheap and private.

**The relay** is stateless: holds the single Claude API key, enforces the per-user fair-use cap, forwards messages, stores nothing. Model tiering (Haiku default → Sonnet/Opus on hard asks) keeps per-user cost ~$1–2/mo. See `PRODUCT_SPEC.md` §10 for the full economics.

---

## 8. Worked example — "Can I afford AirPods this month?"

```
1. price missing → agent asks the user (or returns need_info: ["itemPrice"])
2. getMonthlyCashflow()        → income, spent, days remaining
3. getUpcomingBills()          → bills due before month-end
4. getSavingsGoalStatus()      → goal progress + monthly gap
5. forecastMonthEndBalance()   → projected month-end balance
6. simulatePurchase(22900)     → balance-after, savings impact, rules violated
7. getRelevantRules("tech") / getRecentFinancialSummaries()
8. → structured answer: decision=risky, headline + explanation,
     keyNumbers (each tagged sourceTool), citedRules=[save_min_monthly]
```

Result, e.g.: *"Yes, but it'd put you 40 KM under this month's savings target, and you've told me you overspend on tech — want to wait until you hit the goal on the 25th?"* — every number from a tool, the rule cited, no arithmetic by the model.

---

## 9. Receipt scanning (premium) — a worked example of propose-then-confirm

A scanned receipt is just a **proposed expense**. Same pattern: extract a candidate → pre-filled confirmation card → user confirms → app writes. Nothing auto-inserts.

**Pipeline**
```
1. Capture   → VNDocumentCameraViewController (VisionKit): edge-detect, crop, deskew
2. OCR       → Vision text recognition                      [on-device, $0]
3. Structure → OCR text → typed fields                      [on-device OR cloud]
4. Confirm   → confidence-flagged pre-filled card → user edits → app writes
```

- **Capture:** Apple's document scanner (`VNDocumentCameraViewController`) — rectified page images. Also accept a photo-library pick.
- **OCR:** Apple **Vision** (`RecognizeTextRequest`), on-device, free, returns text lines **with bounding boxes** (layout is signal — the total is the large number near the bottom, etc.).
- **Structure:** on-device **Foundation Models guided generation** (`@Generable`, free) *or* premium cloud — send the **OCR text** (not the image) to the relay → **Haiku 4.5 with structured outputs** forcing the receipt schema.
- **Confirm:** render fields editable; low-confidence fields highlighted.

**Privacy boundary:** OCR runs **on-device**; only the recognized **text** goes to the cloud, **never the image**. A receipt photo is raw data; its extracted text is a derived summary — keeps "raw stays on the phone" literally true, and it's cheaper than a vision call.

**Extraction schema** (per-field confidence drives the confirm UI):
```json
{
  "merchant": "Konzum",
  "date": "2026-06-21",
  "total": { "amountMinor": 4730, "currency": "BAM" },
  "taxAmount": { "amountMinor": 800, "currency": "BAM" },
  "suggestedCategory": "Groceries",
  "lineItems": [ { "description": "Milk", "amountMinor": 250 } ],   // premium
  "confidence": { "merchant": 0.96, "date": 0.71, "total": 0.99 }
}
```

**Cost:** ~$0.002 per receipt (Haiku, text-only) — negligible. **Gate:** premium *entitlement*, not a cloud dependency (both OCR and on-device structuring are free-capable; keep flexibility to make basic scan a free hook later).

---

## 10. MVP cut

| Capability | Tier | How |
|---|---|---|
| NL entry · auto-categorise · basic monthly summary | Free | On-device Foundation Models, single-step |
| Conversational advisor ("can I afford X") | Premium | Phone-orchestrated Claude loop, derived results only |
| Receipt scanning | Premium | On-device capture+OCR → cloud Haiku structuring (text only) → confirm card |
| Cross-device sync / Postgres + pgvector | Later | Not required for MVP |

---

## 11. Open questions (agent-specific)

1. **Forecast formula.** Lock the deterministic `forecastMonthEndBalance` method (how is `avgDailyDiscretionary` derived — trailing 30d? excludes bills? excludes one-offs?).
2. **Foundation Models reliability.** How many tool-call steps can the on-device model chain before it's unreliable? Where exactly is the free/premium capability line?
3. **Rule schema.** Concrete `FinancialRule.type` set + params (min-savings, category-cap, ordering-rule, emergency-floor).
4. **Memory promotion.** When/how does a semantic-memory pattern get *proposed* as a structured rule? Fully user-confirmed?
5. **Bounded loop limits.** Max tool iterations per question (cost vs. completeness).
6. **Receipt free/premium line.** Stay premium-only, or basic on-device scan free + cloud accuracy/line-items premium?
7. **Multi-currency in receipts.** Single device currency for MVP — when does a receipt in another currency need handling?
</content>
