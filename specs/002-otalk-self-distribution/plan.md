# Implementation Plan: O'talk Self-App Distribution (Phase 2)

**Branch**: `feat/rebrand` (spec dir `002-otalk-self-distribution`) | **Date**: 2026-07-12 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-otalk-self-distribution/spec.md`

## Summary

Ship O'talk as OKR Best Inc's own app: swap the technical identity to `com.okrbest.otalk`
(iOS 3 targets + App Group/iCloud/keychain, Android `applicationId` only — Java package
kept per research R1), re-sign under OKR Best accounts, stand up the OKR Best push chain
(Firebase + APNs + self-hosted push proxy — the critical path), create store listings,
swap third-party config, and rewire fastlane/CI. URL schemes are explicitly retained;
their app↔server couplings are documented for a future coordinated change (FR-010, R5).

## Technical Context

**Language/Version**: TypeScript + React Native 0.83.9 (New Arch); Swift/Obj-C++ (iOS); Kotlin/Java (Android); Ruby (fastlane)

**Primary Dependencies**: Xcode project (`ios/Mattermost.xcodeproj`), Gradle (`android/app/build.gradle`), fastlane + match, Firebase FCM, APNs, self-hosted `mattermost-push-proxy`

**Storage**: WatermelonDB shared via iOS App Group (directory moves with `group.com.okrbest.otalk`); no schema change

**Testing**: `npm run tsc` + `npm run fix`; on-device smoke tests (install/login/share/deep link/push) per [quickstart.md](./quickstart.md); detox e2e package refs updated

**Target Platform**: iOS + Android (store distribution)

**Project Type**: mobile-app (+ external infra: push proxy, store consoles)

**Performance Goals**: N/A — no runtime performance impact

**Constraints**: identifiers must be consistent across app/entitlements/signing/push or push fails silently; no upgrade path from `com.mattermost.rnbeta` installs; URL schemes unchanged this phase; external accounts (Apple/Google/Firebase) are prerequisites outside the repo

**Scale/Scope**: ~35 files with identifier references (106 occurrences, research R3); 6 fastlane env files; 1 replaced `google-services.json`; 1 new backend service (push proxy); 2 store listings

## Constitution Check

`.specify/memory/constitution.md` is an unpopulated template — no constitutional gates.
Repo conventions from `CLAUDE.md` honored:

- ✅ Checks (`npm run tsc`, `npm run fix`) before commits.
- ✅ On-device verification with real interaction (quickstart smoke tests), not just launch.
- ✅ Spec-kit artifacts under `specs/` are the committed record.
- ✅ i18n untouched (no string changes in this phase).

**Result**: PASS — Complexity Tracking not required.

## Project Structure

### Documentation (this feature)

```text
specs/002-otalk-self-distribution/
├── spec.md              # Feature spec (/speckit-specify)
├── plan.md              # This file (/speckit-plan)
├── research.md          # Phase 0 decisions (R1–R8)
├── quickstart.md        # Smoke-test / validation guide
├── contracts/
│   └── app-identity.md  # Identity naming contract (single source of truth)
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # (/speckit-tasks — next)
```

> No `data-model.md`: no data entities change; the App Group move relocates the existing
> database directory without schema impact.

### Source Code (repository root) — files touched

```text
ios/
├── Mattermost.xcodeproj/project.pbxproj      # PRODUCT_BUNDLE_IDENTIFIER ×3 targets
├── Mattermost/{Info.plist, Mattermost.entitlements}          # App Group, iCloud, keychain
├── MattermostShare/{Info.plist, MattermostShare.entitlements}
└── NotificationService/{Info.plist, NotificationService.entitlements}
android/app/
├── build.gradle                              # applicationId only (namespace kept — R1)
└── google-services.json                      # replaced with OKR Best Firebase file
assets/base/config.json                       # Sentry DSNs, RudderApiKey, DefaultServerUrl
fastlane/
├── Fastfile, env_vars_example
└── .env.{ios,android}.{beta,pr,release}      # identifier/env map per research R6
detox/                                        # e2e package/bundle refs
app/screens/settings/about/about.tsx          # MATTERMOST_BUNDLE_IDS gate review (R4)
app/database/manager/index.ts                 # identifier usage review (R4)
```

**Structure Decision**: in-place identifier swap with minimal structural churn — Xcode
target names and the Android Java package are intentionally kept (R1/R2) to preserve
upstream merge-ability; only identity values change.

## Phased Delivery (maps to user stories)

1. **US1 — identity rename (repo-only)**: iOS IDs/entitlements, Android applicationId,
   config/env/e2e refs, identifier audit (FR-004), scheme compatibility analysis doc
   (FR-010). Verifiable on simulator/emulator with dev signing — no external accounts.
2. **US2 — push chain (external + repo)**: Firebase project + `google-services.json`,
   APNs key, push proxy deployment + server pointing, end-to-end smoke test (FR-006/007).
3. **US3 — signing/store/CI (external + repo)**: match certs + keystore (FR-005),
   store records + metadata (FR-008), fastlane env/secrets (FR-011), release run,
   on-device release verification (FR-012).

External-account provisioning (R8) starts immediately in parallel — longest lead time.

## Risks (carried from spec + research)

- Push chain misalignment fails silently → quickstart smoke test is mandatory gate.
- `project.pbxproj` hand-editing is error-prone → change only `PRODUCT_BUNDLE_IDENTIFIER`
  lines; verify with `xcodebuild -showBuildSettings` when a macOS runner is available.
- App Group change silently splits app/extension storage if any reference is missed →
  FR-004 audit + share-extension smoke test.
- Store review lead time is outside our control → submit early on internal tracks.

## Complexity Tracking

> Not applicable — Constitution Check passed with no violations.
