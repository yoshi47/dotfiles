# Dotfiles

個人的な設定ファイルを管理するリポジトリです。

## 構造

```
dotfiles/
├── git/               # Git設定
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
- `tpm`: Tmuxプラグインマネージャー
- `dracula/tmux`: Draculaテーマ
- `tmux-sensible`: 基本設定
- `tmux-pain-control`: ペイン操作の改善

## 必要な依存関係

- Homebrew
- Zsh
- Git
- Tmux
- Starship (プロンプト)
- fzf
- nodenv
- pyenv

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