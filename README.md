# <img src="docs/assets/app-icon-rounded.png" alt="" width="36" height="36" align="left" />&nbsp; DontSleep

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue?style=flat)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?style=flat)](#install)
[![Arch](https://img.shields.io/badge/arch-Apple%20silicon-lightgrey?style=flat)](#building)

**Keep the Mac awake with the lid closed.**

DontSleep is a tiny menu bar extra for macOS. It toggles the system
`disablesleep` flag so a closed lid does not put the machine to sleep — on
battery or on power. Click the icon to switch; right-click for the menu.

<p align="center">
  <img src="docs/assets/app-icon-rounded.png" alt="DontSleep app icon: a Space Black MacBook with the lid slightly open and a warm glow from the keyboard" width="220" />
</p>

---

## Why this exists

`caffeinate` and apps like KeepingYouAwake stop **idle** sleep. They do not
stop **closed-lid** sleep. The only supported switch for that is
`pmset disablesleep`, which needs root.

DontSleep is that switch, with a menu bar you can see and a sudoers rule
narrowed to two exact `pmset` invocations.

## Who it’s for

Useful if you:

- Close the lid and keep the Mac reachable (desk, studio, clamshell + display)
- Want the current state visible in the menu bar, not only in a terminal
- Do not want a password prompt every time you flip the setting

Not a replacement for Amphetamine-style idle assertions. Not signed with an
Apple Developer ID (see [Install](#install)).

## What it does

| Action | Result |
| --- | --- |
| Left-click | Toggle on / off |
| Right-click or Control-click | Menu: status, on, off, start at login, quit |
| Filled laptop icon | On — stays awake with the lid closed |
| Outline laptop icon | Off — sleeps when the lid closes |

The menu bar glyphs are template images, so they follow the system menu bar
(dark or light). The UI follows the macOS language: English by default, plus
Korean, Simplified Chinese, and Japanese.

## Install

The release is **ad-hoc signed, not notarized**. On current macOS (Tahoe),
opening a downloaded copy from Finder shows **Move to Trash** only — no
Open button. Gatekeeper checks the app you launch, so clearing quarantine
on a disk image does not help. Do not download and double-click the app.

One command copies the app, clears quarantine on that copy, writes the
helper, and opens DontSleep:

```sh
curl -fsSL https://raw.githubusercontent.com/innocarpe/dontsleep/main/install.sh | zsh
```

macOS asks for your password once. That writes
`/etc/sudoers.d/dontsleep` for **your account only**, limited to:

```
pmset -a disablesleep 1
pmset -a disablesleep 0
```

It does not unlock all of `sudo`. A laptop icon appears in the menu bar.

Read [install.sh](install.sh) first if you prefer not to pipe to a shell.
If you already have the disk image: `zsh install.sh ~/Downloads/DontSleep-*.dmg`.

To remove the helper later: `sudo rm /etc/sudoers.d/dontsleep`.

### From source

```sh
git clone https://github.com/innocarpe/dontsleep.git
cd dontsleep
./scripts/install-sudoers.sh
./build.sh
```

`build.sh` installs to `/Applications/DontSleep.app`.

## Usage

The first launch walks through what DontSleep changes, why a password is
asked, and how the menu bar works. Open **How to Use…** from the menu to
see that again.

Leave it in the menu bar. Turn it off when you want the laptop to sleep in
a bag. **Start at Login** writes `~/Library/LaunchAgents/com.innocarpe.dontsleep.plist`.

While it is on, a closed lid will not sleep the Mac. Watch the battery.

## Building

Requires Xcode Command Line Tools (Swift + `hdiutil`).

```sh
./scripts/build-app.sh            # dist/DontSleep.app
./scripts/package-dmg.sh          # DontSleep-<version>.dmg
./scripts/make-icons.sh           # rebuild icns / menu-bar PDFs
```

## License

[Apache License 2.0](LICENSE)
