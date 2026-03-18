#!/usr/bin/env bash
# Display session icon with powerline-style background.
# Output: raw tmux format string (colors + separator).

# shellcheck disable=SC1091
tmux_icon() { case "$1" in session) echo "#" ;; esac; }
SEP_RIGHT_BOLD="" SEP_RIGHT_THIN="" SEP_LEFT_BOLD="" SEP_LEFT_THIN=""
source "$(dirname "$0")/../common.sh" 2>/dev/null

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
