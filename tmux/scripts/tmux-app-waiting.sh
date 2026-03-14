#!/usr/bin/env bash
# Generic tmux window-level "app waiting for input" indicator.
# Usage: tmux-app-waiting.sh set|clear
#
# Sets/clears the @app_waiting user variable on the correct tmux window.
# Uses $TMUX_PANE to resolve the window, so the flag is set on the right
# window even when the user is viewing a different session/window.
# Tracks the pane that set the flag via @app_waiting_pane to avoid
# multi-pane conflicts (another pane's precmd clearing this pane's flag).

[ -n "$TMUX" ] || exit 0

# Resolve the window containing this pane (works even when viewing another session)
pane="${TMUX_PANE:-}"
[ -n "$pane" ] || exit 0
window=$(tmux display-message -t "$pane" -p '#{window_id}' 2>/dev/null) || exit 0

case "${1:-}" in
  set)
    tmux set-option -wt "$window" @app_waiting 1 2>/dev/null
    tmux set-option -wt "$window" @app_waiting_pane "$pane" 2>/dev/null
    ;;
  clear)
    tmux set-option -wut "$window" @app_waiting 2>/dev/null
    tmux set-option -wut "$window" @app_waiting_pane 2>/dev/null
    ;;
  *)
    echo "Usage: $0 set|clear" >&2; exit 1
    ;;
esac
