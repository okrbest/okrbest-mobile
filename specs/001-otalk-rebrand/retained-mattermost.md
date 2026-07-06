# Retained "Mattermost" After Phase 1 Rebrand — Locations & Rationale

**Feature**: `001-otalk-rebrand` | **Created**: 2026-06-30 | **Scope**: documents every place
the string/name **"Mattermost" stays** after this phase-1 user-facing rebrand, and why.

Companion: [asset-change-inventory.md](./asset-change-inventory.md) (what changes). Mapping
source of truth: `docs/superpowers/specs/2026-06-29-otalk-rebrand-user-facing-design.md`.

> Quick read: 3 en.json strings + 2 NOTICE URLs stay **on purpose** (OSS/license/community
> attribution), all technical identifiers stay (out of scope), internal code/target names
> stay (not user-visible). A gap found here (`share_extension.channel_error`) has since been
> **folded into the change set** — see §D.

## A. User-facing strings retained ON PURPOSE — OSS / platform / community attribution

Kept to comply with Mattermost's open-source license and trademark/attribution terms. All in
`assets/base/i18n/en.json`.

| Key | Line | Text | Why retained |
|-----|------|------|--------------|
| `about.teamEditionLearn` | L9 | "Join the Mattermost community at " | Links to the upstream open-source **community** — attribution, not our product identity. |
| `settings.about.powered_by` | L1541 | "{site} is powered by Mattermost" | Platform attribution — the server/product *is* powered by the Mattermost platform. |
| `settings.notice_text` | L1556 | "Mattermost is made possible by the open source software used in our {platform} and {mobile}." | Open-source **license notice** — legally required attribution. |

Plus, in `assets/base/config.json`:

| Key | Line | Value | Why retained |
|-----|------|-------|--------------|
| `ServerNoticeURL` | L10 | `…/mattermost/mattermost-server/blob/master/NOTICE.txt` | Points to the upstream OSS NOTICE — attribution. |
| `MobileNoticeURL` | L11 | `…/mattermost/mattermost-mobile/blob/master/NOTICE.txt` | Points to the upstream OSS NOTICE — attribution. |

> These map to spec **FR-007** and tasks **T017** (verify-unchanged).

## B. Technical identifiers retained — OUT OF SCOPE (not user-identifying)

Changing any of these breaks authentication, push, deep links, keychain/app-group sharing,
or store identity, and requires coordinated backend + store work. Deferred to a later phase
(spec **FR-008**).

| Identifier | Location | Value |
|------------|----------|-------|
| URL scheme | `app.json` `scheme` (L5) | `mattermost` |
| Auth URL schemes | `assets/base/config.json` `AuthUrlScheme` / `AuthUrlSchemeDev` | `mmauth://` / `mmauthbeta://` |
| iOS bundle identifier | `ios/Mattermost.xcodeproj/project.pbxproj` | `com.mattermost.rnbeta` (+ `.NotificationService`) |
| Android applicationId / namespace | `android/app/build.gradle` (L113 / L105) | `com.mattermost.rnbeta` |
| iOS App Group | `ios/Mattermost/Mattermost.entitlements` (L25) | `group.com.mattermost.rnbeta` |
| iOS keychain access group | `ios/Mattermost/Mattermost.entitlements` (L29) | `…com.mattermost.rnbeta` |

## C. Internal / non-user-visible retained — not in scope, not perceived by users

| Item | Location | Why retained |
|------|----------|--------------|
| Expo project `name` | `app.json` `name` (L2) = `Mattermost` | Internal project identifier (not the home-screen label; `displayName` is what changes). Tied to scheme/slug. |
| iOS target & folder names | `ios/Mattermost/`, `ios/MattermostShare/`, `ios/NotificationService/` | Xcode target/directory names — build identifiers, not shown to users. |
| iOS `NotificationService` display name | `ios/NotificationService/Info.plist` `CFBundleDisplayName` = `NotificationService` | Functional extension label (not a "Mattermost" brand string) — see research R1. |
| Native module / package names | `libraries/@mattermost/*`, `@mattermost/*` deps | Code identifiers / third-party package names. |
| `:mattermost:` emoji asset | `assets/base/images/emojis/mattermost.png` | Excluded this pass (design §4). |
| Upstream NOTICE/license files | `NOTICE.txt`, license headers | License compliance — must remain. |

## D. ✅ Resolved — string moved from retained → changed

| Key | Line | Text | Resolution |
|-----|------|------|------------|
| `share_extension.channel_error` | L1559 | "…Select another server or open **Mattermost** to join a team." | This "Mattermost" is a **product/app reference** ("open the app"). Originally omitted from the change list; now **added to task T013** (→ "open **O'talk** to join a team."). |

Product-identity strings in `en.json` changed to O'talk are therefore **14** (was 13). This
key is **no longer retained** — it is changed in implementation.

## Summary

- **Retained on purpose (user-facing)**: 3 en.json strings + 2 config NOTICE URLs (OSS/attribution).
- **Retained (technical, out of scope)**: scheme, auth schemes, bundle/app IDs, app group, keychain.
- **Retained (internal, not user-visible)**: expo `name`, iOS targets/dirs, package names, emoji, license files.
- **Resolved**: `share_extension.channel_error` moved retained → changed (now in T013); product-identity strings = 14.
