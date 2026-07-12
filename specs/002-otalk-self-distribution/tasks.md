# Tasks: O'talk Self-App Distribution (Phase 2)

**Feature**: `specs/002-otalk-self-distribution` | **Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

**Tests**: Not generated as unit tests — this is identity/infra work with no new logic under
unit test. Verification is on-device smoke testing per [quickstart.md](./quickstart.md) plus
the FR-004 identifier audit. Identity values: [contracts/app-identity.md](./contracts/app-identity.md).

**⚠️ EXTERNAL** marks tasks that depend on accounts/infrastructure outside this repo
(Apple Developer, Play Console, Firebase, proxy host). Start them first — longest lead time.

## Phase 1: Setup

- [X] T001 Create implementation branch for `002-otalk-self-distribution` off the current mainline
- [ ] T002 [P] ⚠️ EXTERNAL Kick off account provisioning: Apple Developer Program (org, D-U-N-S), Google Play Console (org), Firebase project — record owner + status in the task; blocks US2/US3 only
- [X] T003 [P] Capture baseline identifier audit: `grep -rn "com\.mattermost\.rnbeta\|com\.mattermost\.rn\b"` (excluding node_modules/build/dist) saved as evidence; confirm the ~106-reference inventory in research.md R3 still matches

## Phase 2: Foundational

_No blocking foundational work — US1 is repo-only; US2/US3 gate on T002 externals. Proceed to Phase 3._

## Phase 3: User Story 1 — O'talk runs as its own app identity (P1) 🎯 MVP

**Goal**: App installs and runs as `com.okrbest.otalk` on both platforms; share extension, deep links, SSO all work; zero undocumented legacy identifiers.

**Independent test**: quickstart US1 — simulator/emulator install, package ID check, login, share-sheet post, `mattermost://` + `mmauth(beta)://` round-trip.

### iOS identity

- [X] T004 [US1] Set `PRODUCT_BUNDLE_IDENTIFIER` for all 3 targets (main → `com.okrbest.otalk`, NotificationService → `.NotificationService`, MattermostShare → `.MattermostShare` suffixes) in `ios/Mattermost.xcodeproj/project.pbxproj` (all build configurations)
- [X] T005 [P] [US1] Update `ios/Mattermost/Mattermost.entitlements`: App Group `group.com.okrbest.otalk`, iCloud container `iCloud.com.okrbest.otalk`, keychain access group per contract
- [X] T006 [P] [US1] Update `ios/MattermostShare/MattermostShare.entitlements` and `ios/NotificationService/NotificationService.entitlements` to the same App Group/keychain values
- [X] T007 [P] [US1] Update identifier-bearing values in `ios/Mattermost/Info.plist`, `ios/MattermostShare/Info.plist`, `ios/NotificationService/Info.plist` (bundle-ID-derived keys only; URL schemes stay — FR-010)

### Android identity

- [X] T008 [US1] Set `applicationId "com.okrbest.otalk"` in `android/app/build.gradle`; keep `namespace`/Java package unchanged (research R1); verify manifest placeholders and FCM default channel still resolve

### Config, env, and references

- [X] T009 [P] [US1] Update identity values in `fastlane/env_vars_example` and `fastlane/.env.{ios,android}.{beta,pr,release}` per research R6 map (`MAIN_APP_IDENTIFIER`, `EXTENSION_APP_IDENTIFIER`, `MATCH_APP_IDENTIFIER`, `SUPPLY_PACKAGE_NAME`, `IOS_APP_GROUP`, `IOS_ICLOUD_CONTAINER`, `APP_NAME`)
- [X] T010 [P] [US1] Update hardcoded package/bundle references in `detox/` scripts (`create_android_emulator.sh`, `scripts/preboot_ios_simulator.sh`, `maestro/scripts/*.sh`, `e2e/test/setup.ts`) and `test/setup.ts`, `app/init/calls_native.test.ts`
- [X] T011 [P] [US1] Review `MATTERMOST_BUNDLE_IDS` gates: `app/screens/settings/about/about.tsx` and identifier usage in `app/database/manager/index.ts` — confirm non-Mattermost branch behavior is correct for O'talk (research R4); leave constants intact
- [X] T012 [P] [US1] Write the URL-scheme compatibility analysis (FR-010) at `specs/002-otalk-self-distribution/url-scheme-compatibility.md` covering every coupling in research R5 (config.json AuthUrlScheme(s), Info.plist CFBundleURLSchemes, AndroidManifest scheme filters, DEFAULT_AUTOLINKED_URL_SCHEMES, server SSO redirect allow-list) + the coordinated-change plan for a future phase

### Verify (US1 gate)

- [X] T013 [US1] Run identifier audit against contract invariant 4; attach output showing only documented exceptions (FR-004)
- [ ] T014 [US1] On-emulator/simulator verification per quickstart US1 steps 1–6 (coexistence with Mattermost app, login, share-extension post, deep link + SSO round-trip); capture evidence

**Checkpoint**: app is fully functional under the new identity with dev signing — MVP delivered.

## Phase 4: User Story 2 — Push through OKR Best infrastructure (P2)

**Goal**: Background push works end-to-end on both platforms via OKR Best Firebase/APNs + self-hosted push proxy.

**Independent test**: quickstart US2 — physical devices, background DM/mention, notification arrives with content.

- [ ] T015 [US2] ⚠️ EXTERNAL Create OKR Best Firebase project with Android app `com.okrbest.otalk`; download and replace `android/app/google-services.json`
- [ ] T016 [P] [US2] ⚠️ EXTERNAL Generate APNs Auth Key (.p8) under the OKR Best Apple team; store in the team secret store (never in repo)
- [ ] T017 [US2] ⚠️ EXTERNAL Deploy `mattermost-push-proxy` on OKR Best infra (TLS endpoint); configure `ApplePushSettings` (BundleID `com.okrbest.otalk`, .p8) and `AndroidPushSettings` (FCM service account) per research R7
- [ ] T018 [US2] ⚠️ EXTERNAL Point the target server's `PushNotificationServer` (e.g., `dev.okrbest.com` admin console) at the proxy; confirm server-side push contents settings
- [ ] T019 [US2] End-to-end push smoke test per quickstart US2 on physical iOS + Android devices (background DM + mention, NotificationService content fetch, tap-through); attach screenshots + proxy log excerpt (FR-007)

**Checkpoint**: daily-driver viable internal build.

## Phase 5: User Story 3 — Signed release through OKR Best store presence (P3)

**Goal**: CI produces store-accepted signed artifacts; listings live under OKR Best Inc; store builds pass the same smoke tests.

**Independent test**: quickstart US3 — CI lanes upload to TestFlight/Play internal; clean-device install passes US1/US2 flows.

- [ ] T020 [US3] ⚠️ EXTERNAL Register the 3 bundle IDs + App Group + iCloud container in the Apple Developer portal; set up `match` (new certs repo) for the OKR Best team; update `fastlane/Matchfile`
- [ ] T021 [P] [US3] ⚠️ EXTERNAL Create Android upload keystore, enroll the app in Play App Signing, store keystore/credentials in the team secret store
- [ ] T022 [P] [US3] ⚠️ EXTERNAL Create App Store Connect + Play Console app records under OKR Best Inc (name O'talk, publisher OKR Best Inc)
- [ ] T023 [US3] Rotate CI secrets to OKR Best values (match repo token, App Store Connect API key, Play service account, keystore) and remove every Mattermost-era secret from CI (FR-005/FR-011)
- [ ] T024 [P] [US3] Refresh `fastlane/metadata` + screenshots for O'talk store listings; complete privacy labels/data-safety forms in both consoles (FR-008)
- [ ] T025 [US3] Confirm `assets/base/config.json` third-party values per FR-009/A6: Sentry DSNs + RudderApiKey currently empty — either fill with OKR Best-owned project values or record the intentional-empty decision; set `DefaultServerUrl` only if a production server is designated (A5)
- [ ] T026 [US3] Run full CI release lanes (iOS `.ipa` via match → TestFlight; Android `.aab` via upload key → Play internal); zero manual signing steps (SC-004)
- [ ] T027 [US3] Install store-delivered builds on clean devices; re-run quickstart US1 steps 4–6 + US2 steps 1–3 (FR-012); capture evidence

**Checkpoint**: store submission ready; listings in review or live.

## Phase 6: Polish & Verification

- [ ] T028 [P] Run `npm run tsc` and `npm run fix` — both pass
- [ ] T029 [P] Update `docs/` and `README`-level references that describe app identity/build setup to the new IDs where user-facing; leave historical phase-1/2 spec docs as-is
- [ ] T030 Assemble the quickstart "Success evidence checklist" with links to T013/T014/T019/T027 evidence; mark SC-001–SC-006 pass/fail in this file
- [ ] T031 Publish tester/release communication for the identity change: existing `com.mattermost.rnbeta` installs cannot upgrade — uninstall, install O'talk, re-login (covers the "no upgrade path" edge case); include in release notes and internal announcement

## Dependencies & Execution

- **T001–T003 (Setup)** precede everything; **T002 (external accounts)** gates Phase 4/5 external tasks but NOT Phase 3.
- **US1 (T004–T014)** is repo-only and independently deliverable — MVP.
  - T004 before T005–T007 logically (same identity values) but files differ → T005/T006/T007 are [P] after T004 lands the IDs.
  - T009–T012 all [P] (different files). T013–T014 gate the story.
- **US2 (T015–T019)** requires US1 identifiers final + T002 accounts. T015/T016 [P]; T017 needs both; T018 needs T017; T019 needs T015–T018 + a US1 build.
- **US3 (T020–T027)** requires US1; T020–T022 need T002; T023 needs T020–T021; T026 needs T023 (+T024 for store upload metadata); T027 needs T026 + US2 (push on store build).
- **Cross-story**: US2 and US3's external tracks (T015–T018, T020–T022) can run in parallel with each other once US1's IDs are merged.

### Parallel opportunities

- Phase 3: `T005 T006 T007` together after T004; `T009 T010 T011 T012` together.
- Phase 4/5 externals: `T015 T016` ∥ `T020 T021 T022`.
- Polish: `T028 T029` together.

### MVP scope

User Story 1 (T001, T003–T014): a fully working `com.okrbest.otalk` app on dev signing,
scheme-compatibility analysis included — no external accounts needed. US2 then makes it
daily-driver viable; US3 makes it shippable.
