#!/usr/bin/env bash
# Print short hostname.

# shellcheck disable=SC1091
source "$(dirname "$0")/../common.sh" || exit 1

echo "󰍹 $(hostname -s)"
