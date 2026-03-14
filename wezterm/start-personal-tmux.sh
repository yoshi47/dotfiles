#!/bin/zsh
# Start or attach to the personal tmux session (separate socket: -L personal)

if ! command -v tmux >/dev/null 2>&1; then
  echo 'ERROR: tmux not found. Install it with: brew install tmux'
  exec zsh
fi

CONF=~/.config/tmux/tmux.personal.conf
if [ ! -f "$CONF" ]; then
  echo "ERROR: $CONF not found"
  exec zsh
fi

if tmux -L personal list-sessions 2>/dev/null; then
  exec tmux -L personal attach-session -t personal
fi

tmux -L personal -f "$CONF" new-session -d -s personal
if [ $? -ne 0 ]; then
  echo 'ERROR: Failed to create tmux session'
  exec zsh
fi

# Restore is handled by continuum_force_autorestore.sh in tmux.conf
exec tmux -L personal attach-session -t personal
