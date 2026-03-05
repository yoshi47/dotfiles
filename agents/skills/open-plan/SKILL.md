---
name: open-plan
description: Open the current session's plan file in editor
allowed-tools: Bash(bash -c:*), Bash(open:*)
---

Open the plan file for the current session in the editor with a single command:

```bash
bash -c 'HOME_PATTERN=$(echo "$HOME" | tr "/" "-"); SLUG=$(grep -m1 -o "\"slug\":\"[^\"]*\"" "$(ls -t ~/.claude/projects/${HOME_PATTERN}-*/*.jsonl 2>/dev/null | head -1)" | sed "s/\"slug\":\"//;s/\"//") && open -a "${CLAUDE_PLAN_EDITOR:-Cursor}" ~/.claude/plans/${SLUG}.md'
```

If it fails, inform the user that no plan was created in this session.
