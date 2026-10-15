---
name: "speckit-sync"
description: "upstream(mattermost/mattermost-mobile) 커밋을 오래된 순으로 2단 레인(자동 cherry-pick / 정밀 분석·승인)으로 선형 반영하고, docs/upstream-main-unmerged-commits.md 목록을 갱신한다."
argument-hint: "옵션 없이 실행하거나 처리할 커밋 수 힌트를 자연어로 전달"
compatibility: "Requires git remote 'upstream' (mattermost/mattermost-mobile), local branch 'upstream-main', spec-kit project structure"
metadata:
  author: "okrbest"
user-invocable: true
disable-model-invocation: false
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## 목적

okrbest-mobile은 mattermost/mattermost-mobile의 **가볍게 갈라진(lightly-diverged) 포크**다.
포크 자체 변경은 리브랜드 자산·i18n·앱 식별자·배포 설정에 집중되어 있고 제품 코드(app/)는
거의 갈라지지 않았다. 이 스킬은 upstream 커밋을 **오래된 순으로** 다음 넷 중 하나로 처리하여
main에 **선형으로**(merge 커밋 없이) 반영한다:

| 처리 | 조건 | 결과 |
|---|---|---|
| **cherry-pick** | 충돌 없음 + 의미 충돌 없음 | `git cherry-pick -x` 커밋 |
| **adapt** | 충돌 있으나 간단 (≤5 파일·≤150라인 가이드) | 프로젝트 맞춤 수정 후 새 커밋 |
| **exclude** | 우리가 자체 커밋으로 해당 기능을 변경/제거함 | ledger 부록에 사유 기록 |
| **spec** | 대규모·큰 영향 (>15 파일, >500라인, DB 마이그레이션, 신규 대형 기능) | spec-kit 파이프라인으로 별도 개발 |

**본체(okrbest server/webapp)와의 차이 — 2단 레인.** 본체는 heavily-diverged라 커밋마다
대화형 승인을 받지만, 이 포크는 **자동 통과 레인**을 둔다. 신호가 깨끗한 커밋은 연속으로
cherry-pick하고, 신호에 걸리는 커밋만 정밀 분석·대화형 승인을 거친다 (워크플로 2-2 참조).

추적 원리: 반영 커밋 본문의 upstream 해시 참조(`cherry picked from commit <hash>` /
`Upstream: <링크>`)와 ledger 부록(제외/spec)이 기록이며, `scripts/upstream-sync.sh update`가
이를 차감해 미반영 목록을 재생성한다. **별도 상태 파일 없음.**

도우미 스크립트: `.specify/scripts/bash/upstream-sync.sh` (이하 `$SYNC`)
`update` / `status` / `next [n]` / `signals <hash>` / `exclude <hash> <사유>` / `to-spec <hash> <specID>`
리브랜딩 검사: `.specify/scripts/bash/check-rebrand.sh` (i18n 금지 문자열 검출, 세션 게이트)

## 워크플로

### 1. 준비

1. 작업 트리 클린 확인 (`git status`). 더럽면 사용자에게 보고 후 중단.
2. 현재 브랜치 판별 (`git branch --show-current` + `git fetch origin`):
   - **main**: `git pull --ff-only` 후 3으로.
   - **sync/\* 브랜치**: `git cherry origin/main`으로 반영 여부 판별 (patch-id 비교).
     - 전부 `-` → 스테일 브랜치 (내용은 이미 main에 반영됨). 재사용 금지: `git switch main && git pull --ff-only`, 스테일 브랜치 삭제 후 3으로.
     - `+` 커밋 존재 → 미반영 작업이 남은 브랜치. 그 브랜치에서 이어서 작업, 3 생략.
   - **그 외 브랜치**: 의도된 브랜치 전환일 수 있다. 새 브랜치를 만들거나 main으로 전환하지 말고, 사용자에게 현재 브랜치와 상태를 보고한 뒤 지시를 기다린다.
3. sync 브랜치 생성: `git switch -c sync/upstream-$(date +%Y%m%d)`.
4. `$SYNC update` 실행 후 `$SYNC status` 요약 보고.

### 2. 커밋 루프 (사용자가 종료할 때까지 반복)

각 커밋마다:

#### 2-1. 재료 수집

- `$SYNC next` → 대상 full hash
- `$SYNC signals <hash>` → 충돌 예측(CLEAN/CONFLICT + 파일), 규모, HEAD 부재 경로, 보호 경로, 위험 경로, 포크 자체 변경 이력
- `git show <hash>` → 실제 diff 내용 (자동 레인 후보라도 제목·stat은 훑는다)

#### 2-2. 레인 판정

**자동 통과 레인** — 아래 조건을 **모두** 충족하면 승인 없이 즉시 2-4의 cherry-pick을 실행한다:

- MERGE-TREE가 CLEAN
- PROTECTED PATHS 접촉 없음 (리브랜드 자산·i18n·앱 식별자·fastlane·CI·포크 전용 구조물)
- RISK PATHS 접촉 없음 (DB 마이그레이션/스키마·`libraries/@mattermost/`·patches·package.json·Podfile·gradle)
- 규모 ≤15 파일·≤500 라인
- 제목·diff에서 의미 충돌 의심 없음 (리브랜드 문자열, 우리가 제거·변경한 기능 참조)

자동 통과 커밋은 개별 보고를 생략하되, 세션 마감 요약에 전체 목록을 포함해 사후 검토 여지를 남긴다.

**정밀 분석 레인** — 조건 하나라도 미달이면 2-3으로 간다.

**상설 기준 (2026-10-15 초기 캐치업 세션에서 사용자 승인)** — 아래 계열은 정밀 레인
조건에 걸려도 개별 승인 없이 처리하고, 세션 마감 보고에 목록만 남긴다:

- **제품 기능 커밋**: 충돌 없음 + 포크 무접촉 + 위험 경로 무접촉이면 규모 무관 cherry-pick.
- **버전 범프** ("Bump app build/version number"): cherry-pick. 배포 번호는 fastlane이 덮어쓴다.
- **e2e·CI 인프라** (.github workflows, detox/**, .cursor/** 등): cherry-pick/adapt.
  잔여 충돌은 포크 보호 항목(번들 식별자, AGENTS.md 등)을 보존하는 방향으로 기계적 해소.
- **Weblate 번역 커밋**: adapt — ko는 우리 번역 우선, 신규 문자열에 리브랜딩 재적용,
  check-rebrand.sh로 검증.
- **Session Attributes 계보**: 코드는 받되 iOS 식별자 파일 4종의 변경은 버린다
  (upstream-adapted-divergences.md의 복원 조건 참조).
- **추가형(additive) DB 마이그레이션**: cherry-pick + 스키마 문서 갱신 확인.
  파괴적 마이그레이션(컬럼 삭제·타입 변경·데이터 변환)은 여전히 정밀 레인.

#### 2-3. 정밀 레인: LLM 정밀 분석 + 대화형 승인

**분석** (신호는 참고 자료일 뿐, 판단은 여기서):

1. **upstream 커밋의 의도** 파악: 무엇을 왜 바꾸는가 (버그픽스/기능/리팩터/문서/번역).
2. **우리 포크의 자체 변경과 대조**: signals의 FORK HISTORY에 나온 커밋들을 `git show`로 확인하고, 필요시 `git log -p main -- <경로>`와 `specs/`(특히 001-otalk-rebrand, 002-otalk-self-distribution)를 조사한다. 질문: *우리가 이 영역을 의도적으로 바꿨거나 제거했는가?*
3. **의미 충돌 검토**: merge-tree가 CLEAN이어도 리브랜드 문자열(Mattermost→O'talk), 앱 식별자(`com.okrbest.otalk`), 우리가 변경한 기능 참조를 확인한다. 텍스트가 안 겹쳐도 의미가 깨질 수 있다.
4. **미반영 의존 검토**: 이 커밋이 exclude·건너뜀·아직 미반영인 upstream 커밋(선행 리팩터, feature flag, DB 스키마, 네이티브 모듈 버전)에 의존하는지 확인한다. ledger 부록과 `git log upstream-main`으로 선행 커밋 문맥을 조사한다.
5. 근거와 함께 **권고 결정**: cherry-pick / adapt / exclude / spec.

**대화형 승인** (정밀 레인 커밋마다 필수): 사용자가 이해하고 결정할 수 있도록 상세 보고를
먼저 제시한다 — ① 커밋 요약(의도·규모·upstream 링크) ② 우리 포크와의 관계 ③ 판단 근거
④ 선택지별 결과와 되돌리는 방법 ⑤ 권고 + 이유. 그 후 열린 대화로 결정을 받는다:

- "궁금한 점이 있으면 물어보세요. 결정되면 알려주세요."로 마무리 — 즉답을 강요하지 않는다.
- **"추천해줘"·"뭐가 맞아?"는 결정이 아니다** — 권고와 근거를 더 설명하고 다시 결정을 기다린다.
- 결정 표현이 모호하면 "○○로 진행한다는 뜻이 맞나요?"로 명시적 재확인.
- **사용자의 명확한 결정 전에는 어떤 코드 변경도 하지 않는다.**

#### 2-4. 실행

- **cherry-pick** (자동 레인 포함):
  ```bash
  git cherry-pick -x <hash>
  git commit --amend -m "$(git log -1 --pretty=%B)

  Upstream: https://github.com/mattermost/mattermost-mobile/commit/<full-hash>"
  ```
  cherry-pick 실패 시 `git cherry-pick --abort` 후 정밀 레인으로 전환.
- **adapt**: superpowers 규율 적용 — 동작 변경이면 테스트 동반(test-driven-development), 원인 조사는 systematic-debugging, 완료 선언 전 검증 증거(verification-before-completion). 커밋 형식:
  ```
  <원본 커밋 제목 유지>

  <okrbest-mobile 맞춤 수정 요지 1-3줄>

  (cherry picked from commit <full-hash>, adapted for okrbest-mobile)
  Upstream: https://github.com/mattermost/mattermost-mobile/commit/<full-hash>
  ```
  후속 sync에서 충돌·오해를 부를 수 있는 차이는 `docs/upstream-adapted-divergences.md`에 기록.
- **exclude**: `$SYNC exclude <hash> "<사유>"` — 사유는 우리 쪽 근거 커밋/문서를 포함해 구체적으로.
- **spec**: `$SYNC to-spec <hash> "<가칭 또는 specs/NNN-이름>"` 기록. 그 후 사용자에게 `/speckit-specify` 착수 여부를 **명시적으로 질문**한다 (CLAUDE.md 핸드오프 규칙 — 자동 진입 금지). spec 구현 완료 커밋 본문에 `Upstream: <링크>`를 넣어야 목록에서 자동 차감됨을 안내.
- **건너뜀**: 아무것도 하지 않음 (목록 유지).

**커밋 직후 검증**: 정밀 레인의 코드 커밋은 접촉 경로 한정 jest를 즉시 실행해 회귀를 커밋
단위로 귀속시킨다 (`npm run test -- <관련 경로>`). 자동 레인은 연속 pick 구간이 끝날 때
(정밀 레인 진입 직전 또는 10커밋마다) 묶어서 접촉 경로 jest를 실행해 회귀를 배치 단위로
귀속시킨다. docs·i18n·자산만 건드린 커밋은 생략 가능. 실패 시 즉시 해결(systematic-debugging)
또는 해당 커밋 revert 후 사용자 보고 — 실패를 안고 다음 커밋으로 넘어가지 않는다.

#### 2-5. 목록 갱신

`$SYNC update` 재실행 → 남은 개수·마지막 반영 커밋 갱신 확인.

주의: 기본 `update`는 main 기준 계산이라 sync 브랜치의 새 커밋은 차감되지 않아 남은 개수가
즉시 줄지 않는다. 브랜치 커밋까지 포함한 정확한 개수는 `SYNC_BASE_BRANCH=HEAD $SYNC update`로 확인한다.

### 3. 세션 마감

1. **품질 게이트** (통과 증거를 보인 후에만 완료 선언 — verification-before-completion):
   - `npm run tsc` + `npm run fix` (전체)
   - 접촉 영역 jest (`npm run test -- <경로들>`)
   - `.specify/scripts/bash/check-rebrand.sh` (i18n 리브랜딩 누락 검사)
   - **mobile MCP 스모크** (CLAUDE.md 규칙): 서브에이전트로 앱을 기동하고, 이번 세션이 건드린 기능을 실제로 조작해 확인한다 — 기동 확인만으로는 부족하다.
   - **네이티브 접촉 세션** (`ios/`·`android/`·`libraries/@mattermost/`·patches 변경 시): 시뮬레이터 빌드 1회 추가. 핫 리로드로는 네이티브 회귀를 잡을 수 없다.
2. **ledger 커밋 (sync 브랜치 위에서)**:
   ```bash
   SYNC_BASE_BRANCH=HEAD .specify/scripts/bash/upstream-sync.sh update
   git add docs/upstream-main-unmerged-commits.md
   git commit -m "docs: upstream sync 진행 (picked N, adapted M, excluded K)"
   ```
   `SYNC_BASE_BRANCH=HEAD`로 sync 브랜치 커밋까지 차감 계산해 남은 개수 감소를 반영 전에 검증한다.
3. **main 반영 (사용자 확인 후)** — ff-only 고정, merge 커밋·squash 금지:
   ```bash
   git switch main && git pull --ff-only
   # 세션 중 main에 기능 커밋이 쌓였다면 먼저: git switch <sync-branch> && git rebase main && (게이트 재검증) && git switch main
   git merge --ff-only <sync-branch>
   git push origin main
   git branch -d <sync-branch>
   ```
   squash는 커밋 본문이 합쳐져 `Upstream:` 참조가 소실되고 ledger 차감 grep이 깨진다.
   merge 커밋은 선형성을 깬다. rebase는 SHA만 바뀌고 커밋별 본문이 보존되므로 허용된다.
4. 요약 보고: 처리 커밋 수(분기별), **자동 레인 커밋 전체 목록**(사후 검토용), 남은 pending, 다음 대상.
5. **i18n 후속 필요 안내** (해당 항목이 있을 때만): 이번 세션에서 `en.json`만 변경돼 ko 반영이
   밀린 키를 커밋 해시·키·추가/제거 구분으로 나열해 보고한다. 여기서 ko.json을 직접 수정하지는
   않는다 — 별도 작업 착수 여부는 사용자가 결정한다. 확인 명령:
   ```bash
   git diff <세션 base 커밋>..HEAD -- assets/base/i18n/en.json
   ```

## 주의

- 절대 main에서 직접 작업하지 않는다 (sync 브랜치에서만). main 반영은 ff-only만 사용한다.
- 기존 merge 커밋(`cc9de0b94`)은 역사로 둔다 — main 재작성(force push) 금지. 선형성은 앞으로만 적용한다.
- 오래된 순서를 건너뛰어 최신 커밋을 먼저 반영하지 않는다 (의존성 붕괴). "건너뜀"은 예외적·일시적이어야 한다.
- 자동 레인도 기록 형식은 동일하다 (`cherry-pick -x` + `Upstream:` 참조) — 차감 메커니즘의 전제.
- **i18n 파일이 커밋에 포함된 경우** (Weblate 번역 커밋 등): 기본 **adapt** — 신규 키·문구 갱신은
  수용하되 `ko.json`은 우리 번역을 우선하고, 신규 문자열에 리브랜딩 규칙을 재적용한다
  (제품 정체성은 O'talk, 저작권은 `Copyright {currentYear} OKR Best Inc. All rights reserved`,
  예외 4종 — `settings.notice_text`·`settings.about.powered_by`·`about.teamEditionLearn`·`:mattermost:` — 은 Mattermost 유지).
  `check-rebrand.sh`가 세션 게이트에서 누락을 걸러낸다.
- **i18n 파일이 커밋에 없는 경우** (upstream이 `en.json`만 변경한 경우): ko.json을 손대지 않고
  sync를 계속 진행한다. 필요 키만 기록해 두었다가 세션 마감 보고로 안내하고, 실제 반영은 별도
  작업으로 넘긴다 (CLAUDE.md "en 변경 시 같은 변경에서 ko 갱신" 규칙의 sync 한정 예외).
  커밋마다 보정 커밋을 붙이지 않는다.
- 대량 자동 처리라도 **신호 수집(2-1)은 커밋마다 수행**한다 — 자동 레인 판정 자체가 신호에 기댄다.
- 라이선스 관련 upstream 변경(NOTICE.txt, copyright 헤더)은 그대로 반영하고, 우리 리브랜드 문자열은 보존한다.
