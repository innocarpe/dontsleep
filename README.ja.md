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

リリースのディスクイメージは **ad-hoc 署名**で、公証されていません。
「開発元を確認できない」と出るのが普通です。

### ディスクイメージから

1. [Releases](https://github.com/innocarpe/dontsleep/releases) から
   `DontSleep-*.dmg` を入手して開きます。
2. **Install DontSleep.pkg** をダブルクリックし、Mac のパスワードを
   入力します。アプリを Applications に入れ、`pmset` 2 行をパスワード
   なしで許可し、ログイン時に DontSleep を開きます。
3. メニューバーにノートのアイコンが出ます。

パッケージが止まったとき:

1. **Control-クリック → 開く → 開く。** まずこちらです。
2. または システム設定 → プライバシーとセキュリティ → **このまま開く**。

この警告は Gatekeeper です（公証されていないビルド）。インストーラが
聞くパスワードは別で、**今のアカウントだけ** に
`/etc/sudoers.d/dontsleep` を書き、次だけを許可します。

```
pmset -a disablesleep 1
pmset -a disablesleep 0
```

sudo 全体は開きません。パッケージを使わずアプリだけコピーした場合は、
初回起動時に DontSleep がそのパスワードを自分で尋ねます。

消すとき: `sudo rm /etc/sudoers.d/dontsleep`。

### ソースから

```sh
git clone https://github.com/innocarpe/dontsleep.git
cd dontsleep
./scripts/install-sudoers.sh
./build.sh
```

`build.sh` は `/Applications/DontSleep.app` に入れます。

## 使い方

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
