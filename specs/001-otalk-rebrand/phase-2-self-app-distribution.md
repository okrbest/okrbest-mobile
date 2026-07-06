# Phase 2 Review — O'talk Self-App Distribution (Technical Identity + Infra)

**Feature area**: `001-otalk-rebrand` (forward-looking) | **Created**: 2026-07-06
**Status**: Recommendation / scoping notes (not yet a spec-kit spec)

Companion to phase 1: [spec.md](./spec.md), [retained-mattermost.md](./retained-mattermost.md),
[asset-change-inventory.md](./asset-change-inventory.md). Phase 1 changed only user-facing
UI/text/assets and **intentionally deferred** all technical identifiers. This document scopes
the work required to ship O'talk as **OKR Best Inc's own app** (own store listings, signing,
push), i.e. everything phase 1 excluded.

## Why this is a separate phase

Self-app distribution is not string replacement — it swaps **identity + auth + push + store**.
Changing the bundle/package ID produces a brand-new app (no upgrade path from the current
Mattermost-beta identifiers), and per `CLAUDE.md`: **"Self-compiled apps require your own
Mattermost Push Notification Service."**

## Workstreams

### A. Identifier renaming (code) — mechanical once IDs are decided
Current identifier `com.mattermost.rnbeta` (+ `.NotificationService`, `.MattermostShare`) is
used across:
- iOS bundle IDs (3 targets) + entitlements: `ios/Mattermost/Mattermost.entitlements`
  (App Group `group.com.mattermost.rnbeta`, iCloud `iCloud.com.mattermost.rnbeta`, keychain),
  `ios/NotificationService/*`, `ios/MattermostShare/*`, `ios/Mattermost.xcodeproj/project.pbxproj`
- Android `applicationId` / `namespace`: `android/app/build.gradle`
- URL scheme / deep link: `mattermost`, `mmauth://`, `mmauthbeta://` → `ios/Mattermost/Info.plist`,
  `android/app/src/main/AndroidManifest.xml`, `assets/base/config.json`, `app.json`
- **Decision needed**: final bundle/app ID (e.g. `best.okr.otalk` or `com.okrbest.otalk`).

### B. Signing & provisioning (external accounts)
- Apple: **OKR Best Inc developer account** + `match` certs/profiles for the new bundle IDs
  (`fastlane/Matchfile`, `MATCH_APP_IDENTIFIER`).
- Android: new **upload keystore** + Play App Signing enrollment.

### C. Push infrastructure ⚠️ long pole (longest lead time)
- Android FCM: OKR Best Firebase project → **new `android/app/google-services.json`**.
- iOS APNs: APNs key under the OKR Best Apple account.
- **Self-hosted Mattermost Push Proxy** configured with the new APNs/FCM credentials and the
  new bundle/package IDs. Without this, push does not work.

### D. Store listings
- New **App Store Connect** app + **Google Play Console** app under OKR Best Inc accounts.
- Metadata & screenshots (`fastlane/metadata`, `fastlane/screenshots`), privacy labels, review.

### E. Third-party / config
- `SentryDsnIos` / `SentryDsnAndroid`, `RudderApiKey`, and (if an O'talk server exists)
  `DefaultServerUrl` — `assets/base/config.json`.

### F. CI / Fastlane wiring
- Update `fastlane/env_vars_example`-derived config: `APP_NAME`, `MATCH_APP_IDENTIFIER`,
  `SUPPLY_PACKAGE_NAME`, `IOS_APP_GROUP`, `IOS_ICLOUD_CONTAINER`, etc.; rotate CI secrets;
  point `match` repo at the new certs.

## Recommended order (critical path)

1. **Provision external accounts first** (Apple Developer, Play Console, Firebase — approval
   lead time) and **stand up the push proxy** — these are the long poles; start now.
2. **Decide bundle/app ID** → do **A (code rename)** (can run parallel to accounts).
3. **B (signing)** once accounts exist → **F (CI/env)**.
4. Internal test build: verify **push, deep links, SSO login, share extension, notifications**.
5. Store submission (**D**).

## Risks

- **New app identity**: bundle/package ID change = brand-new app; no upgrade from Mattermost
  beta (testers reinstall).
- **App Group / iCloud change**: affects the shared DB directory and the share extension.
- **Scheme / `mmauth` change**: must match the server's SSO redirect configuration exactly.
- **Push alignment**: proxy + APNs/FCM + bundle IDs must all match or push silently fails.

## Recommendation

Decompose into two specs and run through the standard workflow (brainstorming → spec-kit),
since bundle-ID / account / server-policy decisions are ambiguous and need the user:

- **Phase 2a — identifier rename (code)**: self-contained, verifiable in dev without stores.
- **Phase 2b — infra (signing, push, store)**: external-account and backend dependent.

Entry point: `superpowers:brainstorming` to settle the decisions (final ID, accounts, server
policy), then `/speckit-specify` per sub-phase.
