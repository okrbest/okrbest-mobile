# upstream-main 미반영 커밋 목록

`HEAD`에 반영되지 않은 `upstream-main`(mattermost/mattermost-mobile) 커밋 목록 (오래된 순).
`/speckit-sync` 스킬이 이 목록을 갱신·소비한다. 반영 완료된 커밋은 목록에서 제거된다.

- 갱신일: 2026-10-27 13:35
- 기준: `git log --no-merges HEAD..upstream-main` − 처리 완료(cherry-pick/adapt 커밋 본문의 upstream 참조, 하단 부록의 제외·spec 전환)
- 남은 커밋: 0개

**마지막 반영 커밋:** `a635f57c` | [chore: Update NOTICE.txt file with updated dependencies (#10277)](https://github.com/mattermost/mattermost-mobile/commit/a635f57cd32810697c0c9b33dd9eb479ca44c95a) | 2026-10-26

| 커밋 해시 | 커밋 제목 | 커밋 일자 |
|---|---|---|

## 제외된 커밋

| 커밋 해시 | 커밋 제목 | 사유 |
|---|---|---|

## spec 전환 커밋

| 커밋 해시 | 커밋 제목 | spec |
|---|---|---|

## 후속 작업 메모 (macOS)

2026-10-15 초기 캐치업 세션(98커밋 반영, main 병합 완료)이 WSL2 환경이라 실행하지
못한 게이트. macOS에서 수행한 뒤 이 절을 갱신하거나 비운다.

1. **의존성·Pod 설치**: `npm install && npm run pod-install` — calls-native 모듈 신설,
   react-native-emm 2.0.0, network-client 1.11.2, Session Attributes pod 반영.
2. **iOS 시뮬레이터 빌드 1회**: `npm run ios` — iOS 배포 타깃 18.0 상향(f2857a97),
   WatermelonDB WAL 패치, rnutils 백그라운드 가드(0xdead10cc) 등 네이티브 변경 검증.
3. **mobile MCP 스모크**: 통화(DM 발신·수신·CallKit 잠금 화면 응답)와 Agents 채팅
   (툴 수락 UX, AskUserQuestion)을 실제로 조작해 확인 — 기동 확인만으로는 부족.
4. **(선택) Android 에뮬레이터 빌드**: minSdkVersion 30 상향과 expo-image 애니메이션
   이모지 크래시 패치 확인.

참고: call_screen 테스트 1건은 알려진 red (upstream 테스트 간 오염,
`docs/upstream-adapted-divergences.md` 참조) — 빌드 실패와 무관하다.
