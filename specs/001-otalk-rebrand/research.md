# Phase 0 Research: O'talk / OKR Best Inc User-Facing Rebrand

## R1 — iOS display-name targets (corrected)

**Decision**: Change `CFBundleDisplayName` to `O'talk` in **two** plists only:
`ios/Mattermost/Info.plist` (currently `Mattermost Beta`) and
`ios/MattermostShare/Info.plist` (currently `Mattermost`).

**Do NOT change** `ios/NotificationService/Info.plist` — its `CFBundleDisplayName` is
`NotificationService`, a functional extension label, not Mattermost branding. Renaming it
would mislabel the extension without any brand benefit.

**Rationale**: Verified actual values via grep. The spec's FR-001 originally listed three
plists; this research narrows it to the two that actually carry the brand name.

**Alternatives considered**: Renaming all three — rejected (NotificationService is not a
brand string).

## R2 — Apostrophe escaping for "O'talk" across formats

**Decision**: Store the brand string per each format's escaping rules:
- `en.json` / `config.json` (JSON): `O'talk` — apostrophe is a literal character, no escaping needed.
- iOS `Info.plist` (XML): `O'talk` — apostrophe is valid in XML text content, no entity needed.
- Android `strings.xml`: must escape as `O\'talk` (or wrap value in double quotes), otherwise Android resource compilation fails on the unescaped apostrophe.

**Rationale**: Android AAPT treats `'` as a special character in string resources.

**Alternatives considered**: Using a typographic apostrophe (U+2019) — rejected; keep ASCII
`'` for consistency with the brand spelling "O'talk".

## R3 — Android app name / flavors

**Decision**: Single `android/app/src/main/res/values/strings.xml` holds
`app_name = "Mattermost Beta"`; no flavor-specific `strings.xml` overrides were found.
Change to `O'talk` (drop "Beta"), escaped per R2.

**Rationale**: Searched all `strings.xml` under `android/app/src`; only one match.

## R4 — `config.json` WebsiteURL / DefaultServerName

**Decision**: Change `WebsiteURL` `https://mattermost.com` → `https://okr.best`; set
`DefaultServerName` `""` → `O'talk`. These are read by the app's config loader
(`LocalConfig`); `DefaultServerName` is consumed at `app/screens/server/index.tsx:99` as the
add-server display-name fallback (after managed config and any explicitly provided name).

**Verification point (implement)**: Confirm the About-screen "website/learn more" surface
reflects `WebsiteURL` and that no separate hard-coded `mattermost.com` powers that link
(the only `mattermost.com` hits in `app/` are test-fixture emails, not the website link).

**Rationale**: Localized config values; low blast radius.

## R5 — Image asset generation

**Decision**: User provides O'talk master source files at implementation time:
- App icon master (1024×1024, no alpha for iOS).
- Splash logo (light + dark).
- In-app logo for `assets/base/images/logo.png` (+ `icon.png`).

From those, generate the required per-resolution slots:
- iOS `AppIcon.appiconset` (all sizes in the set's Contents.json).
- iOS `SplashIcon.imageset` light/dark @2x/@3x and `SplashBackground.imageset`.
- Android `mipmap-*/ic_launcher.png`, `ic_launcher_round.png`, `ic_launcher_foreground.png`, `ic_launcher_background.png` across densities, plus the `mipmap-anydpi-v26` adaptive icon XML (reuse existing foreground/background structure).
- Android splash drawables incl. `drawable-night-*` dark variants.
- Regenerate from the `assets/base/release/splash_screen/` source pipeline where present.

**Rationale**: Single source-of-truth masters resized to platform slots avoids per-slot
hand-editing and keeps light/dark parity.

**Alternatives considered**: Placeholder generation now — rejected by the user (real source
files will be supplied).

## R6 — Copyright string

**Decision**: `settings.about.copyright` →
`Copyright {currentYear} OKR Best Inc. All rights reserved` (single year; start year 2026
equals current year, so no range). `{currentYear}` interpolation is already supported by
the existing message.

## Open items

None blocking. R4's About-screen website wiring is a verification point during implement,
not a clarification.
