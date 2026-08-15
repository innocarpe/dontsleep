#!/bin/zsh
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
version="$(/usr/bin/defaults read "${root}/Info.plist" CFBundleShortVersionString)"
stage="${root}/dist/DontSleep.app"
work="$(/usr/bin/mktemp -d /tmp/dontsleep-dmg.XXXXXX)"
payload="${work}/DontSleep"
out="${1:-${root}/DontSleep-${version}.dmg}"

"${root}/scripts/build-app.sh" "$stage"

mkdir -p "$payload"
/usr/bin/ditto "$stage" "${payload}/DontSleep.app"
cat > "${payload}/Install.txt" <<'TXT'
DontSleep

Do not open this image and double-click the app. On Tahoe that only
offers Move to Trash. Gatekeeper checks the app you launch.

In Terminal:

  curl -fsSL https://raw.githubusercontent.com/innocarpe/dontsleep/main/install.sh | zsh

That copies the app, clears quarantine on that copy, asks for your
password once (two pmset lines, your account only), and opens DontSleep.

If this disk image is already on disk:

  curl -fsSL https://raw.githubusercontent.com/innocarpe/dontsleep/main/install.sh | zsh -s -- ~/Downloads/DontSleep-*.dmg

While DontSleep is on, a closed lid will not sleep the Mac. Watch the battery.
TXT

/bin/rm -f "$out"
/usr/bin/hdiutil create \
  -volname "DontSleep ${version}" \
  -srcfolder "$payload" \
  -ov -format UDZO \
  "$out" >/dev/null

/bin/rm -rf "$work" "$stage"
print "Wrote ${out}"
/bin/ls -lh "$out"
