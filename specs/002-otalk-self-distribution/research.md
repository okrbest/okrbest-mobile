# Phase 0 Research — O'talk Self-App Distribution

**Feature**: `specs/002-otalk-self-distribution` | **Date**: 2026-07-12

## R1. Android: applicationId vs Java package/namespace

- **Decision**: Change only `applicationId` to `com.okrbest.otalk` in `android/app/build.gradle`; **keep** Gradle `namespace` and the Java/Kotlin source package `com.mattermost.rnbeta` unchanged.
- **Rationale**: Android decouples store identity (`applicationId`) from code namespace (`namespace`/package). Keeping the package avoids renaming `android/app/src/main/java/com/mattermost/rnbeta/**` (MainActivity, push classes, detox test refs) and native-module registration churn — the standard white-label pattern. Store identity, data isolation, and FCM matching all key off `applicationId` only.
- **Alternatives**: full package rename — rejected (large diff, zero user-visible benefit, breaks upstream merge-ability).

## R2. iOS extension bundle-ID suffixes

- **Decision**: `com.okrbest.otalk`, `com.okrbest.otalk.NotificationService`, `com.okrbest.otalk.MattermostShare`. Keep Xcode target names (`Mattermost`, `MattermostShare`, `NotificationService`) unchanged.
- **Rationale**: iOS requires extension IDs to be prefixed by the parent app ID; suffix strings are never user-visible. Keeping target/product names avoids a high-risk `project.pbxproj` restructure and preserves upstream merge-ability. Only `PRODUCT_BUNDLE_IDENTIFIER`, entitlements, and Info.plist values change.
- **Alternatives**: rename targets to `Otalk`/`OtalkShare` — rejected this phase (pure churn; can be a later cosmetic cleanup).

## R3. Identifier inventory (repo audit, 2026-07-12)

106 references to the `com.mattermost.rnbeta` family across ~35 files (excluding node_modules/build). Groups:

| Group | Files | Action |
|---|---|---|
| iOS project | `ios/Mattermost/Info.plist`, `ios/Mattermost/Mattermost.entitlements`, `ios/MattermostShare/{Info.plist,MattermostShare.entitlements}`, `ios/NotificationService/{Info.plist,NotificationService.entitlements}`, `ios/Mattermost.xcodeproj/project.pbxproj` | replace IDs, App Group, iCloud, keychain |
| Android | `android/app/build.gradle` (`applicationId`), `android/app/google-services.json` (replace file) | change/replace |
| Android Java refs | `android/app/src/main/java/com/mattermost/**` (package decls, `rnbeta` classes) | **keep** (R1) |
| App TS | `app/screens/settings/about/about.tsx` (`MATTERMOST_BUNDLE_IDS`), `app/database/manager/index.ts`, `app/init/calls_native.test.ts`, `test/setup.ts` | review per R4 |
| fastlane | `Fastfile`, `env_vars_example`, `.env.ios.{beta,pr,release}`, `.env.android.{beta,pr,release}` | new env values (see R6) |
| detox/e2e | `detox/**` scripts + setup | update package refs for e2e runs |

## R4. `MATTERMOST_BUNDLE_IDS` code gate

- `app/screens/settings/about/about.tsx:36` — `['com.mattermost.rnbeta', 'com.mattermost.rn']` used to branch About-screen behavior for official Mattermost builds.
- **Decision**: leave the constant as-is (it correctly no longer matches us); verify the non-Mattermost branch renders correctly for O'talk (About screen already validated in phase 1). Audit `app/database/manager/index.ts` usage during implementation for the same pattern.
- **Rationale**: the gate's purpose is "is this an official Mattermost build" — for O'talk the answer is genuinely no.

## R5. URL schemes (FR-010 coupling points)

Retained this phase. Coupling inventory for the compatibility analysis deliverable:

- `assets/base/config.json`: `AuthUrlScheme: mmauth://`, `AuthUrlSchemeDev: mmauthbeta://`
- `ios/Mattermost/Info.plist`: `CFBundleURLSchemes` (`mattermost`, `mmauthbeta`)
- `android/app/src/main/AndroidManifest.xml`: `<data android:scheme="mmauthbeta"/>` (+ siblings)
- `app/constants/general.ts:39`: `DEFAULT_AUTOLINKED_URL_SCHEMES` includes `mattermost`
- Server side: SSO redirect URI allow-list must include the `mmauth(beta)://` callback — coordinated change required to ever rename these.

## R6. fastlane/CI variable map

From `fastlane/env_vars_example` (same keys in `.env.*` files):

| Variable | New value |
|---|---|
| `MAIN_APP_IDENTIFIER` | `com.okrbest.otalk` |
| `EXTENSION_APP_IDENTIFIER` | `com.okrbest.otalk.MattermostShare` |
| `MATCH_APP_IDENTIFIER` | `com.okrbest.otalk.NotificationService,com.okrbest.otalk.MattermostShare,com.okrbest.otalk` |
| `SUPPLY_PACKAGE_NAME` | `com.okrbest.otalk` |
| `IOS_APP_GROUP` | `group.com.okrbest.otalk` |
| `IOS_ICLOUD_CONTAINER` | `iCloud.com.okrbest.otalk` |
| `APP_NAME` | `O'talk` |
| match repo / API keys / keystore secrets | new OKR Best-owned values (external) |

## R7. Push chain requirements

- Android: replace `android/app/google-services.json` with the OKR Best Firebase project file whose Android app entry is `com.okrbest.otalk` (FCM silently drops mismatched packages).
- iOS: APNs Auth Key (`.p8`) from the OKR Best Apple team; the push topic = main bundle ID.
- Proxy: self-hosted `mattermost-push-proxy` configured with `ApplePushSettings.Type/BundleID=com.okrbest.otalk` + the `.p8`, and `AndroidPushSettings` with the FCM service-account credentials; server `EmailSettings.PushNotificationServer` → proxy URL.
- Smoke test: physical devices both platforms; background delivery + NotificationService content fetch.

## R8. External-account lead times (critical path)

- Apple Developer Program (org): D-U-N-S verification, days–weeks → start first.
- Google Play Console (org): identity verification, days.
- Firebase project: immediate once a Google account exists.
- Push proxy hosting: any small VM/container; needs TLS endpoint reachable by the Mattermost server.
