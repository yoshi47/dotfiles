# Dotfiles

個人的な設定ファイルを管理するリポジトリです。

## 構造

```
dotfiles/
├── alacritty/        # Alacrittyターミナル設定
│   ├── alacritty.toml
│   └── themes/       # カラーテーマ
│       └── dracula.toml
├── claude/           # Claude Code設定
│   ├── settings.json # 統合設定ファイル
│   ├── CLAUDE.md     # ユーザー指示
│   ├── commands/     # スラッシュコマンド
│   │   ├── create-pr.sh
│   │   ├── pr-status.sh
│   │   └── config.json
│   └── hooks/        # フックスクリプト
│       ├── hook_fetch.sh
│       ├── hook_pre_commands.sh
│       ├── hook_stop_words.sh
│       └── rules/
├── mcp/              # MCP共通設定（複数エディタ対応）
│   ├── config.json   # MCPサーバー設定
│   └── README.md     # MCP設定ガイド
├── git/              # Git設定
│   ├── .gitconfig
│   └── .gitignore_global
├── tmux/             # Tmux設定
│   └── .tmux.conf
├── zsh/              # Zsh設定
│   └── .zshrc
├── .env.example      # 環境変数のテンプレート
├── .gitignore        # Gitで無視するファイル
├── install.sh        # インストールスクリプト
├── uninstall.sh      # アンインストールスクリプト
└── README.md         # このファイル
```

## セットアップ

### 1. リポジトリのクローン

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. インストール

```bash
chmod +x install.sh
./install.sh
```

これにより以下の処理が実行されます：
- 設定ファイルのシンボリックリンクをホームディレクトリに作成
- 既存のファイルは `.backup` として保存
- TPM（Tmux Plugin Manager）を自動インストール
- tmuxプラグインを自動インストール
- Claude Code設定を `~/.claude` にシンボリックリンク作成
- `.env.example` から `.env.local` を作成

### 3. 環境変数の設定

`~/.env.local` を編集して、実際のAPIキーやパスワードを設定してください：

```bash
vim ~/.env.local
```

### 4. ターミナルの再起動

設定を反映するために、ターミナルを再起動するか以下を実行：

```bash
source ~/.zshrc
```

## アンインストール

設定を元に戻したい場合：

```bash
chmod +x uninstall.sh
./uninstall.sh
```

これにより：
- シンボリックリンクが削除されます
- `.backup` ファイルがある場合は復元されます

## カスタマイズ

### 新しい設定ファイルの追加

1. 適切なディレクトリに設定ファイルを追加
2. `install.sh` にシンボリックリンク作成処理を追加
3. `uninstall.sh` に削除処理を追加

### プラグインの管理

#### Zsh
- `fzf-tab`: ファジーファインダー統合
- `enhancd`: cdコマンドの拡張
- `zsh-autosuggestions`: コマンド補完
- `zsh-syntax-highlighting`: シンタックスハイライト

#### Tmux
- `tpm`: Tmuxプラグインマネージャー（自動インストール）
- `dracula/tmux`: Draculaテーマ（自動インストール）
- `tmux-sensible`: 基本設定（自動インストール）
- `tmux-pain-control`: ペイン操作の改善（自動インストール）
- `tmux-copycat`: 検索機能の拡張（自動インストール）

**注意**: 初回インストール時に自動でプラグインがインストールされます。手動でインストールする場合は、tmux内で `prefix + I` (デフォルト: `Ctrl-j + I`) を押してください。

#### Alacritty
- Draculaテーマ: ダークテーマのカラースキーム
- 他のテーマも`alacritty/themes/`に追加可能

### Claude Code設定

#### 設定ファイル
- `claude/settings.json`: 統合設定ファイル（全プロジェクトの権限、フック、モデル設定を含む）
- `claude/CLAUDE.md`: ユーザー固有の指示とガイドライン

#### スラッシュコマンド
利用可能なコマンド:
- `/create-pr` または `/pr`: 現在のブランチのPRを作成
- `/pr-status` または `/prs`: 現在のブランチのPRステータスを確認

#### フックスクリプト
- `hook_fetch.sh`: WebFetch前の処理
- `hook_pre_commands.sh`: コマンド実行前の処理  
- `hook_stop_words.sh`: 読み込み制限の処理

設定には以下のツールへのアクセス権限が含まれています：
- パッケージマネージャー（pnpm、yarn、npm）のコマンド
- Git操作（push、resetを除く）
- MCPツール（Notion、Playwright、Postgres、Figma等）
- 開発ツール（TypeScript、Jest、Biome等）

### MCP (Model Context Protocol) 共通設定

`mcp/config.json`は複数のエディタで共有されるMCPサーバー設定です：

#### 対応エディタ
- Claude Code (`~/.claude.json`)
- Cursor (`~/.cursor/mcp.json`)
- Roo Code (`~/.roo/mcp.json`)
- Windsurf (`~/.windsurf/mcp.json`)

#### 含まれるMCPサーバー
- PostgreSQL データベース接続
- Excel ファイル操作
- Prisma ORM
- Notion API
- Playwright ブラウザ自動化
- Figma デザインツール

インストール時に各エディタの設定場所へ自動的にシンボリックリンクが作成されます。

## 必要な依存関係

- Homebrew
- Zsh
- Git
- Tmux
- Alacritty (ターミナルエミュレータ)
- Starship (プロンプト)
- fzf
- nodenv
- pyenv
- Hack Nerd Font (Alacritty用フォント)

## セキュリティ注意事項

- `.env.local` には機密情報が含まれるため、絶対にGitにコミットしないでください
- APIキーやパスワードは安全に管理してください
- 可能であれば、macOSのキーチェーンやパスワードマネージャーの使用を検討してください

## トラブルシューティング

### シンボリックリンクが作成できない
- 既存のファイルがある場合は自動的にバックアップされます
- 手動で削除またはリネームしてから再実行してください

### プラグインが動作しない
- 必要な依存関係がインストールされているか確認
- `brew install` で必要なパッケージをインストール

### 設定が反映されない
- ターミナルを再起動するか `source ~/.zshrc` を実行

## ライセンス

MIT