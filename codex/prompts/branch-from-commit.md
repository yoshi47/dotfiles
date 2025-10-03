Create a new branch from the latest main/master and cherry-pick specific commit(s).

Context
- This is a Codex CLI custom prompt. Invoke it as `/branch-from-commit <hash...>`.
- Codex will run git commands locally with approvals as needed. Do not force-push or rewrite unrelated history.

Goal
- From the latest `origin/main` (fallback to `origin/master`), create a new local branch and cherry-pick the provided commit hash(es) in chronological order. Do NOT push automatically.

Instructions
1) Parse commit hashes from the user input following the command. If none were provided, ask me for them and stop.
2) `git fetch --all --prune`.
3) Determine base branch: prefer `origin/main`, else `origin/master`. Fail clearly if neither exists.
4) Validate each commit exists locally or on the remote (e.g., `git cat-file -t <sha>` or `git show --no-patch --oneline <sha>`). If any are missing, list which ones and stop.
5) Show a concise preview of the commits to apply (subject, author, date) so I can confirm.
6) Generate a readable branch name from the first commit’s subject: `{my-git-username}/{kebab-summary}`; if exists, append a numeric suffix (`-2`, `-3`, ...).
7) `git checkout -b <branch> <base>`.
8) Cherry-pick commits in chronological (oldest→newest) order using a single command if possible: `git cherry-pick <sha1> <sha2> ...`.
   - If conflicts occur, pause and explain which files conflict and suggested resolve steps; do not auto-resolve.
9) On success, print:
   - Created branch name
   - Number of commits applied
   - Next commands to push and create a PR (but do not execute automatically)

Constraints
- Do not push to origin.
- Do not rebase or reset existing branches.
- Keep all operations local unless I explicitly confirm otherwise.

Examples
- `/branch-from-commit abc1234`
- `/branch-from-commit abc1234 def5678 ghi9012`

Output format
- Short status header, then a bullet list of steps performed and the final branch name. If anything fails, show a clear error and what I should provide next.

