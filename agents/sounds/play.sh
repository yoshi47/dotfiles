#!/usr/bin/env bash
set -euo pipefail
FILE="${1:?Usage: play.sh <file>}"
if command -v mac &>/dev/null; then
  mac afplay "$FILE"
elif [ -n "${WSL_DISTRO_NAME:-}" ]; then
  powershell.exe -c "(New-Object Media.SoundPlayer '$(wslpath -w "$FILE")').PlaySync()"
else
  play -q "$FILE"
fi
