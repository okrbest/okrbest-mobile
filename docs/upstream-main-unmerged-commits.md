# upstream-main 미반영 커밋 목록

`main`에 반영되지 않은 `upstream-main`(mattermost/mattermost-mobile) 커밋 목록 (오래된 순).
`/speckit-sync` 스킬이 이 목록을 갱신·소비한다. 반영 완료된 커밋은 목록에서 제거된다.

- 갱신일: 2026-10-15 12:53
- 기준: `git log --no-merges main..upstream-main` − 처리 완료(cherry-pick/adapt 커밋 본문의 upstream 참조, 하단 부록의 제외·spec 전환)
- 남은 커밋: 98개

**마지막 반영 커밋:** `072c51c6` | [chore(e2e): Fix e2e artifact upload path for CMT workflow (#9955)](https://github.com/mattermost/mattermost-mobile/commit/072c51c647718aa604686163818a4319e2639a65) | 2026-07-21

| 커밋 해시 | 커밋 제목 | 커밋 일자 |
|---|---|---|
| 7e200757 | [fix: push notification navigation delay and stale in-app avatar (#9929)](https://github.com/mattermost/mattermost-mobile/commit/7e200757bbb4e584afdf8a0c2a2853e772b4c272) | 2026-07-22 |
| bcac248e | [feat(e2e): Integrate TSIO reporting (#9925)](https://github.com/mattermost/mattermost-mobile/commit/bcac248ec090f12ab956e0ffcaaaa981ad857481) | 2026-07-23 |
| 8250ccc4 | [Fix CRT-off consecutive reply bar 1px offset and vertical overlap. (#9932)](https://github.com/mattermost/mattermost-mobile/commit/8250ccc4f923af19670c6d1e775d8bd1a9355369) | 2026-07-23 |
| aa55eddf | [Bump app build number to 790 (#9963)](https://github.com/mattermost/mattermost-mobile/commit/aa55eddf1bc032439090c26ebada97a2a175c17e) | 2026-07-24 |
| ec1088cf | [fix: hardware Enter key not sending messages in channel on iPad (#9965)](https://github.com/mattermost/mattermost-mobile/commit/ec1088cfb698469a098a263bf791b108ff9e501c) | 2026-07-24 |
| a949e2ad | [Translations update from Mattermost Weblate (#9968)](https://github.com/mattermost/mattermost-mobile/commit/a949e2ad3f02e084c2e7ed61d8b8e56db2be84df) | 2026-07-27 |
| 0f9beb0f | [ci(e2e): per-job TSIO report groups, commit statuses, and webhook sidecar (#9969)](https://github.com/mattermost/mattermost-mobile/commit/0f9beb0f95eae3606380325e04dcf69bbc719491) | 2026-07-29 |
| e3b8acfa | [fix(ci): recycle Jest workers to prevent test-coverage OOM (#9977)](https://github.com/mattermost/mattermost-mobile/commit/e3b8acfa70076fd3331f1df59dafe05dce356e22) | 2026-07-29 |
| 4b4db668 | [\[MM-69723, MM-69705\] Version-gate ChannelBookmarks and CustomProfileAttributes for flag removal (#9916)](https://github.com/mattermost/mattermost-mobile/commit/4b4db6684463ecad38a1aa7b9f953fff1c8125f6) | 2026-07-29 |
| ca20a9a2 | [fix(e2e): Quarantine proven flakes and harden Detox harness (#9971)](https://github.com/mattermost/mattermost-mobile/commit/ca20a9a20a7c814ad348be44c0660b291b5b18b3) | 2026-07-30 |
| c9b4cf2b | [bump .ruby-version to 3.2.11 (#9962)](https://github.com/mattermost/mattermost-mobile/commit/c9b4cf2be2051d5d61b3828cf9b66354a5ce6112) | 2026-07-30 |
| d3c9b8b1 | [Fix link to image proxy and correct padding in image sizing on blocks (#9976)](https://github.com/mattermost/mattermost-mobile/commit/d3c9b8b1c496daa06503e0e0a68d7db51cdcd123) | 2026-07-30 |
| b05e1fd4 | [Fix shared value lifecycle in useKeyboardEvents (#9924)](https://github.com/mattermost/mattermost-mobile/commit/b05e1fd41545a644aac6680309de6f8ff1c1dcb4) | 2026-07-30 |
| 0a23e0ce | [\[MM-70023\] Consider attachment fields with no title for block translation (#9981)](https://github.com/mattermost/mattermost-mobile/commit/0a23e0ce972fc07edd0d393500a82b61b7c01e06) | 2026-07-30 |
| 084db6ef | [Bump app build number to 793 (#9990)](https://github.com/mattermost/mattermost-mobile/commit/084db6ef1fe655c8af8d1e580b03ff584928375c) | 2026-07-31 |
| 16dd7dbd | [ci(e2e): make E2E/Override waive checks instead of cancelling runs (#9975)](https://github.com/mattermost/mattermost-mobile/commit/16dd7dbdba438164b147db7b5fcaa71dfaa8ee6c) | 2026-07-31 |
| d1e1f936 | [Fix three causes of channels rendering blank (#9992)](https://github.com/mattermost/mattermost-mobile/commit/d1e1f936b620d600bf95f2001a70bfadc78d8ae1) | 2026-08-03 |
| a058422c | [Bump app build number to 794 (#10001)](https://github.com/mattermost/mattermost-mobile/commit/a058422c711b72a711f1208ff459ecc7ee4ab6b9) | 2026-08-03 |
| 4e17e3f3 | [test(e2e): add migrated Detox and Maestro (#9972)](https://github.com/mattermost/mattermost-mobile/commit/4e17e3f3aeb50aea31a13853d9a03420b51b8e43) | 2026-08-04 |
| 587e15ea | [chore(e2e): Cache app builds. Skip E2E on docs only PR. (#9930)](https://github.com/mattermost/mattermost-mobile/commit/587e15ea89bbd35f9bc35ede63f3874e83c357de) | 2026-08-04 |
| d3b43df4 | [Reconcile mobile Agents post display with webapp (multi-round, inline thread, tool approval UX) (#9841)](https://github.com/mattermost/mattermost-mobile/commit/d3b43df46678a5d924dfeca635cebcc51718372b) | 2026-08-05 |
| 6edb76ec | [replace react-native-incall-manager with @mattermost/calls-native for audio management (#9973)](https://github.com/mattermost/mattermost-mobile/commit/6edb76ec686fb1f0e1845e532b9a7795a6074757) | 2026-08-06 |
| 73fe7eff | [Bump app build number to 797 (#10014)](https://github.com/mattermost/mattermost-mobile/commit/73fe7eff4eb71f4ac0a2b945bbe60f125c635de0) | 2026-08-06 |
| 412f35fc | [Fix time-of-day flake in apps_form initValues datetime tests (#10013)](https://github.com/mattermost/mattermost-mobile/commit/412f35fcdd3f7d33ced4037cba969d655763b306) | 2026-08-06 |
| a4059844 | [fix(ci): keep release Fastlane install path; opt-in gem cache for E2E (#10015)](https://github.com/mattermost/mattermost-mobile/commit/a40598448a1d0d8552c714ff204afa7aff96cbf0) | 2026-08-06 |
| 98c2ef9d | [Bump app build number to 798 (#10016)](https://github.com/mattermost/mattermost-mobile/commit/98c2ef9d90fa88770f34576c5d9fdef6480d59ab) | 2026-08-06 |
| 6325368c | [\[MM-70111\] fix(report-problem): always open the Report a Problem screen instead of skipping it (#10010)](https://github.com/mattermost/mattermost-mobile/commit/6325368c3a265f32a52949ce007a11bef74ef7bc) | 2026-08-06 |
| 06ed862d | [Bump app build number to 799 (#10021)](https://github.com/mattermost/mattermost-mobile/commit/06ed862d222012d7c9d0d9fc6111399ad60cf7fa) | 2026-08-07 |
| 4f11e81c | [chore: Update NOTICE.txt file with updated dependencies (#10033)](https://github.com/mattermost/mattermost-mobile/commit/4f11e81c50de8f1b1e9b62d26d15ae9db7182d97) | 2026-08-10 |
| 62787a9a | [Fix/detox recovery hardening cluster (#10022)](https://github.com/mattermost/mattermost-mobile/commit/62787a9a0cd7ac1ebd93248d92dd73b01cd60a5e) | 2026-08-11 |
| c5a25c9a | [MM-70051 Fixing issues with system classifications (#9989)](https://github.com/mattermost/mattermost-mobile/commit/c5a25c9a254cae981f2ae30dafb4dfed9fafa09a) | 2026-08-11 |
| 17d45892 | [fix(ci): avoid Bundler deployment mode for Fastlane gem cache (#10037)](https://github.com/mattermost/mattermost-mobile/commit/17d45892691a80b7e752bd15fd845bc5e1674df0) | 2026-08-12 |
| 10207015 | [Classification Markings: Cached request timer and PSv2 Implementation (#9926)](https://github.com/mattermost/mattermost-mobile/commit/10207015a5023d844c65885ed134814f6c22294a) | 2026-08-13 |
| 428ea43f | [Bump app build number to 800 (#10045)](https://github.com/mattermost/mattermost-mobile/commit/428ea43f9890045898a92c6155ddb5b8122c9c28) | 2026-08-14 |
| 05f4e676 | [fix(e2e): make MM-T5611 iOS browser hand-off assert on Safari's breadcrumb (#10043)](https://github.com/mattermost/mattermost-mobile/commit/05f4e6769e6c73f6e10212a2b6c7349a0d5e5c03) | 2026-08-14 |
| 07c96346 | [Update supported ESR version (#9954)](https://github.com/mattermost/mattermost-mobile/commit/07c963463a9d1bc1b5a1d477d611591d854ed325) | 2026-08-17 |
| 8f4c71ad | [MM-69550: Update welcome and server onboarding copy for DISC audience (#10046)](https://github.com/mattermost/mattermost-mobile/commit/8f4c71add24dfd97f24ac44bd324ee230b1e1fe0) | 2026-08-17 |
| 60342ac2 | [Bump app build and version number (#10071)](https://github.com/mattermost/mattermost-mobile/commit/60342ac2289ed5db75d293cf0444a0ef61119bc6) | 2026-08-18 |
| 8619971a | [Fix deeplink handler (#9919)](https://github.com/mattermost/mattermost-mobile/commit/8619971a7f79e68eb955701acfe79ac834014669) | 2026-08-19 |
| 88a23376 | [\[MM-68986\]\[MM-69203\] Add module to collect Session Attributes from Mobile App (#9830)](https://github.com/mattermost/mattermost-mobile/commit/88a23376bbae89473a239df44f1fc5b6944b2aa8) | 2026-08-18 |
| 58d0fca8 | [fix: session attributes pod (#10080)](https://github.com/mattermost/mattermost-mobile/commit/58d0fca88021bcc272ef491d32c9b1ce98166a57) | 2026-08-20 |
| ebc1f138 | [Bump app build number to 805 (#10086)](https://github.com/mattermost/mattermost-mobile/commit/ebc1f1382bb0334c0f679467bb6cc97fa6b8c0ae) | 2026-08-20 |
| 876af76f | [\[MM-69129\] Prevent crash on nameless attachment (#10091)](https://github.com/mattermost/mattermost-mobile/commit/876af76f36bedbfd8b922cfd7a508a9dc828fe2e) | 2026-08-24 |
| 6f8f87b0 | [fix: Product fixes to run e2e tests (#10081)](https://github.com/mattermost/mattermost-mobile/commit/6f8f87b081ec19f14a32ce19f51b0d98e052da0f) | 2026-08-26 |
| f663d0f5 | [perf: skip Android Keystore listing on cold start (#10056)](https://github.com/mattermost/mattermost-mobile/commit/f663d0f52051b427864c5aab6726e946a7e12674) | 2026-08-26 |
| f3af9dbe | [Fix/detox hittest cluster (#10023)](https://github.com/mattermost/mattermost-mobile/commit/f3af9dbe994c19abcf5b3b26086e12e14426fa29) | 2026-08-27 |
| 9e2a3468 | [MM-69625 MM-69633: Collapse-all and task filtering on playbook run checklists (#9928)](https://github.com/mattermost/mattermost-mobile/commit/9e2a34682e77b1a2d6585182471b3251fdcf8e88) | 2026-08-27 |
| 69491de3 | [fix: map the record value in observeTutorialWatched and push-ack observables (#10101)](https://github.com/mattermost/mattermost-mobile/commit/69491de3ed80879ab1fce0b01e87403e1865aa1a) | 2026-08-28 |
| 7a8bf6d6 | [\[MM-70388\] Request location permission for the SSID session attribute (#10100)](https://github.com/mattermost/mattermost-mobile/commit/7a8bf6d69f86e720ebe465359074135c27393e04) | 2026-08-28 |
| 08f83d4e | [Add E2E coverage for custom terms of service login flow (#10105)](https://github.com/mattermost/mattermost-mobile/commit/08f83d4e7f8aa5c710e9c36962c8be1548ead966) | 2026-09-01 |
| f00701ec | [On iOS, resuming after the 5-minute window showed no biometric prompt — (#10102)](https://github.com/mattermost/mattermost-mobile/commit/f00701ec9a473f734aed757b6ff12470d7ba43d5) | 2026-09-02 |
| b4b72060 | [Re-enable WAL journal mode for WatermelonDB (#10109)](https://github.com/mattermost/mattermost-mobile/commit/b4b72060944fedf7033eae015b1b7fb1f0c03dd3) | 2026-09-02 |
| bc84b6ee | [Guard long-running DB chains against RUNNINGBOARD 0xdead10cc on iOS (#10110)](https://github.com/mattermost/mattermost-mobile/commit/bc84b6ee3aa78e9ddc7da73710e07c7d2088bfa5) | 2026-09-02 |
| b9aee2b8 | [Mm 68768 auto cache rolling cleanup (#9958)](https://github.com/mattermost/mattermost-mobile/commit/b9aee2b8036f3f899a03e4133504461409140a8a) | 2026-09-03 |
| f5e7f998 | [fix(android): open every SQLite connection in WAL, not just the JSI one (#10117)](https://github.com/mattermost/mattermost-mobile/commit/f5e7f9982be6f76dfb2a8bf4875302f18aab5b62) | 2026-09-03 |
| 06e3558f | [\[MM-67557\] Retry connecting with progressively shorter server URLs (#10112)](https://github.com/mattermost/mattermost-mobile/commit/06e3558fe717b2d4ad29c1227f47df134b474134) | 2026-09-03 |
| 044dba21 | [\[MM-69735\] Improve DM call user experience (#10017)](https://github.com/mattermost/mattermost-mobile/commit/044dba2188ebdb07bddc05c0b4618d7cc2b8c77b) | 2026-09-04 |
| 46c2da9d | [Add Cursor Cloud Agent environment for PR babysitting (#10128)](https://github.com/mattermost/mattermost-mobile/commit/46c2da9d4e2b9e6b4e9e747999f135d8036611c1) | 2026-09-04 |
| 827eae87 | [\[MM-70525\] Fix CallKit call disconnect on lock-screen answer (#10111)](https://github.com/mattermost/mattermost-mobile/commit/827eae876cbdd1704ec1c0752eb287d07407247c) | 2026-09-08 |
| ef1ecc1d | [fix: stabilize server switch, saved posts, favorites, and related runtime races (#10122)](https://github.com/mattermost/mattermost-mobile/commit/ef1ecc1d9edb0d6e8c9ea76e462d1eb7d0be5927) | 2026-09-09 |
| 24de882b | [Hide approval UI for auto-executing agent tool calls (would_auto_execute) (#10027)](https://github.com/mattermost/mattermost-mobile/commit/24de882b05d679183801940e34f4163d8b9fa545) | 2026-09-09 |
| e4e75c7e | [patch image picker (#10127)](https://github.com/mattermost/mattermost-mobile/commit/e4e75c7e5693d5c355f6ba8fc14c342b2924e8b2) | 2026-09-10 |
| dfc94b3c | [test(e2e): close manual release-test gaps (#10125)](https://github.com/mattermost/mattermost-mobile/commit/dfc94b3c3c72a3869efa1acd16a938878519e93e) | 2026-09-11 |
| b8f42ac6 | [Bump app build number (#10145)](https://github.com/mattermost/mattermost-mobile/commit/b8f42ac65f1a0fcdba1b7aac255b216967e2d06d) | 2026-09-11 |
| 939c7bd5 | [\[MM-70694\] Drop fake-webapp-dir workaround from i18n precommit script (#10150)](https://github.com/mattermost/mattermost-mobile/commit/939c7bd55bafde3c0ae82ad18c3fc5e322a9c482) | 2026-09-12 |
| 7e2cfefd | [Log network failures in REST client and websocket manager (#10074)](https://github.com/mattermost/mattermost-mobile/commit/7e2cfefd0f1218810c494142a60d8689de748b43) | 2026-09-14 |
| 0869dc8e | [\[MM-62038\] Fix urgent mention badge colors (#10119)](https://github.com/mattermost/mattermost-mobile/commit/0869dc8eab1d3369efbafcad561fb6fb631d130a) | 2026-09-14 |
| 6ec7bef3 | [MM-70688 Autolink phone numbers in posts as tel: links (#10143)](https://github.com/mattermost/mattermost-mobile/commit/6ec7bef33450605ab91b94bed89dca3358ab5f23) | 2026-09-14 |
| d943628e | [\[MM-70707\] Hide the DM call action for bots, deactivated users, and self-DMs (#10157)](https://github.com/mattermost/mattermost-mobile/commit/d943628e0fa3b22b9b4e32dba5de0ea59e26daf4) | 2026-09-15 |
| 5fe7c8fe | [\[MM-66560\] Fix channel links ending in channel IDs (#10158)](https://github.com/mattermost/mattermost-mobile/commit/5fe7c8fe0c2e5a622eb250572ec82d7e2f639b25) | 2026-09-15 |
| c2fe3bed | [ci(release): bump setup-ruby so 3.2.11 from .ruby-version resolves (#10162)](https://github.com/mattermost/mattermost-mobile/commit/c2fe3beda22befd2178dce431793c09111ed903e) | 2026-09-16 |
| f2857a97 | [Mm 67525 bump min version (#9640)](https://github.com/mattermost/mattermost-mobile/commit/f2857a97d1c22c59e4b4c24a626364f4c3a8a114) | 2026-09-16 |
| b5fef869 | [test(e2e): fix main-branch E2E flakes and make a killed shard report red (#10161)](https://github.com/mattermost/mattermost-mobile/commit/b5fef869931570cb0f452765f6edd61c326b547e) | 2026-09-17 |
| 224571f8 | [Fix stale attachment image after in-place post edit (#10167)](https://github.com/mattermost/mattermost-mobile/commit/224571f82e79100736876a3756dbede8d25ee836) | 2026-09-17 |
| 54731fa6 | [Mm 70299 channel labels display phase 1 (#10113)](https://github.com/mattermost/mattermost-mobile/commit/54731fa6aceeb9fb758be7b92ff633a92ce9b87c) | 2026-09-17 |
| 4f5b83e6 | [fix: read manual time entry from both datetime config keys, and unblock main-branch E2E (#10174)](https://github.com/mattermost/mattermost-mobile/commit/4f5b83e6af7a37a04a8b36c867edf08f371682f8) | 2026-09-18 |
| cd623ab2 | [Bump app build and version number (#10175)](https://github.com/mattermost/mattermost-mobile/commit/cd623ab2cb290463e0b6fc264fd07ea7c7973f3a) | 2026-09-18 |
| 26e5b4b7 | [Bump app build number to 817 (#10177)](https://github.com/mattermost/mattermost-mobile/commit/26e5b4b7d902f39b6bc75812e7e7736483b7c1c5) | 2026-09-18 |
| 0c0d6c48 | [ci(cmt): run the CMT full suite on 28 shards to match PR/main (#10178)](https://github.com/mattermost/mattermost-mobile/commit/0c0d6c48ecd1432a80ecdbe69aafa394af49d03c) | 2026-09-18 |
| 72e74b87 | [test(e2e): make CMT and PR E2E green (absorbs #10186) (#10184)](https://github.com/mattermost/mattermost-mobile/commit/72e74b8785607838d85fdf3ac482e7854a0c9947) | 2026-09-22 |
| 7e527fde | [\[MM-70689\] Keep DM call tile order stable from ringing to answered in calls (#10153)](https://github.com/mattermost/mattermost-mobile/commit/7e527fde5f6849c63aeab7681d4e729f58d0842b) | 2026-09-22 |
| 46251434 | [fetch roles during entry to avoid UI observing inconsistent channel s… (#9873)](https://github.com/mattermost/mattermost-mobile/commit/462514347e00bdcdde41f3be9de2b379c32a6f03) | 2026-09-22 |
| ad6b834d | [Mm 68296 audit ephemeral mode events (#10139)](https://github.com/mattermost/mattermost-mobile/commit/ad6b834d34df2fc3c2724f7f9c53bc3d0a45946a) | 2026-09-23 |
| 769987b7 | [test(e2e): fix Detox and Maestro flakes, bound config-guard requests, stop passing unrun flag-off tests (#10191)](https://github.com/mattermost/mattermost-mobile/commit/769987b7a1807b9fc68f0985cd1464066d7f74c2) | 2026-09-24 |
| 689825af | [\[MM-70539\] Viewing call thread will restart the app and disconnect the call if you had a different thread open when joining (#10116)](https://github.com/mattermost/mattermost-mobile/commit/689825af21b042612308597b694a886a030e64f9) | 2026-09-24 |
| 79207ac5 | [Bump app build number to 819 (#10197)](https://github.com/mattermost/mattermost-mobile/commit/79207ac53b900df93e938422e3254e71ee4041c2) | 2026-09-25 |
| bc03c18f | [\[MM-70866\] Explain Android location permission before request (#10194)](https://github.com/mattermost/mattermost-mobile/commit/bc03c18f88581bde36dd82a84321b2ddde40d12c) | 2026-09-25 |
| 9183991a | [MM-70813 - support multi value attribute chips (#10192)](https://github.com/mattermost/mattermost-mobile/commit/9183991a0ef3690424be57215de9d16b9b771121) | 2026-09-30 |
| 74862a2f | [\[MM-71039\] Upgrade react-native-network-client (#10204)](https://github.com/mattermost/mattermost-mobile/commit/74862a2f641dc5398d56baa9b98a971488b7d30b) | 2026-10-01 |
| e2b167b2 | [Mm 68293 ephemeral mode warnings (#10140)](https://github.com/mattermost/mattermost-mobile/commit/e2b167b2c6262b0abc211c86ecc8ef94a380d80a) | 2026-10-01 |
| b70dedb7 | [Bump app build number to 821 (#10207)](https://github.com/mattermost/mattermost-mobile/commit/b70dedb760d4b2c3648fa07701c2f6f4f63f6589) | 2026-10-02 |
| e5be3119 | [Agents: fix stuck tool approvals, add AskUserQuestion, settle streamed replies (#10028)](https://github.com/mattermost/mattermost-mobile/commit/e5be3119634923d2cdb2bbcaeee0da81a23a5509) | 2026-10-02 |
| d295fa1c | [Limit bookmark names to the server's 64 characters (#10211)](https://github.com/mattermost/mattermost-mobile/commit/d295fa1c9e93d189b89f77dbe97c7b59fe60a1b7) | 2026-10-04 |
| 62f18af3 | [\[MM-71006\] Update timezone data to 2026d (#10201)](https://github.com/mattermost/mattermost-mobile/commit/62f18af38254a9acf74390b3815c2a11852b7bc5) | 2026-10-05 |
| 284ac4c1 | [MM-69627: Add playbook task requirements support on mobile (#10035)](https://github.com/mattermost/mattermost-mobile/commit/284ac4c16d8116d2643f743a987259cedceb5ca4) | 2026-10-07 |
| c05aea4a | [ MM-69122: Add file element support to interactive dialogs (#9898)](https://github.com/mattermost/mattermost-mobile/commit/c05aea4a2bf3c876cd1ea0af76979b60aae44611) | 2026-10-07 |
| e2164046 | [Fix version bump checkout when a tag shares the branch name (#10229)](https://github.com/mattermost/mattermost-mobile/commit/e216404659b7bba5fdcb9e7936efd054f1142d87) | 2026-10-08 |
| 726cd986 | [Fix Android crashes caused by animated custom emoji (#10030)](https://github.com/mattermost/mattermost-mobile/commit/726cd9865d4b2c0040853e9c364fa6365791dbb1) | 2026-10-12 |

## 제외된 커밋

| 커밋 해시 | 커밋 제목 | 사유 |
|---|---|---|

## spec 전환 커밋

| 커밋 해시 | 커밋 제목 | spec |
|---|---|---|
