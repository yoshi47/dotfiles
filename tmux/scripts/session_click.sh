#!/bin/bash
# Switch to session based on mouse click position on status line

# Get mouse click X position
mouse_x="$1"

if [ -z "$mouse_x" ]; then
  exit 0
fi

# Get current session
current_session=$(tmux display-message -p '#S')

# Get all sessions
sessions=$(tmux list-sessions -F '#S' 2>/dev/null)

if [ -z "$sessions" ]; then
  exit 0
fi

# Calculate positions based on actual status-left layout
# Layout: [session_icon segment] [session_list segment]
# session_icon: " 󰆍 " (icon with padding and separator) ≈ 3-4 chars
# Each session in list: " sessionname " with separator

pos=0

# Skip the session_icon segment (icon + padding + separator)
# Approximate: icon(2) + padding(2) + separator(1) = 5
icon_segment_width=5
pos=$((pos + icon_segment_width))

target_session=""
first=true

while IFS= read -r session; do
  # Calculate session name width with padding
  # Format: " session " (space before and after)
  session_width=$((${#session} + 2))

  # Add separator width (except for first session)
  if [ "$first" = false ]; then
    # Powerline separator (bold) takes ~1 char
    pos=$((pos + 1))
  fi
  first=false

  # Check if click position falls within this session's area
  start_pos=$pos
  end_pos=$((pos + session_width))

  if [ "$mouse_x" -ge "$start_pos" ] && [ "$mouse_x" -lt "$end_pos" ]; then
    target_session="$session"
    break
  fi

  # Move to next session position
  pos=$end_pos
done <<< "$sessions"

# Switch to the target session if found and it's different from current
if [ -n "$target_session" ] && [ "$target_session" != "$current_session" ]; then
  tmux switch-client -t "$target_session"
fi
