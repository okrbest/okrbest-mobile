# DEPLOYMENT.md — O'talk 앱 빌드·배포 절차 (초보자용 정석)

> 이 문서는 **그대로 따라 하면 되는 하나의 정석 경로**만 본문에 담았습니다.
> 선택 사항·다른 방법·문제 해결은 맨 아래 **부록**에서만 참조하세요.
>
> - 앱: **O'talk** (React Native 0.83.9 / Expo 55), 패키지·번들 ID `com.okrbest.otalk`
> - 계정 경로: **조직(Organization) 계정** 기준 (D-U-N-S 발급 완료 상태)
> - 공식 문서 확인 시점: **2026년 7월**. 요구사항은 바뀔 수 있으니 각 단계의 공식 링크로 최신 여부를 확인하세요.

---

## 0. 전체 그림

| 구분 | Android (Google Play) | iOS (App Store) |
|------|----------------------|-----------------|
| 개발자 계정 | Google Play Console, **$25 1회** | Apple Developer Program, **$99/년** |
| 빌드 가능 OS | Windows / Linux / Mac | **Mac 필수** (Xcode) |
| 제출 형식 | **AAB** (App Bundle) | **IPA** (Xcode가 생성) |
| 서명 | 업로드 키(내가) + **Play App Signing**(Google) | **자동 서명**(Xcode 권장) |
| 심사 시간 | 보통 최대 7일 | 보통 24–48시간 |

> ⚠️ **iOS 빌드는 Mac에서만 가능합니다.** 이 저장소가 있는 현재 개발 환경(Linux)에서는 Android만 빌드됩니다. iOS는 Mac + Xcode 26 이상에서 진행하세요.

---

# PART A — Android (Google Play) 배포

## A-1. 준비물 확인
- [ ] Google Play Console 조직 계정 생성 완료 (https://play.google.com/console , $25 1회 결제)
- [ ] 이 저장소를 빌드할 수 있는 상태 (`npm install` 완료)
- [ ] JDK 설치됨 (`keytool`, 이미 있음)

## A-2. 업로드 키(keystore) 만들기 — **최초 1회만**

배포용 서명 키를 만듭니다. **이 파일과 비밀번호는 절대 잃어버리면 안 되고, git에 커밋 금지입니다.**

```bash
keytool -genkeypair -v \
  -keystore ~/keystores/otalk-upload.keystore \
  -alias otalk \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -storetype PKCS12
```

- 실행하면 **비밀번호**와 이름/조직 정보를 물어봅니다. 비밀번호는 안전하게 기록해 두세요.
- 만들어진 `~/keystores/otalk-upload.keystore` 파일을 **여러 곳에 백업**하세요(클라우드 등).

> 💡 이 키를 잃어버려도 **Play App Signing을 켜 두면**(A-6에서 자동) 앱을 다시 등록할 필요 없이 Play Console에서 업로드 키를 재설정할 수 있습니다. 그래도 백업은 필수입니다.

## A-3. 서명 정보를 Gradle에 연결 — **최초 1회만**

**저장소 밖** 파일인 `~/.gradle/gradle.properties`에 아래를 추가합니다(홈 디렉터리라 커밋 위험 없음):

```properties
MATTERMOST_RELEASE_STORE_FILE=/home/사용자명/keystores/otalk-upload.keystore
MATTERMOST_RELEASE_KEY_ALIAS=otalk
MATTERMOST_RELEASE_PASSWORD=A-2에서_정한_비밀번호
```

> 이 프로젝트의 `android/app/build.gradle`은 이미 이 세 값을 읽도록 설정돼 있습니다. 값만 채우면 됩니다.

## A-4. 버전 올리기 — **업로드할 때마다 매번**

`android/app/build.gradle`에서 `versionCode`를 **이전보다 큰 숫자로** 올립니다(중복 불가). 사용자에게 보이는 버전은 `versionName`.

```gradle
versionCode 790        // 이전 업로드보다 큰 정수로 반드시 증가
versionName "2.43.1"   // 사용자에게 보이는 버전
```

## A-5. AAB 빌드

```bash
cd android
./gradlew :app:bundleRelease
```

산출물: **`android/app/build/outputs/bundle/release/app-release.aab`**

서명 확인(선택):
```bash
# A-3 설정이 맞으면 업로드 키로 서명되어 있음
jarsigner -verify -verbose app-release.aab | head
```

## A-6. Play Console에 앱 만들기 + 기본 정보 작성 — **최초 1회만**

Play Console(https://play.google.com/console)에서:

1. **앱 만들기** → 앱 이름·기본 언어·앱/게임 여부·유·무료 선택
2. 좌측 메뉴 **"앱 설정 → 앱 콘텐츠(App content)"** 의 모든 항목 작성:
   개인정보처리방침, 앱 액세스 권한, 광고 포함 여부, 콘텐츠 등급, 타겟층, 데이터 보안(Data safety)
3. **"스토어 설정 → 기본 스토어 등록정보(Store listing)"**: 앱 설명, 스크린샷, 아이콘, 카테고리, 지원 이메일

## A-7. 팀원·테스터에게 내부 테스트 배포 — **프로덕션 전에 여기서 먼저 확인**

프로덕션에 올리기 전에 **내부 테스트(Internal testing)** 로 소수에게 먼저 배포해 확인합니다.
심사 대기가 없어 업로드 후 **몇 분 내** 테스터가 받을 수 있습니다.

1. 좌측 **"테스트 및 출시 → 테스트 → 내부 테스트(Internal testing)"**
2. **테스터(Testers)** 탭 → **이메일 목록 만들기** → 팀원·테스터 이메일 주소 입력(최대 **100명**)
3. **새 버전 만들기** → A-5의 `app-release.aab` 업로드 → 출시
   - Play App Signing은 신규 앱에서 **자동으로 켜집니다**(권장, 그대로 둠)
4. **참여 링크(opt-in URL)** 복사 → 팀원·테스터에게 전달
5. 테스터는 그 링크를 휴대폰에서 열어 **테스터 등록** → Play 스토어에서 O'talk 설치
6. 새 빌드는 A-4(versionCode↑) → A-5 → 이 화면에서 **새 버전 만들기** 반복

> 내부 테스트 트랙: 최대 100명, 심사 없음. 더 많은 인원(2,000명 목록)이 필요하면 **비공개 테스트(Closed testing)** 사용 → 부록 C.
> 공식: https://support.google.com/googleplay/android-developer/answer/9845334

## A-8. 프로덕션(정식) 출시

테스트로 확인이 끝나면 정식 출시합니다.

1. **"테스트 및 출시 → 프로덕션(Production)"** → **새 버전 만들기**
2. A-5의 `app-release.aab` 업로드 (또는 내부 테스트 버전을 **승격**해 재사용)
3. 출시 노트 작성 → **검토 후 프로덕션 출시 시작**

> 심사는 보통 최대 7일. 신규 앱·신규 계정은 더 걸릴 수 있습니다.
> 공식 절차: https://support.google.com/googleplay/android-developer/answer/9859348

✅ **Android 끝.**

---

# PART B — iOS (App Store) 배포 · **Mac 필수**

> 아래는 **Mac + Xcode 26 이상**에서 진행합니다. Apple은 **2026년 4월 28일부터 iOS 26 SDK(= Xcode 26 이상)로 빌드한 앱만** 업로드를 허용합니다.
> 공식: https://developer.apple.com/news/upcoming-requirements/

## B-1. 준비물 확인
- [ ] Mac + **Xcode 26 이상** 설치
- [ ] Apple Developer Program 조직 멤버십 활성 ($99/년, https://developer.apple.com/programs/ )
- [ ] Apple ID로 Xcode 로그인 (Xcode → Settings → Accounts에 계정 추가)

## B-2. 번들 ID 등록 + 앱 레코드 만들기 — **최초 1회만**

1. **Apple Developer 포털**(https://developer.apple.com/account) → Certificates, Identifiers & Profiles → **Identifiers** → `+` → App ID → 번들 ID **`com.okrbest.otalk`** 등록
2. **App Store Connect**(https://appstoreconnect.apple.com) → 앱 → `+` → **새로운 앱** → 이름·기본 언어·번들 ID(`com.okrbest.otalk`)·SKU 입력

## B-3. 프로젝트 열기 + 자동 서명 설정

```bash
# 저장소에서 (Mac)
npm run pod-install          # CocoaPods 설치
open ios/Mattermost.xcworkspace   # .xcodeproj 아님, .xcworkspace 를 열 것
```

Xcode에서:
1. 좌측 프로젝트 네비게이터 → 타겟 선택 → **Signing & Capabilities** 탭
2. **"Automatically manage signing"** 체크 (Apple 권장 방식)
3. **Team**을 조직 계정으로 선택 → 서명 인증서·프로파일이 자동 생성됨

## B-4. 빌드(Archive) + 업로드

1. Xcode 상단 기기 선택에서 **"Any iOS Device (arm64)"** 선택
2. 메뉴 **Product → Archive**
3. Archive 완료되면 **Organizer** 창이 뜸 → **Distribute App** → **App Store Connect** → **Upload**
4. 자동 서명이면 나머지는 기본값으로 진행 → 업로드 완료

## B-5. 팀원·테스터에게 TestFlight 배포 — **정식 심사 전에 여기서 먼저 확인**

업로드한 빌드를 **TestFlight**로 팀원에게 먼저 배포해 확인합니다.
App Store Connect(https://appstoreconnect.apple.com) → 해당 앱 → **TestFlight** 탭.

**팀원(내부 테스터) — 가장 빠름, 심사 없음**
1. 먼저 팀원을 App Store Connect **사용자**로 초대(역할: Admin / App Manager / Developer 등)
2. **TestFlight → 내부 테스트(Internal Testing)** 그룹에 팀원 추가 → B-4에서 올린 빌드 선택
3. 처리 완료되면 **몇 분 내** 팀원이 받을 수 있음(최대 **100명**, Beta App Review 불필요)

**외부 테스터(팀 밖 사람) — 공개 링크**
1. **외부 테스트(External Testing)** 그룹 만들기 → 빌드 추가
2. 그룹의 **첫 빌드는 Beta App Review 통과 필요**(정식 심사보다 가벼움)
3. **공개 링크(Public Link)** 생성 → 테스터에게 전달(최대 **10,000명**)

**테스터가 설치하는 법**
- 휴대폰에 App Store에서 **TestFlight 앱** 설치 → 받은 **초대 이메일 링크** 또는 **공개 링크** 열기 → O'talk 설치

> TestFlight 빌드는 **90일**간 유효(이후 만료). 새 빌드는 B-4를 반복해 업로드.
> 공식: https://developer.apple.com/testflight/

## B-6. 메타데이터 작성 + 정식 심사 제출

TestFlight 확인이 끝나면 정식 출시합니다. App Store Connect에서:
1. 앱 정보·스크린샷·설명·키워드·카테고리·개인정보 항목·가격/출시 국가 작성
2. **빌드 선택**에서 업로드된 빌드 지정
3. **심사에 제출(Submit for Review)**

> 심사는 보통 24–48시간(약 90%가 24시간 내). 승인 후 수동 또는 자동 출시.
> 공식: https://developer.apple.com/distribute/app-review

✅ **iOS 끝.**

---

## 요약 치트시트

```bash
# ── Android (어디서나) ──
# 1) 최초 1회: 키 생성 + ~/.gradle/gradle.properties 설정 (A-2, A-3)
# 2) 매번: versionCode 올리기 (A-4)
cd android && ./gradlew :app:bundleRelease
#   → app-release.aab 를 Play Console 에 업로드
#   → 테스트: 내부 테스트 트랙 + 이메일 목록 + 참여 링크 전달 (A-7)
#   → 정식: 프로덕션 트랙 업로드 후 심사 제출 (A-8)

# ── iOS (Mac만) ──
npm run pod-install
open ios/Mattermost.xcworkspace
#   → Xcode: 자동 서명 → Product > Archive → Distribute > Upload
#   → 테스트: TestFlight 탭 + 내부/외부 그룹 + 링크 전달 (B-5)
#   → 정식: App Store Connect 메타데이터 작성 후 심사 제출 (B-6)
```

> 배포 순서 요약: **빌드 → 테스터에게 먼저(Android 내부 테스트 / iOS TestFlight) → 확인 후 정식 출시.**

---
---

# 부록 (선택 사항 — 본문을 따랐다면 몰라도 됩니다)

## 부록 A. Fastlane 자동화 (반복 배포·CI용)
이 저장소에는 Fastlane이 이미 구성돼 있습니다(`fastlane/Fastfile`). 수동 업로드 대신 자동화하고 싶을 때만.
- Android 배포 lane: `supply`(Play 업로드) 사용 → `fastlane android deploy`
- iOS 배포 lane: `gym`(빌드) + `pilot`(TestFlight) / `deliver`(스토어) 사용 → `fastlane ios deploy`
- 프로젝트 래퍼: `npm run build:android`, `npm run build:ios` (→ `scripts/build.sh`)
- iOS 인증서 공유는 `match`(Matchfile) 기반 — 팀·CI 환경에서 인증서를 git repo로 공유. 개인 최초 배포엔 불필요.

## 부록 B. 개인(Personal) 계정으로 Play 배포하는 경우
조직 계정이 아니라 **개인 계정**(2023-11-13 이후 생성)으로 배포하면, 프로덕션 출시 전에
**최소 12명의 테스터가 14일 연속 비공개 테스트(Closed testing)에 참여**해야 합니다.
- 공식: https://support.google.com/googleplay/android-developer/answer/14151465
- 조직 계정(D-U-N-S 보유)은 이 규칙이 **면제**됩니다 → 본문의 조직 경로 권장 이유.

## 부록 C. 더 큰 규모의 테스트 트랙 (본문 A-7 / B-5 보완)
본문(A-7 내부 테스트, B-5 TestFlight)으로 충분하지만, 인원이 더 필요하거나 단계가 나뉠 때:
- **Android 트랙 위계**: Internal testing(내부, 최대 100명) → **Closed testing(비공개, 이메일 목록당 2,000명·최대 50목록)** → Open testing(공개, 제한 없음) → Production.
  - 비공개 테스트는 이메일 목록 외에 **Google Groups**(`이름@googlegroups.com`)로도 테스터 추가 가능.
  - ⚠️ **개인 계정**은 프로덕션 전에 비공개 테스트 12명·14일이 **의무**(부록 B). 조직 계정은 면제.
  - 공식: https://support.google.com/googleplay/android-developer/answer/9845334
- **iOS TestFlight 규모**: 내부 100명(심사 없음) / 외부 10,000명(첫 빌드 Beta App Review). 테스터당 기기 30대, 빌드 90일 유효.
  - 공식: https://developer.apple.com/testflight/

## 부록 D. Android — 로컬 테스트용 빌드 (스토어 제출 아님)
기기·에뮬레이터에서 바로 설치해 확인할 때:
```bash
cd android
./gradlew :app:assembleDebug   # debug.keystore 자동 서명, 설정 불필요
#   → app/build/outputs/apk/debug/app-debug.apk
```
APK는 스토어 제출용이 아니라 **직접 설치/테스트용**입니다(신규 앱 Play 제출은 AAB만).

## 부록 E. Android — Play App Signing을 쓰지 않고 직접 서명하는 경우 (비권장)
Play App Signing을 끄면 **앱 서명 키를 본인이 보관**하며, 분실 시 **같은 앱 업데이트가 영구 불가**(새 패키지명으로 새 앱 등록해야 함). 신규 배포에는 권장하지 않습니다. 그래도 필요하면 unsigned 빌드 후 `apksigner`로 수동 서명:
```bash
cd android && ./gradlew :app:assembleRelease   # gradle.properties 설정 시 release 서명
# 또는 unsigned 후 수동 서명:
# ./gradlew :app:assembleUnsigned
# $ANDROID_HOME/build-tools/<버전>/zipalign -v 4 in.apk aligned.apk
# $ANDROID_HOME/build-tools/<버전>/apksigner sign --ks <keystore> --ks-key-alias otalk aligned.apk
```

## 부록 F. iOS — 수동 서명 (자동 서명이 안 될 때만)
Apple은 **자동 서명을 권장**합니다(부록 아님, 본문 B-3). 팀 정책상 수동이 필요할 때만:
- Developer 포털에서 **Distribution Certificate** + **App Store Provisioning Profile**(번들 ID `com.okrbest.otalk`) 생성
- Xcode Signing & Capabilities에서 "Automatically manage signing" 해제 후 해당 프로파일 지정
- 공식: https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile

## 부록 G. 타겟 API / SDK 마감일 (참고)
- **Google Play**: 2025-08-31부터 API 35(Android 15), **2026-08-31부터 API 36(Android 16)** 이상 타겟 필수. 이 프로젝트는 이미 `targetSdkVersion = 36` 이라 충족.
  - 공식: https://support.google.com/googleplay/android-developer/answer/11926878
- **Apple**: 2026-04-28부터 **Xcode 26 + iOS 26 SDK**로 빌드 필수(빌드 SDK 기준이며, 최소 지원 iOS 버전은 별개로 낮게 유지 가능).
  - 공식: https://developer.apple.com/news/upcoming-requirements/

## 부록 H. 자주 막히는 지점
- **Play "업로드 키가 이미 사용됨" / 서명 불일치**: 첫 업로드 이후에는 항상 같은 업로드 키로 서명해야 함.
- **Play `versionCode` 중복 오류**: 매 업로드마다 `versionCode`를 반드시 증가.
- **iOS `ITMS-90725` 류 SDK 오류**: 오래된 Xcode로 빌드함 → Xcode 26 이상으로 재빌드.
- **iOS 업로드 시 서명 실패**: Xcode → Settings → Accounts에 조직 팀이 있는지, 번들 ID가 `com.okrbest.otalk`로 일치하는지 확인.
