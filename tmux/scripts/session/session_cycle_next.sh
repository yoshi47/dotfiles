#!/bin/sh
set -e

current="$(tmux display-message -p -F '#S')"

ordered="$(tmux list-sessions -F '#{session_id}	#{session_name}' \
  | awk -F '\t' '{id=$1; sub(/^\$/,"",id); print id "\t" $2}' \
  | sort -n)"

if [ -z "$ordered" ]; then
  tmux display-message -d 3000 "No sessions found"
  exit 0
fi

next="$(printf '%s\n' "$ordered" | awk -F '\t' -v cur="$current" '
  { names[NR]=$2; if ($2==cur) idx=NR }
  END { if (NR<=1) exit 0; if (idx==0) idx=1; nxt=(idx%NR)+1; print names[nxt] }
')"

if [ -n "$next" ] && [ "$next" != "$current" ]; then
  tmux switch-client -t "$next"
  # tmux refresh-client -S
fi
