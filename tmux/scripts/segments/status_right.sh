#!/usr/bin/env bash
# Compose right status: cpu | mem | battery with accent-colored thin separators.

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
SEP_RIGHT_BOLD="" SEP_RIGHT_THIN="" SEP_LEFT_BOLD="" SEP_LEFT_THIN=""
source "$(dirname "$0")/../common.sh" 2>/dev/null

_seg_log=/tmp/tmux-segments.log
# Truncate log if over 100KB to prevent unbounded growth
[ -f "$_seg_log" ] && [ "$(wc -c < "$_seg_log")" -gt 102400 ] && : > "$_seg_log"

# Segments: script|accent_color
SEGS=(
	"seg_cpu.sh|${THEME_GREEN}"
	"seg_mem.sh|${THEME_CYAN}"
	"seg_battery.sh|${THEME_PINK}"
	"seg_weather.sh|${THEME_ORANGE}"
	"seg_hostname.sh|${THEME_PURPLE}"
)

output=""
first=true

for entry in "${SEGS[@]}"; do
	script="${entry%%|*}"
	color="${entry#*|}"

	text=$("$SCRIPTS_DIR/$script" 2>>"$_seg_log")
	[ -z "$text" ] && continue

	if [ "$first" = true ]; then
		first=false
	else
		output+=" #[fg=${color}]${SEP_LEFT_THIN}#[default] "
	fi

	output+="#[fg=${color}]${text}#[default]"
done

echo -n "$output "
