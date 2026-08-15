#!/bin/zsh
set -euo pipefail

# Writes /etc/sudoers.d/dontsleep so DontSleep can toggle
# `pmset -a disablesleep` without a password prompt.
# Scope is only those two argv lists — not all of sudo.

me="$(/usr/bin/id -un)"
rule="${me} ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 1, /usr/bin/pmset -a disablesleep 0"
tmp="$(/usr/bin/mktemp /tmp/dontsleep-sudoers.XXXXXX)"
printf '%s\n' "$rule" > "$tmp"
/usr/sbin/visudo -cf "$tmp"

/usr/bin/osascript <<EOF
do shell script "install -m 0440 -o root -g wheel " & quoted form of "$tmp" & " /etc/sudoers.d/dontsleep && /usr/sbin/visudo -cf /etc/sudoers.d/dontsleep" with administrator privileges
EOF

/bin/rm -f "$tmp"

if /usr/bin/sudo -n /usr/bin/pmset -a disablesleep 0 && /usr/bin/sudo -n /usr/bin/pmset -a disablesleep 1; then
  print "sudoers OK. Reopen DontSleep, then toggle it from the menu bar."
else
  print "The file was written, but sudo -n pmset failed. Check sudo -l." >&2
  exit 1
fi
