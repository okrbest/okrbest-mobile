# URL Scheme Compatibility Analysis (FR-010)

**Feature**: `002-otalk-self-distribution` | **Date**: 2026-07-12 | **Status**: schemes RETAINED this phase

Why retained: `mmauth(beta)://` is the SSO **redirect contract between app and server** — the
server redirects the completed SSO login back to the app via this scheme. Renaming app-side
only breaks SSO login. A rename requires a coordinated app+server change (tracked here for a
future phase).

## 1. App-side declarations (where the schemes live)

| Location | Declaration | Role |
|---|---|---|
| `app.json:5` | `"scheme": "mattermost"` | expo-router deep-link scheme |
| `ios/Mattermost/Info.plist:28-38` | `CFBundleURLName com.mattermost`; `CFBundleURLSchemes [mattermost, mmauthbeta]` | iOS URL handling registration |
| `android/app/src/main/AndroidManifest.xml:84-95` | intent-filters `android:scheme="mattermost"`, `android:scheme="mmauthbeta"` | Android URL handling registration |
| `assets/base/config.json:2-3` | `AuthUrlScheme: mmauth://`, `AuthUrlSchemeDev: mmauthbeta://` | SSO redirect scheme source of truth (bundled config) |

## 2. App-side consumers (code that uses them)

| Location | Usage |
|---|---|
| `app/constants/sso.ts:7-8` | exports `REDIRECT_URL_SCHEME(_DEV)` from LocalConfig |
| `app/screens/sso/sso_authentication.tsx:41-43` | builds the SSO login redirect URL handed to the server |
| `app/screens/sso/sso_authentication_with_external_browser.tsx:68-70` | same, external-browser flow |
| `app/routes/+native-intent.ts:27` | routes incoming `mmauth(beta)://` URLs back into the SSO flow |
| `app/constants/general.ts:39` | `DEFAULT_AUTOLINKED_URL_SCHEMES` includes `mattermost` (markdown autolinking) |

## 3. Server-side couplings (outside this repo)

| Coupling | Detail |
|---|---|
| SSO redirect acceptance | The Mattermost server's OAuth/SAML/OpenID flow redirects to `mmauth(beta)://callback…`. Server (and any IdP redirect-URI allow-list) must accept the scheme the app sends. Today the app sends `mmauth://` (prod builds) / `mmauthbeta://` (dev) regardless of our new bundle ID — works unchanged. |
| Deep links from server content | Server-rendered links (email notifications, in-product links) may use `mattermost://` scheme URLs. Any scheme rename must be mirrored wherever the server/IdP emits them. |
| Native intent registration mismatch risk | iOS registers `mmauthbeta` but NOT `mmauth` in `CFBundleURLSchemes` (upstream beta build); Android likewise only `mmauthbeta`. Prod SSO flows that use `AuthUrlScheme (mmauth://)` rely on build-flavor plist/manifest adjustments in release lanes — verify during T026/T027 that release artifacts register `mmauth`. |

## 4. Device-level collision (accepted risk this phase)

Custom schemes are first-come/ambiguous when multiple installed apps register the same
scheme. With the official Mattermost app installed alongside O'talk:

- iOS: which app opens `mattermost://` is undefined (OS picks one).
- Android: user sees an app-chooser (disambiguation dialog).

Impact: cosmetic/UX only; SSO still completes in whichever app initiated it on iOS ≥
(callback returns to the initiating flow via the browser session, but scheme hijack is
theoretically possible). Accepted for internal/beta phase; resolved permanently by the
future rename.

## 5. Future coordinated rename plan (out of scope now)

1. Choose new schemes (e.g., `otalk://`, `otalk-auth://`, `otalk-authdev://`).
2. App: update the four declaration sites (§1) + keep OLD schemes registered in parallel
   for one transition release.
3. Server/IdP: add new redirect URIs to allow-lists BEFORE shipping the app change; emit
   `otalk://` links in server content where applicable.
4. Ship app accepting both; flip `AuthUrlScheme` to the new value; after adoption, drop the
   legacy schemes from Info.plist/AndroidManifest/app.json.
5. Re-run SSO + deep-link smoke tests (quickstart US1 step 6) on both platforms.
