#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
PERMISSION_MODE=$(echo "$INPUT" | jq -r '.permission_mode // ""')

if [[ "$PERMISSION_MODE" != "plan" ]]; then
    echo '{"decision":"approve"}'
    exit 0
fi

# plan mode → プランファイルの存在を確認してレビュー指示を注入
PLAN_DIR="$HOME/.claude/plans"
PLAN_FILE=$(ls -t "$PLAN_DIR"/*.md 2>/dev/null | head -1)

if [[ -z "${PLAN_FILE:-}" ]]; then
    echo '{"decision":"approve"}'
    exit 0
fi

# message で /plan-review skill の実行を指示
cat <<EOF
{"decision":"approve","message":"[Plan Review Required] Plan mode が検出されました。/plan-review skill を実行して、最新のプランファイル (${PLAN_FILE}) を Codex CLI でレビューしてください。"}
EOF
