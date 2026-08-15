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
/bin/ln -s /Applications "${payload}/Applications"
/bin/cp "${root}/scripts/install-sudoers.sh" "${payload}/Install Sudoers.command"
/bin/chmod +x "${payload}/Install Sudoers.command"

cat > "${payload}/Install.txt" <<'TXT'
DontSleep

1. Drag DontSleep.app onto Applications.
2. Double-click Install Sudoers.command.
   This writes /etc/sudoers.d/dontsleep so two exact pmset
   invocations can run without a password. You will be asked
   for an administrator password once.
3. Open DontSleep.app. A laptop icon appears in the menu bar.
   Left-click toggles. Right-click (or Control-click) opens the menu.

Gatekeeper may block the first launch. Control-click the app and choose Open.

The Mac stays awake with the lid closed while DontSleep is on. Watch the battery.
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
