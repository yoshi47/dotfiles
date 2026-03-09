#!/usr/bin/env bash
# Set @claude_stale flag on Claude Code panes (identified by @running_cmd containing "claude")
for srv in default personal; do
  for pane in $(tmux -L "$srv" list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null); do
    cmd=$(tmux -L "$srv" show-option -pt "$pane" @running_cmd 2>/dev/null | awk '{print $2}')
    if [[ "$cmd" == *claude* ]]; then
      tmux -L "$srv" set -pt "$pane" @claude_stale 1
    fi
  done
done
