#!/usr/bin/env bash
# Yazi file picker for tmux keybinding.
# Sets theme config based on TMUX_THEME_PALETTE, then runs yazi in chooser mode.
_palette="${TMUX_THEME_PALETTE:-dracula}"
if [[ "$_palette" != "dracula" ]]; then
  _yc="$HOME/.config/yazi-${_palette}"
  [[ -d "$_yc" ]] && export YAZI_CONFIG_HOME="$_yc"
fi
YAZI_TMUX_PICKER=1 yazi --chooser-file=/dev/stdout | pbcopy
