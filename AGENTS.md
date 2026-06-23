# AGENTS.md — Troshko (coding-agent guide)

**`CLAUDE.md` is the canonical project guide — read it first**, then follow the doc read-order it lists. This file is the short version for agents that key off `AGENTS.md`.

## Read in order
1. **`CLAUDE.md`** — architecture, conventions, status, working agreements.
2. **`docs/BUILD_ROADMAP.md`** — living phase tracker; find the **CURRENT** phase.
3. **The current phase's spec** (now: **`docs/PHASE_5_SPEC.md`**) — the work order.
4. **`PRODUCT_SPEC.md`** (what & why, incl. §10 economics) · **`docs/AI_AGENT_DESIGN.md`** (the AI/agent layer).

## Working agreements — must follow
- **Do NOT run `git commit`.** The user makes all commits. **Never add a `Co-Authored-By` trailer.**
- **Do NOT run builds or the simulator.** Make the change, then ask the user to build and report results.
- **Work only the current phase**, to its "done when" gate. **No half-features** — cut scope rather than ship broken.
- **Design is taste-driven:** for visual/motion work, **propose 3–4 directions and let the user choose** before building. Don't ship a default aesthetic.
- **Ask before destructive data actions** (e.g. resetting/migrating the SwiftData store).
- **Conventions are non-negotiable:** Clean Architecture feature layout, Styleguide tokens only (no raw colors/fonts/spacing), localization for every user-facing string (`en` + `bs-BA`). See `CLAUDE.md`.

## Now
Current phase: **Phase 5 — Foundations** (`docs/PHASE_5_SPEC.md`). Start with **Track A: money `Double` → integer minor units**. Before editing, produce a short implementation plan (the `Money` type, files you'll touch, and how you'll handle the existing SwiftData store) and wait for the user's OK.
</content>
