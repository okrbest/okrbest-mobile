# Asset Change Inventory — Files to Replace for O'talk Rebrand (Phase 1)

**Feature**: `001-otalk-rebrand` | **Created**: 2026-06-30

Exact image files that must be replaced with O'talk artwork, by platform. Companion:
[retained-mattermost.md](./retained-mattermost.md). Covers tasks **T008–T012**.

> **Source files needed from user** (research R5): app-icon master (1024×1024, no alpha),
> splash logo (light + dark), in-app logo. All per-resolution files below are generated from
> those masters.

## 1. iOS — App icon · `ios/Mattermost/Images.xcassets/AppIcon.appiconset/` (T008)

Replace all PNGs; keep `Contents.json` slot mapping.

```
20.png  20@2x.png  20@3x.png
29.png  29@2x.png  29@3x.png
40.png  40@2x.png  40@3x.png
76.png  76@2x.png  83.5@2x.png
Icon-60@2x.png  Icon-60@3x.png
iTunesArtwork@2x.png        # 1024 App Store artwork
Contents.json               # keep (slot map) — do not delete
```

## 2. iOS — Splash · `ios/Mattermost/Images.xcassets/` (T010)

```
SplashIcon.imageset/
  SplashIcon.png  SplashIcon@2x.png  SplashIcon@3x.png            # light
  SplashIcon_Dark.png  SplashIcon_Dark@2x.png  SplashIcon_Dark@3x.png  # dark
  Contents.json                                                   # keep
SplashBackground.imageset/
  SplashBackground.png  SplashBackground@2x.png  SplashBackground@3x.png         # light
  SplashBackgroundDark.png  SplashBackgroundDark@2x.png  SplashBackgroundDark@3x.png  # dark
  Contents.json                                                   # keep
```

> `SplashBackgroundColor.colorset` (brand background color) — review/adjust if O'talk brand
> color differs; otherwise leave.

## 3. Android — Launcher icon · `android/app/src/main/res/mipmap-*/` (T009)

Replace PNGs across **all 5 densities** (`mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi`):

```
mipmap-<density>/ic_launcher.png
mipmap-<density>/ic_launcher_round.png
mipmap-<density>/ic_launcher_foreground.png   # adaptive icon foreground
mipmap-<density>/ic_launcher_background.png   # adaptive icon background
```

Adaptive-icon XML (review references; usually no change unless layer names differ):

```
mipmap-anydpi-v26/ic_launcher.xml
mipmap-anydpi-v26/ic_launcher_round.xml
```

## 4. Android — Splash · `android/app/src/main/res/drawable*/` (T011)

Replace PNGs across light densities **and** `drawable-night-*` dark variants
(`mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi` each):

```
drawable-<density>/splash.png
drawable-<density>/splash_background.png
drawable-night-<density>/splash.png
drawable-night-<density>/splash_background.png
```

XML (review; usually no change): `drawable/launch_screen.xml`. Brand colors:
`values/colors.xml`, `values-night/colors.xml` (adjust if O'talk color differs).

## 5. In-app logo · `assets/base/images/` (T012)

```
assets/base/images/logo.png    # login / server-connection screen logo (~32 KB current)
assets/base/images/icon.png    # in-app small icon (~3.5 KB current)
```

## 6. Shared source pipeline · `assets/base/release/splash_screen/` (regenerate)

This tree is the **source** that feeds the native splash assets above. Update it in sync so
release regeneration doesn't reintroduce old artwork:

```
assets/base/release/splash_screen/ios/
  SplashIcon.imageset/*  SplashBackground.imageset/*  splash.png  LaunchScreen.storyboard
assets/base/release/splash_screen/android/
  drawable-<density>/splash.png + splash_background.png
  drawable-night-<density>/splash.png + splash_background.png
  layout/launch_screen.xml  values/colors.xml  values-night/colors.xml  values/styles.xml
```

> Note: `ic_notif_action_reply.png` under this tree is a notification action icon, **not
> branding** — leave it unless intentionally restyled.

## NOT changed (excluded)

- `assets/base/images/emojis/mattermost.png` — `:mattermost:` emoji, out of scope (design §4).
- `ios/NotificationService/*`, `ios/MattermostShare/*` icons (if any) beyond display name — no brand icons there.
- Notification small icons / `ic_notif_*` — functional, not brand.

## Counts (per master → generated)

| Group | Files | Task |
|-------|-------|------|
| iOS app icon | 15 PNG (+Contents.json kept) | T008 |
| iOS splash | 12 PNG (6 icon + 6 bg, light+dark) | T010 |
| Android launcher | 20 PNG (4 × 5 densities) + 2 XML review | T009 |
| Android splash | 20 PNG (2 × 10 density/night) + XML/colors | T011 |
| In-app logo | 2 PNG | T012 |
| Shared source | mirrors of iOS+Android splash | regenerate |
