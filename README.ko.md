# <img src="docs/assets/app-icon-rounded.png" alt="" width="36" height="36" align="left" />&nbsp; DontSleep

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue?style=flat)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?style=flat)](#설치)
[![Arch](https://img.shields.io/badge/arch-Apple%20silicon-lightgrey?style=flat)](#빌드)

**덮개만 닫으면 됩니다. 일은 계속되고, 화면과 키보드는 꺼집니다.**

덮개를 닫아도 맥을 깨워 두려고 `pmset disablesleep` 을 쓰는 사람이
많습니다. 그건 됩니다. 다만 잠자기만 막으면 내장 화면이 닫힌 뚜껑
안에서 그대로 켜져 있습니다. 빠져나갈 곳 없는 통 안에서 패널이 계속
돌아가니 열이 더 납니다.

DontSleep은 그 스위치를 메뉴바에 올려 두고, 덮개를 닫는 순간 굳이 켜
둘 필요 없는 것까지 끕니다. 내장 화면, 키보드 백라이트. 다시 열면
쓰던 밝기로 돌아옵니다. 미리 어둡게 할 필요 없습니다.

터미널에서 잠자기만 끄는 것보다 이 앱을 쓰는 이유가 여기 있습니다.
일은 그대로 두고, 닫힌 안에서 태울 필요 없는 불만 끕니다. 출퇴근,
회의실, 덮어 두고 돌리는 작업에 맞습니다.

아이콘을 누르면 켜고 끕니다. 오른쪽 클릭이 나머지 메뉴입니다. 채워진
노트북이 켜짐, 윤곽만 있으면 꺼짐입니다.

<p align="center">
  <img src="docs/assets/app-icon-rounded.png" alt="DontSleep 앱 아이콘: 뚜껑이 살짝 열린 Space Black 맥북과 키보드에서 새는 따뜻한 빛" width="220" />
</p>

`caffeinate` 나 KeepingYouAwake 는 가만히 둘 때 잠드는 것만 막습니다.
덮개를 닫으면 끝입니다. 이건 덮개를 닫아도 됩니다. Apple Developer ID
서명은 없습니다.

가방에 넣기 전에 끄세요. 그 안에서도 맥은 깨어 있습니다.

---

## 설치

릴리즈는 ad-hoc 서명이고 공증이 없습니다. Tahoe에서 받은 파일을 열면
**휴지통으로 이동**만 나옵니다. 더블클릭하지 마세요.

```sh
curl -fsSL https://raw.githubusercontent.com/innocarpe/dontsleep/main/install.sh | zsh
```

첫 창에서 비밀번호를 한 번 묻습니다. 지금 계정에만
`/etc/sudoers.d/dontsleep` 를 쓰고, `pmset` 두 줄만 허용합니다.
`sudo` 전체를 열지 않습니다.

파이프가 불편하면 [install.sh](install.sh) 를 먼저 읽으면 됩니다.
디스크 이미지가 있으면: `zsh install.sh ~/Downloads/DontSleep-*.dmg`.

지울 때: `sudo rm /etc/sudoers.d/dontsleep`.

### 소스에서

```sh
git clone https://github.com/innocarpe/dontsleep.git
cd dontsleep
./build.sh
```

첫 창에서 설정을 끝냅니다. 셸에서 하려면 `./scripts/install-sudoers.sh`.

## 사용

첫 실행이 설정입니다. 메뉴의 **쓰는 법…** 에서 다시 열립니다.

메뉴바에 두고 씁니다. 쓰던 밝기 그대로 덮개를 닫으면 됩니다.
**로그인 시 열기** 는
`~/Library/LaunchAgents/com.innocarpe.dontsleep.plist` 를 씁니다.

**과열 경고 시 잠자기** 는 기본이 꺼져 있습니다. 덮개를 닫아 쓰는 중
맥이 과열 경고를 보내면 DontSleep을 끄고 바로 잠듭니다.

배터리를 확인하세요.

## 빌드

Xcode Command Line Tools (Swift + `hdiutil`).

```sh
./scripts/build-app.sh            # dist/DontSleep.app
./scripts/package-dmg.sh          # DontSleep-<version>.dmg
./scripts/make-icons.sh           # icns / 메뉴바 PDF 다시 만들기
```

## 라이선스

[Apache License 2.0](LICENSE)
