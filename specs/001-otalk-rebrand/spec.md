# Feature Specification: O'talk / OKR Best Inc User-Facing Rebrand (Phase 1)

**Feature Branch**: `001-otalk-rebrand`

**Created**: 2026-06-30

**Status**: Draft

**Input**: First-pass user-facing rebrand to OKR Best Inc (company) / O'talk (service). Scope is ONLY user-identifiable UI and information; technical identifiers are explicitly OUT. Authoritative design: `docs/superpowers/specs/2026-06-29-otalk-rebrand-user-facing-design.md`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Recognizable O'talk identity at install/launch (Priority: P1)

A person installs and opens the app. The home-screen name, app icon, and launch (splash) screen present **O'talk**, not Mattermost, so the product is immediately recognizable as O'talk.

**Why this priority**: The app name, icon, and splash are the most visible brand signals. Without them, the rebrand is not perceptible regardless of in-app text changes. This is the minimum viable slice.

**Independent Test**: Install the build on iOS and Android, view the home screen and app switcher, and launch the app — confirm the display name reads "O'talk" and the icon/splash show O'talk identity.

**Acceptance Scenarios**:

1. **Given** the app is installed, **When** the user views the device home screen and app switcher, **Then** the app name reads "O'talk" on both iOS and Android.
2. **Given** the user taps the app, **When** the launch screen appears, **Then** it shows the O'talk splash (light and dark variants where supported).

---

### User Story 2 - Consistent O'talk wording across in-app text (Priority: P2)

While using the app — onboarding, adding a server, settings, calls notifications, the ratings prompt, and share flows — the user sees the product referred to as **O'talk** rather than Mattermost, so messaging is consistent with the brand.

**Why this priority**: Reinforces the rebrand throughout the experience. Builds on P1 but is not required for the app to read as "O'talk" at first glance.

**Independent Test**: Walk through onboarding, the add-server screen, Settings, and trigger a calls notification and the ratings prompt — confirm no product-identity "Mattermost" wording remains in the in-scope strings.

**Acceptance Scenarios**:

1. **Given** a first-run user, **When** they view the onboarding welcome, **Then** the product is described as "O'talk".
2. **Given** the add-server screen, **When** it loads, **Then** the server display-name field defaults to "O'talk" (unless overridden by managed configuration or an explicitly provided name).
3. **Given** a calls notification, **When** it appears, **Then** it reads "O'talk Calls" / "O'talk".
4. **Given** the ratings prompt, **When** it appears, **Then** it reads "Enjoying O'talk?".

---

### User Story 3 - Correct legal/company info with OSS attribution preserved (Priority: P3)

A user opens the About/legal screen. They see **OKR Best Inc** as the copyright holder and **https://okr.best** as the product website, while open-source license, platform, and community attributions remain intact.

**Why this priority**: Ensures legal/company accuracy and license/trademark compliance. Lower frequency of view, but compliance-critical.

**Independent Test**: Open Settings → About and compare each line against the keep/change list in the design doc.

**Acceptance Scenarios**:

1. **Given** the About screen, **When** the user reads the copyright line, **Then** it attributes "OKR Best Inc" with the current year.
2. **Given** the About screen, **When** the user reads links/info, **Then** the product website is https://okr.best.
3. **Given** the About screen, **When** the user reads attribution text, **Then** the open-source notice, "powered by" line, and community link remain unchanged.

---

### Edge Cases

- **Long-name layout**: "O'talk" is short; confirm no layout regression where "Mattermost" was previously sized (home-screen label, calls notification title).
- **Dark mode splash**: Dark-variant splash assets must render correctly alongside light variants.
- **Mixed About screen**: The About screen intentionally contains both changed (copyright, website) and retained (OSS notice, "powered by", community) lines — verify the retained lines are not accidentally altered.
- **Managed-config override**: When MDM/managed configuration supplies a server name, it must still take precedence over the new "O'talk" default.
- **Copyright year**: With start year equal to the current year, the copyright renders a single year, not a range.
- **Apostrophe handling**: The literal apostrophe in "O'talk" must display correctly in all surfaces (notifications, native display name, JSON-escaped strings).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app's display name MUST read "O'talk" on the device home screen and app switcher on both iOS and Android. (iOS: `Mattermost` and `MattermostShare` plists; the `NotificationService` extension label is not branding and stays unchanged — see research R1.)
- **FR-002**: The app icon and launch/splash screen MUST present O'talk visual identity, including light and dark variants where the platform provides them.
- **FR-003**: All in-scope product-identity text currently referencing "Mattermost" MUST refer to "O'talk", per the mapping in the design doc (about label, onboarding welcome, add-server/extension messages, invite message, calls microphone prompt, calls notification name/title, managed-device security messages, server-upgrade message, ratings prompt).
- **FR-004**: The company/legal copyright notice MUST attribute "OKR Best Inc" with the current year.
- **FR-005**: The product website reference MUST point to https://okr.best.
- **FR-006**: The default server display name on the add-server screen MUST default to "O'talk" when not overridden by managed configuration or an explicitly provided name.
- **FR-007**: Open-source license, platform, and community attributions MUST remain unchanged — the open-source notice text, the "powered by Mattermost" line, the "Join the Mattermost community" link, and the server/mobile NOTICE URLs — to preserve license and trademark compliance.
- **FR-008**: Technical identifiers MUST NOT change in this feature: URL scheme, auth URL schemes, iOS bundle identifier, Android applicationId/package, App Group identifier, push-notification topic, and deep-link host. The `:mattermost:` emoji asset is also excluded.
- **FR-009**: Only the canonical English i18n source (`en.json`) MUST be edited; other locale files MUST NOT be modified.
- **FR-010**: The change set MUST be verified on a running app (visual confirmation of name, icon/splash, onboarding text, and About screen) and MUST pass the project type-check and lint.

### Key Entities

Not applicable — this feature changes presentation strings and assets only; it introduces no new data entities.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 0 stray product-identity "Mattermost" references remain in the in-scope user-facing surfaces (all listed product-identity strings display "O'talk").
- **SC-002**: A new user completing first-run/onboarding encounters no "Mattermost" product naming on any onboarding screen.
- **SC-003**: The About screen shows OKR Best Inc copyright and the okr.best website, while 100% of the designated open-source/platform/community attribution lines remain intact (verified line-by-line against the keep/change list).
- **SC-004**: The app display name reads "O'talk" on both iOS and Android home screens.
- **SC-005**: No regression to authentication, push notification, or deep-link behavior — all excluded technical identifiers are unchanged and existing flows continue to function.

## Assumptions

- **A1**: Product website is `https://okr.best` (confirmed).
- **A2**: `DefaultServerName` is currently blank (confirmed) and will be set to "O'talk" as the add-server display-name default.
- **A3**: Android app name becomes "O'talk" (the prior "Beta" qualifier is dropped).
- **A4**: The three OSS/platform/community strings (`settings.notice_text`, `settings.about.powered_by`, `about.teamEditionLearn`) are retained unchanged.
- **A5**: O'talk image source files (icon, splash light/dark, in-app logo) are provided during implementation; this spec fixes only the replacement points and size specifications.
- **A6**: The copyright start year is 2026 (current year); the notice renders a single `{currentYear}` rather than a range.
- **A7**: The "open source platform" wording in the onboarding welcome description is retained; only the product name is swapped.
- **A8**: Managed (MDM) configuration continues to take precedence over the "O'talk" default server name.
- **Dependency**: The authoritative per-string mapping and asset inventory live in `docs/superpowers/specs/2026-06-29-otalk-rebrand-user-facing-design.md`.
