#!/bin/bash

# --- find_my_prs_in_pr.sh ---
#
# Usage: ./find_my_prs_in_pr.sh [-o|--open] <PR_NUMBER>
#
# Description:
#   Finds and lists pull requests authored by the current user
#   that are included in a specified pull request.
#   If the -o or --open flag is provided, it opens the found URLs
#   in the default web browser.
#
# Dependencies:
#   - gh (GitHub CLI)
#   - jq (JSON processor)

set -e
set -o pipefail

# --- Default options ---
OPEN_BROWSER=false

# --- Parse arguments ---
if [[ "$1" == "-w" || "$1" == "--web" ]]; then
  OPEN_BROWSER=true
  shift # remove the option from the arguments, so $1 is now the PR number
fi

# 1. 引数のチェック
if [ -z "$1" ]; then
  echo "Error: PR number is required." >&2
  echo "Usage: $0 [-w|--web] <PR_NUMBER>" >&2
  exit 1
fi
PR_NUMBER=$1

# 2. 依存関係のチェック
if ! command -v gh &> /dev/null; then
    echo "Error: 'gh' command not found. Please install GitHub CLI." >&2
    exit 1
fi
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' command not found. Please install jq (e.g., 'brew install jq')." >&2
    exit 1
fi

# 3. 現在のユーザーとリポジトリ情報を取得
CURRENT_USER=$(gh api user --jq .login)
REPO_NWO=$(gh repo view --json nameWithOwner --jq .nameWithOwner) # owner/repo 形式

if [ -z "$CURRENT_USER" ] || [ -z "$REPO_NWO" ]; then
  echo "Error: Could not get GitHub user or repository info." >&2
  echo "Please ensure you are in a git repository and logged in with 'gh auth login'." >&2
  exit 1
fi

echo "Searching for PRs authored by '$CURRENT_USER' in https://github.com/$REPO_NWO/pull/$PR_NUMBER"
echo "---"

# 4. ghコマンドでコミット情報を取得し、jqで処理して結果を配列に格納
URLS=($(gh api "repos/$REPO_NWO/pulls/$PR_NUMBER/commits" --paginate | jq -r --arg user "$CURRENT_USER" --arg repo_nwo "$REPO_NWO" '.[] | select(.author? and .author.login == $user) | .commit.message | match("#([0-9]+)") | select(. != null) | .captures[0].string | "https://github.com/\($repo_nwo)/pull/\(.)"' | sort -u))

# 5. 結果を出力
if [ ${#URLS[@]} -eq 0 ]; then
  echo "No pull requests found authored by $CURRENT_USER."
else
  echo "Found ${#URLS[@]} pull request(s):"
  printf "%s\n" "${URLS[@]}"

  if [ "$OPEN_BROWSER" = true ]; then
    echo -e "\nOpening all URLs in a new browser window..."
    # Detect default browser and open the first URL in a new window
    if command -v google-chrome &> /dev/null || [ -d "/Applications/Google Chrome.app" ]; then
      open -na "Google Chrome" --args --new-window "${URLS[0]}"
    elif [ -d "/Applications/Firefox.app" ]; then
      open -na "Firefox" --args --new-window "${URLS[0]}"
    else
      # Fallback to Safari or default browser
      open -na "Safari" --args --new-window "${URLS[0]}"
    fi
    # Wait a moment for the new window to be ready
    sleep 1
    # Open the rest of the URLs in the new window as tabs
    for i in $(seq 1 $((${#URLS[@]} - 1))); do
      open "${URLS[$i]}"
    done
  fi
fi

echo -e "\n---"
echo "Search complete."