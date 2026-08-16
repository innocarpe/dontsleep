# <img src="docs/assets/app-icon-rounded.png" alt="" width="36" height="36" align="left" />&nbsp; DontSleep

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue?style=flat)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?style=flat)](#安装)
[![Arch](https://img.shields.io/badge/arch-Apple%20silicon-lightgrey?style=flat)](#构建)

**合上盖子就行。事情继续跑，屏幕和键盘会灭。**

很多人用 `pmset disablesleep` 让合盖后的 Mac 别睡。这招有效 ——
但只关休眠的话，内置屏幕还在盖子里面亮着。封闭壳子里面板还在转，
热更不容易散。

DontSleep 把同一个开关放到菜单栏，合盖时再把不必开的东西关掉：
内置屏幕和键盘背光。再打开，亮度回到刚才那样。不用先把屏幕调暗。

这就是用这个应用、而不是只在终端里关休眠的原因。事情照跑，少留
一点盖子里面的热。通勤、会议室、合盖还要跑完的任务，都是这种用法。

点图标开关。右键是剩下的菜单。实心笔记本是开，线框是关。

<p align="center">
  <img src="docs/assets/app-icon-rounded.png" alt="DontSleep 应用图标：略微打开的 Space Black 笔记本，键盘透出暖光" width="220" />
</p>

`caffeinate` 和 KeepingYouAwake 只能挡住闲着时候的休眠。合盖它们
不管。这个可以。没有 Apple Developer ID 签名。

放进包里之前先关。里面电脑还是醒的。

---

## 安装

发布构建是 ad-hoc 签名，未经公证。在 Tahoe 上打开下载的文件只有
**移到废纸篓**。不要双击。

```sh
curl -fsSL https://raw.githubusercontent.com/innocarpe/dontsleep/main/install.sh | zsh
```

第一个窗口会问一次密码。只给当前账户写 `/etc/sudoers.d/dontsleep`，
只允许两行 `pmset`。不会开放全部 `sudo`。

不想直接把脚本交给 shell，先看 [install.sh](install.sh)。
磁盘映像已经在本地：`zsh install.sh ~/Downloads/DontSleep-*.dmg`。

删除：`sudo rm /etc/sudoers.d/dontsleep`。

### 从源码

```sh
git clone https://github.com/innocarpe/dontsleep.git
cd dontsleep
./build.sh
```

在首个窗口做完设置。或 `./scripts/install-sudoers.sh`。

## 使用

首次启动就是设置。菜单里的 **怎么用…** 可以再打开。

留在菜单栏。按现在的亮度直接合盖。**登录时打开** 会写入
`~/Library/LaunchAgents/com.innocarpe.dontsleep.plist`。

**过热警告时休眠** 默认关闭。合盖使用时如果 Mac 发出过热警告，
DontSleep 会关掉并马上休眠。

请留意电量。

## 构建

Xcode Command Line Tools（Swift + `hdiutil`）。

```sh
./scripts/build-app.sh            # dist/DontSleep.app
./scripts/package-dmg.sh          # DontSleep-<version>.dmg
./scripts/make-icons.sh           # icns / 菜单栏 PDF
```

## 许可

[Apache License 2.0](LICENSE)
