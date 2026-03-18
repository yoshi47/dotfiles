#!/usr/bin/env bash
# Force continuum auto-restore even when another tmux server is running.
# continuum_restore.sh skips restore when another server is detected,
# but we want independent restore per socket (personal vs default).

RESTORE_SCRIPT="$HOME/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh"

if [ ! -f "$RESTORE_SCRIPT" ]; then
  exit 0
fi

# Skip if continuum already restored (prevents double restore)
already_restored="$(tmux show-option -gqv @resurrect-restore-completed 2>/dev/null)"
if [ "$already_restored" = "1" ]; then
  exit 0
fi

# Only restore on first startup (single session, single window)
session_count="$(tmux list-sessions 2>/dev/null | wc -l | tr -d ' ')"
if [ "$session_count" -gt 1 ]; then
  exit 0
fi

window_count="$(tmux list-windows 2>/dev/null | wc -l | tr -d ' ')"
if [ "$window_count" -gt 1 ]; then
  exit 0
fi

# Check if continuum auto-restore is enabled
auto_restore="$(tmux show-option -gqv @continuum-restore 2>/dev/null)"
if [ "$auto_restore" != "on" ]; then
  exit 0
fi

# Check if resurrect has a saved session
resurrect_dir="$(tmux show-option -gqv @resurrect-dir 2>/dev/null)"
resurrect_dir="${resurrect_dir/#\~/$HOME}"
if [ ! -f "$resurrect_dir/last" ]; then
  exit 0
fi

# Give tmux time to finish initialization (same as continuum)
sleep 1

"$RESTORE_SCRIPT"
