# <img src="docs/assets/app-icon-rounded.png" alt="" width="36" height="36" align="left" />&nbsp; DontSleep

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue?style=flat)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?style=flat)](#安装)
[![Arch](https://img.shields.io/badge/arch-Apple%20silicon-lightgrey?style=flat)](#构建)

**合上盖子后仍保持 Mac 唤醒。**

DontSleep 是一个很小的 macOS 菜单栏应用。它切换系统的 `disablesleep`
标志，使合盖不会让电脑休眠（电源或电池均可）。单击图标即可开关；
右键打开菜单。

<p align="center">
  <img src="docs/assets/app-icon-rounded.png" alt="DontSleep 应用图标：略微打开的 Space Black 笔记本，键盘透出暖光" width="220" />
</p>

---

## 为什么存在

`caffeinate` 和 KeepingYouAwake 只能阻止**空闲**休眠，不能阻止**合盖**
休眠。官方开关是需要 root 的 `pmset disablesleep`。

DontSleep 把这个开关放到菜单栏，并把 sudoers 限制为两条精确的 `pmset`
命令。

## 适合谁

适合这些情况：

- 合盖后仍希望 Mac 保持在线（桌面、工作室、外接显示器）
- 希望在菜单栏看到当前状态，而不是只在终端里看
- 不想每次切换都输入密码

它不能替代只阻止空闲休眠的工具。也没有使用 Apple Developer ID 签名
（见[安装](#安装)）。

## 功能

| 操作 | 结果 |
| --- | --- |
| 左键 | 开启 / 关闭 |
| 右键或 Control-单击 | 菜单：状态、开启、关闭、登录时启动、退出 |
| 实心笔记本图标 | 已开启 — 合盖后仍保持唤醒 |
| 线框笔记本图标 | 已关闭 — 合盖后休眠 |

菜单栏图标是模板图，会跟随系统菜单栏的深色/浅色。界面跟随 macOS 语言，
默认为英语，并提供韩语、简体中文和日语。

## 安装

发布构建是 **ad-hoc 签名**，未经公证。在当前 macOS（Tahoe）上，用
Finder 打开下载的副本只会弹出 **移到废纸篓**。Gatekeeper 检查的是
你启动的那个应用，所以清除磁盘映像上的隔离属性没有用。不要下载后
双击应用。

下面这一条命令会复制应用、清除该副本的隔离属性，并打开 DontSleep：

```sh
curl -fsSL https://raw.githubusercontent.com/innocarpe/dontsleep/main/install.sh | zsh
```

第一个窗口里有一个小终端。按 Enter 后，macOS 会询问一次密码，并只为
**当前账户**写入 `/etc/sudoers.d/dontsleep`，且只允许：

```
pmset -a disablesleep 1
pmset -a disablesleep 0
```

不会开放全部 `sudo`。这一步不需要打开“终端”应用。

若不希望把脚本直接交给 shell，请先阅读 [install.sh](install.sh)。
若磁盘映像已在本地：`zsh install.sh ~/Downloads/DontSleep-*.dmg`。

要删除：`sudo rm /etc/sudoers.d/dontsleep`。

### 从源码

```sh
git clone https://github.com/innocarpe/dontsleep.git
cd dontsleep
./build.sh
```

`build.sh` 会安装到 `/Applications/DontSleep.app`。请在首个窗口完成
辅助规则。若想在 shell 里写：`./scripts/install-sudoers.sh`。

## 使用

首次启动会说明会改什么，在应用内终端运行辅助命令，并介绍菜单栏。
可在菜单中打开 **使用方法…** 再次查看。

留在菜单栏即可。放进包里之前请先关闭。**登录时启动** 会写入
`~/Library/LaunchAgents/com.innocarpe.dontsleep.plist`。

开启时合盖也不会休眠。请留意电量。

## 构建

需要 Xcode Command Line Tools（Swift + `hdiutil`）。

```sh
./scripts/build-app.sh            # dist/DontSleep.app
./scripts/package-dmg.sh          # DontSleep-<version>.dmg
./scripts/make-icons.sh           # 重建 icns / 菜单栏 PDF
```

## 许可

[Apache License 2.0](LICENSE)
