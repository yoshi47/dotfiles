#!/usr/bin/env bash
# Display session icon with powerline-style background.
# Output: raw tmux format string (colors + separator).

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPTS_DIR/common.sh" || exit 1

prefix_pressed=$(tmux display-message -p '#{client_prefix}' 2>/dev/null || true)
icon=$(tmux_icon session)

next_bg="${THEME_SURFACE}"

if [ "$prefix_pressed" = "1" ]; then
	bg="${THEME_YELLOW}"
	fg="${THEME_BASE}"
	echo -n "#[fg=${fg},bg=${bg},bold] ${icon} #[nobold]"
else
	bg="${THEME_GREEN}"
	fg="${THEME_BASE}"
	echo -n "#[fg=${fg},bg=${bg}] ${icon} "
fi

echo -n "#[fg=${bg},bg=${next_bg}]${SEP_RIGHT_BOLD}#[default]"
