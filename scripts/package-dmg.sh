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
   That is scripts/install-sudoers.sh. It does not install the app.
   It writes /etc/sudoers.d/dontsleep so only these two commands
   can run without a password:

     pmset -a disablesleep 1
     pmset -a disablesleep 0

   You will be asked for an administrator password once.
3. Open DontSleep.app. Left-click toggles. Right-click opens the menu.

The build is not notarized. If macOS blocks the app or the .command file:
Control-click → Open → Open.
Or System Settings → Privacy & Security → Open Anyway.
xattr -d com.apple.quarantine is optional, not the default path.

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
