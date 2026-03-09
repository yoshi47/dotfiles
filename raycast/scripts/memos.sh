#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Memos
# @raycast.mode compact
# @raycast.icon 📝
# @raycast.argument1 { "type": "text", "placeholder": "メモを入力" }
# @raycast.description Memosにメモを投稿

TOKEN="${MEMOS_YOSHI_TOKEN:?MEMOS_YOSHI_TOKEN is not set}"
HOST="http://138.2.36.171:5230"

curl -s -X POST "$HOST/api/v1/memos" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg content "$1" '{content: $content, visibility: "PROTECTED"}')"

echo "Posted to Memos"
