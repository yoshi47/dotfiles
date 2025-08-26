
# Path configurations
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Node version manager
eval "$(nodenv init -)"

# Python version manager
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv init --path)"

# Load local configuration (API keys, environment-specific settings)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# History configuration
HISTSIZE=100000
SAVEHIST=100000

# History patterns to exclude
HISTORY_IGNORE="(node 'node_modules/.bin/jest'*|cd server &&*|cd web &&*|cd /Users/yoshiki.kadono/meetsone/server &&*)"

# Function to exclude certain commands from history
zshaddhistory() {
  local line=${1%%$'\n'}
  [[ ! $line =~ $~HISTORY_IGNORE ]]
}

# History options
setopt hist_ignore_space # 前頭がスペースのみの場合はヒストリに追加しない
setopt hist_ignore_all_dups # 重複するコマンドラインは古い方を削除する
setopt hist_ignore_dups # 直前と同じコマンドラインはヒストリに追加しない
setopt hist_save_no_dups # 古いコマンドと同じものはヒストリに追加しない
setopt hist_reduce_blanks # 先頭と末尾の空白を削除する
setopt hist_expire_dups_first # 重複するコマンドラインは古い方から削除する
setopt hist_find_no_dups # ヒストリの検索時に重複を無視する
setopt hist_no_store # history コマンド自体はヒストリに追加しない
setopt extended_history # タイムスタンプ情報を保存する
setopt inc_append_history # 即座にヒストリファイルに追加する
setopt share_history # ターミナル間でヒストリを共有する
setopt no_flow_control # Ctrl-S, Ctrl-Q でのフロー制御を無効化

# Initialize completion system
autoload -Uz compinit && compinit

# Plugin configurations
source ~/fzf-tab/fzf-tab.plugin.zsh
source ~/enhancd/init.sh
source ~/fzf.zsh
eval "$(starship init zsh)"

# Zsh plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

COMPLETION_WAITING_DOTS="true"

ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste up-line-or-search down-line-or-search expand-or-complete accept-line push-line-or-edit)

# Docker Desktop completions
fpath=(/Users/yoshiki.kadono/.docker/completions $fpath)

# Bun completions
[ -s "/Users/yoshiki.kadono/.bun/_bun" ] && source "/Users/yoshiki.kadono/.bun/_bun"

# Bun path
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Local environment variables
. "$HOME/.local/bin/env"

# Aliases
alias rm='rmtrash'

# Initialize zoxide (better cd)
eval "$(zoxide init zsh)"

# pnpm
export PNPM_HOME="/Users/yoshiki.kadono/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Kiro terminal integration
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

export PATH="$PATH:"