# Implementation Plan: O'talk / OKR Best Inc User-Facing Rebrand (Phase 1)

**Branch**: `001-otalk-rebrand` | **Date**: 2026-06-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-otalk-rebrand/spec.md`

## Summary

Replace user-identifiable Mattermost branding with O'talk (service) and OKR Best Inc
(company) across display names, in-app English text, branding config, and image assets —
while preserving OSS license/platform/community attribution and leaving all technical
identifiers unchanged. Pure presentation change (strings, config values, asset files); no
new code paths or data. Authoritative per-string/asset mapping lives in
`docs/superpowers/specs/2026-06-29-otalk-rebrand-user-facing-design.md`.

## Technical Context

**Language/Version**: TypeScript + React Native 0.83.9 (New Arch); Obj-C++/Swift (iOS native); XML/resources (Android native)

**Primary Dependencies**: i18n source `assets/base/i18n/en.json`; `assets/base/config.json`; `expo-splash-screen`; iOS asset catalogs (`.xcassets`); Android resource dirs (`mipmap-*`, `drawable-*`)

**Storage**: N/A (no data model change)

**Testing**: `npm run tsc` (type-check), `npm run fix` (lint), mobile MCP visual verification on a running app; `npm run i18n-extract` only if message IDs change (they don't — values only)

**Target Platform**: iOS and Android

**Project Type**: mobile-app

**Performance Goals**: N/A — no runtime/perf impact

**Constraints**: Edit only `en.json` among i18n files; preserve OSS attribution strings/URLs; do NOT change technical identifiers (scheme, bundle/app IDs, package, App Group, push topic, deep-link host); "O'talk" apostrophe must render/escape correctly in JSON, native plists, and Android XML (escape as `O\'talk` in Android strings.xml)

**Scale/Scope**: ~13 product-identity strings + 1 copyright string in `en.json`; 2 keys in `config.json`; 4 native display-name locations (app.json, 2 iOS plists, Android strings.xml); image asset sets (app icon, splash light/dark, in-app logo) across iOS + Android

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` is an unpopulated template — no project-specific
constitutional gates are defined. The governing rules are the repo conventions in
`CLAUDE.md`, which this plan honors:

- ✅ i18n: only `en.json` is edited (never other locale files).
- ✅ Localization: existing message IDs reused; values changed only; `defineMessages`/extract not needed since no new IDs.
- ✅ Pre-commit: `npm run tsc` + `npm run fix` before any commit.
- ✅ Verification: changes tested on a running app via mobile MCP (not just "app launches").
- ✅ No planning scratch files committed; spec-kit artifacts under `specs/` are the record.

**Result**: PASS — no violations, Complexity Tracking not required.

## Project Structure

### Documentation (this feature)

```text
specs/001-otalk-rebrand/
├── spec.md              # Feature spec (/speckit-specify)
├── plan.md              # This file (/speckit-plan)
├── research.md          # Phase 0 decisions (/speckit-plan)
├── quickstart.md        # Phase 1 verification guide (/speckit-plan)
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # (/speckit-tasks — not created here)
```

> No `data-model.md` (no entities) and no `contracts/` (purely internal UI; no external interface).

### Source Code (repository root) — files touched by this feature

```text
app.json                                              # displayName → O'talk
assets/base/
├── i18n/en.json                                      # 13 product strings + copyright
├── config.json                                       # WebsiteURL, DefaultServerName
└── images/{logo.png, icon.png}                       # in-app logo
ios/
├── Mattermost/Info.plist                             # CFBundleDisplayName → O'talk
├── MattermostShare/Info.plist                        # CFBundleDisplayName → O'talk
│   # NotificationService/Info.plist NOT changed (value "NotificationService", not branding — R1)
└── Mattermost/Images.xcassets/
    ├── AppIcon.appiconset/*                           # app icon
    ├── SplashIcon.imageset/*  (light/dark @2x/@3x)    # splash icon
    └── SplashBackground.imageset/*                    # splash bg
android/app/src/main/res/
├── values/strings.xml                                # app_name → O'talk
├── mipmap-*/ic_launcher*.png                          # launcher icons
├── mipmap-anydpi-v26/*.xml                            # adaptive icon
└── drawable*/                                         # splash drawables
```

**Structure Decision**: In-place edits within the existing repo layout. Text via the
canonical i18n + config JSON; native display names in their platform files; images
replaced at their existing asset paths. No new modules, no abstraction layer (YAGNI for a
single-brand static rebrand).

## Complexity Tracking

> Not applicable — Constitution Check passed with no violations.
