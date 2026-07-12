# T011 — MATTERMOST_BUNDLE_IDS gate review (research R4)

**Date**: 2026-07-12

## Findings

1. `app/screens/settings/about/about.tsx:36` — `MATTERMOST_BUNDLE_IDS = ['com.mattermost.rnbeta', 'com.mattermost.rn']`
   - Sole functional use: line ~329, `!MATTERMOST_BUNDLE_IDS.includes(applicationId)` gates the
     `settings.about.powered_by` footer ("{site} is powered by Mattermost").
   - With `applicationId = com.okrbest.otalk` the gate evaluates to "not an official Mattermost
     build" → the powered-by attribution line is now SHOWN on the About screen.
   - This is the upstream-designed white-label path and matches FR-007 (attribution retained)
     and the phase-1 retained-strings decision (`settings.about.powered_by` kept in en/ko).
   - **Decision: constant left unchanged. Do NOT add `com.okrbest.otalk` to it** — doing so
     would masquerade as an official build and suppress required attribution.

2. `app/database/manager/index.ts:583` — `com.mattermost.rnbeta` appears only inside a JSDoc
   comment (example Android data path). No functional code. Left unchanged; listed as a
   documented exception in the FR-004 audit.

## Verification

- About screen behavior for the non-Mattermost branch was already visually verified in
  phase 1 (About screen renders correctly); the powered_by line rendering will be confirmed
  in T014/T027 smoke tests.
