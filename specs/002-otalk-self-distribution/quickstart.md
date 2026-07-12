# Quickstart — Validating O'talk Self-Distribution

Validation guide per user story. Identity values: [contracts/app-identity.md](./contracts/app-identity.md).

## Prerequisites

- Phase 1 rebrand merged (`001-otalk-rebrand`).
- US1: none beyond a dev machine (simulator/emulator OK, dev signing).
- US2: physical iOS + Android devices; OKR Best Firebase project; APNs key; deployed
  push proxy; a Mattermost server you control (e.g., `dev.okrbest.com`) with push
  settings pointed at the proxy.
- US3: OKR Best Apple Developer + Play Console accounts, match repo, upload keystore.

## US1 — Identity rename

1. `npm install && npm run tsc && npm run fix` — pass.
2. Android: `npm run android`, then
   `adb shell pm list packages | grep okrbest` → `com.okrbest.otalk`.
   The app must coexist with any installed Mattermost app.
3. iOS (macOS runner): build, then verify
   `xcodebuild -showBuildSettings | grep PRODUCT_BUNDLE_IDENTIFIER` for all 3 targets.
4. Login to `dev.okrbest.com`, post a message.
5. Share sheet → share a photo into O'talk → posts successfully (App Group storage OK).
6. Open a `mattermost://` deep link and complete an SSO login (`mmauth(beta)://`
   round-trip) — behavior unchanged.
7. Identifier audit: repo grep for `com.mattermost.rnbeta|com.mattermost.rn` returns only
   the documented exceptions (contract invariant 4). Attach output as evidence.

## US2 — Push chain

1. Install an internal build on both physical devices; log in; background the app.
2. From another account, send a DM + an @mention.
3. **Expected**: notification arrives on both platforms; iOS shows fetched message
   content (NotificationService worked); tapping opens the right channel.
4. Negative check: proxy logs show delivery entries; server logs show no push errors.
5. Record: device models, OS versions, proxy version, timestamp — attach to the task.

## US3 — Signing / store / CI

1. CI release lane (iOS): produces a signed `.ipa` for `com.okrbest.otalk` via match,
   uploads to TestFlight — no manual signing prompts.
2. CI release lane (Android): produces a signed `.aab` with the OKR Best upload key,
   uploads to Play internal testing.
3. Install from TestFlight / Play internal track on clean devices; re-run US1 steps 4–6
   and US2 steps 1–3 on the store-delivered build (FR-012).
4. Store listings show O'talk name/icon/screenshots and OKR Best Inc publisher.

## Success evidence checklist

- [ ] US1: package/bundle IDs verified; share extension + deep link + SSO pass
- [ ] US1: identifier audit output attached (0 undocumented references)
- [ ] FR-010: URL-scheme compatibility analysis committed
- [ ] US2: background push screenshots (iOS + Android) + proxy log excerpt
- [ ] US3: TestFlight + Play internal builds installable; store-build smoke test pass
