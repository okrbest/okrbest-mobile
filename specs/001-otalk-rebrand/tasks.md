# Tasks: O'talk / OKR Best Inc User-Facing Rebrand (Phase 1)

**Feature**: `specs/001-otalk-rebrand` | **Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

**Tests**: Not generated — this is a presentation-only change (strings, config values, image
assets) with no logic under unit test. Verification is via static checks + on-device mobile
MCP (see [quickstart.md](./quickstart.md)). Authoritative mapping:
`docs/superpowers/specs/2026-06-29-otalk-rebrand-user-facing-design.md`.

**Apostrophe rule (research R2)**: JSON & iOS plist use literal `O'talk`; Android
`strings.xml` must escape as `O\'talk`.

## Phase 1: Setup

- [x] T001 Ensure work is on a dedicated implementation branch for `001-otalk-rebrand` (branch off current `main`)
- [x] T002 Obtain O'talk image source files from the user and stage them: app-icon master (1024×1024, no alpha), splash logo (light + dark), in-app logo — required before Phase 3 asset tasks
- [x] T003 [P] Capture baseline: grep in-scope "Mattermost" occurrences (`assets/base/i18n/en.json`, native display-name files, `assets/base/config.json`) to confirm the exact change set vs the design doc

## Phase 2: Foundational

_No blocking foundational work — the three user stories are independent. Proceed to Phase 3._

## Phase 3: User Story 1 — Recognizable O'talk identity at launch (P1) 🎯 MVP

**Goal**: Home-screen name, app icon, and splash present O'talk on iOS + Android.

**Independent test**: Install build, view home screen/app switcher and launch — name reads "O'talk", icon/splash show O'talk (light + dark).

### Display name

- [x] T004 [P] [US1] Set `displayName` to `O'talk` in `app.json`
- [x] T005 [P] [US1] Set `CFBundleDisplayName` to `O'talk` in `ios/Mattermost/Info.plist`
- [x] T006 [P] [US1] Set `CFBundleDisplayName` to `O'talk` in `ios/MattermostShare/Info.plist` (do NOT touch `ios/NotificationService/Info.plist` — research R1)
- [x] T007 [P] [US1] Set `app_name` to `O\'talk` (escaped) in `android/app/src/main/res/values/strings.xml`

### App icon

- [x] T008 [US1] Generate all sizes and replace `ios/Mattermost/Images.xcassets/AppIcon.appiconset/*` from the O'talk master (match the set's `Contents.json` slots)
- [x] T009 [P] [US1] Replace Android launcher icons in `android/app/src/main/res/mipmap-*/` (`ic_launcher.png`, `ic_launcher_round.png`, `ic_launcher_foreground.png`, `ic_launcher_background.png`) and verify `mipmap-anydpi-v26/*.xml` adaptive icon references

### Splash

- [x] T010 [US1] Replace iOS `ios/Mattermost/Images.xcassets/SplashIcon.imageset/*` (light/dark @2x/@3x) and `SplashBackground.imageset/*`; regenerate from `assets/base/release/splash_screen/` source where used
- [x] T011 [P] [US1] Replace Android splash drawables under `android/app/src/main/res/drawable*/` (including `drawable-night-*` dark variants)

### In-app logo

- [x] T012 [P] [US1] Replace `assets/base/images/logo.png` and `assets/base/images/icon.png` with O'talk artwork

**Checkpoint**: Build runs; home-screen name = O'talk; icon + splash show O'talk (light/dark).

## Phase 4: User Story 2 — Consistent O'talk wording in-app (P2)

**Goal**: Product-identity text says O'talk, not Mattermost.

**Independent test**: Walk onboarding, add-server, Settings, calls notification, ratings prompt — no product "Mattermost" wording in in-scope strings.

- [x] T013 [US2] In `assets/base/i18n/en.json`, change product-identity values to `O'talk` for keys: `about.mattermost`, `about.planNameLearn`, `extension.no_memberships.description`, `extension.no_servers.description`, `invite_people_to_team.message`, `mobile.calls_mic_error`, `mobile.calls.foreground_service.channel_name` ("O'talk Calls"), `mobile.calls.foreground_service.title`, `mobile.managed.not_secured.android`, `mobile.managed.not_secured.ios`, `mobile.server_upgrade.description`, `onboaring.welcome_description` (keep "open source platform" wording), `rate.title` ("Enjoying O'talk?"), `share_extension.channel_error` ("…open **O'talk** to join a team.")
- [x] T014 [US2] Set `DefaultServerName` to `O'talk` in `assets/base/config.json`

**Checkpoint**: Onboarding/add-server/calls/rating all read O'talk.

## Phase 5: User Story 3 — Correct legal/company info, OSS attribution preserved (P3)

**Goal**: OKR Best Inc copyright + okr.best website; OSS attributions intact.

**Independent test**: Open Settings → About; copyright = OKR Best Inc, website = okr.best, OSS/community lines unchanged.

- [x] T015 [US3] In `assets/base/i18n/en.json`, set `settings.about.copyright` to `Copyright {currentYear} OKR Best Inc. All rights reserved`
- [x] T016 [US3] Set `WebsiteURL` to `https://okr.best` in `assets/base/config.json`
- [x] T017 [US3] Verify retained-unchanged: `settings.notice_text`, `settings.about.powered_by`, `about.teamEditionLearn` in `en.json` and `ServerNoticeURL`/`MobileNoticeURL` in `config.json` are NOT modified

**Checkpoint**: About screen shows OKR Best Inc + okr.best; OSS lines preserved.

## Phase 6: Polish & Verification

- [x] T018 [P] Run `npm run tsc` — type-check passes
- [x] T019 [P] Run `npm run fix` — lint passes
- [x] T020 Guard review on `git diff`: zero in-scope product "Mattermost" references remain; only `en.json` among `assets/base/i18n/`; technical identifiers (scheme, bundle/app IDs, package, App Group, push topic, deep-link host) and `:mattermost:` emoji untouched
- [ ] T021 Mobile MCP on-device verification per `quickstart.md` steps 1–8; capture screenshots for steps 1, 2, 3, 6 as completion evidence

## Dependencies & Execution

- **Setup (T001–T003)** precedes everything. T002 (asset files) blocks Phase 3 asset tasks (T008–T012) but not display-name (T004–T007).
- **User stories are independent** and can be delivered in priority order. US1 = MVP.
- **Shared-file ordering**: T013 & T015 both edit `en.json` → run sequentially (US2 before US3). T014 & T016 both edit `config.json` → run sequentially. These are the only intra-feature ordering constraints.
- **Parallel opportunities**: display-name tasks T004/T005/T006/T007 (different files) are `[P]`; Android asset tasks (T009, T011, T012) are `[P]` with iOS asset tasks (T008, T010); final checks T018/T019 are `[P]`.

### MVP scope
User Story 1 (T001–T012) — delivers a recognizably O'talk app (name + icon + splash). US2 and US3 layer in text and legal/OSS correctness.
