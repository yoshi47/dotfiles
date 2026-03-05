#!/bin/bash
# shellcheck shell=bash
# Unified palette loader — auto-generated from .chezmoidata.yaml
# Usage: source palette.sh [palette_name]
#   Falls back to $TMUX_THEME_PALETTE, then "dracula"

_palette="${1:-${TMUX_THEME_PALETTE:-dracula}}"

case "$_palette" in
catppuccin_mocha)
    export THEME_BASE='#1E1E2E'
    export THEME_TEXT='#CDD6F4'
    export THEME_SURFACE='#45475A'
    export THEME_OVERLAY='#6C7086'
    export THEME_GREEN='#A6E3A1'
    export THEME_CYAN='#94E2D5'
    export THEME_PINK='#F5C2E7'
    export THEME_ORANGE='#FAB387'
    export THEME_PURPLE='#CBA6F7'
    export THEME_YELLOW='#F9E2AF'
    export THEME_BLUE='#89B4FA'
    export THEME_RED='#F38BA8'
    ;;
dracula)
    export THEME_BASE='#282a36'
    export THEME_TEXT='#f8f8f2'
    export THEME_SURFACE='#44475a'
    export THEME_OVERLAY='#6272a4'
    export THEME_GREEN='#50fa7b'
    export THEME_CYAN='#8be9fd'
    export THEME_PINK='#ff79c6'
    export THEME_ORANGE='#ffb86c'
    export THEME_PURPLE='#bd93f9'
    export THEME_YELLOW='#f1fa8c'
    export THEME_BLUE='#bd93f9'
    export THEME_RED='#ff5555'
    ;;
monokai)
    export THEME_BASE='#272822'
    export THEME_TEXT='#F8F8F2'
    export THEME_SURFACE='#3E3D32'
    export THEME_OVERLAY='#75715E'
    export THEME_GREEN='#A6E22E'
    export THEME_CYAN='#66D9EF'
    export THEME_PINK='#F92672'
    export THEME_ORANGE='#FD971F'
    export THEME_PURPLE='#AE81FF'
    export THEME_YELLOW='#E6DB74'
    export THEME_BLUE='#66D9EF'
    export THEME_RED='#F92672'
    ;;
tokyo_night)
    export THEME_BASE='#1A1B26'
    export THEME_TEXT='#C0CAF5'
    export THEME_SURFACE='#24283B'
    export THEME_OVERLAY='#414868'
    export THEME_GREEN='#9ECE6A'
    export THEME_CYAN='#7DCFFF'
    export THEME_PINK='#FF007C'
    export THEME_ORANGE='#FF9E64'
    export THEME_PURPLE='#BB9AF7'
    export THEME_YELLOW='#E0AF68'
    export THEME_BLUE='#7AA2F7'
    export THEME_RED='#F7768E'
    ;;
*)
    echo "Unknown palette: $_palette" >&2
    return 1 2>/dev/null || exit 1
    ;;
esac
unset _palette
