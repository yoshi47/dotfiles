#!/usr/bin/env bash
# Force continuum auto-save interpolation into status-right.
# continuum skips auto-save when another tmux server is running.
# This script bypasses that check for multi-socket setups.

SAVE_SCRIPT="$HOME/.config/tmux/plugins/tmux-continuum/scripts/continuum_save.sh"

if [ ! -f "$SAVE_SCRIPT" ]; then
  exit 0
fi

status_right="$(tmux show-options -gv status-right 2>/dev/null)"

# Check if already present
if echo "$status_right" | grep -q "continuum_save"; then
  exit 0
fi

# Prepend the save interpolation
save_interp="#(${SAVE_SCRIPT})"
tmux set -g status-right "${save_interp}${status_right}"
