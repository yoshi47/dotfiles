---
name: plan-review
description: Review the current plan with Codex CLI
allowed-tools: Bash(bash -c:*), Bash(codex exec:*), Bash(ls:*), Bash(cat:*), Bash(ai-conversation-search:*)
---

Review the latest plan file using Codex CLI with conversation context for better reviews. Use this when the automatic hook doesn't fire (e.g., Shift+Tab plan mode).

1. Find the latest plan file:

```bash
ls -t ~/.claude/plans/*.md 2>/dev/null | head -1
```

If no plan file exists, inform the user that no plan was found in `~/.claude/plans/`.

2. Read the plan content and extract 2-3 keywords (file names, feature names, domain terms) for context search.

3. Gather conversation context using conversation-search:

```bash
ai-conversation-search search "extracted keywords" --days 1 --content --limit 5
```

4. Combine all context and run Codex review:

```bash
codex exec --dangerously-bypass-approvals-and-sandbox --ephemeral "以下の実装計画をレビューしてください。会話コンテキストも参考にして、潜在的な問題点、見落とし、改善提案があれば簡潔に指摘してください。問題がなければ「問題なし」と回答してください。

--- 実装計画 ---
$(cat PLAN_FILE_PATH)

--- 会話コンテキスト ---
CONVERSATION_CONTEXT_HERE"
```

Replace `PLAN_FILE_PATH` with the actual path from step 1. Replace `CONVERSATION_CONTEXT_HERE` with the results from step 3.

5. Show the review result to the user.

6. If Codex points out issues, fix the plan and re-run the review. Repeat until Codex responds with「問題なし」(OK).
