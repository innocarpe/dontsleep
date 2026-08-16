# <img src="docs/assets/app-icon-rounded.png" alt="" width="36" height="36" align="left" />&nbsp; DontSleep

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue?style=flat)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?style=flat)](#安装)
[![Arch](https://img.shields.io/badge/arch-Apple%20silicon-lightgrey?style=flat)](#构建)

**合上盖子就行。事情继续跑，屏幕和键盘会灭。**

DontSleep 是 macOS 菜单栏应用。开着，按现在的亮度直接合盖即可。
电脑不睡。内置屏幕和键盘背光会像合盖外接那样关掉，再打开时回到
原来的亮度。单击切换，右键打开菜单。

<p align="center">
  <img src="docs/assets/app-icon-rounded.png" alt="DontSleep 应用图标：略微打开的 Space Black 笔记本，键盘透出暖光" width="220" />
</p>

---

## 为什么存在

`caffeinate` 和 KeepingYouAwake 只能阻止**空闲**休眠，不能阻止**合盖**
休眠。官方开关是需要 root 的 `pmset disablesleep`。

DontSleep 把这个开关放到菜单栏。如果只禁止休眠，内置屏幕还会亮着。
合盖时屏幕和键盘灯也会关掉，打开后再回到你刚才的亮度。

## 适合谁

适合这些情况：

- 合盖后还要继续干活（通勤、会议室、跑很久的任务）
- 希望在菜单栏看到当前状态，而不是只在终端里看
- 不想每次切换都输入密码

它不是空闲休眠工具。也没有 Apple Developer ID 签名（见[安装](#安装)）。

## 功能

| 操作 | 结果 |
| --- | --- |
| 左键 | 开启 / 关闭 |
| 右键 | 菜单 |
| 实心笔记本图标 | 开 — 合盖也不睡，屏幕和键盘会灭 |
| 线框笔记本图标 | 已关闭 — 合盖后休眠 |

菜单栏图标跟随浅色/深色。语言跟随 macOS：英语、韩语、简体中文、日语。

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

不会开放全部 `sudo`。

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

首次启动就是设置。菜单里的 **怎么用…** 可以再打开。

留在菜单栏。按现在的亮度直接合盖即可。装包前先关。**登录时打开**
会写入 `~/Library/LaunchAgents/com.innocarpe.dontsleep.plist`。

**过热警告时休眠** 默认关闭。合盖使用时如果 Mac 发出过热警告，
DontSleep 会关掉并马上休眠。

请留意电量。

## 构建

需要 Xcode Command Line Tools（Swift + `hdiutil`）。

```sh
./scripts/build-app.sh            # dist/DontSleep.app
./scripts/package-dmg.sh          # DontSleep-<version>.dmg
./scripts/make-icons.sh           # 重建 icns / 菜单栏 PDF
```

## 许可

[Apache License 2.0](LICENSE)
