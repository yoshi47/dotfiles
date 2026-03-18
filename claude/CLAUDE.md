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

## Superpowers スキルフレームワーク

[superpowers](https://github.com/obra/superpowers) プラグインが導入済み。セッション開始時に `using-superpowers` スキルが自動注入され、**すべてのタスクでスキルの適用可否を確認してから行動する**ことが求められる。

### コアワークフロー

非自明な作業は以下の順序で進める。単純な変更（typo修正、1ファイルの小さな編集等）ではスキップしてよい。

1. **brainstorming** — 要件を対話で明確化し、設計ドキュメント（spec）を作成
2. **writing-plans** — 実装計画を bite-sized タスクに分解（各タスク2-5分、ファイルパス・コード付き）
3. **subagent-driven-development** — タスクごとにサブエージェントを起動し、2段階レビュー（spec準拠 → コード品質）
4. **test-driven-development** — RED → GREEN → REFACTOR サイクル
5. **requesting-code-review** / **receiving-code-review** — コードレビュー
6. **finishing-a-development-branch** — テスト確認、マージ/PR/保持/破棄の選択肢を提示

### スキル一覧と発動条件

| スキル | 発動タイミング |
|--------|--------------|
| `brainstorming` | 機能追加・設計変更など創造的な作業の前 |
| `writing-plans` | spec/要件がありマルチステップの実装が必要な時 |
| `executing-plans` | 書かれた計画をレビューチェックポイント付きで実行する時 |
| `subagent-driven-development` | 計画内の独立タスクを並列実行する時 |
| `dispatching-parallel-agents` | 2つ以上の独立タスクを並行処理する時 |
| `test-driven-development` | 機能実装・バグ修正でコードを書く前 |
| `systematic-debugging` | バグ・テスト失敗・予期しない動作に遭遇した時 |
| `verification-before-completion` | 作業完了を宣言する前（必ず検証コマンドを実行） |
| `requesting-code-review` | タスク完了後、マージ前にレビューを依頼する時 |
| `receiving-code-review` | レビューフィードバックを受けて対応する時 |
| `finishing-a-development-branch` | 実装完了・テスト通過後にブランチを統合する時 |
| `writing-skills` | 新しいスキルを作成・編集する時 |

- **plan ファイルの保存先**: `docs/superpowers/plans/` ではなく **`.claude/plans/YYYY-MM-DD-<feature-name>.md`** に保存する（Claude Code のプロジェクトフォルダ内に置く）
- **spec ファイルの保存先**: **`.claude/specs/YYYY-MM-DD-<topic>-design.md`** に保存する
- スキルの発動判断に迷ったら、**1% でも該当しそうなら Skill ツールで呼び出す**（中身を確認して不要なら従わなくてよい）
