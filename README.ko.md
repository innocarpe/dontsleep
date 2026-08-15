# <img src="docs/assets/app-icon-rounded.png" alt="" width="36" height="36" align="left" />&nbsp; DontSleep

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue?style=flat)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?style=flat)](#설치)
[![Arch](https://img.shields.io/badge/arch-Apple%20silicon-lightgrey?style=flat)](#빌드)

**덮개를 닫아도 맥이 잠들지 않게 합니다.**

DontSleep은 macOS 메뉴바 앱입니다. 시스템 `disablesleep` 플래그를 켜고 끄므로
배터리와 전원 모두에서 덮개를 닫아도 슬립하지 않습니다. 아이콘을 클릭하면
토글되고, 오른쪽 클릭하면 메뉴가 열립니다.

<p align="center">
  <img src="docs/assets/app-icon-rounded.png" alt="DontSleep 앱 아이콘: 뚜껑이 살짝 열린 Space Black 맥북과 키보드에서 새는 따뜻한 빛" width="220" />
</p>

---

## 왜 있나

`caffeinate` 나 KeepingYouAwake 는 **유휴** 슬립만 막습니다. **덮개 닫힘**
슬립은 막지 않습니다. 그걸 바꾸는 공식 스위치는 root 가 필요한
`pmset disablesleep` 뿐입니다.

DontSleep은 그 스위치를 메뉴바에 올려 두고, sudoers 규칙은 `pmset` 두
인자만 허용합니다.

## 누구를 위한가

이런 경우에 맞습니다.

- 덮개를 닫은 채로 맥을 켜 두고 싶을 때 (책상, 스튜디오, 외부 디스플레이)
- 터미널이 아니라 메뉴바에서 지금 상태를 보고 싶을 때
- 켤 때마다 비밀번호를 치고 싶지 않을 때

유휴 슬립만 막는 앱을 대체하지 않습니다. Apple Developer ID 로 서명되어
있지 않습니다 ([설치](#설치)).

## 동작

| 조작 | 결과 |
| --- | --- |
| 왼쪽 클릭 | 켜기 / 끄기 |
| 오른쪽 클릭 또는 Control-클릭 | 메뉴: 상태, 켜기, 끄기, 로그인 시 시작, 종료 |
| 채워진 노트북 아이콘 | 켜짐 — 덮개를 닫아도 깨어 있음 |
| 윤곽 노트북 아이콘 | 꺼짐 — 덮개를 닫으면 잠 |

메뉴바 아이콘은 템플릿이라 시스템 메뉴바 색을 따릅니다. 인터페이스는
macOS 언어를 따르며, 기본은 영어이고 한국어·중국어 간체·일본어를 제공합니다.

## 설치

릴리즈 디스크 이미지는 **ad-hoc 서명**이고 공증되어 있지 않습니다.
“확인되지 않은 개발자” 경고가 뜨는 것이 정상입니다.

### 디스크 이미지

1. [Releases](https://github.com/innocarpe/dontsleep/releases) 에서
   `DontSleep-*.dmg` 를 받아 엽니다.
2. **DontSleep** 을 **Applications** 로 끌어다 놓습니다.
3. **Install Sudoers.command** 를 더블클릭합니다 (아래 설명).
   관리자 비밀번호를 한 번 묻습니다.
4. **DontSleep** 을 엽니다. 메뉴바에 노트북 아이콘이 생깁니다.

앱이나 `.command` 가 막히면:

1. **Control-클릭 → 열기 → 열기.** 기본은 이쪽입니다.
2. 또는 설정 → 개인정보 보호 및 보안 → **확인 없이 열기**.
3. 터미널이 편할 때만. 필수는 아닙니다.

   ```sh
   xattr -d com.apple.quarantine /Applications/DontSleep.app
   ```

### Install Sudoers.command 가 뭔가

`scripts/install-sudoers.sh` 를 Finder 에서 더블클릭할 수 있게
`.command` 로 넣은 것입니다. 앱을 설치하지 않고, `sudo` 전체를 열지도
않습니다.

덮개 닫힘 슬립은 root `pmset` 설정입니다. 이 파일이 없으면 DontSleep은
켜지지만 **켜기** 가 실패합니다. `sudo -n` (비밀번호 없이) 을 쓰기
때문입니다. 스크립트는 **지금 계정에만** `/etc/sudoers.d/dontsleep` 를
쓰며, 허용하는 명령은 다음 두 줄뿐입니다.

```
pmset -a disablesleep 1
pmset -a disablesleep 0
```

설치 후 그 파일을 읽어볼 수 있습니다. 지울 때는
`sudo rm /etc/sudoers.d/dontsleep`.

### 소스에서

```sh
git clone https://github.com/innocarpe/dontsleep.git
cd dontsleep
./scripts/install-sudoers.sh
./build.sh
```

`build.sh` 는 `/Applications/DontSleep.app` 에 설치합니다.

## 사용

메뉴바에 두고 씁니다. 가방에 넣을 때는 끄세요. **로그인할 때 시작** 은
`~/Library/LaunchAgents/com.innocarpe.dontsleep.plist` 를 씁니다.

켜져 있는 동안 덮개를 닫아도 잠들지 않습니다. 배터리를 확인하세요.

## 빌드

Xcode Command Line Tools (Swift + `hdiutil`) 가 필요합니다.

```sh
./scripts/build-app.sh            # dist/DontSleep.app
./scripts/package-dmg.sh          # DontSleep-<version>.dmg
./scripts/make-icons.sh           # icns / 메뉴바 PDF 다시 만들기
```

## 라이선스

[Apache License 2.0](LICENSE)
