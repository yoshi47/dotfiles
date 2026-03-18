#!/usr/bin/env bash
# Generic tmux window-level app flag indicator.
# Usage: tmux-app-flag.sh <flag_name> set|clear
#
# Sets/clears the @app_<flag_name> user variable on the correct tmux window.
# Uses $TMUX_PANE to resolve the window, so the flag is set on the right
# window even when the user is viewing a different session/window.
# Tracks the pane that set the flag via @app_<flag_name>_pane to avoid
# multi-pane conflicts.

[ -n "$TMUX" ] || exit 0

flag="${1:-}"
action="${2:-}"

if [ -z "$flag" ] || [ -z "$action" ]; then
  echo "Usage: $0 <flag_name> set|clear" >&2
  exit 1
fi

var="@app_${flag}"
var_pane="@app_${flag}_pane"

# Resolve the window containing this pane (works even when viewing another session)
pane="${TMUX_PANE:-}"
[ -n "$pane" ] || exit 0
window=$(tmux display-message -t "$pane" -p '#{window_id}' 2>/dev/null) || exit 0

case "$action" in
  set)
    tmux set-option -wt "$window" "$var" 1 2>/dev/null
    tmux set-option -wt "$window" "$var_pane" "$pane" 2>/dev/null
    tmux refresh-client -S 2>/dev/null
    ;;
  clear)
    owner=$(tmux show-option -wqvt "$window" "$var_pane" 2>/dev/null)
    if [ -z "$owner" ] || [ "$owner" = "$pane" ]; then
      tmux set-option -wut "$window" "$var" 2>/dev/null
      tmux set-option -wut "$window" "$var_pane" 2>/dev/null
      tmux refresh-client -S 2>/dev/null
    fi
    ;;
  *)
    echo "Usage: $0 <flag_name> set|clear" >&2; exit 1
    ;;
esac
