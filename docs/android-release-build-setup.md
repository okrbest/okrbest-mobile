# Android 배포 빌드 환경 구성 가이드

새 시스템에서 O'talk Android 배포 빌드(Play 업로드용 서명 .aab)를 재현하기 위한
설치·확인 절차다. Ubuntu 22.04(WSL2 포함)에서 검증했다 (2026-11-03).

> **버전의 진실 원천.** 아래 표의 버전은 작성 시점 값이다. 설치 전에 반드시 각
> 원천 파일에서 현재 값을 확인한다 — 표가 아니라 파일이 기준이다.

| 구성 요소 | 검증된 버전 | 진실 원천 |
|---|---|---|
| JDK | OpenJDK 21 | React Native 0.83 요구 범위(17–21) |
| Android build-tools / platform | 36.0.0 / android-36 | `android/build.gradle`의 `buildToolsVersion`·`compileSdkVersion` |
| Android NDK | 27.1.12297006 | `android/build.gradle`의 `ndkVersion` (정확히 일치해야 함) |
| Node | 22.11+ 또는 24.15+ | `package.json`의 `engines`, `.nvmrc` |
| Ruby | 3.2.11 | `.ruby-version` |
| bundler | 2.5.11 | `fastlane/Gemfile.lock`의 `BUNDLED WITH` |
| fastlane | 2.234.0 | `fastlane/Gemfile.lock` |

## 1. 시스템 패키지

Ruby 컴파일과 네이티브 gem(nokogiri) 빌드에 필요하다.

```bash
sudo apt update
sudo apt install -y git curl unzip autoconf bison build-essential libssl-dev \
  libyaml-dev libreadline-dev zlib1g-dev libgmp-dev libncurses-dev libffi-dev libgdbm-dev
```

## 2. JDK 21

```bash
sudo apt install -y openjdk-21-jdk
java -version   # openjdk 21.x 확인
```

## 3. Android SDK

Android Studio 없이 cmdline-tools만으로 구성할 수 있다.

```bash
mkdir -p ~/Android/Sdk/cmdline-tools
# https://developer.android.com/studio#command-line-tools-only 에서 최신 zip을 받아
# ~/Android/Sdk/cmdline-tools/latest/ 가 되도록 푼다

export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
# 위 두 줄은 ~/.bashrc에도 추가한다

# 버전은 android/build.gradle에서 확인한 현재 값으로 바꾼다
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0" "ndk;27.1.12297006"
sdkmanager --licenses   # 전부 동의해야 gradle이 진행된다
```

`android/local.properties`는 필요 없다 — gradle이 `ANDROID_HOME`으로 SDK를 찾는다.

## 4. Node + npm 의존성

```bash
# nvm 권장: .nvmrc의 버전을 그대로 쓴다
nvm install && nvm use
cd <저장소 루트>
npm install   # postinstall이 patch-package 적용과 자산 복사를 수행한다
```

## 5. Ruby + fastlane

apt의 Ruby는 버전이 맞지 않으므로 rbenv로 `.ruby-version`을 따른다.

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
exec bash

cd <저장소 루트>
rbenv install "$(cat .ruby-version)"
gem install bundler -v "$(tail -1 fastlane/Gemfile.lock | tr -d ' ')"
rbenv rehash
cd fastlane && bundle install
bundle exec fastlane --version   # Gemfile.lock의 fastlane 버전이 나오면 성공
```

## 6. 릴리스 서명

업로드 keystore는 **저장소에 절대 커밋하지 않는다**. 팀 시크릿 저장소에서 받아
홈 디렉터리 아래(예: `~/keystores/otalk-upload.keystore`)에 둔다.

`~/.gradle/gradle.properties`(저장소 밖)에 세 속성을 등록한다:

```properties
MATTERMOST_RELEASE_STORE_FILE=/home/<사용자>/keystores/otalk-upload.keystore
MATTERMOST_RELEASE_KEY_ALIAS=<alias>
MATTERMOST_RELEASE_PASSWORD=<비밀번호>
```

```bash
chmod 600 ~/.gradle/gradle.properties
```

주의:

- `android/app/build.gradle`은 store/key 비밀번호에 **같은 값**을 쓴다.
- 비밀번호에 `#`(이후가 주석 처리됨)나 `\`(`\\`로 이스케이프)가 있으면 그대로 넣으면 안 된다.
- 이 속성이 없으면 release 빌드도 debug 키로 서명되어 Play에 올릴 수 없다.

연결 확인:

```bash
cd android && ./gradlew :app:signingReport --quiet | grep -A7 "Variant: release"
# Store 경로·Alias가 맞고 지문(SHA1)이 출력되면 성공
```

## 7. 환경 검증 체크리스트

```bash
java -version                      # 21.x
sdkmanager --list_installed        # platform-36, build-tools 36.0.0, ndk 일치
node -v                            # engines 범위
ruby -v                            # .ruby-version 값 (저장소 안에서 실행)
cd fastlane && bundle check        # "dependencies are satisfied"
cd android && ./gradlew help       # 구성 단계 통과 (최초 실행은 gradle 배포판 다운로드)
```

## 8. 배포 빌드 실행

```bash
# Sentry: fastlane/.env.android.release의 SENTRY_ENABLED가 true이고 org가
# upstream 값이면 임시로 false로 바꾼다(T025 미결). --env 파일은 Dotenv.overload로
# 로드되어 셸 환경 변수를 덮어쓰므로, 셸에서 넘기는 것으로는 못 바꾼다.

export PATH="$HOME/.rbenv/shims:$PATH"
cd <저장소 루트>/fastlane
NODE_ENV=production ANDROID_BUILD_TASK=bundle \
  bundle exec fastlane android build --env android.release
```

- 산출물: 저장소 루트의 `Otalk.aab` (APK 빌드는 `ANDROID_BUILD_TASK` 생략 → `Otalk-<abi>.apk`)
- 네이티브 전체 빌드라 수십 분 걸린다. 다음 빌드 때 같은 이름으로 덮어써지므로
  보관할 산출물은 업로드 후 별도 폴더로 옮긴다.

서명 검증:

```bash
keytool -printcert -jarfile Otalk.aab | grep SHA1
# signingReport의 지문과 일치해야 한다
```

빌드는 작업 트리의 일부 추적 파일(스플래시·아이콘, manifest 스킴, strings.xml,
fastlane/metadata)을 빌드용으로 변형한다. 커밋 전 원복한다:

```bash
git restore android/ fastlane/metadata/
```

## 9. Play 업로드 전 확인

- `versionCode`(`android/app/build.gradle`)는 업로드마다 증가해야 한다.
- 첫 업로드 시 이 키를 업로드 키로 Play App Signing에 등록한다.
- `android/app/google-services.json`의 `package_name`이 `com.okrbest.otalk`인지 확인한다.
