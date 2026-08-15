#!/bin/zsh
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
me="$(/usr/bin/id -un)"
writer="${root}/scripts/write-sudoers.sh"

/usr/bin/osascript <<EOF
do shell script (quoted form of "$writer") & " " & (quoted form of "$me") with administrator privileges
EOF

print "sudoers OK. Reopen DontSleep, then toggle it from the menu bar."
