#!/usr/bin/env bash
# Shared helpers for tmux status scripts.
# Sources the palette and provides separator constants + platform detection.

# shellcheck disable=SC1091
if ! source "$HOME/.config/tmux/palettes/palette.sh" 2>/dev/null; then
	echo "[common.sh] ERROR: palette.sh not found" >&2
	return 1 2>/dev/null || exit 1
fi

seg_log() {
	local level="$1" msg="$2"
	# info はデバッグモード時のみ出力
	[ "$level" = "info" ] && [ -z "$TMUX_SEG_DEBUG" ] && return
	local script
	script="$(basename "${BASH_SOURCE[1]:-$0}" .sh)"
	echo "[$(date +%Y-%m-%dT%H:%M:%S) ${script}] ${level}: ${msg}" >&2
}

if [ -z "$THEME_TEXT" ]; then
	seg_log warn "palette not loaded (THEME_TEXT empty)"
	return 1 2>/dev/null || exit 1
fi

# Powerline separators (patched font assumed)
# U+E0B0, U+E0B1, U+E0B2, U+E0B3
SEP_RIGHT_BOLD=""
SEP_RIGHT_THIN=""
SEP_LEFT_BOLD=""
SEP_LEFT_THIN=""

shell_is_macos() { [ "$(uname)" = "Darwin" ]; }
shell_is_linux() { [ "$(uname)" = "Linux" ]; }

tmux_icon() {
	local key="$1"

	case "$key" in
		session) echo "" ;; #           

		cpu) echo "󰍛" ;;

		mem) echo "󰘚" ;;

		battery_full) echo "󱊣" ;;
		battery_med) echo "󱊢" ;;
		battery_empty) echo "󰂎" ;;
		battery_charge) echo "󰂄" ;;
		adapter) echo "󰚥" ;;

		weather_clear) echo "󰖙" ;;
		weather_cloud) echo "󰖐" ;;
		weather_rain) echo "" ;;
		weather_snow) echo "󰜗" ;;
		weather_thunder) echo "󱐋" ;;
		weather_fog) echo "󰖑" ;;
		weather_unknown) echo "󰖔" ;;
		*) echo "󰖔" ;;
	esac
}
