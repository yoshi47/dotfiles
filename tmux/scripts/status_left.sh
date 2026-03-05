#!/usr/bin/env bash
# Compose left status: session_icon + session_list.
# Both segments output their own tmux format strings (colors + separators).

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"

_seg_log=/tmp/tmux-segments.log
[ -f "$_seg_log" ] && [ "$(wc -c < "$_seg_log")" -gt 102400 ] && : > "$_seg_log"

echo -n "$("$SCRIPTS_DIR/seg_session_icon.sh" 2>>"$_seg_log")$("$SCRIPTS_DIR/seg_session_list.sh" 2>>"$_seg_log")"
