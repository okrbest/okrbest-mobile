# Contract: O'talk App Identity

Single source of truth for every identity-derived value. Any file that encodes app
identity MUST match this table exactly (FR-004 audit checks against it).

| Item | Value |
|---|---|
| iOS main bundle ID | `com.okrbest.otalk` |
| iOS NotificationService bundle ID | `com.okrbest.otalk.NotificationService` |
| iOS Share extension bundle ID | `com.okrbest.otalk.MattermostShare` |
| iOS App Group | `group.com.okrbest.otalk` |
| iOS iCloud container | `iCloud.com.okrbest.otalk` |
| iOS keychain access group | `$(AppIdentifierPrefix)com.okrbest.otalk` |
| APNs push topic | `com.okrbest.otalk` |
| Android `applicationId` | `com.okrbest.otalk` |
| Android Gradle `namespace` / Java package | `com.mattermost.rnbeta` (unchanged — research R1) |
| FCM package registration | `com.okrbest.otalk` |
| Display name | `O'talk` (phase 1) |
| URL schemes | `mattermost`, `mmauth://`, `mmauthbeta://` (unchanged this phase — FR-010) |

## Invariants

1. Extension bundle IDs are prefixed by the main bundle ID (iOS requirement).
2. The push proxy's `BundleID`/package config, the APNs topic, and the FCM package MUST
   equal the values above — any mismatch = silent push failure.
3. Xcode target names and the Android Java package are cosmetic internals and stay
   Mattermost-named to minimize churn (research R1/R2); they carry no user-facing or
   store-facing identity.
4. `com.mattermost.rnbeta`-family strings may remain ONLY in: Android
   namespace/package (invariant 3), the `MATTERMOST_BUNDLE_IDS` gate constant (R4),
   historical docs, and upstream test fixtures explicitly listed by the FR-004 audit.
