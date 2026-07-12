# Feature Specification: O'talk Self-App Distribution (Phase 2)

**Feature Branch**: `002-otalk-self-distribution`

**Created**: 2026-07-12

**Status**: Draft

**Input**: Distribute O'talk as OKR Best Inc's own self-published app. Phase 1 (`001-otalk-rebrand`) changed user-facing identity only; this phase swaps the technical identity (bundle/package IDs, entitlements), signing, push infrastructure, store presence, third-party config, and CI wiring. Scoping source: [phase-2-self-app-distribution.md](../001-otalk-rebrand/phase-2-self-app-distribution.md). Decided: bundle ID `com.okrbest.otalk`; single spec; URL schemes retained (see FR-010).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - O'talk runs as its own app identity (Priority: P1)

A developer builds the app and installs it on a device. The installed app is `com.okrbest.otalk` — a fully independent app that coexists with any installed Mattermost app, with its own data directory, share extension, and notification service extension all working under the new identity.

**Why this priority**: Every other workstream (signing, push, store) keys off the final bundle/package ID. The rename is self-contained and verifiable in development without any external account, so it unblocks the rest while accounts are being provisioned.

**Independent Test**: Build and install on iOS simulator + Android emulator. Verify app installs under the new ID, launches, logs into a server, share extension shares into the app, and (Android) the app appears with its own identity in system settings.

**Acceptance Scenarios**:

1. **Given** a device with the Mattermost app installed, **When** O'talk is installed, **Then** both apps coexist as separate apps with separate data.
2. **Given** the O'talk build, **When** inspecting the installed package, **Then** iOS bundle IDs are `com.okrbest.otalk` plus derived extension IDs, and Android `applicationId` is `com.okrbest.otalk`.
3. **Given** a logged-in O'talk session, **When** the user shares a photo from the system share sheet into O'talk, **Then** the share extension opens, lists the user's channels, and posts successfully (shared App Group storage works under `group.com.okrbest.otalk`).
4. **Given** the app is running, **When** a `mattermost://` deep link or `mmauth://` SSO redirect fires, **Then** it is handled by O'talk exactly as before (schemes unchanged this phase).

---

### User Story 2 - Push notifications arrive through OKR Best infrastructure (Priority: P2)

A user with the O'talk app in the background receives push notifications (messages, mentions, calls) delivered through OKR Best Inc's own push pipeline — Firebase project, APNs key, and self-hosted push proxy — with no dependency on Mattermost's hosted push service.

**Why this priority**: Push is the longest lead-time item (external accounts + a new backend service) and the most fragile: any mismatch between proxy, APNs/FCM credentials, and the new bundle IDs makes push fail silently. Without it the app is not viable for daily use, but it depends on US1's identifiers being final.

**Independent Test**: With an internal (non-store) build on a physical device, background the app, send a message from another account, and verify the notification arrives on both iOS and Android; verify the notification service extension fetches and renders message content.

**Acceptance Scenarios**:

1. **Given** the app is backgrounded on Android, **When** another user posts a mention, **Then** a push notification arrives via the OKR Best Firebase project.
2. **Given** the app is backgrounded on iOS, **When** another user posts a direct message, **Then** a push notification arrives via APNs using OKR Best credentials, and the notification service extension fetches and displays the message content.
3. **Given** the server's push settings point at the OKR Best push proxy, **When** the proxy or credentials are misconfigured, **Then** the failure is observable (proxy logs/server logs), not silent — a documented smoke-test procedure exists to verify the chain end-to-end.

---

### User Story 3 - Installable release through OKR Best store presence (Priority: P3)

An end user finds O'talk on the App Store / Google Play under OKR Best Inc's publisher name and installs a signed release build. Internal testers receive builds through TestFlight / Play internal testing lanes driven by CI.

**Why this priority**: Store presence is the final delivery step; it needs US1 (identity) and US2 (push) complete, plus signing and CI. It has external review lead time but little engineering risk.

**Independent Test**: A release-signed build uploads successfully to TestFlight and Play internal testing via the existing fastlane lanes; store listings display O'talk branding and OKR Best Inc as the publisher.

**Acceptance Scenarios**:

1. **Given** OKR Best signing credentials, **When** CI runs the iOS/Android release lanes, **Then** signed artifacts are produced for `com.okrbest.otalk` without manual signing steps.
2. **Given** the signed artifacts, **When** uploaded, **Then** App Store Connect / Play Console accept them under the OKR Best Inc apps (correct team/publisher, new app records).
3. **Given** the store listings, **When** a user views them, **Then** name, icon, screenshots, and privacy labels reflect O'talk / OKR Best Inc.

---

### Edge Cases

- **No upgrade path**: existing installs under `com.mattermost.rnbeta` cannot upgrade to `com.okrbest.otalk` — testers must reinstall and re-login; communicate this explicitly.
- **App Group data relocation**: the shared database directory moves with the App Group ID; a fresh install has no old data to migrate, but any stale-identifier reference (e.g., hardcoded `group.com.mattermost.rnbeta`) would silently split app and extension storage — the rename must be exhaustive, verified by repo-wide identifier audit.
- **Keychain access group change**: stored credentials are namespaced by team + bundle ID; re-login after install is expected, not a bug.
- **Push token/bundle mismatch**: APNs rejects tokens for the wrong bundle ID with generic errors; the smoke test must include both platforms, foreground token registration, and background delivery.
- **Scheme collision deferred**: keeping `mattermost://`/`mmauth://` means an installed Mattermost app on the same device may intercept links; acceptable this phase, documented in the compatibility analysis (FR-010).
- **`MATTERMOST_BUNDLE_IDS` gate**: app code special-cases official Mattermost bundle IDs (e.g., `app/screens/settings/about`); behavior for non-Mattermost IDs must be reviewed so nothing user-visible breaks.
- **Sentry/analytics blackout**: if new DSN/keys are not ready at cutover, crash reporting silently stops; config must either fail visibly or ship intentionally empty (decision recorded in A6).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The iOS app MUST use bundle ID `com.okrbest.otalk` for the main target and derived IDs for the NotificationService and Share extension targets, with matching provisioning entitlements.
- **FR-002**: iOS entitlements MUST move to the new namespace — App Group `group.com.okrbest.otalk`, iCloud container `iCloud.com.okrbest.otalk`, keychain access group — consistently across all three targets, and the app + share extension MUST share storage through the new App Group.
- **FR-003**: The Android app MUST use `applicationId` (and Gradle `namespace` where applicable) `com.okrbest.otalk`.
- **FR-004**: A repo-wide identifier audit MUST show zero remaining functional references to the `com.mattermost.rnbeta`/`com.mattermost.rn` identity family (bundle IDs, App Group, iCloud container, push topics) outside documented, intentional exceptions (e.g., historical docs).
- **FR-005**: Release signing MUST use OKR Best Inc credentials: Apple certificates/profiles for the three new bundle IDs, and a new Android upload keystore enrolled in Play App Signing. No Mattermost-owned credential may remain in the pipeline.
- **FR-006**: Android push MUST use an OKR Best-owned Firebase project (replacing `google-services.json`); iOS push MUST use an APNs key from the OKR Best Apple account.
- **FR-007**: A push proxy owned by OKR Best MUST be configured with the new APNs/FCM credentials and new bundle/package IDs, and the target server(s) MUST point at it; an end-to-end push smoke-test procedure (both platforms, background delivery) MUST be documented and pass.
- **FR-008**: Store records MUST exist under OKR Best Inc in App Store Connect and Google Play Console with O'talk metadata, screenshots, and privacy labels; release/beta lanes MUST upload to them.
- **FR-009**: Third-party service config in the bundled app config (Sentry DSNs, analytics key, default server URL) MUST be either replaced with OKR Best-owned values or explicitly emptied — no Mattermost-owned endpoint may receive O'talk telemetry.
- **FR-010**: URL schemes (`mattermost://`, `mmauth://`, `mmauthbeta://`) MUST remain unchanged this phase, and a compatibility analysis document MUST enumerate every coupling between these schemes and server-side configuration (SSO redirect URIs, deep-link host, notice links) so a future coordinated app+server scheme change can be planned safely.
- **FR-011**: CI/fastlane configuration MUST be updated for the new identity (app identifiers, App Group, iCloud container, package name, match repo, store credentials) with all Mattermost-era secrets rotated out; a full CI release run MUST succeed without manual intervention.
- **FR-012**: The release candidate MUST pass on-device verification — install, login, share-extension post, deep link open, and background push receipt on both platforms — before store submission.

### Key Entities

- **App identity**: iOS bundle ID triple + Android applicationId, plus derived namespaces (App Group, iCloud container, keychain group, push topics). Single source of decision: `com.okrbest.otalk`.
- **Signing credential set**: Apple team certificates/profiles per bundle ID; Android upload keystore + Play App Signing key — owned by OKR Best Inc accounts.
- **Push credential chain**: FCM project → `google-services.json`; APNs key → push proxy config → server push endpoint. All links must agree on the app identity.
- **Store listing**: per-platform app record (metadata, screenshots, privacy labels, publisher identity).
- **Remote/third-party config**: Sentry DSNs, analytics key, default server URL in the bundled config.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A clean device install of the release build coexists with the Mattermost app, and 100% of the smoke-test flows (install, login, share-extension post, deep link, background push on iOS + Android) pass.
- **SC-002**: Push notifications are delivered end-to-end through OKR Best infrastructure on both platforms, with the Mattermost-hosted push service absent from the delivery chain.
- **SC-003**: Repo identifier audit reports 0 functional `com.mattermost.rnbeta`/`rn` references outside documented exceptions.
- **SC-004**: A CI-triggered release produces store-accepted signed artifacts for both platforms under OKR Best Inc publisher accounts, with no manual signing steps.
- **SC-005**: Store listings live (or in review) with O'talk branding; internal testers can install via TestFlight / Play internal track.
- **SC-006**: The URL-scheme compatibility analysis exists and lists every app↔server coupling point, reviewed against the dev server (`dev.okrbest.com`) configuration.

## Assumptions

- **A1**: Bundle/package ID is `com.okrbest.otalk` (decided). iOS extension target IDs follow the `com.okrbest.otalk.<TargetName>` pattern; exact suffixes finalized during planning.
- **A2**: URL schemes stay `mattermost://`/`mmauth://`/`mmauthbeta://` this phase (decided) — they are app↔server protocol contracts; changing them requires coordinated server-side SSO/redirect changes, out of scope here (FR-010 documents the coupling for a later phase).
- **A3**: OKR Best Inc provisions the external accounts (Apple Developer Program, Google Play Console, Firebase). Account creation is outside the repo but on the critical path; tasks will mark these as external blockers.
- **A4**: The push proxy is the standard self-hosted Mattermost Push Proxy (per repo docs: "Self-compiled apps require your own Mattermost Push Notification Service"); its deployment target is chosen during planning.
- **A5**: `DefaultServerUrl` remains unset unless OKR Best designates a production server; `dev.okrbest.com` is used for verification only.
- **A6**: Sentry/analytics: if OKR Best-owned projects are not ready at implementation time, keys ship empty (telemetry off) rather than pointing at Mattermost-owned projects.
- **A7**: No user-data migration from Mattermost-identified installs is required (new app, fresh installs only).
- **A8**: Phase 1 user-facing branding (name, icons, i18n) is complete and carries over unchanged.

## Dependencies

- Phase 1 rebrand complete (`001-otalk-rebrand`).
- External accounts: Apple Developer Program membership, Google Play Console account, Firebase project — longest lead time, start first.
- A reachable Mattermost server whose push settings the team controls (e.g., `dev.okrbest.com`) for end-to-end push verification.
- Scoping source document: [phase-2-self-app-distribution.md](../001-otalk-rebrand/phase-2-self-app-distribution.md).
