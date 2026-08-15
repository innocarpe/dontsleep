# <img src="docs/assets/app-icon-rounded.png" alt="" width="36" height="36" align="left" />&nbsp; DontSleep

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue?style=flat)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?style=flat)](#インストール)
[![Arch](https://img.shields.io/badge/arch-Apple%20silicon-lightgrey?style=flat)](#ビルド)

**カバーを閉じても Mac をスリープさせません。**

DontSleep は小さな macOS メニューバーアプリです。システムの
`disablesleep` を切り替え、電源・バッテリーのどちらでもカバーを閉じても
スリープしないようにします。クリックでオン/オフ、右クリックでメニューです。

<p align="center">
  <img src="docs/assets/app-icon-rounded.png" alt="DontSleep のアプリアイコン。わずかに開いた Space Black のノートブックと、キーボードから漏れる暖かい光" width="220" />
</p>

---

## なぜあるのか

`caffeinate` や KeepingYouAwake は**アイドル**スリープだけを止めます。
**カバーを閉じた**スリープは止めません。それを変える公式のスイッチは
root が必要な `pmset disablesleep` だけです。

DontSleep はそのスイッチをメニューバーに置き、sudoers は 2 つの正確な
`pmset` 呼び出しだけを許可します。

## だれ向けか

次のようなときに向きます。

- カバーを閉じたまま Mac を起こしておきたい（デスク、スタジオ、外部ディスプレイ）
- ターミナルではなくメニューバーで今の状態を見たい
- 切り替えるたびにパスワードを入れたくない

アイドルスリープだけを止めるアプリの代わりではありません。Apple Developer
ID では署名されていません（[インストール](#インストール)）。

## できること

| 操作 | 結果 |
| --- | --- |
| 左クリック | オン / オフ |
| 右クリックまたは Control-クリック | メニュー: 状態、オン、オフ、ログイン時に開く、終了 |
| 塗りつぶしたノートのアイコン | オン — カバーを閉じてもスリープしない |
| 輪郭だけのノートのアイコン | オフ — カバーを閉じるとスリープする |

メニューバーのアイコンはテンプレートなので、システムのメニューバー
（ダーク / ライト）に従います。UI は macOS の言語に従い、既定は英語、
加えて韓国語・中国語（簡体字）・日本語です。

## インストール

リリースは **ad-hoc 署名**で、公証されていません。いまの macOS
（Tahoe）では、ダウンロードしたコピーを Finder で開くと
**ゴミ箱に入れる** しか出ません。Gatekeeper が見るのは起動するアプリ
なので、ディスクイメージの隔離属性を消しても意味がありません。
アプリを入手してダブルクリックしないでください。

次の 1 行がアプリのコピー、そのコピーの隔離解除、DontSleep の起動まで
行います。

```sh
curl -fsSL https://raw.githubusercontent.com/innocarpe/dontsleep/main/install.sh | zsh
```

最初のウィンドウに小さなターミナルがあります。Enter を押すと
macOS がパスワードを一度尋ね、**今のアカウントだけ** に
`/etc/sudoers.d/dontsleep` を書き、次だけを許可します。

```
pmset -a disablesleep 1
pmset -a disablesleep 0
```

sudo 全体は開きません。この手順にターミナルアプリは不要です。

シェルに直接渡したくなければ、先に [install.sh](install.sh) を読んでください。
ディスクイメージが既にあるときは: `zsh install.sh ~/Downloads/DontSleep-*.dmg`。

消すとき: `sudo rm /etc/sudoers.d/dontsleep`。

### ソースから

```sh
git clone https://github.com/innocarpe/dontsleep.git
cd dontsleep
./build.sh
```

`build.sh` は `/Applications/DontSleep.app` に入れます。ヘルパーは
最初のウィンドウで完了します。シェルから書く場合は
`./scripts/install-sudoers.sh`。

## 使い方

初回起動で、何を変えるかを案内し、アプリ内ターミナルでヘルパーを
実行し、メニューバーの使い方を示します。メニューの **使い方…** から
再表示できます。

メニューバーに置いたまま使います。バッグに入れる前にオフにしてください。
**ログイン時に開く** は
`~/Library/LaunchAgents/com.innocarpe.dontsleep.plist` を書き込みます。

オンのあいだはカバーを閉じてもスリープしません。バッテリーに注意してください。

## ビルド

Xcode Command Line Tools（Swift + `hdiutil`）が必要です。

```sh
./scripts/build-app.sh            # dist/DontSleep.app
./scripts/package-dmg.sh          # DontSleep-<version>.dmg
./scripts/make-icons.sh           # icns / メニューバー PDF を再生成
```

## ライセンス

[Apache License 2.0](LICENSE)
