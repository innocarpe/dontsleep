#!/bin/zsh
set -euo pipefail

root="$(cd "$(dirname "$0")" && pwd)"
stage="${root}/dist/DontSleep.app"
dest="/Applications/DontSleep.app"

"${root}/scripts/build-app.sh" "$stage"

install_app() {
  # Replace the bundle inode. ditto-into-existing keeps the old folder
  # mtime, and Alfred/iconservices keep serving the first icon they cached.
  /bin/rm -rf "$dest"
  if /usr/bin/ditto "$stage" "$dest" 2>/dev/null; then
    /usr/bin/touch "$dest"
    return 0
  fi
  osascript <<EOF
do shell script "/bin/rm -rf " & quoted form of "$dest" & " && /usr/bin/ditto " & quoted form of "$stage" & " " & quoted form of "$dest" & " && /usr/bin/touch " & quoted form of "$dest" with administrator privileges
EOF
}

install_app

LSREG="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
"$LSREG" -u "$stage" >/dev/null 2>&1 || true
rm -rf "$stage"
"$LSREG" -f "$dest" >/dev/null 2>&1 || true

echo "Installed ${dest}"
