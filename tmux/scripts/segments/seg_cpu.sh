#!/usr/bin/env bash
# Print total CPU usage as a percentage (plain text).

# shellcheck disable=SC1091
shell_is_macos() { [ "$(uname)" = "Darwin" ]; }
shell_is_linux() { [ "$(uname)" = "Linux" ]; }
tmux_icon() { case "$1" in cpu) echo "CPU" ;; esac; }
seg_log() { :; }
source "$(dirname "$0")/../common.sh" 2>/dev/null

icon="$(tmux_icon cpu) "

if shell_is_linux; then
	# /proc/stat gives cumulative CPU ticks; sample twice 0.5s apart for accuracy
	read_cpu_ticks() { awk '/^cpu / {print $2+$3+$4+$5+$6+$7+$8, $5}' /proc/stat; }
	read -r total1 idle1 <<< "$(read_cpu_ticks)"
	sleep 0.5
	read -r total2 idle2 <<< "$(read_cpu_ticks)"
	dt=$((total2 - total1))
	di=$((idle2 - idle1))
	if [ "$dt" -gt 0 ]; then
		cpu_idle=$(awk -v di="$di" -v dt="$dt" 'BEGIN { printf "%.1f", 100 * di / dt }')
	fi
elif shell_is_macos; then
	cpu_idle=$(top -l 1 -n 0 | grep 'CPU usage:' | sed 's/CPU usage: //' | awk '{print $5}' | sed 's/%//')
else
	exit 1
fi

[ -n "${cpu_idle:-}" ] || exit 1

usage=$(awk -v idle="$cpu_idle" 'BEGIN {u = 100 - idle; if(u < 0) u = 0; if(u > 100) u = 100; printf "%.0f", u}')
[ -n "$usage" ] || exit 1

echo "${icon}${usage}%"
