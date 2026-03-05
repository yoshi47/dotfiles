#!/bin/bash
# PreToolUse hook - WebFetch実行前のチェック

INPUT=$(cat)

HOOK_FETCH_PATH="$HOME/.claude/hooks/rules/hook_fetch_rules.json"
HOOK_MCP_MAPPINGS_PATH="$HOME/.claude/hooks/rules/hook_fetch_mcp_mappings.json"

# ツール名を取得
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')

# WebFetchツールの場合のみチェック
if [ "$TOOL_NAME" = "WebFetch" ]; then
    # URLを取得
    URL=$(echo "$INPUT" | jq -r '.tool_input.url')

    # MCPマッピングファイルが存在する場合、URLをチェック
    if [ -f "$HOOK_MCP_MAPPINGS_PATH" ]; then
        # 各MCPサービスをループ処理
        SERVICES=$(jq -r '.mcp_mappings | keys[]' "$HOOK_MCP_MAPPINGS_PATH")
        for SERVICE in $SERVICES; do
            # URLパターン配列を取得
            PATTERNS=$(jq -r ".mcp_mappings.\"$SERVICE\".patterns[]" "$HOOK_MCP_MAPPINGS_PATH" 2>/dev/null)
            
            # 各パターンをチェック
            for pattern in $PATTERNS; do
                if echo "$URL" | grep -qE "$pattern"; then
                    # サービスの情報を取得
                    MESSAGE=$(jq -r ".mcp_mappings.\"$SERVICE\".message" "$HOOK_MCP_MAPPINGS_PATH")
                    
                    # エラーメッセージを構成
                    ERROR_MESSAGE=$(cat << EOF
💡 $MESSAGE

検出されたURL: $URL

WebFetchの代わりに以下のツールを使用することをお勧めします：

📍 利用可能なツール:
EOF
)
                    
                    # ツール一覧を追加
                    TOOLS=$(jq -r ".mcp_mappings.\"$SERVICE\".tools[] | \"• \" + .name + \" - \" + .description" "$HOOK_MCP_MAPPINGS_PATH")
                    ERROR_MESSAGE="${ERROR_MESSAGE}
$TOOLS"
                    
                    # ID抽出設定がある場合
                    HAS_ID_EXTRACTION=$(jq -e ".mcp_mappings.\"$SERVICE\".id_extraction" "$HOOK_MCP_MAPPINGS_PATH" 2>/dev/null && echo "true" || echo "false")
                    
                    if [ "$HAS_ID_EXTRACTION" = "true" ]; then
                        ID_PATTERN=$(jq -r ".mcp_mappings.\"$SERVICE\".id_extraction.pattern" "$HOOK_MCP_MAPPINGS_PATH")
                        EXAMPLE_USAGE=$(jq -r ".mcp_mappings.\"$SERVICE\".id_extraction.example_usage" "$HOOK_MCP_MAPPINGS_PATH")
                        UUID_FORMAT=$(jq -r ".mcp_mappings.\"$SERVICE\".id_extraction.uuid_format // false" "$HOOK_MCP_MAPPINGS_PATH")
                        
                        # IDを抽出
                        if echo "$URL" | grep -qE "$ID_PATTERN"; then
                            EXTRACTED_ID=$(echo "$URL" | grep -oE "$ID_PATTERN" | head -1)
                            
                            # UUID形式に変換が必要な場合
                            if [ "$UUID_FORMAT" = "true" ] && [ ${#EXTRACTED_ID} -eq 32 ]; then
                                EXTRACTED_ID="${EXTRACTED_ID:0:8}-${EXTRACTED_ID:8:4}-${EXTRACTED_ID:12:4}-${EXTRACTED_ID:16:4}-${EXTRACTED_ID:20:12}"
                            fi
                            
                            # 使用例を追加
                            FORMATTED_EXAMPLE=$(echo "$EXAMPLE_USAGE" | sed "s/{id}/$EXTRACTED_ID/g")
                            ERROR_MESSAGE="${ERROR_MESSAGE}

💡 使用例:
$FORMATTED_EXAMPLE"
                        fi
                    fi
                    
                    ERROR_MESSAGE="${ERROR_MESSAGE}

詳細はMCPツールのヘルプを参照してください。"
                    
                    # 色を適用
                    COLORED_MESSAGE=$(echo "$ERROR_MESSAGE" | sed $'s/^/\033[94m/' | sed $'s/$/\033[0m/')
                    
                    # JSONエスケープ
                    ESCAPED_MESSAGE=$(echo "$COLORED_MESSAGE" | jq -Rs .)
                    
                    # blockレスポンスを返す
                    cat << EOF
{
  "decision": "block",
  "reason": $ESCAPED_MESSAGE
}
EOF
                    exit 0
                fi
            done
        done
    fi

    if [ -n "$URL" ] && [ -f "$HOOK_FETCH_PATH" ]; then
        # 各ルールをループ処理
        RULES=$(jq -r 'keys[]' "$HOOK_FETCH_PATH")
        for RULE_NAME in $RULES; do
            # URLパターン配列を取得
            PATTERNS=$(jq -r ".\"$RULE_NAME\".patterns[]" "$HOOK_FETCH_PATH" 2>/dev/null)
            MESSAGE=$(jq -r ".\"$RULE_NAME\".message" "$HOOK_FETCH_PATH" 2>/dev/null)

            # 各パターンをチェック
            for pattern in $PATTERNS; do
                if echo "$URL" | grep -qF "$pattern"; then
                    # エラーメッセージを構成
                    ERROR_MESSAGE=$(cat << EOF
❌ エラー: 禁止されたURLパターン「$pattern」が検出されました。

ルール: $RULE_NAME
メッセージ: $MESSAGE

検出されたURL:
$URL

このURLへのアクセスは許可されていません。
EOF
)
                    # 色を適用
                    COLORED_MESSAGE=$(echo "$ERROR_MESSAGE" | sed $'s/^/\033[91m/' | sed $'s/$/\033[0m/')

                    # JSONエスケープ
                    ESCAPED_MESSAGE=$(echo "$COLORED_MESSAGE" | jq -Rs .)

                    # blockレスポンスを返す
                    cat << EOF
{
  "decision": "block",
  "reason": $ESCAPED_MESSAGE
}
EOF
                    exit 0
                fi
            done
        done
    fi
fi

# 問題なければ承認
echo '{"decision": "approve"}'
exit 0