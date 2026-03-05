#!/usr/bin/env bash
# Preview material icons used by tmux segments.

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPTS_DIR/common.sh" || exit 1

printf '[material]\n'
printf ' session: %s\n' "$(tmux_icon session)"
printf ' cpu:     %s 42%%\n' "$(tmux_icon cpu)"
printf ' mem:     %s 12.3 GB\n' "$(tmux_icon mem)"
printf ' battery: %s 90%% | %s 55%% | %s 15%% | %s charging | %s adapter\n' \
	"$(tmux_icon battery_full)" \
	"$(tmux_icon battery_med)" \
	"$(tmux_icon battery_empty)" \
	"$(tmux_icon battery_charge)" \
	"$(tmux_icon adapter)"
printf ' weather: %s clear | %s cloud | %s rain | %s snow | %s thunder | %s fog | %s unknown\n' \
	"$(tmux_icon weather_clear)" \
	"$(tmux_icon weather_cloud)" \
	"$(tmux_icon weather_rain)" \
	"$(tmux_icon weather_snow)" \
	"$(tmux_icon weather_thunder)" \
	"$(tmux_icon weather_fog)" \
	"$(tmux_icon weather_unknown)"
