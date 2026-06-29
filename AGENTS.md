# AGENTS.md — OKRBest Mobile (Codex)

> **Full engineering conventions live in [`CLAUDE.md`](./CLAUDE.md)** at the repo root —
> architecture (dual WatermelonDB, NetworkManager/ClientMix, actions/queries layers),
> testing patterns, React Native / hooks rules, i18n, and code-quality rules. Codex must
> read `CLAUDE.md` before non-trivial work; **those rules apply in Codex exactly as in
> Claude Code.** This file adds the feature workflow and the Codex-specific tool mapping.

## Spec-Kit + Superpowers Integrated Workflow (Codex)

This is the canonical workflow for all feature work in this repo. It is **identical in
process and result** to the Claude Code setup documented in `CLAUDE.md`; only the
invocation syntax differs (Codex). It combines `superpowers` skills (idea + execution
discipline) with `spec-kit` skills (spec-driven procedure).

### Codex platform notes
- **spec-kit skills** are installed under `.agents/skills/speckit-*` (Codex auto-discovers
  `.agents/skills`). The `.specify/` directory holds shared, agent-agnostic infrastructure
  (templates, scripts, `memory/constitution.md`, `extensions.yml`).
- **superpowers skills** load natively (installed as a global Codex plugin; `multi_agent =
  true` is already set in `~/.codex/config.toml`).
- **Invoking a skill**: mention it explicitly with `$skill-name` or via `/skills`; Codex
  also selects skills implicitly when the task matches the skill description. Below,
  `$speckit-specify` etc. mean "run that skill".
- **Subagents**: superpowers subagent work (`subagent-driven-development`,
  `dispatching-parallel-agents`) uses `spawn_agent` / `wait_agent` / `close_agent`.
- **Task tracking**: use `update_plan` (the equivalent of TodoWrite).

### Pipeline overview

```
feature request
  → (complexity gate) superpowers:brainstorming        [idea formation]
  → EXPLICIT user handoff                                [never silent/auto]
  → $speckit-specify → $speckit-clarify? → $speckit-plan → $speckit-tasks
  → $speckit-analyze (offer it; run when requested)      [spec phase done]
  → ⟦COMMIT GATE 1 — recommend⟧
  → $speckit-implement  (superpowers skills active)      [implementation]
  → ⟦COMMIT GATE 2 — recommend⟧
```

### 1. Idea formation — complexity-gated brainstorming
- **Complex / ambiguous feature** → run `superpowers:brainstorming` first to settle intent,
  requirements, and design.
- **Simple / well-defined feature** → skip brainstorming and go straight to `$speckit-specify`.
- **The brainstorming → spec-kit handoff MUST be an explicit user choice — never a silent or
  automatic transition.** When the design is settled, surface the handoff visibly and let the
  user choose: ① proceed to `$speckit-specify`, ② refine the design more, ③ pause/hold. Do not
  auto-close brainstorming or enter spec-kit before the user says so.
- Resolve minor ambiguity with reasonable defaults recorded in Assumptions; reserve
  `[NEEDS CLARIFICATION]` for decisions that genuinely need the user. Avoid long Q&A.

### 2. Spec-kit procedure
Run the spec-kit skills in order: `$speckit-specify` → `$speckit-clarify` (optional, before
plan, to de-risk ambiguity) → `$speckit-plan` → `$speckit-tasks`. The shared `extensions.yml`
auto-offers an agent-context refresh after specify and after plan — accept it.

### 3. Analyze (after tasks)
After `$speckit-tasks`, **always offer `$speckit-analyze`** (cross-artifact consistency &
alignment report). Run it whenever the user requests it before moving to implementation.
This marks the end of the **spec phase**.

### 4. Implementation — superpowers active
During `$speckit-implement`, the relevant `superpowers` skills drive execution discipline:
- `superpowers:test-driven-development` — before writing implementation code.
- `superpowers:subagent-driven-development` — execute independent tasks via `spawn_agent`
  (aligns with the "use a subagent per phase" rule in `CLAUDE.md`).
- `superpowers:systematic-debugging` — on any bug, test failure, or unexpected behavior.
- `superpowers:verification-before-completion` — before claiming any task done; evidence first.
- `superpowers:requesting-code-review` / `receiving-code-review` — when finishing work.
- Honor existing repo rules: run `npm run tsc` + `npm run fix` (checks) before committing, and
  **actually test the change with the mobile MCP** (not just "the app launches") before calling
  it complete.

### 5. Commit gates (recommend only — never auto-commit)
At each gate, **recommend** a commit and let the user decide each time:
- **Gate 1 — spec complete** (after `$speckit-tasks`, and `$speckit-analyze` if run, before
  `$speckit-implement`): recommend committing the spec-kit artifacts under `specs/`.
- **Gate 2 — implementation complete** (after `$speckit-implement`, checks pass, mobile MCP
  verified): recommend committing the code change.
- **Clarification on the "never commit planning markdown" rule:** that rule targets ad-hoc
  scratch files (e.g. a root `PLAN.md`). Spec-kit artifacts under `specs/` (`spec.md`,
  `plan.md`, `tasks.md`, analysis output) **are** the spec-driven record and are committed at
  Gate 1. Keep transient scratch planning files out of commits.

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
<!-- SPECKIT END -->
