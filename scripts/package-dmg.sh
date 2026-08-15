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
cat > "${payload}/Install.txt" <<'TXT'
DontSleep

1. Drag DontSleep.app onto the Applications folder.
2. Gatekeeper checks that copy, not this disk image. In Terminal:

     xattr -dr com.apple.quarantine /Applications/DontSleep.app
     open /Applications/DontSleep.app

3. If the disk image itself will not open:

     xattr -dr com.apple.quarantine ~/Downloads/DontSleep-*.dmg
     open ~/Downloads/DontSleep-*.dmg

   Then do steps 1 and 2.

4. First launch asks for your Mac password once. That allows two
   pmset commands without a password, for your account only.

This build is not notarized. On Tahoe the only dialog is Move to Trash.
Double-click and Control-click both fail until you clear quarantine
on the app in Applications.

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
