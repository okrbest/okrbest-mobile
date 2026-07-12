# T014 — Build verification (partial)

**Date**: 2026-07-13 | **Machine**: SDH (WSL2)

## Done
- `./gradlew assembleDebug` BUILD SUCCESSFUL (19m51s, 1671 tasks)
- aapt2 badging on app-debug.apk:
  - package: name='com.okrbest.otalk' versionCode='778' versionName='2.42.0'
  - application-label: O'talk
  - launchable-activity: com.mattermost.rnbeta.MainActivity  <- R1 proof:
    applicationId and Java namespace decoupled and working
- `npm run tsc`: 0 errors. eslint on changed TS files: 0 errors
  (3 pre-existing `any` warnings on untouched lines)

## Remaining (needs emulator/simulator + server)
- quickstart US1 steps: install + coexistence check, login to dev.okrbest.com,
  share-extension post, mattermost:// deep link + mmauth(beta):// SSO round-trip
- iOS build verification requires a macOS runner (xcodebuild -showBuildSettings)

T014 stays unchecked until the on-device portion runs (emulator machine or macOS).
