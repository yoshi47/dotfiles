#!/usr/bin/env bash
# Print short hostname.

# shellcheck disable=SC1091
tmux_icon() { case "$1" in hostname) echo "@" ;; esac; }
source "$(dirname "$0")/../common.sh" 2>/dev/null

echo "$(tmux_icon hostname) $(hostname -s)"
