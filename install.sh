#!/bin/zsh
# Put DontSleep in Applications, clear Gatekeeper quarantine on that
# copy, and open it. The first-launch window writes sudoers.
#
#   curl -fsSL https://raw.githubusercontent.com/innocarpe/dontsleep/main/install.sh | zsh
#   zsh install.sh /path/to/DontSleep-*.dmg
#   zsh install.sh /path/to/DontSleep.app
set -euo pipefail

dest="/Applications/DontSleep.app"
repo="innocarpe/dontsleep"
work=""
mnt=""
app=""

cleanup() {
  if [[ -n "$mnt" ]]; then
    /usr/bin/hdiutil detach "$mnt" -quiet >/dev/null 2>&1 || true
  fi
  if [[ -n "$work" ]]; then
    /bin/rm -rf "$work"
  fi
}
trap cleanup EXIT

die() {
  print -u2 "dontsleep: $*"
  exit 1
}

if [[ "$(/usr/bin/uname -m)" != "arm64" ]]; then
  die "this build is Apple silicon only."
fi

usage() {
  cat <<'EOF'
Install DontSleep into /Applications and open it.

  curl -fsSL https://raw.githubusercontent.com/innocarpe/dontsleep/main/install.sh | zsh
  zsh install.sh [DontSleep.dmg|DontSleep.app]

The app window then writes /etc/sudoers.d/dontsleep. Press Enter
there; macOS asks for your password once. That allows only:

  pmset -a disablesleep 1
  pmset -a disablesleep 0

for your account. It does not unlock all of sudo.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

work="$(/usr/bin/mktemp -d /tmp/dontsleep-install.XXXXXX)"

fetch_latest_dmg() {
  local api url
  api="${work}/release.json"
  /usr/bin/curl -fsSL -A "dontsleep-install" \
    "https://api.github.com/repos/${repo}/releases/latest" >"$api" \
    || die "could not read https://github.com/${repo}/releases"
  url="$(/usr/bin/grep -oE 'https://github.com/[^"]+/DontSleep-[^"]+\.dmg' "$api" | /usr/bin/head -n1)"
  [[ -n "$url" ]] || die "latest release has no disk image."
  print -u2 "Downloading ${url:t}…"
  /usr/bin/curl -fL --progress-bar -A "dontsleep-install" -o "${work}/DontSleep.dmg" "$url" \
    || die "download failed."
  print -- "${work}/DontSleep.dmg"
}

mount_dmg() {
  local dmg="$1"
  mnt="${work}/volume"
  /bin/mkdir -p "$mnt"
  /usr/bin/xattr -dr com.apple.quarantine "$dmg" >/dev/null 2>&1 || true
  /usr/bin/hdiutil attach -nobrowse -readonly -mountpoint "$mnt" "$dmg" >/dev/null \
    || die "could not mount ${dmg}."
  [[ -d "${mnt}/DontSleep.app" ]] || die "DontSleep.app is not in ${dmg}."
  app="${mnt}/DontSleep.app"
}

resolve_source() {
  local src
  if [[ $# -eq 0 ]]; then
    mount_dmg "$(fetch_latest_dmg)"
    return
  fi
  src="${1:A}"
  if [[ -d "$src" && "$src" == *.app ]]; then
    app="$src"
    return
  fi
  if [[ -f "$src" && "$src" == *.dmg ]]; then
    mount_dmg "$src"
    return
  fi
  die "expected a DontSleep.dmg or DontSleep.app, got ${1}."
}

copy_app() {
  /usr/bin/killall DontSleep >/dev/null 2>&1 || true
  if /bin/rm -rf "$dest" && /usr/bin/ditto "$app" "$dest" && /usr/bin/touch "$dest"; then
    return 0
  fi
  /usr/bin/osascript -e \
    "do shell script \"/bin/rm -rf \" & quoted form of \"$dest\" & \" && /usr/bin/ditto \" & quoted form of \"$app\" & \" \" & quoted form of \"$dest\" & \" && /usr/bin/touch \" & quoted form of \"$dest\" with administrator privileges" \
    || die "could not copy the app to Applications."
}

resolve_source "$@"
copy_app
/usr/bin/xattr -dr com.apple.quarantine "$dest" >/dev/null 2>&1 || true
/usr/bin/open "$dest"

print "DontSleep is in Applications and in the menu bar."
print "Finish setup in the window: press Enter, then the Mac password once."
print "Remove helper later: sudo rm /etc/sudoers.d/dontsleep"
