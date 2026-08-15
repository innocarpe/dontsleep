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

发布的磁盘映像是 **ad-hoc 签名**，未经公证。系统提示“无法验证开发者”
是预期行为。

### 磁盘映像

1. 从 [Releases](https://github.com/innocarpe/dontsleep/releases) 下载
   `DontSleep-*.dmg` 并打开。
2. 将 **DontSleep** 拖到 **Applications**。
3. 双击 **Install Sudoers.command**（见下文）。会询问一次管理员密码。
4. 打开 **DontSleep**。菜单栏会出现笔记本图标。

若 macOS 拒绝打开应用或 `.command` 文件：

1. **按住 Control 单击 → 打开 → 打开。** 请先用这一步。
2. 或：系统设置 → 隐私与安全性 → **仍要打开**。
3. 仅在你本来就用终端时。不是必须步骤：

   ```sh
   xattr -d com.apple.quarantine /Applications/DontSleep.app
   ```

### Install Sudoers.command 是什么

它就是 `scripts/install-sudoers.sh`，加上 `.command` 后缀，以便在
Finder 里双击后在终端运行。它**不会**安装应用，也**不会**放开全部
`sudo`。

合盖休眠是需要 root 的 `pmset` 设置。没有这个文件时 DontSleep 能打开，
但**开启**会失败，因为它使用 `sudo -n`（不弹出密码）。脚本只为
**当前账户** 写入 `/etc/sudoers.d/dontsleep`，且只允许这两条：

```
pmset -a disablesleep 1
pmset -a disablesleep 0
```

安装后可以打开该文件查看。要删除：
`sudo rm /etc/sudoers.d/dontsleep`。

### 从源码

```sh
git clone https://github.com/innocarpe/dontsleep.git
cd dontsleep
./scripts/install-sudoers.sh
./build.sh
```

`build.sh` 会安装到 `/Applications/DontSleep.app`。

## 使用

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
