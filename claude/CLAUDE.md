SQLクエリを聞かれた場合は実際にクエリを実行して有効性を確かめて
わからないことがあればAskUserQuestionToolを利用してください

## General Guidelines

When asked to create a plan or investigate something, explore the codebase first before asking clarifying questions. Prefer action over clarification.

Before proposing any changes, first read the relevant source files and understand the current architecture. Then create a concrete plan with file paths and code snippets. Do not ask clarifying questions — explore the code instead.

## Communication Style

When providing comparisons or technical plans, be detailed and concrete with code examples. Avoid vague or high-level summaries — the user will ask for more detail.

## Environment Notes

作業開始時に `~/.claude/environment.md` を読んで実行環境（OrbStack VM / macOS ホスト構成、パス対応、利用可能ツール）を把握すること。

Be aware of sandbox restrictions. When working with file writes, git hooks, or shell scripts, check if sandbox mode will block operations and proactively suggest running with appropriate permissions.

## ランタイム・パッケージ管理

| ツール | 用途 |
|--------|------|
| **mise** | ランタイムバージョン管理（Node.js, Python 等）。設定は `~/.config/mise/config.toml` |
| **uv** | Python パッケージ管理・スクリプト実行。PEP 723 インラインメタデータ付きスクリプトは `uv run` で実行する（`python3` で直接実行しない） |
