Create a draft pull request for the current or specified branch.

Context
- This is a Codex CLI custom prompt. Invoke it as `/pr` or `/pr <branch-name>`.
- Codex will ask for permission before running git/gh commands.

Goal
- Create a draft PR from the working branch (current by default; or switch to the provided branch if it exists). Use a repository PR template if present.

Instructions
1) If a branch name was provided, verify it exists (`git branch --list <name>`); switch with `git checkout <name>`. If not provided, use the current branch. Never create PRs directly from `main` or `master`; warn and stop.
2) `git status` and `git diff --stat` to surface uncommitted changes. If there are staged/unstaged changes, ask whether to commit them; otherwise continue.
3) Ensure the branch has an upstream. If not, push with `git push -u origin HEAD`.
4) Find PR template in order:
   - `.github/pull_request_template.md`
   - `.github/PULL_REQUEST_TEMPLATE.md`
   - `.github/PULL_REQUEST_TEMPLATE/` (pick the most relevant if multiple)
5) Prepare `/tmp/pr_body.md` by copying the template and appending a brief summary of recent commits (subject lines) and a checklist. Do not delete any existing template content.
6) Title rules:
   - If the branch name contains an issue key like `ABC-123`, set the title to `[ABC-123] <concise change summary>`.
   - Otherwise prefix with `[NO-TASK]`.
7) Create a DRAFT PR using GitHub CLI:
   - `gh pr create --fill --draft --body-file /tmp/pr_body.md`
   - If `--fill` is unsuitable, construct `--title` from the rule above.
8) Output the created PR URL, and remove `/tmp/pr_body.md`.

Constraints
- Do not merge or convert to ready-for-review automatically.
- Do not force-push.

Examples
- `/pr` — create a PR for the current branch
- `/pr yoshiki/NONE-123` — switch to this branch and create a draft PR titled `[NONE-123] <summary>`

Output format
- PR URL on a single line, followed by a short summary of what was included (branch, base, title). If anything blocks creation, show what I should fix and the exact command to retry.

