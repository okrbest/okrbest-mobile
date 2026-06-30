# Quickstart / Verification Guide: O'talk Rebrand (Phase 1)

This guide proves the rebrand end-to-end. It is a validation guide — implementation detail
lives in `tasks.md`. See [spec.md](./spec.md) (FR/SC) and
[research.md](./research.md) for decisions.

## Prerequisites

- App buildable for at least one platform (iOS simulator or Android emulator).
- O'talk image source files provided (app icon master, splash logo light/dark, in-app logo) — required for the asset-verification steps.
- Mobile MCP available for visual verification (per `CLAUDE.md`).

## Static checks (no device)

```bash
npm run tsc      # type-check passes
npm run fix      # lint passes / auto-fixes
```

- Grep guard: no in-scope product string still says "Mattermost".
  Confirm the retained attribution strings (`settings.notice_text`,
  `settings.about.powered_by`, `about.teamEditionLearn`) and the NOTICE URLs are unchanged.
- Confirm no other locale file under `assets/base/i18n/` was modified (only `en.json`).
- Confirm technical identifiers unchanged (scheme, bundle/app IDs, package, App Group, push
  topic, deep-link host) — `git diff` touches none of them.

## On-device verification (mobile MCP)

Map each step to its success criterion:

| Step | Action | Expected | Covers |
|------|--------|----------|--------|
| 1 | View home screen / app switcher | App name reads **O'talk** (iOS + Android) | SC-004, FR-001 |
| 2 | Launch app | Splash shows O'talk identity (light + dark) | FR-002 |
| 3 | First-run onboarding | Welcome describes **O'talk** (no "Mattermost") | SC-002, FR-003 |
| 4 | Add-server screen | Display-name field defaults to **O'talk** | FR-006 |
| 5 | Trigger a call / its notification | Reads **O'talk Calls** / **O'talk** | FR-003 |
| 6 | Settings → About | Copyright = **OKR Best Inc** (current year); website = **https://okr.best**; OSS notice / "powered by" / community link **unchanged** | SC-003, FR-004/005/007 |
| 7 | Trigger ratings prompt (if reachable) | Reads **Enjoying O'talk?** | FR-003 |
| 8 | Sanity: sign in to a server, receive a push, open a deep link | All work as before | SC-005, FR-008 |

## Done when

- Static checks pass; on-device steps 1–8 observed; SC-001…SC-005 satisfied.
- Screenshots of steps 1, 2, 3, 6 captured as evidence (per verification-before-completion).
