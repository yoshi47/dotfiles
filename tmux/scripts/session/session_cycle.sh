#!/bin/sh
# Cycle tmux sessions in creation-order.
# Usage: session_cycle.sh next|prev
set -e

direction="${1:-next}"

current="$(tmux display-message -p -F '#S')"

ordered="$(tmux list-sessions -F '#{session_id}	#{session_name}' \
  | awk -F '\t' '{id=$1; sub(/^\$/,"",id); print id "\t" $2}' \
  | sort -n)"

if [ -z "$ordered" ]; then
  tmux display-message -d 3000 "No sessions found"
  exit 0
fi

target="$(printf '%s\n' "$ordered" | awk -F '\t' -v cur="$current" -v dir="$direction" '
  { names[NR]=$2; if ($2==cur) idx=NR }
  END {
    if (NR<=1) exit 0
    if (idx==0) idx=1
    if (dir=="prev") { nxt=idx-1; if (nxt<1) nxt=NR }
    else             { nxt=(idx%NR)+1 }
    print names[nxt]
  }
')"

if [ -n "$target" ] && [ "$target" != "$current" ]; then
  tmux switch-client -t "$target"
fi
