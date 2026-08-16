# <img src="docs/assets/app-icon-rounded.png" alt="" width="36" height="36" align="left" />&nbsp; DontSleep

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue?style=flat)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?style=flat)](#install)
[![Arch](https://img.shields.io/badge/arch-Apple%20silicon-lightgrey?style=flat)](#building)

**Close the lid. Work keeps going. The screen and keyboard go dark.**

A lot of people run `pmset disablesleep` so a closed MacBook stays awake.
That works — and it leaves the built-in screen on inside a shut lid. The
panel keeps making heat in a box that cannot vent well.

DontSleep does the same stay-awake switch from the menu bar, then turns
off what you do not need once the lid is down: the built-in screen and
the keyboard light. Open it again and both come back as they were. You
do not dim first.

That is the point of the app. Not a prettier `pmset`. Less leftover heat
while the machine keeps working — commute, a meeting room, a long job
you do not want to stop.

Click the icon to turn it on or off. Right-click for the rest. Filled
laptop means on. Outline means off.

<p align="center">
  <img src="docs/assets/app-icon-rounded.png" alt="DontSleep app icon: a Space Black MacBook with the lid slightly open and a warm glow from the keyboard" width="220" />
</p>

`caffeinate` and KeepingYouAwake only stop idle sleep. They do not stop
a closed lid. This does. It is not signed with an Apple Developer ID.

Off before the bag. The machine is still awake in there.

---

## Install

The release is ad-hoc signed, not notarized. On Tahoe, a downloaded copy
only offers **Move to Trash**. Do not double-click it.

```sh
curl -fsSL https://raw.githubusercontent.com/innocarpe/dontsleep/main/install.sh | zsh
```

The first window asks for your password once. That writes
`/etc/sudoers.d/dontsleep` for your account, two `pmset` lines only.
It does not unlock all of `sudo`.

Read [install.sh](install.sh) first if you prefer. Already have the
disk image: `zsh install.sh ~/Downloads/DontSleep-*.dmg`.

Remove the helper later: `sudo rm /etc/sudoers.d/dontsleep`.

### From source

```sh
git clone https://github.com/innocarpe/dontsleep.git
cd dontsleep
./build.sh
```

Finish setup in the first window. Or `./scripts/install-sudoers.sh`.

## Usage

First launch is setup. **How to Use…** in the menu opens it again.

Leave it in the menu bar. Close the lid at whatever brightness you were
using. **Open at Login** writes
`~/Library/LaunchAgents/com.innocarpe.dontsleep.plist`.

**Sleep on Overheat Warning** is off unless you turn it on. If the Mac
sends an overheat warning with the lid closed, DontSleep turns off and
the machine sleeps immediately.

Watch the battery.

## Building

Xcode Command Line Tools (Swift + `hdiutil`).

```sh
./scripts/build-app.sh            # dist/DontSleep.app
./scripts/package-dmg.sh          # DontSleep-<version>.dmg
./scripts/make-icons.sh           # icns / menu-bar PDFs
```

## License

[Apache License 2.0](LICENSE)
