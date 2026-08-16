# <img src="docs/assets/app-icon-rounded.png" alt="" width="36" height="36" align="left" />&nbsp; DontSleep

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue?style=flat)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?style=flat)](#インストール)
[![Arch](https://img.shields.io/badge/arch-Apple%20silicon-lightgrey?style=flat)](#ビルド)

**カバーを閉じるだけ。作業は続き、画面とキーボードは消えます。**

カバーを閉じても起こしておくために `pmset disablesleep` を使う人は
多いです。それは効きます。ただしスリープを止めるだけでは、内蔵画面が
閉じたカバーの中でついたままです。逃げ場のない箱の中でパネルが回り
続けるので、熱がこもります。

DontSleep はそのスイッチをメニューバーに置き、カバーを閉じた瞬間に
いらないものまで消します。内蔵画面とキーボードの明かりです。開けると
使っていた明るさに戻ります。先に暗くする必要はありません。

ターミナルでスリープだけ止めるより、これを使う理由がそこにあります。
作業はそのまま、閉じた中で燃やす必要のない灯だけ消します。通勤、
会議室、閉じたまま回しておきたい仕事向けです。

アイコンをクリックでオン/オフ。右クリックが残りのメニューです。
塗りつぶしたノートがオン、輪郭だけがオフです。

<p align="center">
  <img src="docs/assets/app-icon-rounded.png" alt="DontSleep のアプリアイコン。わずかに開いた Space Black のノートブックと、キーボードから漏れる暖かい光" width="220" />
</p>

`caffeinate` や KeepingYouAwake は、触らずにいるときのスリープだけ
止めます。カバーを閉じると終わりです。これは閉じても大丈夫です。
Apple Developer ID では署名されていません。

バッグに入れる前にオフ。中でも Mac は起きています。

---

## インストール

リリースは ad-hoc 署名で、公証されていません。Tahoe でダウンロード
したファイルを開くと **ゴミ箱に入れる** しか出ません。ダブルクリック
しないでください。

```sh
curl -fsSL https://raw.githubusercontent.com/innocarpe/dontsleep/main/install.sh | zsh
```

最初のウィンドウでパスワードを一度聞きます。今のアカウントだけに
`/etc/sudoers.d/dontsleep` を書き、`pmset` 2 行だけ許可します。
sudo 全体は開きません。

シェルに直接渡したくなければ [install.sh](install.sh) を先に読んでください。
ディスクイメージがあるとき: `zsh install.sh ~/Downloads/DontSleep-*.dmg`。

消すとき: `sudo rm /etc/sudoers.d/dontsleep`。

### ソースから

```sh
git clone https://github.com/innocarpe/dontsleep.git
cd dontsleep
./build.sh
```

最初のウィンドウでセットアップします。または
`./scripts/install-sudoers.sh`。

## 使い方

初回起動がセットアップです。メニューの **使い方…** から再表示できます。

メニューバーに置いたまま使います。使っていた明るさのままカバーを
閉じればよいです。**ログイン時に開く** は
`~/Library/LaunchAgents/com.innocarpe.dontsleep.plist` を書き込みます。

**過熱警告でスリープ** は初期状態でオフです。カバーを閉じたまま過熱
警告が出ると、DontSleep を切ってすぐスリープします。

バッテリーに注意してください。

## ビルド

Xcode Command Line Tools（Swift + `hdiutil`）。

```sh
./scripts/build-app.sh            # dist/DontSleep.app
./scripts/package-dmg.sh          # DontSleep-<version>.dmg
./scripts/make-icons.sh           # icns / メニューバー PDF
```

## ライセンス

[Apache License 2.0](LICENSE)
