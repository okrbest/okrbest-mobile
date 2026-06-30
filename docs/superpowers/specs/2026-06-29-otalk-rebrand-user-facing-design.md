# 실행 계획서 — O'talk / OKR Best Inc 사용자 식별 리브랜딩 (1차)

- **Date:** 2026-06-29
- **Status:** Design (pending user review → spec-kit handoff)
- **Scope:** 사용자에게 식별되는 UI/정보만 (텍스트 + 표시 이름 + 이미지 에셋). 기술 식별자 제외.
- **Company / legal name:** OKR Best Inc
- **Service / product name:** O'talk

## 1. 목적 (Goal)

Mattermost 포크인 본 앱에서 **최종 사용자가 인지하는 브랜드 표면**만 OKR Best Inc / O'talk로
교체한다. 인증·푸시·딥링크·스토어 등록에 영향을 주는 기술 식별자는 이번 범위에서 제외하여
무중단·저위험으로 1차 리브랜딩을 완료한다.

## 2. 이름 매핑 원칙

- **제품/서비스 지칭** ("Mattermost"가 앱·서비스를 의미) → **O'talk**
- **회사/법적 명칭** ("Mattermost, Inc.") → **OKR Best Inc**
- **OSS 라이선스 귀속·플랫폼·커뮤니티 표기** → **원문 유지** (라이선스/상표 준수)

## 3. 범위 — 포함 (IN)

### 3.1 화면 표시 이름 (App display name)
| 위치 | 현재 | 변경 |
|---|---|---|
| `app.json` `displayName` | `Mattermost` | `O'talk` |
| `ios/Mattermost/Info.plist` `CFBundleDisplayName` | `Mattermost` | `O'talk` |
| `ios/NotificationService/Info.plist` `CFBundleDisplayName` | (Mattermost) | `O'talk` |
| `ios/MattermostShare/Info.plist` `CFBundleDisplayName` | (Mattermost) | `O'talk` |
| `android/app/src/main/res/values/strings.xml` `app_name` | `Mattermost Beta` | `O'talk` |

> `app.json` `name`, `scheme` 및 iOS/Android의 bundle/package 식별자는 **변경하지 않음**(기술 식별자, §4).

### 3.2 텍스트 — `assets/base/i18n/en.json` (정본; 다른 언어 파일은 건드리지 않음)

**→ O'talk (제품 정체성)**
- `about.mattermost`
- `about.planNameLearn`
- `extension.no_memberships.description`
- `extension.no_servers.description`
- `invite_people_to_team.message`
- `mobile.calls_mic_error`
- `mobile.calls.foreground_service.channel_name` ("Mattermost Calls" → "O'talk Calls")
- `mobile.calls.foreground_service.title`
- `mobile.managed.not_secured.android`
- `mobile.managed.not_secured.ios`
- `mobile.server_upgrade.description`
- `onboaring.welcome_description` ("O'talk is an open source platform …" — "open source" 표현 유지, 이름만 교체)
- `rate.title` ("Enjoying O'talk?")

**→ OKR Best Inc (회사/법적)**
- `settings.about.copyright` → `Copyright {currentYear} OKR Best Inc. All rights reserved` (시작 연도 2026 = 현재 연도이므로 범위 표기 생략, 단일 `{currentYear}`)

**→ 유지 (OSS 귀속/플랫폼/커뮤니티)**
- `settings.notice_text` ("made possible by the open source software …")
- `settings.about.powered_by` ("{site} is powered by Mattermost")
- `about.teamEditionLearn` ("Join the Mattermost community at ")

### 3.3 브랜딩 정보 — `assets/base/config.json`
- `WebsiteURL` `https://mattermost.com` → `https://okr.best`
- `DefaultServerName` `""`(현재 공란, 확인 완료) → `O'talk` (서버 추가 화면 표시이름 기본값, `app/screens/server/index.tsx:99`)
- `ServerNoticeURL`, `MobileNoticeURL` → **유지** (OSS NOTICE)
- `AuthUrlScheme`/`AuthUrlSchemeDev` (`mmauth://`/`mmauthbeta://`) → **유지** (기술 식별자)

### 3.4 이미지 에셋 (사용자 원본 제공 → 해상도별 가공 후 교체)
- **앱 아이콘:** iOS `ios/Mattermost/Images.xcassets/AppIcon.appiconset/*`; Android `android/app/src/main/res/mipmap-*/ic_launcher.png`·`ic_launcher_round.png`·`ic_launcher_foreground.png`·`ic_launcher_background.png` + `mipmap-anydpi-v26/*.xml` (적응형 배경/전경 검토)
- **스플래시:** iOS `Images.xcassets/SplashIcon.imageset`(라이트/다크 @2x/@3x)·`SplashBackground.imageset`·`SplashBackgroundColor.colorset`; Android splash drawable(`drawable-night-*` 포함); 생성 원본 `assets/base/release/splash_screen/`
- **인앱 로고:** `assets/base/images/logo.png`(로그인/서버 화면), `assets/base/images/icon.png`

## 4. 범위 — 제외 (OUT, 다음 단계)

기술 식별자 — 사용자 비식별이며 변경 시 인증/푸시/딥링크/스토어·백엔드 연동이 깨짐:
URL 스킴 `mattermost`, `mmauth://`/`mmauthbeta://`, iOS bundle identifier, Android `applicationId`/package,
App Group identifier, 푸시 알림 토픽, 딥링크 호스트. 또한 `:mattermost:` 이모지 에셋
(`assets/base/images/emojis/mattermost.png`)도 이번 제외.

## 5. Assumptions (미결 항목의 확정 기본값)

- **A1 — WebsiteURL:** `https://okr.best`로 변경 (확정).
- **A2 — DefaultServerName:** 현재 공란 확인 완료 → `O'talk`로 설정 (서버 추가 화면 표시이름 기본값).
- **A3 — Android 이름:** `Mattermost Beta` → **`O'talk`** (Beta 표기 제거, 단순화).
- **A4 — 유지 3개 문자열:** `powered_by`, `teamEditionLearn`, `notice_text`는 **유지**(라이선스/플랫폼 귀속).
- **A5 — 이미지 원본 제공 시점:** **implement 단계**에서 제공. 교체 지점·규격은 본 문서 §3.4로 확정.
- **A6 — 저작권 연도:** 시작 연도 **2026**(=현재 연도) → 범위 대신 단일 `{currentYear}` 사용, 회사명 OKR Best Inc.

## 6. 검증 (Verification)

- `npm run tsc` + `npm run fix` 통과
- **mobile MCP 실제 실행** 확인: 홈 화면 앱 아이콘/이름(O'talk), 스플래시, 온보딩 문구,
  About 화면(저작권=OKR Best Inc, powered by/notice 유지), 평점 유도 문구
- en.json 신규/변경 후 `npm run i18n-extract` 정합성 (신규 ID 없음 — 기존 값 수정이므로 해당 시에만)

## 7. 비범위(Non-goals) / 리스크

- 스토어 메타데이터(앱스토어/플레이스토어 등재명·설명) 변경은 본 코드 범위 밖.
- OSS 귀속 임의 제거 금지(라이선스/상표 리스크). §3.2 유지 항목 준수.
- 기술 식별자 변경은 후속 스펙에서 백엔드/푸시/스토어와 함께 진행.

## 8. 다음 단계

본 설계 승인 → spec-kit `/speckit-specify`로 명시적 핸드오프 → plan → tasks →
(analyze 제안) → 스펙 완료 커밋 게이트(권유) → `/speckit-implement`(superpowers 활성)에서
텍스트·표시이름 변경 + 사용자 제공 이미지 에셋 교체 → 구현 완료 커밋 게이트(권유).
