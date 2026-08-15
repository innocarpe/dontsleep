#!/bin/zsh
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
assets="${root}/Assets"
src="${DONT_SLEEP_ICON_SRC:-${root}/Assets/app-icon-master.jpg}"
sdk="$(xcrun --show-sdk-path)"

mkdir -p "$assets"

if [[ ! -f "$src" ]]; then
  echo "missing icon source: $src" >&2
  exit 1
fi

sips -s format png --out "${assets}/AppIcon-1024.png" "$src" >/dev/null

iconset="${assets}/AppIcon.iconset"
rm -rf "$iconset"
mkdir -p "$iconset"

# Traditional icns sizes. Tahoe remasks the 1024 master.
for spec in \
  "icon_16x16:16" \
  "icon_16x16@2x:32" \
  "icon_32x32:32" \
  "icon_32x32@2x:64" \
  "icon_128x128:128" \
  "icon_128x128@2x:256" \
  "icon_256x256:256" \
  "icon_256x256@2x:512" \
  "icon_512x512:512" \
  "icon_512x512@2x:1024"
do
  name="${spec%%:*}"
  px="${spec##*:}"
  sips -z "$px" "$px" "${assets}/AppIcon-1024.png" --out "${iconset}/${name}.png" >/dev/null
done

iconutil -c icns -o "${assets}/AppIcon.icns" "$iconset"
rm -rf "$iconset"

swiftc -O -sdk "$sdk" -framework AppKit \
  -o /tmp/dontsleep-render-menubar \
  "${root}/scripts/render-menubar.swift"
/tmp/dontsleep-render-menubar "$assets"

mkdir -p "${root}/docs/assets"
swiftc -O -sdk "$sdk" -framework AppKit \
  -o /tmp/dontsleep-render-readme-icon \
  "${root}/scripts/render-readme-icon.swift"
/tmp/dontsleep-render-readme-icon \
  "${assets}/AppIcon-1024.png" \
  "${root}/docs/assets/app-icon-rounded.png"

echo "Icons in ${assets} and docs/assets/app-icon-rounded.png"
