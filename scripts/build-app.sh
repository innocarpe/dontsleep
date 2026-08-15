#!/bin/zsh
set -euo pipefail

# Build DontSleep.app into $1 (default: <repo>/dist/DontSleep.app).
# Does not install into /Applications.

root="$(cd "$(dirname "$0")/.." && pwd)"
stage="${1:-${root}/dist/DontSleep.app}"
macos="${stage}/Contents/MacOS"
res="${stage}/Contents/Resources"
sdk="$(xcrun --show-sdk-path)"

mkdir -p "$macos" "$res"
cp "${root}/Info.plist" "${stage}/Contents/Info.plist"
cp "${root}/Assets/AppIcon.icns" "${res}/AppIcon.icns"
cp "${root}/Assets/MenubarOn.pdf" "${root}/Assets/MenubarOff.pdf" "${root}/Assets/MenubarError.pdf" "$res"

for lang in en ko zh-Hans ja; do
  mkdir -p "${res}/${lang}.lproj"
  cp "${root}/Resources/${lang}.lproj/Localizable.strings" "${res}/${lang}.lproj/"
done

swiftc -O \
  -target arm64-apple-macos14.0 \
  -sdk "$sdk" \
  -framework AppKit \
  -framework SwiftUI \
  -framework Combine \
  -o "${macos}/DontSleep" \
  "${root}"/Sources/*.swift

codesign -s - --force --deep "${stage}" >/dev/null
print "Built ${stage}"
