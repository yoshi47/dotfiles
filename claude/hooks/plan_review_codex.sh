#!/usr/bin/env bash

# Plan Review Hook (PostToolUse:ExitPlanMode)
# Codex CLI でプランをレビューし、結果を stderr に表示する。
# 常に approve を返す（情報提供のみ、ブロックしない）。

set -euo pipefail

# 依存コマンドチェック
for cmd in jq codex; do
    if ! command -v "$cmd" &>/dev/null; then
        echo '{"decision":"approve"}'
        exit 0
    fi
done

# stdin から hook input JSON を読み取り
INPUT=$(cat)

# ~/.claude/plans/ から最新のプランファイルを取得
PLAN_DIR="$HOME/.claude/plans"
PLAN_FILE=$(ls -t "$PLAN_DIR"/*.md 2>/dev/null | head -1)

if [[ -z "${PLAN_FILE:-}" || ! -f "${PLAN_FILE:-}" ]]; then
    echo '{"decision":"approve"}'
    exit 0
fi

PLAN_CONTENT=$(cat "$PLAN_FILE")

# プランが空または極端に短い場合はスキップ
if [[ ${#PLAN_CONTENT} -lt 50 ]]; then
    echo '{"decision":"approve"}'
    exit 0
fi

# Codex でレビュー実行（タイムアウト120秒）
REVIEW=$(timeout 120 codex exec \
    --dangerously-bypass-approvals-and-sandbox \
    --ephemeral \
    "以下の実装計画をレビューしてください。
潜在的な問題点、見落とし、改善提案があれば簡潔に指摘してください。
問題がなければ「問題なし」と回答してください。

---
$PLAN_CONTENT" 2>/dev/null) || true

# レビュー結果を stderr に整形出力
if [[ -n "${REVIEW:-}" ]]; then
    echo "" >&2
    echo "━━━ Codex Plan Review ━━━" >&2
    echo "$REVIEW" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "" >&2
fi

# 常に approve
echo '{"decision":"approve"}'
