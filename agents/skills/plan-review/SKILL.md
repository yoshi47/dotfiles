---
name: plan-review
description: Review the current plan with Codex CLI
allowed-tools: Bash(bash -c:*), Bash(codex exec:*), Bash(ls:*), Bash(cat:*)
---

Review the latest plan file using Codex CLI. Use this when the automatic hook doesn't fire (e.g., Shift+Tab plan mode).

1. Find the latest plan file:

```bash
ls -t ~/.claude/plans/*.md 2>/dev/null | head -1
```

2. Read the plan content, then run Codex review:

```bash
codex exec --dangerously-bypass-approvals-and-sandbox --ephemeral "以下の実装計画をレビューしてください。潜在的な問題点、見落とし、改善提案があれば簡潔に指摘してください。問題がなければ「問題なし」と回答してください。

---
$(cat PLAN_FILE_PATH)"
```

Replace `PLAN_FILE_PATH` with the actual path from step 1.

3. Show the review result to the user.

If no plan file exists, inform the user that no plan was found in `~/.claude/plans/`.
