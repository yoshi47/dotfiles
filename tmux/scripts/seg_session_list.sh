#!/usr/bin/env bash
# Display tmux session list (window-list style) with clickable ranges.
# Output: raw tmux format string.

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPTS_DIR/common.sh" || exit 1

current_session=$(tmux display-message -p '#S')

if ! sessions=$(tmux list-sessions -F '#{session_name}|#{session_id}|#{?session_alerts,1,}' 2>/dev/null); then
	sessions=$(tmux list-sessions -F '#{session_name}|#{session_id}|' 2>/dev/null) || exit 0
fi
[ -z "$sessions" ] && exit 0

base_bg="${THEME_SURFACE}"
base_fg="${THEME_TEXT}"
active_bg="${THEME_OVERLAY}"

fmt_regular="#[fg=${base_fg},bg=${base_bg},nobold,noitalics,nounderscore]"
fmt_inverse="#[fg=${base_fg},bg=${active_bg},nobold,noitalics,nounderscore]"

bell_icon="󰂚"
bell_alert_fg="${THEME_YELLOW}"

# Sort by numeric session id to match choose-tree order
sessions_sorted="$(
	while IFS='|' read -r session_name session_id session_has_alert; do
		[ -z "$session_name" ] && continue
		[ -z "$session_id" ] && continue
		session_index="${session_id#\$}"
		case "$session_index" in
		''|*[!0-9]*) session_index=99999 ;;
		esac
		printf '%s|%s|%s|%s\n' "$session_index" "$session_name" "$session_id" "$session_has_alert"
	done <<<"$sessions" | sort -t'|' -k1,1n
)"

output=""

while IFS='|' read -r _session_index session_name session_id session_has_alert; do
	[ -z "$session_name" ] && continue
	[ -z "$session_id" ] && continue

	bell_prefix=""
	if [ -n "$session_has_alert" ]; then
		bell_prefix="#[fg=${bell_alert_fg}]${bell_icon}#[fg=${base_fg}] "
	fi

	# Check if any window in this session has @app_alert or @app_waiting set
	# Priority: alert (yellow) > waiting (green) > normal
	name_fg="${base_fg}"
	local_flags=$(tmux list-windows -t "$session_name" -F '#{@app_alert}|#{@app_waiting}' 2>/dev/null)
	if echo "$local_flags" | grep -q '^1|'; then
		name_fg="${THEME_YELLOW}"
	elif echo "$local_flags" | grep -q '|1$'; then
		name_fg="${THEME_GREEN}"
	fi

	if [ "$session_name" = "$current_session" ]; then
		output+="#[fg=${base_bg},bg=${active_bg}]${SEP_RIGHT_BOLD}"
		output+="${fmt_inverse}#[range=session|${session_id}]${bell_prefix}#[fg=${name_fg}]${session_name}#[fg=${base_fg}]#[norange]"
		output+="#[fg=${active_bg},bg=${base_bg}]${SEP_RIGHT_BOLD}"
		output+="${fmt_regular}"
	else
		output+="#[fg=${base_bg},bg=${base_bg}]${SEP_RIGHT_BOLD}"
		output+="${fmt_regular}#[range=session|${session_id}]${bell_prefix}#[fg=${name_fg}]${session_name}#[fg=${base_fg}]#[norange]"
		output+="#[fg=${base_bg},bg=${base_bg}]${SEP_RIGHT_BOLD}"
		output+="${fmt_regular}"
	fi
done <<<"$sessions_sorted"

echo -n "$output"
