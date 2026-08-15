#!/bin/zsh
set -euo pipefail

# Run as root. $1 is the login user who may call the two pmset lines.
user="${1:?user}"
rule="${user} ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 1, /usr/bin/pmset -a disablesleep 0"
tmp="$(/usr/bin/mktemp /tmp/dontsleep-sudoers.XXXXXX)"
printf '%s\n' "$rule" > "$tmp"
/usr/sbin/visudo -cf "$tmp"
/usr/bin/install -m 0440 -o root -g wheel "$tmp" /etc/sudoers.d/dontsleep
/usr/sbin/visudo -cf /etc/sudoers.d/dontsleep
/bin/rm -f "$tmp"
