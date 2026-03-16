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

# If the personal session already exists, just attach
if tmux -L personal has-session -t personal 2>/dev/null; then
  exec tmux -L personal attach-session -t personal
fi

# Create a new session and attach
tmux -L personal -f "$CONF" new-session -d -s personal
if [ $? -ne 0 ]; then
  echo 'ERROR: Failed to create tmux session'
  exec zsh
fi

# Restore is handled by continuum_force_autorestore.sh in tmux.conf
exec tmux -L personal attach-session -t personal
