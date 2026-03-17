#!/usr/bin/env bash
# Print short hostname.

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPTS_DIR/common.sh" || exit 1

echo "󰍹 $(hostname -s)"
