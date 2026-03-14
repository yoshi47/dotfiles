#!/bin/zsh
# shellcheck shell=bash disable=SC2076,SC2154
# SC2076: zshではクォート付き正規表現が正しく動作します
# SC2154: zshでは=~マッチ時にmatch配列が自動的に設定されます
# Apply personal theme to this Alacritty window, then start personal tmux.
# Used by Cmd+N keybinding in alacritty.toml (msg create-window).
# alacritty msg config targets $ALACRITTY_WINDOW_ID (= calling window).

theme="$HOME/alacritty/themes/alacritty-theme/themes/monokai.toml"

# Parse TOML theme file into dotted key=value args for alacritty msg config
# e.g. [colors.primary] + background = '#1E1E2E' → colors.primary.background="#1E1E2E"
args=()
section=""
while IFS= read -r line; do
  line="${line#"${line%%[![:space:]]*}"}"     # trim leading whitespace
  [[ -z "$line" || "$line" == \#* ]] && continue

  if [[ "$line" =~ '^\[(.+)\]$' ]]; then
    section="${match[1]}"
  elif [[ "$line" =~ "^([a-z_]+)[[:space:]]*=[[:space:]]*['\\\"]([^'\\\"]+)['\\\"]" ]]; then
    args+=("${section}.${match[1]}=\"${match[2]}\"")
  fi
done < "$theme"

/Applications/Alacritty.app/Contents/MacOS/alacritty msg config "${args[@]}"

export TMUX_THEME_PALETTE="monokai"

# Check if the personal tmux server is already running
if tmux -L personal list-sessions &>/dev/null; then
  # Server exists — just attach
  exec tmux -L personal attach-session -t personal
else
  # New server — start and attach (restore is handled by continuum_force_autorestore.sh in tmux.conf)
  tmux -L personal -f ~/.config/tmux/tmux.personal.conf new-session -d -s personal
  exec tmux -L personal attach-session -t personal
fi
