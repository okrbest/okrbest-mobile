# Google Play 스토어 등록·배포 가이드 (O'talk)

O'talk Android 앱을 Google Play에 **처음 등록하고 배포**한 뒤, 이후 **업데이트를 반복 배포**하는
절차를 초보자가 순서대로 따라할 수 있게 정리했다. Google Play Console 고객센터와 Android
개발자 문서의 공식 페이지를 2026-11-03에 확인해서 작성했다. 콘솔 화면 문구는 한국어 UI 기준이다.

> **이 문서의 범위.** Play Console 작업과 업로드 절차만 다룬다. 서명된 `.aab`를 만드는
> 빌드 환경 구성은 [android-release-build-setup.md](./android-release-build-setup.md)를 따른다.
> Play Console 화면은 자주 바뀌므로, 메뉴 이름이 다르면 각 절 끝의 공식 문서 링크로 확인한다.

## 0. 전체 흐름과 소요 기간

| 단계 | 하는 일 | 걸리는 시간(대략) |
|---|---|---|
| 1 | 준비물 모으기 | 반나절 |
| 2 | 개발자 계정(조직) 만들기 + 인증 | D-U-N-S 최대 30일, 결제 수단 인증 최대 5일 |
| 3 | Play Console에서 앱 만들기 | 10분 |
| 4 | 앱 콘텐츠 선언·스토어 등록정보 작성 | 2~4시간 |
| 5 | 서명된 `.aab` 빌드 | 수십 분 |
| 6 | 내부 테스트 트랙에 첫 업로드 (Play 앱 서명 자동 등록) | 30분 |
| 7 | 내부 → 비공개 테스트로 검증 | 며칠 |
| 8 | 프로덕션 출시 제출 + 검토 | 검토는 보통 수일, 신규 계정은 더 길 수 있음 |
| 9 | fastlane 자동 업로드 연결 (선택) | 1시간 |
| 10 | 업데이트 반복 배포 | 회당 1시간 + 검토 |

가장 오래 걸리는 것은 2단계다. **계정 인증을 가장 먼저 시작**하고, 기다리는 동안 4단계
재료를 준비한다.

## 1. 준비물 체크리스트

계정·회사 정보:

- [ ] 회사 명의로 관리할 **Google 계정** (개인 지메일보다 회사 도메인 계정 권장)
- [ ] 등록 수수료 **US$25 (1회, 환불 불가)** 를 낼 **신용/체크카드** — Mastercard, Visa, American Express. 선불카드는 불가
- [ ] **D-U-N-S 번호** — Apple Developer 등록 때 받은 OKR Best Inc의 번호를 그대로 쓴다
- [ ] 조직의 **법적 이름·주소** (D&B 프로필과 글자 단위로 같아야 한다)
- [ ] 조직 **공개 전화번호** (웹사이트나 사업자 등록부에서 확인 가능한 번호)
- [ ] 조직 **웹사이트** URL
- [ ] **개발자 이메일**과 **연락처 이메일** — 회사 도메인 주소여야 하고, 일반 무료 메일은 거부된다
- [ ] 일회용 비밀번호(OTP)를 받을 **전화번호** 2개 (연락처용, 개발자용. 같은 번호라도 되지만 계속 유효해야 한다)

앱 정보:

- [ ] 패키지 이름 `com.okrbest.otalk` (이미 `android/app/build.gradle`에 설정됨, 한 번 올리면 바꿀 수 없다)
- [ ] **개인정보처리방침 URL** — https://okr.best/privacy-policy (공개 페이지, 데이터 보안 양식 제출에 필수)
- [ ] 사용자 문의용 **지원 이메일** (스토어에 공개된다). 개인정보처리방침에 적힌 `sdh@okr.best`를 쓰거나 공용 주소를 새로 만든다
- [ ] 심사관이 로그인할 **테스트 서버 URL + 테스트 계정(아이디/비밀번호)** — O'talk는 로그인 없이는 쓸 수 없는 앱이라 필수다
- [ ] 앱 이름 "O'talk", 간단한 설명(80자 이내), 자세한 설명(4,000자 이내)의 **한국어·영어 문안** — `fastlane/metadata/android/ko-KR/`과 `en-US/`에 작성해 두었다. 콘솔에 붙여 넣을 때 이 파일을 원본으로 쓴다

그래픽 자산 (모두 필수):

| 자산 | 규격 |
|---|---|
| 앱 아이콘 | 512×512px, 32비트 PNG(알파 포함), 1,024KB 이하 |
| 그래픽 이미지(feature graphic) | 1024×500px, JPEG 또는 24비트 PNG(알파 없음) |
| 휴대전화 스크린샷 | 최소 2장, 최대 8장. JPEG 또는 24비트 PNG(알파 없음). 한 변 320~3,840px, 긴 변이 짧은 변의 2배를 넘지 않게 |
| 7인치·10인치 태블릿 스크린샷 | 기기 유형별 2~8장. 1,080~7,680px, 16:9 또는 9:16 권장 |

빌드 재료:

- [ ] 업로드 keystore (`~/keystores/otalk-upload.keystore`)와 alias·비밀번호
- [ ] [android-release-build-setup.md](./android-release-build-setup.md) 6절까지 마친 빌드 환경

## 2. 개발자 계정 만들기 (조직 계정)

### 2.1 개인 계정이 아니라 조직 계정을 쓰는 이유

Play Console 계정은 **개인**과 **조직** 두 종류다. O'talk는 OKR Best Inc 이름으로 배포하므로
조직 계정을 만든다. 공식 문서 기준으로 두 유형의 실무적 차이는 다음과 같다.

| 항목 | 개인 계정 | 조직 계정 |
|---|---|---|
| 신원 확인 | 신분증 + 본인 명의 카드 | D-U-N-S 번호로 조직 확인 + 결제 수단 인증 |
| 기기 인증 | Play Console 모바일 앱으로 Android 기기 인증 필요 | 해당 없음 |
| 프로덕션 출시 전 테스트 의무 | 2023-11-13 이후 생성 계정은 **비공개 테스트에 테스터 12명 이상을 14일 연속 유지** 후 "프로덕션 신청" 필요 | 해당 없음 |
| 스토어에 표시되는 개발자 이름 | 개인 이름 | 조직 법적 이름 |

즉 조직 계정이면 12명·14일 테스트 의무가 없어서 바로 프로덕션에 올릴 수 있다. 다만 아래 7절처럼
내부·비공개 테스트를 거치는 편이 안전하다.

### 2.2 D-U-N-S 번호 확인

1. Apple 등록 때 받은 D-U-N-S 번호를 꺼낸다. 없다면 Dun & Bradstreet 공식 사이트에서 조회·신청한다.
   **신청은 무료**이며, 수수료를 요구하는 대행 사이트는 피한다. 신규 발급은 최대 30일 걸린다.
2. D&B 프로필에 등록된 **조직 이름과 주소를 메모**한다. 뒤의 결제 프로필에 글자 단위로 똑같이
   입력해야 인증이 통과된다.

### 2.3 가입 절차

1. 회사 Google 계정으로 로그인한 상태에서 https://play.google.com/console/signup 에 접속한다.
2. 계정 유형에서 **조직**을 선택한다.
3. **결제 프로필**을 만들거나 연결한다. 여기에 D-U-N-S 번호, 조직 법적 이름, 주소를 입력한다.
   Play Console은 이 세 항목을 결제 프로필에서 가져오므로 가입 양식에서 따로 고칠 수 없다.
4. 가입 양식의 나머지 항목을 채운다: 개발자 이름(스토어에 표시됨), 조직 전화번호, 조직 웹사이트,
   연락처 이름·이메일·전화번호, 개발자 이메일·전화번호.
5. 전화번호로 온 OTP와 이메일 인증을 완료한다.
6. **Google Play 개발자 배포 계약**을 읽고 동의한다.
7. 카드로 **US$25**를 결제한다.
8. Play Console 상단 배너나 이메일로 오는 **인증 요청**을 처리한다. 결제 수단 인증은 소액 시험
   입금 확인 또는 은행 서류 업로드 방식이며 최대 5일 걸린다.

인증이 모두 끝나면 Play Console 첫 화면에 **앱 만들기** 버튼이 활성화된다.

자주 막히는 곳:

- **"조직 이름 또는 주소가 인증되지 않습니다"**: 결제 프로필과 D&B 프로필이 다르다. D&B 쪽 표기에
  맞춰 결제 프로필을 수정한 뒤 배너의 **세부정보 보기 → 세부정보 검토**로 다시 제출한다.
- **이메일 거부**: `@gmail.com` 같은 일반 주소는 조직 계정 개발자·연락처 이메일로 받지 않는다.
- **D-U-N-S 상태가 "폐업"**: D&B에 직접 연락해 프로필을 살려야 한다.

공식 문서: [개발자 계정 등록](https://support.google.com/googleplay/android-developer/answer/6112435?hl=ko) ·
[조직 인증 요건](https://support.google.com/googleplay/android-developer/answer/13628312?hl=ko) ·
[계정 유형 선택](https://support.google.com/googleplay/android-developer/answer/13634885?hl=ko) ·
[신규 개인 계정의 테스트 요건](https://support.google.com/googleplay/android-developer/answer/14151465?hl=ko)

## 3. Play Console에서 앱 만들기

1. Play Console 홈에서 **앱 만들기**를 누른다.
2. 양식을 채운다.
   - **앱 이름**: `O'talk` (나중에 바꿀 수 있다)
   - **기본 언어**: `한국어 – ko-KR`
   - **앱 또는 게임**: 앱
   - **무료 또는 유료**: 무료 (**유료로 올린 앱은 나중에 무료로 바꿀 수 있지만 반대는 불가**)
   - 사용자 문의 이메일
3. **선언** 섹션에서 개발자 프로그램 정책, 미국 수출 법규, Play 앱 서명 서비스 약관에 체크한다.
4. **앱 만들기**를 누른다.

패키지 이름은 이 단계에서 묻지 않는다. 첫 `.aab`를 올릴 때 그 파일의 `applicationId`가 앱에
영구히 고정된다. 올리기 전에 `android/app/build.gradle`의 `applicationId`가 `com.okrbest.otalk`인지
한 번 더 본다.

공식 문서: [앱 만들기 및 설정](https://support.google.com/googleplay/android-developer/answer/9859152?hl=ko)

## 4. 대시보드 작업: 앱 콘텐츠 선언과 스토어 등록정보

앱을 만들면 왼쪽 메뉴 **대시보드**에 "앱 설정" 작업 목록이 뜬다. 체크 표시가 모두 켜질 때까지
하나씩 완료한다. 항목은 **정책 및 프로그램 → 앱 콘텐츠**에서도 직접 열 수 있다. 표시되는 항목은
앱 성격에 따라 조금 다르다.

### 4.1 앱 콘텐츠 선언

| 항목 | O'talk 기준 답변 안내 |
|---|---|
| **개인정보처리방침** | 1절에서 준비한 공개 URL을 입력한다. 사용자 데이터를 수집하지 않더라도 필수다. |
| **앱 액세스 권한** | "전체 또는 일부 기능이 제한됨"을 선택하고 **+ 새 안내 추가**로 심사관용 **서버 URL, 아이디, 비밀번호**를 적는다. 안내는 최대 5개. MFA나 OTP 같은 특수 로그인이 있으면 '다른 안내'란에 설명한다. 이 정보가 없으면 심사관이 로그인 화면에서 막혀 거부될 수 있다. |
| **광고** | 앱에 광고가 없으므로 "아니요". |
| **콘텐츠 등급** | 4.2 참고. |
| **타겟층 및 콘텐츠** | 연령대는 **18세 이상**(업무용 메신저). 어린이 대상이 아니라고 답한다. |
| **뉴스 앱** | 아니요. |
| **데이터 보안** | 4.3 참고. |
| **정부 앱** | 아니요. |
| **금융 기능** | 금융 기능 없음. |
| **건강 앱** | 건강 기능 없음. |
| **광고 ID** | 앱이 광고 ID를 쓰지 않으면 "아니요". (이 항목은 targetSdk 33 이상 앱에 표시된다.) |
| **권한 선언 양식** | 민감 권한(SMS, 통화기록, 접근성, 백그라운드 위치 등)을 요청할 때만 뜬다. O'talk 기본 빌드는 해당 권한을 쓰지 않는다. |

### 4.2 콘텐츠 등급 설문지

1. **앱 콘텐츠 → 콘텐츠 등급 → 시작**.
2. IARC(국제 연령 등급 연합)와 연락할 이메일을 입력한다.
3. 카테고리에서 앱 유형(유틸리티·생산성·커뮤니케이션 등)을 고른다.
4. 폭력·성적 콘텐츠·사용자 생성 콘텐츠·사용자 간 소통 같은 질문에 **사실대로** 답한다. 메신저이므로
   "사용자가 서로 소통할 수 있음", "사용자 생성 콘텐츠 공유 가능"은 "예"다.
5. **요약** 화면의 등급을 확인하고 **제출**한다. 등급은 여러 기관(GRAC 포함)에서 각각 매겨진다.

설문 응답에 영향을 줄 만큼 기능이 바뀌면 설문을 다시 작성해야 한다. 등급이 없으면 해당
지역에서 앱이 내려갈 수 있다.

### 4.3 데이터 보안 양식

내부 테스트 트랙만 쓰는 동안은 면제지만, **비공개 테스트부터는 필수**다. 양식은 14개 데이터
범주(위치, 개인 정보, 금융 정보, 건강, 메시지, 사진·동영상, 오디오, 파일·문서, 캘린더, 연락처,
앱 활동, 웹 탐색, 앱 정보·성능, 기기 ID)마다 "수집 여부 → 공유 여부 → 필수/선택 → 목적"을 묻는다.

- "수집"은 **사용자 기기에서 앱이 데이터를 외부로 전송하는 것**이다. 기기 안에서만 처리되거나
  종단간 암호화되어 개발자도 못 읽는 데이터는 수집으로 선언하지 않아도 된다.
- O'talk는 메시지·파일·사진을 **사용자가 지정한 서버**로 보내는 셀프호스팅 메신저다. 메시지,
  사진·동영상, 파일·문서, 개인 정보(이름·이메일), 앱 활동(상호작용), 기기 ID(푸시 토큰),
  앱 정보·성능(크래시 로그, Sentry 사용 시)은 수집으로 선언하는 것이 일반적이다. **실제 빌드 설정
  (`assets/base/config.json`의 Sentry·RudderStack 값)에 맞춰 답한다.** 선언과 실제 동작이 다르면
  업데이트 차단이나 삭제 대상이 된다.
- "전송 중 암호화" 질문에는 TLS(HTTPS) 사용으로 "예"를 고른다.
- "데이터 삭제 요청 방법 제공" 질문에는 사용자가 찾을 수 있는 경로(앱 내 계정 삭제, 문의 양식,
  전용 이메일 등)를 준비해 두고 답한다.

### 4.4 스토어 설정과 기본 스토어 등록정보

경로: **사용자 늘리기 → 앱 정보 → 스토어 설정** 과 **기본 스토어 등록정보**.

1. **앱 카테고리**: 앱 / `커뮤니케이션` 또는 `비즈니스`. 태그도 몇 개 고른다.
2. **연락처 세부정보**: 지원 이메일(필수), 전화번호, 웹사이트.
3. **앱 세부정보**: 아래 파일 내용을 그대로 붙여 넣는다.
   - 앱 이름(한글 15자 / 영문 30자 제한): `fastlane/metadata/android/ko-KR/title.txt` → `O'talk`
   - 간단한 설명(80자 이내): `fastlane/metadata/android/ko-KR/short_description.txt`
   - 자세한 설명(4,000자 이내): `fastlane/metadata/android/ko-KR/full_description.txt`. "OKRBEST 워크스페이스 주소가 필요"하다는 사용 조건이 들어 있다
4. **그래픽**: `fastlane/metadata/android/ko-KR/images/` 아래 파일을 올린다. 앱 아이콘 `icon.png`(512px),
   그래픽 이미지 `featureGraphic.png`(1024×500), 휴대전화 스크린샷 `phoneScreenshots/` 6장(1080×2120,
   상태 표시줄·내비게이션 바 제거본). 태블릿 스크린샷은 대형 화면 노출을 원하면 추가한다.
5. **번역 추가**로 `영어(미국) – en-US` 등록정보도 넣는다. 문안은 `fastlane/metadata/android/en-US/`에 있다.
   fastlane 업로드를 쓸 계획이면 콘솔 내용과 이 폴더 내용을 항상 같게 유지한다 (9절).

저장 후 대시보드의 모든 작업에 체크가 켜지면 출시 준비가 된 것이다.

공식 문서: [앱 액세스 권한](https://support.google.com/googleplay/android-developer/answer/9859455?hl=ko) ·
[콘텐츠 등급](https://support.google.com/googleplay/android-developer/answer/9859655?hl=ko) ·
[데이터 보안](https://support.google.com/googleplay/android-developer/answer/10787469?hl=ko) ·
[미리보기 애셋 규격](https://support.google.com/googleplay/android-developer/answer/9866151?hl=ko)

## 5. 서명된 App Bundle 만들기

2021년 8월 이후 만든 앱은 APK가 아니라 **App Bundle(`.aab`)** 만 올릴 수 있다.

1. `android/app/build.gradle`에서 두 값을 확인한다.
   - `versionCode`: **업로드마다 1씩 올린다.** Play는 같은 값을 두 번 받지 않는다. 현재 값은 831.
   - `versionName`: 사용자에게 보이는 버전 문자열(예: `2.46.0`).
2. `android/build.gradle`의 `targetSdkVersion`이 **36 이상**인지 확인한다. Google Play는
   2026-08-31부터 신규 앱과 업데이트에 Android 16(API 36) 타겟을 요구한다. 이 저장소는 이미 36이다.
3. [android-release-build-setup.md](./android-release-build-setup.md) 8절대로 빌드한다.

```bash
export PATH="$HOME/.rbenv/shims:$PATH"
cd <저장소 루트>/fastlane
NODE_ENV=production ANDROID_BUILD_TASK=bundle \
  bundle exec fastlane android build --env android.release
```

4. 저장소 루트에 `Otalk.aab`가 생긴다. 서명 지문이 업로드 keystore와 같은지 확인한다.

```bash
cd <저장소 루트>
keytool -printcert -jarfile Otalk.aab | grep SHA1
cd android && ./gradlew :app:signingReport --quiet | grep -A7 "Variant: release"
# 두 SHA1이 같아야 한다
```

5. 빌드가 바꿔 놓은 추적 파일을 원복한다: `git restore android/ fastlane/metadata/`

## 6. 첫 업로드: 내부 테스트 트랙과 Play 앱 서명

첫 `.aab`는 **내부 테스트** 트랙에 올린다. 내부 테스트는 정책 검토 없이 몇 분 안에 테스터에게
배포되고, 앱 설정(4절)을 다 마치지 않았어도 시작할 수 있다. 테스터는 최대 100명이다.

### 6.1 업로드

1. **테스트 및 출시 → 테스트 → 내부 테스트 → 새 버전 만들기**.
2. **App Bundle 추가 → 업로드**에서 `Otalk.aab`를 올린다. 처음 올리는 순간 패키지 이름이 고정된다.
3. **출시명**은 콘솔에서만 보이는 메모다. `2.46.0 (831)`처럼 적는다. 비워 두면 자동으로 채워진다.
4. **출시 노트**는 언어 태그를 한 줄에 따로 쓰고 아래에 본문을 쓴다. 언어당 500자 제한.

```
<ko-KR>
O'talk 첫 내부 테스트 빌드입니다.
</ko-KR>
<en-US>
First internal test build of O'talk.
</en-US>
```

5. **다음 → 미리보기 및 확인**에서 오류가 없으면 **출시 시작**(내부 테스트 트랙으로 출시)을 누른다.

### 6.2 Play 앱 서명이 자동으로 켜진다

새 앱은 첫 업로드 때 **Play 앱 서명**에 자동 등록된다. 구조를 이해해 두면 키 사고를 막을 수 있다.

| 키 | 누가 보관 | 역할 |
|---|---|---|
| **업로드 키** | 개발자(`~/keystores/otalk-upload.keystore`) | `.aab`에 서명해서 "내가 올린 것"임을 증명 |
| **앱 서명 키** | Google | 사용자 기기에 내려가는 최종 APK에 서명. Google이 RSA 4096비트로 생성 |

- 방금 올린 `.aab`의 서명 인증서가 **업로드 키 인증서**로 등록된다. **Google Play로 보호됨 → Play 스토어 배포 → Play 앱 서명**에서
  "업로드 키 인증서"의 SHA-1이 5절 `signingReport` 값과 같은지 확인한다.
- 앞으로 올리는 모든 `.aab`는 **이 keystore로만** 서명해야 한다. 다른 키로 서명하면 업로드가 거부된다.
- **앱 서명 키 SHA-1**(Google 보관 키)은 Firebase 콘솔의 Android 앱 설정에 추가로 등록해 두어야
  Google 로그인 같은 API 지문 검증이 스토어 빌드에서도 통과한다. FCM 푸시만 쓰면 필수는 아니다.
- 업로드 keystore를 잃어버리면: 새 keystore를 만들고 인증서를 PEM으로 내보낸 뒤, 같은 페이지의
  **업로드 키 재설정 요청**으로 올린다. 앱이 잠기지는 않는다.

```bash
keytool -export -rfc -keystore <새 keystore> -alias <alias> -file upload_certificate.pem
```

공식 문서: [Play 앱 서명](https://support.google.com/googleplay/android-developer/answer/9842756?hl=ko) ·
[테스트 트랙 설정](https://support.google.com/googleplay/android-developer/answer/9845334?hl=ko) ·
[버전 준비 및 출시](https://support.google.com/googleplay/android-developer/answer/9859348?hl=ko)

## 7. 테스트 트랙으로 검증하기

트랙은 네 단계다. 조직 계정은 의무 단계가 없으므로 상황에 맞게 고른다.

| 트랙 | 누가 받나 | 검토 | 권장 용도 |
|---|---|---|---|
| 내부 테스트 | 이메일 목록(최대 100명) | 없음, 몇 분 내 배포 | 개발팀 스모크 테스트 |
| 비공개 테스트 | 이메일 목록 또는 Google 그룹 | 정책 검토 있음 | 사내 전 직원 베타 |
| 공개 테스트 | 누구나(스토어에서 참여) | 정책 검토 있음 | 외부 베타 |
| 프로덕션 | 선택한 국가의 모든 사용자 | 정책 검토 있음 | 정식 출시 |

### 7.1 테스터 등록과 참여 링크

1. 해당 트랙의 **테스터** 탭에서 **이메일 목록 만들기**로 테스터 Google 계정 주소를 넣는다
   (CSV 업로드 가능). 비공개 테스트는 Google 그룹 주소(`xxx@googlegroups.com`)도 된다.
2. 저장하면 **테스트 참여 링크**가 생긴다. 앱 상태가 "게시됨"이어야 링크가 보인다.
   O'talk의 링크 형식은 `https://play.google.com/apps/testing/com.okrbest.otalk`이다.
3. 테스터는 등록된 Google 계정으로 로그인한 상태에서 링크를 열어 **참여**를 누른 뒤 Play 스토어에서
   설치한다. 이후 새 빌드는 몇 분 안에 자동 업데이트된다.

내부 테스트에 참여 중인 계정은 공개·비공개 테스트에 동시에 참여할 수 없다. 옮기려면 내부
테스트 참여를 먼저 해제한다.

### 7.2 사전 출시 보고서 활용

`.aab`를 올리면 Google이 실제 기기에서 앱을 자동으로 실행해 크래시, 접근성, 보안 경고를
**테스트 및 출시 → 사전 출시 보고서**에 올려 준다. 로그인이 필요한 앱은 보고서 설정에서
테스트 계정을 넣어 두면 로그인 이후 화면까지 크롤링한다. 프로덕션 제출 전에 한 번 훑어본다.

### 7.3 비공개 테스트로 승격

내부 테스트 빌드가 괜찮으면 **비공개 테스트 → 새 버전 만들기 → App Bundle 추가 → 라이브러리에서 추가**로
같은 빌드를 고른다. 다시 빌드할 필요가 없다. 비공개 테스트부터는 4절 선언이 모두 완료되어
있어야 하고, 제출 후 정책 검토를 거친다.

## 8. 프로덕션 출시

### 8.1 제출

1. **테스트 및 출시 → 프로덕션 → 국가/지역**에서 배포 국가를 고른다 (대한민국만, 또는 전체).
2. **새 버전 만들기 → 라이브러리에서 추가**로 테스트를 마친 빌드를 고르고 출시 노트를 적는다.
3. **다음 → 미리보기 및 확인**. 상단 "오류 요약"이 있으면 **더보기**로 원인을 고친다. 오류가 남아 있으면 제출할 수 없다.
4. **프로덕션 출시 시작**을 누른다. 첫 출시는 **단계적 출시(비율 지정)를 쓸 수 없고** 100%로만 나간다.
5. **게시 개요** 페이지의 **검토 중인 변경사항**에 항목이 올라간다. 승인되면 자동으로 게시된다.

### 8.2 검토 기간과 일정 잡기

- Google 공식 안내는 "검토 완료까지 보통 7일 이내, 경우에 따라 더 길어질 수 있음"이다.
  **새 개발자 계정의 첫 앱은 더 오래 걸리는 경우가 많다.** 출시 목표일보다 최소 1~2주 앞서 제출한다.
- 상태는 **게시 개요**와 대시보드 상단에서 본다. 거부되면 이메일과 **정책 상태** 페이지에 사유가
  적힌다. 고친 뒤 **앱 콘텐츠**에서 저장하고 **게시 개요 → 전송하여 검토받기**로 다시 보낸다.

### 8.3 관리형 게시 (두 번째 출시부터)

**게시 개요 → 관리형 게시 켜기**를 켜 두면 검토가 끝나도 자동 게시되지 않고, **변경사항 게시**
버튼을 누를 때 반영된다. 서버 배포와 시점을 맞추고 싶을 때 유용하다. **앱을 처음 게시할 때는
사용할 수 없고**, 첫 출시가 게시된 뒤부터 켤 수 있다.

공식 문서: [관리형 게시](https://support.google.com/googleplay/android-developer/answer/9859654?hl=ko) ·
[타겟 API 수준 요건](https://support.google.com/googleplay/android-developer/answer/11926878?hl=ko)

## 9. (선택) fastlane으로 자동 업로드 연결

콘솔에 수동으로 올리는 대신 `fastlane android deploy`가 `supply`로 `.aab`를 올리게 할 수 있다.
**첫 업로드는 반드시 콘솔에서 수동으로(6절) 끝낸 뒤**에만 동작한다.

### 9.1 Google Cloud 서비스 계정 만들기

1. Play Console **설정 → API 액세스**에서 Google Cloud 프로젝트를 새로 만들거나 **기존 프로젝트 연결**을 한다.
   한 Cloud 프로젝트는 한 Play Console 계정에만 연결할 수 있다. 목록에 안 보이면 현재 Google
   계정이 그 Cloud 프로젝트의 **소유자**인지 확인한다.
2. Google Cloud 콘솔에서 그 프로젝트를 선택하고 **API 및 서비스 → 라이브러리**에서
   **Google Play Android Developer API**(Google Play Developer API)를 **사용 설정**한다.
3. **IAM 및 관리자 → 서비스 계정 → 서비스 계정 만들기**. 이름은 `play-publisher` 정도로 짓고,
   "이 서비스 계정에 프로젝트 액세스 권한 부여" 단계는 건너뛰고 **완료**한다. 생성된 이메일
   주소(`...@...iam.gserviceaccount.com`)를 복사한다.
4. 서비스 계정 → **키 → 키 추가 → 새 키 만들기 → JSON**. 내려받은 파일을
   `~/keystores/play-service-account.json`처럼 **저장소 밖**에 두고 `chmod 600` 한다.
   이 파일이 있으면 누구든 스토어 등록정보를 바꾸고 빌드를 올릴 수 있다. 절대 커밋하지 않는다.

### 9.2 Play Console에서 권한 부여

1. **사용자 및 권한 → 새 사용자 초대**에서 서비스 계정 이메일을 넣는다.
2. 권한은 **앱 단위**로 O'talk만 지정하고, 다음을 준다: 앱 정보 수정·삭제(스토어 등록정보 업로드용),
   프로덕션 트랙에 출시, 테스트 트랙에 출시, 앱 버전 관리. 재무 데이터·주문 관리 권한은 주지 않는다.
3. **사용자 초대**. 권한이 API에 반영되기까지 수 분에서 최대 24시간 걸릴 수 있다.

### 9.3 이 저장소의 lane 동작

`fastlane/Fastfile`의 `submit_to_google_play`는 환경 변수 `SUPPLY_JSON_KEY`가 비어 있으면
업로드를 **조용히 건너뛰고** 파일 이름만 정리한다. 따라서 셸에서 키 경로를 반드시 넘긴다.

| 변수 | 의미 | `.env.android.release` 기본값 |
|---|---|---|
| `SUPPLY_JSON_KEY` | 서비스 계정 JSON 경로 | 없음(셸에서 지정) |
| `SUPPLY_PACKAGE_NAME` / `MAIN_APP_IDENTIFIER` | 패키지 이름 | `com.okrbest.otalk` |
| `SUPPLY_TRACK` | 올릴 트랙 | `internal` |
| `MATTERMOST_WEBHOOK_URL` | 완료 알림(없으면 건너뜀) | 없음 |

트랙 이름은 fastlane 표기와 콘솔 표기가 다르다.

| `SUPPLY_TRACK` | Play Console 트랙 |
|---|---|
| `internal` | 내부 테스트 |
| `alpha` | 비공개 테스트 |
| `beta` | 공개 테스트 |
| `production` | 프로덕션 |

`.env.android.release`는 **내부 테스트**(`internal`)를 가리킨다. `--env` 파일은 셸 변수를 덮어쓰므로,
다른 트랙에 올리려면 파일 값을 바꾸거나 lane 호출 뒤에 콘솔에서 승격한다. `beta`로 두면 공개 테스트
트랙이 열려 누구나 참여할 수 있으므로 주의한다.

### 9.4 실행

```bash
# 1) 키 검증 (한 번만)
cd <저장소 루트>/fastlane
bundle exec fastlane run validate_play_store_json_key \
  json_key:$HOME/keystores/play-service-account.json

# 2) 빌드(5절) 후 업로드 (경로는 절대 경로로 넘긴다)
SUPPLY_JSON_KEY=$HOME/keystores/play-service-account.json \
  bundle exec fastlane android deploy file:<저장소 루트>/Otalk.aab --env android.release
```

`supply`의 기본 `release_status`는 **완료**이므로, 성공하면 해당 트랙에 새 버전이 만들어지고
곧바로 출시(검토 대상 트랙이면 검토 제출)까지 진행된다. 콘솔에서 출시 노트를 다듬고 나서
내보내고 싶다면 `.env.android.release`의 `SUPPLY_TRACK`을 `internal`로 바꿔 내부 테스트에만
올린 뒤, 콘솔에서 **라이브러리에서 추가**로 상위 트랙에 승격하는 흐름이 안전하다.

스토어 등록정보는 `fastlane/metadata/android/ko-KR/`과 `en-US/` 아래의 `title.txt`,
`short_description.txt`, `full_description.txt`, `changelogs/default.txt`, `images/icon.png`로
관리한다. 버전별 출시 노트는 `changelogs/<versionCode>.txt`(예: `831.txt`)를 추가하면 `default.txt`보다
우선 적용된다. 스크린샷은 `images/phoneScreenshots/`에 파일명 순서대로 넣는다. `supply`는 실행 시
콘솔의 등록정보를 이 폴더 내용으로 **덮어쓴다**는 점을 기억한다. 이 저장소의 빌드 lane은
`title.txt`를 `APP_NAME`으로 다시 쓰므로, 빌드 뒤 `git restore fastlane/metadata/`로 원복한다.

공식 문서: [Google Play Developer API 시작하기](https://developers.google.com/android-publisher/getting_started?hl=ko) ·
[fastlane supply](https://docs.fastlane.tools/actions/supply/)

## 10. 업데이트 배포 루틴

출시 이후 매 버전은 이 순서를 반복한다.

1. `android/app/build.gradle`에서 `versionCode`를 1 올리고 `versionName`을 정한 뒤 커밋한다.
2. 5절대로 `.aab`를 빌드하고 SHA-1을 확인한다.
3. 내부 테스트 트랙에 올려(콘솔 또는 9절) 팀이 설치 확인한다.
4. 프로덕션 → **새 버전 만들기 → 라이브러리에서 추가**로 같은 빌드를 고르고 출시 노트를 적는다.
5. **출시 비율**에서 단계적 출시(예: 10% → 50% → 100%)를 고른다. 문제가 생기면 **출시 중단**이 가능하다.
   업데이트부터는 이 옵션이 열린다.
6. 관리형 게시를 켜 두었다면 검토 완료 후 **변경사항 게시**를 누른다.
7. 데이터 수집이나 기능이 크게 바뀌었으면 데이터 보안 양식과 콘텐츠 등급 설문을 갱신한다.

## 11. 2026년에 특히 신경 쓸 것

- **타겟 API 수준**: 2026-08-31부터 신규 앱·업데이트는 **API 36(Android 16)** 이상이어야 한다.
  저장소는 이미 36이므로, upstream 동기화 때 `targetSdkVersion`을 낮추는 변경이 들어오지 않게만 본다.
- **Android 개발자 인증(Android developer verification)**: Google은 Play Console 개발자를
  Play 앱의 99%를 자동 등록한다고 안내한다. 2026-09-30부터 브라질·인도네시아·싱가포르·태국에서
  인증된 기기에 보호 조치가 시작되고 2027년에 전 세계로 확대된다. Play 외부(APK 직접 배포)로도
  앱을 나눠 줄 계획이면 Play Console **Android 개발자 인증 → 패키지 이름** 탭에서 등록 상태를 확인한다.
- **데이터 보안 양식과 데이터 삭제 경로**: 양식은 비공개 테스트부터 필수이고, 계정을 만드는 앱은
  사용자가 찾기 쉬운 삭제 요청 수단을 제공해야 한다.
- **개인 계정의 12명·14일 규칙**: 조직 계정에는 적용되지 않지만, 만약 개인 계정으로 시작했다면
  비공개 테스트에 테스터 12명을 14일 연속 유지한 뒤 대시보드의 **프로덕션 신청**을 거쳐야 한다.

공식 문서: [Android 개발자 인증](https://developer.android.com/developer-verification?hl=ko) ·
[Play Console에서 패키지 이름 등록](https://support.google.com/googleplay/android-developer/answer/16761053?hl=ko)

## 12. 자주 막히는 지점

| 증상 | 원인과 해결 |
|---|---|
| 업로드 시 "이미 사용 중인 버전 코드" | `versionCode`를 올리지 않았다. 올리고 다시 빌드한다. |
| "업로드 키로 서명되지 않은 App Bundle" | 다른 keystore로 서명했다. `~/.gradle/gradle.properties`의 `MATTERMOST_RELEASE_*`가 업로드 keystore를 가리키는지 확인한다. 디버그 키로 서명된 경우도 이 오류다. |
| 새 버전 만들기 버튼이 비활성 | 같은 트랙에 미완료(임시보관) 버전이 있다. 완료하거나 삭제한다. |
| 테스트 참여 링크가 안 보임 | 앱이 아직 "초안"이나 "게시 대기 중"이다. 트랙 출시가 게시된 뒤 보인다. |
| 심사 거부: "앱에 로그인할 수 없음" | 앱 액세스 권한에 서버 URL과 계정이 없거나 만료됐다. 갱신 후 재제출한다. |
| 데이터 보안 양식 미완료로 출시 불가 | 내부 테스트 외 트랙은 양식이 필수다. 4.3을 완료한다. |
| `supply`가 아무것도 올리지 않고 끝남 | `SUPPLY_JSON_KEY`가 비어 있다. 셸에서 경로를 넘긴다. |
| `supply` 403 권한 오류 | 서비스 계정 초대 직후다. 최대 24시간 기다리거나, 사용자 및 권한에서 앱 권한을 다시 확인한다. |
| 조직 인증 실패 배너 | 결제 프로필의 이름·주소가 D&B와 다르다. 2.3 참고. |

## 13. 참고한 공식 문서 (2026-11-03 확인)

- Play Console 고객센터
  - [개발자 계정 등록](https://support.google.com/googleplay/android-developer/answer/6112435?hl=ko)
  - [조직의 인증 요건](https://support.google.com/googleplay/android-developer/answer/13628312?hl=ko)
  - [개발자 계정 유형 선택](https://support.google.com/googleplay/android-developer/answer/13634885?hl=ko)
  - [신규 개인 개발자 계정의 앱 테스트 요건](https://support.google.com/googleplay/android-developer/answer/14151465?hl=ko)
  - [앱 만들기 및 설정](https://support.google.com/googleplay/android-developer/answer/9859152?hl=ko)
  - [앱 액세스 권한](https://support.google.com/googleplay/android-developer/answer/9859455?hl=ko)
  - [콘텐츠 등급](https://support.google.com/googleplay/android-developer/answer/9859655?hl=ko)
  - [데이터 보안 섹션](https://support.google.com/googleplay/android-developer/answer/10787469?hl=ko)
  - [스토어 등록정보 미리보기 애셋](https://support.google.com/googleplay/android-developer/answer/9866151?hl=ko)
  - [Play 앱 서명](https://support.google.com/googleplay/android-developer/answer/9842756?hl=ko)
  - [테스트 트랙 설정](https://support.google.com/googleplay/android-developer/answer/9845334?hl=ko)
  - [버전 준비 및 출시](https://support.google.com/googleplay/android-developer/answer/9859348?hl=ko)
  - [관리형 게시](https://support.google.com/googleplay/android-developer/answer/9859654?hl=ko)
  - [타겟 API 수준 요건](https://support.google.com/googleplay/android-developer/answer/11926878?hl=ko)
  - [Android 개발자 인증을 위한 패키지 이름 등록](https://support.google.com/googleplay/android-developer/answer/16761053?hl=ko)
- Android 개발자 문서: [Android 개발자 인증](https://developer.android.com/developer-verification?hl=ko)
- Google Play Developer API: [시작하기](https://developers.google.com/android-publisher/getting_started?hl=ko)
- fastlane: [supply 액션](https://docs.fastlane.tools/actions/supply/)
