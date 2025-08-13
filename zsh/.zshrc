# Zscaler Certificate (for corporate environments)
export NODE_EXTRA_CA_CERTS="/Applications/Zscaler/cert/ZscalerRootCertificate-2048-SHA256.crt"
export NODE_TLS_REJECT_UNAUTHORIZED=0

# Path configurations
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Node version manager
eval "$(nodenv init -)"

# Python version manager
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv init --path)"

# API Keys (consider using .env file or keychain)
source ~/.env.local

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
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_reduce_blanks
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_no_store
setopt extended_history
setopt inc_append_history
setopt no_flow_control

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
alias claude="/Users/yoshiki.kadono/.claude/local/claude"
alias rm='rmtrash'

# Initialize zoxide (better cd)
eval "$(zoxide init zsh)"

export PATH="$PATH:"