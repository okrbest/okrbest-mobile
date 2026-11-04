# App Store 등록·배포 가이드 (O'talk iOS)

O'talk iOS 앱을 **빌드할 Mac을 준비**하고, **Apple 개발자 포털과 App Store Connect에 앱을 등록**한 뒤,
**TestFlight를 거쳐 App Store에 출시**하는 절차를 초보자가 순서대로 따라할 수 있게 정리했다.
Apple 공식 문서(App Store Connect 도움말, Developer 계정 도움말, App Review 가이드라인,
Upcoming Requirements)를 2026-11-04에 확인해서 작성했다. 화면 문구는 App Store Connect
한국어 UI 기준이며, 영어 UI 명칭을 괄호로 함께 적었다.

> **이 문서의 범위.** Mac 빌드 환경, Apple 포털 설정, App Store Connect 등록, TestFlight, 심사
> 제출까지 다룬다. Android는 [google-play-store-release-guide.md](./google-play-store-release-guide.md)를
> 본다. 시뮬레이터 개발 환경은 [CLAUDE-IOS-SIMULATOR.md](../CLAUDE-IOS-SIMULATOR.md)를 참고한다.

> **대전제: Mac이 필요하다.** iOS 앱은 macOS의 Xcode로만 빌드·서명·업로드할 수 있다. 지금 쓰는
> WSL2 Linux 환경에서는 할 수 없다. 2026-04-28부터 App Store Connect는 **Xcode 26 이상**으로 빌드한
> 앱만 받으므로, macOS 15.6(Sequoia) 이상이 설치되는 Mac이 있어야 한다. Mac이 없으면
> GitHub Actions의 macOS 러너(저장소의 `.github/workflows/build-ios-release.yml`)나 클라우드 Mac을 쓴다.

## 0. 전체 흐름과 소요 기간

| 단계 | 하는 일 | 걸리는 시간(대략) |
|---|---|---|
| 1 | 준비물 모으기 | 반나절 |
| 2 | Mac 빌드 환경 구성 | 반나절 (Xcode 다운로드 포함) |
| 3 | Apple 개발자 포털: App ID 3개, App Group, iCloud 컨테이너, APNs 키 | 1시간 |
| 4 | Xcode 프로젝트의 팀(Team) 교체 | 30분 |
| 5 | App Store Connect: 앱 레코드 만들기 | 10분 |
| 6 | 앱 정보·개인정보 라벨·연령 등급·스크린샷 입력 | 2~4시간 |
| 7 | 서명된 빌드 만들기 + 업로드 | 1시간 (첫 빌드는 더 걸림) |
| 8 | TestFlight 내부 테스트 | 며칠 |
| 9 | 심사 제출 → 승인 → 출시 | 심사는 보통 1~3일, 첫 앱은 더 걸릴 수 있음 |
| 10 | 업데이트 반복 | 회당 1시간 + 심사 |

Apple Developer Program 조직 계정은 이미 있고 D-U-N-S 등록도 끝났으므로 계정 가입 단계는 없다.
연회비(US$99)는 매년 갱신된다. 만료되면 앱이 스토어에서 내려가므로 결제 수단을 유지한다.

## 1. 준비물 체크리스트

계정·권한:

- [ ] Apple Developer Program **조직 계정**의 **Account Holder** 또는 **Admin** 권한을 가진 Apple ID (2단계 인증 필수)
- [ ] **Team ID** (10자리 영숫자). developer.apple.com → 계정 → Membership details에서 확인
- [ ] App Store Connect의 **최신 계약 동의**. Account Holder가 App Store Connect → 비즈니스(Business)에서 Apple Developer Program License Agreement에 동의해야 앱을 만들 수 있다. 무료 앱이므로 유료 앱 계약(Paid Apps)은 필요 없다

장비:

- [ ] macOS 15.6 이상 Mac, 여유 디스크 60GB 이상 (Xcode 26 + 시뮬레이터 + 빌드 산출물)
- [ ] 실기기 iPhone 1대 (푸시·통화·공유 확장 확인용)

앱 정보 (Android 가이드와 같은 재료를 재사용한다):

- [ ] 개인정보처리방침 URL: https://okr.best/privacy-policy
- [ ] 지원 URL: https://okr.best/faq, 마케팅 URL: https://okr.best
- [ ] 심사관용 **테스트 서버 URL + 계정(아이디/비밀번호)**. 로그인 없이는 쓸 수 없는 앱이라 필수다 (가이드라인 2.1)
- [ ] 앱 이름 `O'talk`, 부제(30자), 설명(4,000자), 키워드(100자)의 한국어·영어 문안. `fastlane/metadata/ko/`, `en-US/`에 작성해 두었다
- [ ] 연락 담당자 이름·전화·이메일 (심사팀이 연락하는 용도, 비공개)

그래픽 자산:

| 자산 | 규격 |
|---|---|
| 앱 아이콘 | 1024×1024 PNG, 알파 없음. 이미 `ios/Mattermost/Images.xcassets/AppIcon.appiconset/iTunesArtwork@2x.png`에 있고 빌드에 포함되어 자동으로 올라간다 |
| iPhone 스크린샷 (필수) | **6.1형**(Dynamic Island 중형) 1179×2556 또는 1206×2622 px, 최소 1장, 최대 10장 |
| iPhone 스크린샷 (권장) | **6.9형** 1320×2868 px (없으면 6.5형 1284×2778이 필수가 됨) |
| iPad 스크린샷 (필수) | 이 앱은 iPad를 지원하므로(`TARGETED_DEVICE_FAMILY = 1,2`) **13형** 2064×2752 또는 2048×2732 px 최소 1장 |
| 형식 | PNG 또는 JPEG, 알파 채널 없음. 실제 사용 화면이어야 하고 로그인 화면·스플래시만으로는 안 된다 (가이드라인 2.3.3) |

Android용으로 만든 1080×2120 스크린샷은 비율이 달라 그대로 쓸 수 없다. 시뮬레이터(iPhone 16 Pro,
iPhone 16 Pro Max, iPad Pro 13형)에서 `Cmd+S`로 캡처하면 위 규격이 바로 나온다.

## 2. Mac 빌드 환경 구성

### 2.1 Xcode 26

1. Mac App Store에서 **Xcode**를 설치한다(약 15GB). 또는 developer.apple.com/download에서 받는다.
2. 처음 실행해 추가 구성 요소 설치를 허용하고, 터미널에서 라이선스에 동의한다.

```bash
sudo xcode-select -s /Applications/Xcode.app
sudo xcodebuild -license accept
xcodebuild -downloadPlatform iOS      # iOS 26 시뮬레이터 런타임, 수 GB
xcodebuild -version                   # "Xcode 26.x" 이어야 한다
```

3. Xcode → Settings → Accounts에서 Apple ID를 추가하고 OKR Best 팀이 보이는지 확인한다.

### 2.2 Node, Ruby, CocoaPods

Android 가이드의 도구 버전과 같다. 진실 원천은 저장소 파일이다.

```bash
# Homebrew가 없으면 https://brew.sh 절차로 설치
brew install nvm rbenv ruby-build watchman

cd <저장소 루트>
nvm install && nvm use                # .nvmrc
rbenv install "$(cat .ruby-version)"  # Ruby 3.2.11
rbenv local "$(cat .ruby-version)"
gem install bundler -v "$(tail -1 fastlane/Gemfile.lock | tr -d ' ')"

npm install                           # postinstall이 patch-package 적용
npm run ios-gems                      # 루트 Gemfile: cocoapods 1.16.1
npm run pod-install                   # ios/Pods 생성, 처음은 10분 이상
```

### 2.3 환경 검증

```bash
xcodebuild -version                    # 26.x
pod --version                          # 1.16.1
node -v && ruby -v                     # engines 범위 / 3.2.11
cd fastlane && bundle check            # dependencies are satisfied
cd ../ios && xcodebuild -workspace Mattermost.xcworkspace -scheme Mattermost -showBuildSettings | grep -m1 PRODUCT_BUNDLE_IDENTIFIER
# com.okrbest.otalk 이 나오면 워크스페이스 구성 완료
```

## 3. Apple 개발자 포털 설정 (Certificates, Identifiers & Profiles)

developer.apple.com/account → **Certificates, Identifiers & Profiles**. Account Holder 또는 Admin만
할 수 있다. 저장소의 entitlements 파일이 요구하는 항목을 그대로 등록한다. 값은
[specs/002-otalk-self-distribution/contracts/app-identity.md](../specs/002-otalk-self-distribution/contracts/app-identity.md)가
진실 원천이다.

### 3.1 App Group과 iCloud 컨테이너 먼저

1. **Identifiers → + → App Groups → Continue**. Description `O'talk App Group`, Identifier
   `group.com.okrbest.otalk` → Register.
2. **Identifiers → + → iCloud Containers → Continue**. Description `O'talk iCloud`, Identifier
   `iCloud.com.okrbest.otalk` → Register.

### 3.2 App ID 3개 (모두 Explicit)

**Identifiers → + → App IDs → App → Continue**. Explicit을 고르고 아래 표대로 Bundle ID와
Capabilities를 체크한다. 확장(extension)은 반드시 메인 번들 ID를 접두어로 갖는다.

| Description | Bundle ID | 체크할 Capabilities |
|---|---|---|
| O'talk | `com.okrbest.otalk` | **Push Notifications**, **App Groups**(→ Configure에서 `group.com.okrbest.otalk` 선택), **iCloud**(Include CloudKit support 체크 안 함, → Configure에서 `iCloud.com.okrbest.otalk` 선택), **Communication Notifications**, Keychain Sharing(기본 포함) |
| O'talk Notification Service | `com.okrbest.otalk.NotificationService` | **App Groups**(`group.com.okrbest.otalk`) |
| O'talk Share | `com.okrbest.otalk.MattermostShare` | **App Groups**(`group.com.okrbest.otalk`) |

근거: `ios/Mattermost/Mattermost.entitlements`에 `aps-environment`, `icloud-services: CloudDocuments`,
`ubiquity-kvstore`, `usernotifications.communication`, `application-groups`, `keychain-access-groups`가
있고, 두 확장의 entitlements에는 `application-groups`만 있다.

### 3.3 APNs 인증 키 (.p8)

푸시 프록시(`mattermost-push-proxy`)가 APNs에 보낼 때 쓴다 (spec 작업 T016). 앱 빌드에는 필요 없다.

1. **Keys → + → Key Name** `O'talk APNs` → **Apple Push Notifications service (APNs)** 체크 → Continue.
2. **Configure**에서 환경은 Sandbox & Production, 유형은 Team Scoped를 고른다.
3. Register 후 **Download**. `.p8` 파일은 **한 번만** 내려받을 수 있다. Key ID와 Team ID를 함께
   팀 시크릿 저장소에 보관한다. 저장소에는 절대 커밋하지 않는다.

### 3.4 인증서와 프로비저닝 프로파일

두 가지 방법이 있다. **처음에는 A안**으로 올리고, 반복 배포가 시작되면 B안으로 옮기는 것을 권한다.

- **A안. Xcode 자동 서명(Automatically manage signing)**: Xcode가 배포 인증서와 App Store 프로파일을
  알아서 만든다. 포털에서 따로 만들 것이 없다. 4절에서 설정한다.
- **B안. fastlane match**: 인증서·프로파일을 암호화해 비공개 Git 저장소에 두고 팀과 CI가 공유한다.
  6절에서 설정한다.

## 4. Xcode 프로젝트의 팀(Team) 교체

프로젝트 파일에는 아직 **Mattermost의 Team ID(`UQ8HT4Q2XM`)** 가 남아 있다. 이 상태로는 OKR Best
계정으로 서명할 수 없다.

1. `ios/Mattermost.xcworkspace`를 Xcode로 연다 (`.xcodeproj`가 아니라 **.xcworkspace**).
2. 왼쪽 네비게이터에서 프로젝트 **Mattermost** → TARGETS에서 **Mattermost**, **NotificationService**,
   **MattermostShare** 세 타깃 각각에 대해 **Signing & Capabilities** 탭을 연다.
3. **Automatically manage signing**을 켜고 **Team**을 OKR Best 조직 팀으로 고른다.
4. 각 타깃의 Bundle Identifier가 3.2절 표와 같은지, Capabilities 목록에 App Groups
   (`group.com.okrbest.otalk`)가 체크되어 있는지 본다. 메인 타깃에는 Push Notifications, iCloud
   (CloudDocuments, 컨테이너 `iCloud.com.okrbest.otalk`), Communication Notifications가 보여야 한다.
5. 빨간 오류가 사라지고 "Provisioning Profile: Xcode Managed Profile"이 표시되면 끝이다.

명령줄로 한 번에 바꾸려면 (Team ID는 본인 값으로):

```bash
sed -i '' 's/DEVELOPMENT_TEAM = UQ8HT4Q2XM;/DEVELOPMENT_TEAM = <OKR Best Team ID>;/g' ios/Mattermost.xcodeproj/project.pbxproj
grep -c "<OKR Best Team ID>" ios/Mattermost.xcodeproj/project.pbxproj   # 6 이상이면 전부 바뀐 것
```

이 변경은 커밋한다. 푸시 테스트를 하려면 실기기를 Mac에 연결하고 **Product → Run**으로 한 번
설치해 자동 서명이 개발용 프로파일까지 만들어 두는 것이 좋다.

## 5. App Store Connect에서 앱 만들기

1. https://appstoreconnect.apple.com → **나의 앱(Apps)** → 왼쪽 위 **+** → **신규 앱(New App)**.
2. 양식을 채운다.
   - **플랫폼**: iOS
   - **이름**: `O'talk` (2~30자, 전 세계에서 유일해야 함. 이미 쓰는 앱이 있으면 등록 불가)
   - **기본 언어**: 한국어
   - **번들 ID**: 목록에서 `com.okrbest.otalk` 선택 (3.2절에서 등록했어야 보인다)
   - **SKU**: `otalk-ios` (내부 식별자, 사용자에게 안 보임, 나중에 못 바꿈)
   - **사용자 액세스**: 전체 액세스
3. **생성**. 상태가 **제출 준비 중(Prepare for Submission)** 인 앱 레코드가 생긴다.

확장 타깃(NotificationService, MattermostShare)은 메인 앱에 포함되어 올라가므로 별도 레코드가
필요 없다.

## 6. (선택) fastlane용 App Store Connect API 키와 match

A안(Xcode 자동 서명)으로 첫 출시를 끝냈다면 이 절은 건너뛰어도 된다. CI나 명령줄 배포를 쓸 때
돌아온다.

### 6.1 API 키 만들기

1. App Store Connect → **사용자 및 액세스(Users and Access)** → **통합(Integrations)** 탭 →
   **App Store Connect API** → **팀 키(Team Keys)**.
2. 처음이면 Account Holder가 **액세스 요청**을 눌러 약관에 동의한다.
3. **+ (API 키 생성)** → 이름 `fastlane`, 액세스 **App Manager** → 생성.
4. **Issuer ID**(페이지 상단, 팀 공통)와 **키 ID**를 적어 두고 **API 키 다운로드**로 `.p8`을 받는다.
   **한 번만** 받을 수 있다. 잃어버리면 폐기하고 새로 만든다.

저장소의 lane은 세 환경 변수로 키를 읽는다 (`fastlane/Fastfile`의 `get_apple_api_key`).

```bash
export IOS_API_KEY_ID=<키 ID>
export IOS_API_ISSUER_ID=<Issuer ID>
export IOS_API_KEY="$(awk 'NF {printf "%s\\n", $0}' ~/keystores/AuthKey_<키 ID>.p8)"   # 줄바꿈을 \n 문자로
```

### 6.2 match 설정

1. GitHub(또는 사내 Git)에 **비공개 저장소** `okrbest-ios-certificates`를 만든다. 내용은 비워 둔다.
2. 암호화 비밀번호(`MATCH_PASSWORD`)를 정해 팀 시크릿 저장소에 보관한다.
3. 인증서와 App Store 프로파일을 생성한다. 번들 ID 세 개를 모두 넘긴다.

```bash
# API 키를 match가 읽는 JSON 형식으로 저장소 밖에 저장한다 (한 번만)
printf '{"key_id":"%s","issuer_id":"%s","key":"%s"}' \
  "$IOS_API_KEY_ID" "$IOS_API_ISSUER_ID" "$IOS_API_KEY" > ~/keystores/asc_api_key.json
chmod 600 ~/keystores/asc_api_key.json

export MATCH_GIT_URL=git@github.com:okrbest/okrbest-ios-certificates.git
export MATCH_PASSWORD=<암호화 비밀번호>
cd <저장소 루트>/fastlane
bundle exec fastlane match appstore \
  -a com.okrbest.otalk,com.okrbest.otalk.NotificationService,com.okrbest.otalk.MattermostShare \
  --api_key_path ~/keystores/asc_api_key.json
```

4. 성공하면 Git 저장소에 암호화된 `certs/`와 `profiles/`가 생긴다. 이후 다른 Mac이나 CI에서는
   `.env.ios.release`의 `MATCH_READONLY=true` 설정대로 **읽기만** 한다(`fastlane ios certs`).
5. match로 만든 프로파일을 쓰려면 Xcode의 Automatically manage signing을 끄고 각 타깃에
   `match AppStore <번들 ID>` 프로파일을 지정한다. A안과 B안을 섞어 쓰면 서명 오류가 자주 난다.

`fastlane/Matchfile`은 비어 있고 주석뿐이다. 값은 전부 환경 변수(`fastlane/env_vars_example` 참고)로 넘긴다.

## 7. 빌드하고 업로드하기

### 7.1 버전 번호

iOS는 **버전(CFBundleShortVersionString, 예 2.46.0)** 과 **빌드 번호(CFBundleVersion, 예 831)** 두
값을 쓴다. 같은 버전 안에서 빌드 번호는 업로드마다 커져야 한다. 저장소의 lane은 **iOS 빌드 번호와
Android `versionCode`를 같은 숫자로 함께** 올리도록 되어 있다. 두 플랫폼이 같은 번호를 쓰는 것이
이 저장소의 관례이므로, Android가 833까지 썼다면 iOS 첫 업로드도 834부터 시작한다.

```bash
cd <저장소 루트>/fastlane
INCREMENT_BUILD_NUMBER=true BUILD_NUMBER=834 bundle exec fastlane set_app_build_number
# ios/Mattermost.xcodeproj의 CURRENT_PROJECT_VERSION과 android/app/build.gradle의 versionCode를 834로 바꾼다
# 버전 자체를 올릴 때: VERSION_NUMBER=2.47.0 bundle exec fastlane set_app_version
```

`INCREMENT_BUILD_NUMBER=true`가 없으면 lane이 아무것도 하지 않는다. 실행 후
`ios/Mattermost/Info.plist`의 `CFBundleVersion`도 같은 값인지 확인하고 커밋한다. iOS만 올리고
싶으면 pbxproj의 `CURRENT_PROJECT_VERSION`(3곳)과 Info.plist를 직접 고친다.

### 7.2 빌드 전에 확인할 환경 파일

`fastlane/.env.ios.release`는 빌드 lane이 Info.plist·entitlements·번들 ID를 다시 쓰는 데 쓰인다.
2026-11-04에 두 값을 바로잡았다.

| 변수 | 값 | 비고 |
|---|---|---|
| `IOS_APP_GROUP` | `group.com.okrbest.otalk` | 기존 `group.com.mattermost`는 포털에 없는 그룹이라 서명 실패 원인이었다 |
| `SENTRY_ENABLED` | `false` | 업스트림 Sentry 조직으로 심볼 업로드 시도 방지 (T025) |
| `IOS_ICLOUD_CONTAINER` | `iCloud.com.okrbest.otalk` | 3.1절과 일치 |
| `MATCH_APP_IDENTIFIER` | 번들 ID 3개 | 6.2절과 일치 |
| `INTUNE_ENABLED` | `false` | Microsoft Intune 앱 보호(MAM)를 끈다. 남아 있는 `INTUNE_CLIENT_ID`는 Mattermost 명의의 Entra ID 앱 등록이라 O'talk 번들 ID의 리다이렉트 URI가 없어 동작하지 않는다. Intune 고객이 생기면 OKR Best 명의로 앱을 등록해 새 ID로 교체한 뒤 켠다 |

### 7.3 A안: Xcode에서 Archive → 업로드 (처음 권장)

1. Xcode 상단 기기 선택에서 **Any iOS Device (arm64)** 를 고른다.
2. 메뉴 **Product → Archive**. 10~30분 걸린다. 끝나면 Organizer 창이 열린다.
3. Organizer에서 방금 만든 아카이브를 선택 → **Distribute App → App Store Connect → Upload**.
   "Manage Version and Build Number"는 끄고, 나머지는 기본값(Upload symbols 켬)으로 **Upload**.
4. 완료 메시지 후 App Store Connect **TestFlight** 탭에 빌드가 나타나기까지 10~30분 걸린다
   ("처리 중" 표시).

주의: Xcode Archive는 fastlane lane이 하는 Info.plist·번들 ID 치환을 거치지 않는다. 저장소의
값이 이미 O'talk 기준이므로 결과는 같지만, Intune 설정 같은 lane 전용 치환은 적용되지 않는다.

### 7.4 B안: fastlane으로 빌드

```bash
cd <저장소 루트>
export IOS_API_KEY_ID=... IOS_API_ISSUER_ID=... IOS_API_KEY=...   # 6.1절
export MATCH_GIT_URL=... MATCH_PASSWORD=...                         # 6.2절
npm run build:ios            # = fastlane ios build --env ios.release → 루트에 Otalk.ipa
cd fastlane && bundle exec fastlane ios deploy file:<저장소 루트>/Otalk.ipa --env ios.release   # pilot으로 TestFlight 업로드
```

빌드 lane은 작업 트리의 추적 파일(Info.plist, entitlements, pbxproj, 스플래시 자산)을 변형한다.
업로드가 끝나면 원복한다. `fastlane/metadata/`는 스토어 문안이 들어 있으므로 건드리지 않는다.

```bash
git status --short ios/            # 변경 목록 확인
git restore ios/                   # 버전 번호를 이 턴에 올렸다면 pbxproj·Info.plist는 제외하고 원복
```

## 8. 앱 정보 입력 (App Store Connect)

왼쪽 메뉴 순서대로 채운다. 저장 버튼은 각 페이지 오른쪽 위에 있다.

### 8.1 일반 → 앱 정보(App Information)

- **이름** `O'talk`, **부제** 30자 이내: `팀 목표와 대화를 하나로` (`fastlane/metadata/ko/subtitle.txt`)
- **카테고리**: 기본 **비즈니스**, 보조 **생산성**
- **콘텐츠 권한**: 타사 콘텐츠를 포함하지 않음
- **연령 등급 → 설정**: 2025년 7월 개편된 설문이다. 메신저이므로 "사용자 생성 콘텐츠", "사용자 간
  소통(메시지·채팅)", "무제한 웹 액세스(링크 열기)"에 해당 여부를 사실대로 답한다. 2026년 9월부터
  **소셜 미디어 기능** 질문 답변이 필수다. 결과는 보통 **13+** 이상으로 나온다. 한국은 GRAC 등급이
  별도 표시되며, 심사팀이 GRAC 등급 분류 번호(RCN)를 요구하면 그때 추가한다.
- **라이선스 계약**: Apple 표준 EULA 사용

### 8.2 일반 → 앱 개인 정보 보호(App Privacy)

1. **개인정보 처리방침 URL**: https://okr.best/privacy-policy
2. **시작하기**로 데이터 수집 설문을 연다. Android 데이터 보안 양식과 같은 기준으로 답한다.
   "수집"은 기기 밖으로 전송해 개발자나 파트너가 접근할 수 있는 것을 뜻한다. O'talk는 사용자가
   지정한 OKRBEST 서버로 보내므로 아래 항목이 일반적이다. **실제 빌드 설정**(Sentry·RudderStack이
   꺼져 있으면 진단·사용 데이터는 제외)에 맞춘다.

| 데이터 유형 | 세부 | 연결 여부 | 추적 | 목적 |
|---|---|---|---|---|
| 연락처 정보 | 이름, 이메일 주소 | 사용자와 연결됨 | 아니요 | 앱 기능 |
| 사용자 콘텐츠 | 이메일 또는 문자 메시지, 사진 또는 동영상, 오디오 데이터, 기타 사용자 콘텐츠 | 연결됨 | 아니요 | 앱 기능 |
| 식별자 | 사용자 ID, 기기 ID(푸시 토큰) | 연결됨 | 아니요 | 앱 기능 |
| 진단 | 충돌 데이터 | Sentry를 켠 경우에만 | 아니요 | 앱 기능 |

   "추적(Tracking)"은 광고·데이터 브로커 목적의 결합을 뜻하므로 모두 **아니요**다. 그래서 앱 추적
   투명성(ATT) 팝업도 필요 없다.
3. **게시**를 눌러야 라벨이 저장된다. 앱 업데이트 없이 언제든 수정할 수 있다.

### 8.3 가격 및 사용 가능 여부(Pricing and Availability)

- **가격**: 무료(KRW 0)
- **사용 가능 여부**: 처음에는 **대한민국**만 선택. 이유는 Android 가이드와 같다. EU 국가를 넣으려면
  먼저 **비즈니스 → 거래자 상태(DSA trader status)** 를 제출·인증해야 한다.
- **사전 주문** 없음

### 8.4 iOS 앱 → 버전 1.0 준비(Prepare for Submission)

버전 번호는 빌드의 `CFBundleShortVersionString`과 같게(예: 2.46.0) 바꾼다.

- **스크린샷**: 1절 규격대로 iPhone 6.1형(필수), 6.9형, iPad 13형을 올린다. 한국어가 기본이고,
  **영어(미국)** 현지화를 추가해 같은 그림을 재사용할 수 있다.
- **프로모션 텍스트**(170자, 심사 없이 수정 가능), **설명**(4,000자), **키워드**(100자, 쉼표 구분,
  이름·카테고리 단어 반복 금지): `fastlane/metadata/ko/`와 `en-US/`의 파일을 붙여 넣는다.
- **지원 URL** https://okr.best/faq, **마케팅 URL** https://okr.best
- **저작권**: `2026 OKR Best Inc.`
- **빌드**: **+** 를 눌러 TestFlight에 올라온 빌드를 선택한다. 처리 중이면 목록에 안 보인다.
- **앱 심사 정보(App Review Information)**:
  - **로그인 필요** 켬 → 사용자 이름, 암호 입력
  - **메모**에 서버 주소와 절차를 적는다. 예:

```
This app connects to a self-hosted OKRBEST workspace.
1. Launch the app and tap "로그인".
2. Enter server URL: https://<테스트 서버 주소>
3. Sign in with the credentials above.
Push notifications and calls require a second account; a second test account is listed below.
```

  - **연락처 정보**: 심사 중 전화가 올 수 있는 담당자
- **버전 출시(Version Release)**: 첫 출시는 **수동으로 이 버전 출시**를 권한다. 승인 후 서버 준비가
  끝났을 때 **출시** 버튼을 누르면 된다. 업데이트부터는 **단계적 출시(7일에 걸쳐 자동 업데이트 비율
  증가)** 를 쓸 수 있다.
- **수출 규정 준수**: `Info.plist`에 `ITSAppUsesNonExemptEncryption = false`가 있어 업로드 때
  질문이 생략된다. HTTPS 같은 표준 암호화만 쓰는 앱은 면제 대상이다.
- **광고 식별자(IDFA)**: 사용 안 함

## 9. TestFlight로 먼저 확인하기

업로드된 빌드는 **TestFlight** 탭에서 관리한다. 빌드는 업로드 후 **90일**이 지나면 만료된다.

| 구분 | 내부 테스터 | 외부 테스터 |
|---|---|---|
| 인원 | 최대 100명 | 최대 10,000명 |
| 자격 | App Store Connect에 **사용자로 등록된** 팀원(역할 무관) | 이메일만 있으면 됨, 공개 링크 가능 |
| 심사 | 없음, 처리 완료 즉시 | 첫 빌드는 **Beta App Review** 통과 필요(보통 하루 안) |
| 용도 | 개발팀 스모크 테스트 | 사내 전 직원·고객 베타 |

절차:

1. **사용자 및 액세스 → 사용자 → +** 로 팀원을 초대한다(역할은 Developer면 충분). 초대 수락까지
   기다린다.
2. **TestFlight → 내부 테스트 → +** 로 그룹 `O'talk Dev`를 만들고 테스터를 추가한다.
   "빌드 자동 배포"를 켜 두면 이후 업로드가 자동으로 간다.
3. 그룹에 빌드를 추가한다. 테스터는 iPhone에 **TestFlight 앱**을 설치하고 초대 메일의 링크를 열어
   설치한다.
4. **테스트 정보**(베타 앱 설명, 피드백 이메일)를 채워야 외부 그룹을 만들 수 있다.
5. 실기기에서 반드시 확인할 것: 서버 로그인, 푸시 알림 수신(프록시 연동 후), 음성 통화를 건 뒤
   홈으로 나가도 유지되는지, 사진 앱에서 공유 시트에 O'talk가 뜨고 업로드되는지, 알림 서비스 확장이
   메시지 본문을 보여 주는지.

## 10. 심사 제출과 출시

1. 8절의 모든 항목이 채워지면 버전 페이지 오른쪽 위 **심사에 추가(Add for Review)** → **App 심사에
   제출(Submit to App Review)** 을 누른다.
2. 상태가 **심사 대기 중 → 심사 중 → 승인됨(또는 거부됨)** 으로 바뀐다. 보통 24~48시간이지만 첫 앱은
   더 걸릴 수 있다. 플랫폼당 심사 중인 앱 버전은 하나뿐이다.
3. **거부되면** App Store Connect 상단 알림과 이메일로 사유가 온다. **심사(Review)** 페이지의
   메시지 스레드(Resolution Center)에서 답하거나 수정 빌드를 올려 다시 제출한다. 흔한 사유는
   심사관이 로그인을 못 한 경우(계정 만료, 서버 다운, 2단계 인증), 스크린샷이 실제 화면과 다른 경우,
   개인정보 라벨과 실제 수집이 다른 경우다.
4. **승인됨** 상태에서 수동 출시를 골랐다면 **이 버전 출시** 버튼을 누른다. 스토어 반영까지 최대
   24시간 걸린다.

## 11. 업데이트 배포 루틴

1. `set_app_build_number`로 빌드 번호를 올리고(버전 변경 시 `set_app_version`도) 커밋한다.
2. Archive 또는 `npm run build:ios`로 빌드해 업로드한다.
3. TestFlight 내부 그룹에서 확인한다.
4. App Store Connect에서 **+ 버전** 으로 새 버전을 만들고 **이 버전의 새로운 기능(What's New)** 을
   적는다(`fastlane/metadata/ko/release_notes.txt`). 스크린샷·설명은 바뀐 것만 고친다.
5. 빌드를 선택하고 단계적 출시를 켠 뒤 제출한다. 문제가 생기면 단계적 출시를 **일시 정지**할 수 있다.
6. 데이터 수집이나 연령 등급 관련 기능이 바뀌었으면 8.1·8.2를 갱신한다.

## 12. 2026년에 특히 신경 쓸 것

- **Xcode 26 / iOS 26 SDK 필수 (2026-04-28부터)**: 빌드 Mac과 CI 러너의 Xcode가 26 이상이어야
  업로드가 받아들여진다. 저장소 CI는 `macos-15-large` 러너를 쓰므로 Xcode 26이 설치된 이미지인지
  확인한다. 호환성 테스트 워크플로는 이미 `macos-26`으로 옮겨져 있다.
- **최소 배포 대상 iOS 13 이상 (2026-09-09부터)**: 이 앱은 iOS 18.0이 최소이므로 문제없다.
- **연령 등급 설문 개편**: 2026-01-31까지 새 설문에 답하지 않은 앱은 업데이트 제출이 막힌다. 신규
  앱은 8.1절에서 바로 새 설문을 채우므로 해당 없다. 2026년 9월부터 소셜 미디어 질문이 필수다.
- **개인정보 매니페스트(PrivacyInfo.xcprivacy)**: 2024-05-01부터 필수. 세 타깃 모두 파일이 있다.
  새 서드파티 SDK를 추가할 때 그 SDK의 매니페스트가 포함되는지 확인한다.
- **계정 삭제 규정(가이드라인 5.1.1(v))**: 앱 안에서 계정을 **만들 수 있으면** 앱 안에서 삭제도
  제공해야 한다. O'talk는 서버 관리자가 계정을 만들지만, 연결하는 서버에 공개 가입이 켜져 있으면
  심사관이 이 조항을 적용할 수 있다. 심사용 서버는 공개 가입을 끄고, 삭제 요청 경로를 개인정보처리방침에
  명시해 둔다.
- **EU 디지털 서비스법(DSA)**: EU 국가에 배포하려면 거래자 상태 인증이 선행되어야 한다. 대한민국만
  배포하는 동안은 해당 없다.
- **연회비 갱신**: Apple Developer Program은 매년 US$99다. 만료되면 앱이 내려간다.

## 13. 자주 막히는 지점

| 증상 | 원인과 해결 |
|---|---|
| Xcode에서 "No profiles for 'com.okrbest.otalk' were found" | 4절 Team이 아직 Mattermost 팀이거나 3.2절 App ID가 없다. Team을 바꾸고 Try Again |
| "Provisioning profile doesn't include the com.apple.security.application-groups entitlement" | App ID에 App Groups capability가 없거나 `group.com.okrbest.otalk`를 선택하지 않았다. 포털에서 Configure 후 Xcode에서 프로파일을 다시 받는다 |
| fastlane 빌드가 `group.com.mattermost` 관련 서명 오류 | `.env.ios.release`의 `IOS_APP_GROUP`이 옛 값이다. 2026-11-04 수정본인지 확인한다 |
| 업로드는 됐는데 TestFlight에 빌드가 안 보임 | 처리 중이다. 10~30분 기다린다. "Missing Compliance" 경고가 뜨면 수출 규정 질문에 답한다 |
| 업로드 거부: "SDK version issue" | Xcode 26 미만으로 빌드했다. 2.1절 |
| 업로드 거부: "The bundle version must be higher than the previously uploaded version" | 빌드 번호를 올리지 않았다. 7.1절 |
| 심사 거부 2.1: "We were unable to sign in" | 심사용 계정·서버가 죽었거나 2단계 인증이 켜져 있다. 전용 계정을 만들고 메모에 서버 URL을 적는다 |
| 심사 거부 5.1.1: 개인정보 라벨 불일치 | 8.2절 표와 실제 전송 데이터를 다시 대조한다 |
| 새 앱 이름을 쓸 수 없음 | 다른 개발자가 `O'talk`를 선점했다. 부제를 붙여 `O'talk - 팀 협업` 식으로 등록하거나 상표권으로 이의 제기한다 |
| 심사팀이 GRAC 등급 번호를 요구 | 게임물관리위원회 자체등급분류 번호(RCN)를 받아 앱 정보에 입력하고 재제출한다 |

## 14. 참고한 공식 문서 (2026-11-04 확인)

- Apple Developer
  - [Upcoming requirements (Xcode 26 SDK, iOS 13 최소, 연령 등급 등)](https://developer.apple.com/news/upcoming-requirements/)
  - [Program enrollment (조직 요건, 연회비)](https://developer.apple.com/help/account/membership/program-enrollment/)
  - [Register an App ID](https://developer.apple.com/help/account/identifiers/register-an-app-id)
  - [Create a private key (APNs .p8)](https://developer.apple.com/help/account/keys/create-a-private-key)
  - [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
  - [App privacy details](https://developer.apple.com/app-store/app-privacy-details/)
- App Store Connect 도움말
  - [Add a new app](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app)
  - [App information (이름 2~30자, 부제 30자)](https://developer.apple.com/help/app-store-connect/reference/app-information)
  - [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications)
  - [Set an app age rating](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating)
  - [Overview of export compliance](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance)
  - [App Store Connect API keys](https://developer.apple.com/help/app-store-connect/get-started/app-store-connect-api)
  - [TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview)
  - [Submit for review](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-for-review)
- fastlane: [match](https://docs.fastlane.tools/actions/match/)
