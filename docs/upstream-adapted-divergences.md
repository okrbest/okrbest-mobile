# adapt로 벌어진 upstream 대비 차이

`/speckit-sync`가 **adapt**로 반영한 커밋 중, 우리 코드가 upstream과 **의도적으로 달라진 채
남는** 지점을 기록한다. 나중에 그 차이를 없앨 조건(선행 커밋 도입, 계보 복원)까지 함께 적는다.

두 문서의 역할이 다르다.

| 문서 | 담는 것 | 갱신 주체 |
|---|---|---|
| `docs/upstream-main-unmerged-commits.md` | 미반영 커밋 목록 + 제외·spec 전환 부록 | `upstream-sync.sh update`가 재생성 (부록만 보존) |
| **이 문서** | 코드가 **동작하지만 upstream과 형태가 다른** 지점 | 사람이 작성 |

**수록 기준.** adapt 커밋 전부를 적지 않는다. 우리에게 없는 파일의 훅을 버리는 식의 기계적
처리는 커밋 본문으로 충분하다. 여기에는 **후속 sync에서 충돌·오해를 부를 수 있는 차이**만
적는다 — 함수 구조가 달라졌거나, 제외한 계보에서 일부만 이식했거나, 설정·필드 이름이
upstream과 어긋난 경우. 상시 발생하는 i18n 리브랜딩 치환(Mattermost→O'talk)은 규칙이
CLAUDE.md에 있으므로 여기에 적지 않는다.

**시점.** 2026-10-15(선형 동기화 도입)부터 기록한다.

| 우리 커밋 | upstream | 차이 요약 |
|---|---|---|
| `fbfd407e5` Session Attributes 수집 모듈 | [88a23376](https://github.com/mattermost/mattermost-mobile/commit/88a23376bbae89473a239df44f1fc5b6944b2aa8) (#9830) | iOS 식별자 파일 4개의 변경을 버렸다 — 아래 참조 |
| `9eb671e33` DM 통화 타일 순서 안정화 | [7e527fde](https://github.com/mattermost/mattermost-mobile/commit/7e527fde5f6849c63aeab7681d4e729f58d0842b) (#10153) | 신규 테스트 1건이 파일 전체 실행에서만 타임아웃 — 아래 참조 |

---

## Session Attributes — iOS 위치 권한·Wi-Fi 엔타이틀먼트 미반영

**반영 상태.** 모듈 코드 전체(JS 액션·매니저, Gekidou Swift, rnshare Kotlin,
network-client 1.11.0)는 들어왔다. 버린 것은 식별자 파일 4개의 변경뿐이다:
`ios/Mattermost/Info.plist`·`ios/MattermostShare/Info.plist`의
`NSLocationWhenInUseUsageDescription`, 그리고 두 타깃 `.entitlements`의
`com.apple.developer.networking.wifi-info`.

**왜 버렸나.** ① okrbest 서버 포크는 Session Attributes 계보를 제외하고 있어 서버가
이 기능을 요구하지 않는다 — 모듈은 휴면 상태다. ② Wi-Fi 엔타이틀먼트는 Apple 개발자
포털의 App ID capability 등록과 프로비저닝 프로필 재발급을 요구하므로, 진행 중인
com.okrbest.otalk 배포 파이프라인(specs/002)을 서명 단계에서 깨뜨린다.
엔타이틀먼트가 없으면 SSID 조회가 빈 값을 돌려줄 뿐 컴파일·동작은 정상이다.

**복원 조건.** 서버 쪽에서 Session Attributes를 도입해 이 기능을 활성화할 때:
(1) Apple 포털에서 App ID에 Access Wi-Fi Information capability 추가 + 프로필 재발급,
(2) upstream 88a23376의 식별자 파일 4개 변경을 복원,
(3) 위치 권한 설명문은 O'talk 문구로 번역·조정.
이 전에는 후속 SA 커밋이 이 4개 파일을 다시 건드릴 때 같은 기준으로 버린다.

---

## call_screen 테스트 1건 — 파일 전체 실행에서만 타임아웃 (알려진 red)

**증상.** `app/products/calls/screens/call_screen/call_screen.test.tsx`의
"should hide the host badge in DM calls even when the other participant is the host"가
파일 전체(23테스트) 실행에서만 30초 타임아웃으로 실패한다. 코드는 upstream 그대로이며
우리 포크 변경과 무관하다.

**분석 결과 (2026-10-15).** 단독 실행 통과, 선행 테스트와의 짝 실행(1+3, 2+3) 통과,
선행 2개 + 피해 테스트의 3개 조합은 무한 대기 재현. `--runInBand`에서도 동일하므로
워커 경합이 아니라, beforeEach의 fake timers 아래에서 선행 렌더 2회가 누적시키는
타이머 상태가 세 번째 렌더를 막는 **upstream 테스트 간 오염**이다.

**처리.** 제품 코드 결함이 아니고 upstream이 활발히 재작성 중인 테스트 파일이므로
포크에서 고치지 않고 알려진 red로 둔다. 후속 sync에서 이 파일을 건드리는 커밋이
오면 그 시점에 해소 여부를 재확인한다.
