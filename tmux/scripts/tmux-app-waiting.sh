#!/usr/bin/env bash
# Generic tmux window-level "app waiting for input" indicator.
# Usage: tmux-app-waiting.sh set|clear
#
# Sets/clears the @app_waiting user variable on the current tmux window.
# The tmux window-status-format uses this variable to change text color.
# Tracks the pane that set the flag via @app_waiting_pane to avoid
# multi-pane conflicts (another pane's precmd clearing this pane's flag).

[ -n "$TMUX" ] || exit 0

case "${1:-}" in
  set)
    tmux set-option -w @app_waiting 1 2>/dev/null
    tmux set-option -w @app_waiting_pane "${TMUX_PANE:-}" 2>/dev/null
    ;;
  clear)
    tmux set-option -wu @app_waiting 2>/dev/null
    tmux set-option -wu @app_waiting_pane 2>/dev/null
    ;;
  *)
    echo "Usage: $0 set|clear" >&2; exit 1
    ;;
esac
