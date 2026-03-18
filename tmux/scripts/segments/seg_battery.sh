#!/usr/bin/env bash
# Print battery status as percentage (plain text).

# shellcheck disable=SC1091
shell_is_macos() { [ "$(uname)" = "Darwin" ]; }
shell_is_linux() { [ "$(uname)" = "Linux" ]; }
tmux_icon() {
	case "$1" in battery_full|battery_med|battery_empty) echo "BAT" ;;
		battery_charge) echo "CHG" ;; adapter) echo "AC" ;; esac
}
seg_log() { :; }
source "$(dirname "$0")/../common.sh" 2>/dev/null

BATTERY_FULL="$(tmux_icon battery_full)"
BATTERY_MED="$(tmux_icon battery_med)"
BATTERY_EMPTY="$(tmux_icon battery_empty)"
BATTERY_CHARGE="$(tmux_icon battery_charge)"
ADAPTER="$(tmux_icon adapter)"

__battery_macos() {
	local batt_info
	batt_info=$(pmset -g batt) || return 1

	local charge
	charge=$(echo "$batt_info" | grep -o '[0-9][0-9]*%' | tr -d '%')
	[ -z "$charge" ] && return 1

	if echo "$batt_info" | grep -q "'AC Power'"; then
		echo "$BATTERY_CHARGE $charge"
	elif [ "$charge" -lt 50 ]; then
		echo "$BATTERY_EMPTY $charge"
	elif [ "$charge" -lt 80 ]; then
		echo "$BATTERY_MED $charge"
	else
		echo "$BATTERY_FULL $charge"
	fi
}

__battery_linux() {
	local total_full=0 total_now=0
	while read -r bat; do
		local full="$bat/charge_full" now="$bat/charge_now"
		[ ! -r "$full" ] && full="$bat/energy_full"
		[ ! -r "$now" ] && now="$bat/energy_now"
		if [ -r "$full" ] && [ -r "$now" ]; then
			total_full=$((total_full + $(cat "$full")))
			total_now=$((total_now + $(cat "$now")))
		fi
	done <<<"$(grep -l "Battery" /sys/class/power_supply/*/type 2>/dev/null | sed -e 's,/type$,,')"
	if [ "$total_full" -gt 0 ]; then
		[ "$total_now" -gt "$total_full" ] && total_now=$total_full
		local charge=$((100 * total_now / total_full))
		# 充電状態の検出
		local charging=false
		for status_file in /sys/class/power_supply/*/status; do
			[ -r "$status_file" ] && grep -qi 'charging\|full' "$status_file" && charging=true && break
		done
		if $charging; then
			echo "$BATTERY_CHARGE $charge"
		elif [ "$charge" -lt 50 ]; then
			echo "$BATTERY_EMPTY $charge"
		elif [ "$charge" -lt 80 ]; then
			echo "$BATTERY_MED $charge"
		else
			echo "$BATTERY_FULL $charge"
		fi
	fi
}

if shell_is_macos; then
	battery_status=$(__battery_macos)
else
	battery_status=$(__battery_linux)
fi

if [ -z "$battery_status" ]; then
	# No battery detected (e.g. VM or desktop) — show nothing
	exit 0
else
	echo "${battery_status}%"
fi
