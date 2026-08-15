#!/bin/zsh
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
version="$(/usr/bin/defaults read "${root}/Info.plist" CFBundleShortVersionString)"
stage="${root}/dist/DontSleep.app"
work="$(/usr/bin/mktemp -d /tmp/dontsleep-dmg.XXXXXX)"
payload="${work}/DontSleep"
pkgroot="${work}/pkgroot"
pkgscripts="${work}/pkgscripts"
pkg="${work}/Install DontSleep.pkg"
out="${1:-${root}/DontSleep-${version}.dmg}"

"${root}/scripts/build-app.sh" "$stage"

mkdir -p "${pkgroot}/Applications"
/usr/bin/ditto "$stage" "${pkgroot}/Applications/DontSleep.app"

mkdir -p "$pkgscripts"
/bin/cp "${root}/scripts/pkg/postinstall" "${pkgscripts}/postinstall"
/bin/chmod 755 "${pkgscripts}/postinstall"

/usr/bin/pkgbuild \
  --identifier com.innocarpe.dontsleep \
  --version "$version" \
  --root "$pkgroot" \
  --install-location / \
  --scripts "$pkgscripts" \
  "$pkg" >/dev/null

mkdir -p "$payload"
/bin/cp "$pkg" "${payload}/Install DontSleep.pkg"
cat > "${payload}/Install.txt" <<'TXT'
DontSleep

1. Double-click Install DontSleep.pkg.
2. Enter your Mac password when the installer asks.
   That copies the app to Applications, allows two pmset
   commands without a password, and starts DontSleep at login.
3. If macOS says the developer cannot be verified:
   Control-click the package → Open → Open.
   Or System Settings → Privacy & Security → Open Anyway.

This build is not notarized. That warning is expected.

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
