# <img src="docs/assets/app-icon-rounded.png" alt="" width="36" height="36" align="left" />&nbsp; DontSleep

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue?style=flat)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?style=flat)](#install)
[![Arch](https://img.shields.io/badge/arch-Apple%20silicon-lightgrey?style=flat)](#building)

**Close the lid. Work keeps going. The screen and keyboard go dark.**

DontSleep is a macOS menu bar app. Turn it on, close the lid as-is —
no dimming first. The Mac stays awake. The built-in screen and keyboard
backlight turn off like clamshell, then come back as they were when you
open it. Click the icon to switch; right-click for the menu.

<p align="center">
  <img src="docs/assets/app-icon-rounded.png" alt="DontSleep app icon: a Space Black MacBook with the lid slightly open and a warm glow from the keyboard" width="220" />
</p>

---

## Why this exists

`caffeinate` and apps like KeepingYouAwake stop **idle** sleep. They do not
stop **closed-lid** sleep. The only supported switch for that is
`pmset disablesleep`, which needs root.

DontSleep is that switch, in the menu bar. Sleep-disable alone would
leave the built-in panel on. Closing the lid also blanks the screen and
keyboard light, then restores the levels you were using.

## Who it’s for

Useful if you:

- Close the lid and keep work running (commute, meeting room, a long agent job)
- Want the current state visible in the menu bar, not only in a terminal
- Do not want a password prompt every time you flip the setting

Not an idle-sleep app. Not signed with an Apple Developer ID
(see [Install](#install)).

## What it does

| Action | Result |
| --- | --- |
| Left-click | Toggle on / off |
| Right-click | Menu |
| Filled laptop icon | On — lid closed, stays awake; screen and keyboard go dark |
| Outline laptop icon | Off — sleeps when the lid closes |

Menu bar icons follow light and dark. Language follows macOS: English,
Korean, Simplified Chinese, Japanese.

## Install

The release is **ad-hoc signed, not notarized**. On current macOS (Tahoe),
opening a downloaded copy from Finder shows **Move to Trash** only — no
Open button. Gatekeeper checks the app you launch, so clearing quarantine
on a disk image does not help. Do not download and double-click the app.

One command copies the app, clears quarantine on that copy, and opens
DontSleep:

```sh
curl -fsSL https://raw.githubusercontent.com/innocarpe/dontsleep/main/install.sh | zsh
```

The first window has a small terminal. Press Enter. macOS asks for your
password once and writes `/etc/sudoers.d/dontsleep` for **your account
only**, limited to:

```
pmset -a disablesleep 1
pmset -a disablesleep 0
```

It does not unlock all of `sudo`.

Read [install.sh](install.sh) first if you prefer not to pipe to a shell.
If you already have the disk image: `zsh install.sh ~/Downloads/DontSleep-*.dmg`.

To remove the helper later: `sudo rm /etc/sudoers.d/dontsleep`.

### From source

```sh
git clone https://github.com/innocarpe/dontsleep.git
cd dontsleep
./build.sh
```

`build.sh` installs to `/Applications/DontSleep.app`. Finish setup in
the first window. `./scripts/install-sudoers.sh` does the same helper
from a shell if you want.

## Usage

First launch is the setup. **How to Use…** in the menu opens it again.

Leave it in the menu bar. Close the lid at whatever brightness you were
using. Off before the bag. **Open at Login** writes
`~/Library/LaunchAgents/com.innocarpe.dontsleep.plist`.

**Sleep on Overheat Warning** is off unless you turn it on. If macOS
sends an overheat warning with the lid closed, DontSleep turns off and
the Mac sleeps immediately.

Watch the battery.

## Building

Requires Xcode Command Line Tools (Swift + `hdiutil`).

```sh
./scripts/build-app.sh            # dist/DontSleep.app
./scripts/package-dmg.sh          # DontSleep-<version>.dmg
./scripts/make-icons.sh           # rebuild icns / menu-bar PDFs
```

## License

[Apache License 2.0](LICENSE)
