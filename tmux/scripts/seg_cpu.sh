#!/usr/bin/env bash
# Print total CPU usage as a percentage (plain text).

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPTS_DIR/common.sh" || exit 1

icon="$(tmux_icon cpu) "

if shell_is_linux; then
	cpu_idle=$(top -b -n 1 | grep 'Cpu(s)' | grep -o "[0-9]\+\(\.[0-9]\+\)\? *id\(le\)?" | awk '{ print $1 }')
elif shell_is_macos; then
	cpu_idle=$(top -l 1 -n 0 | grep 'CPU usage:' | sed 's/CPU usage: //' | awk '{print $5}' | sed 's/%//')
else
	exit 1
fi

[ -n "${cpu_idle:-}" ] || exit 1

usage=$(awk -v idle="$cpu_idle" 'BEGIN {u = 100 - idle; if(u < 0) u = 0; if(u > 100) u = 100; printf "%.0f", u}')
[ -n "$usage" ] || exit 1

echo "${icon}${usage}%"
