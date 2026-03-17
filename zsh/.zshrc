
# Reset PATH on re-source to prevent accumulation
if [[ -n $_ZSHRC_LOADED ]]; then
  export PATH="$_ZSHRC_ORIGINAL_PATH"
fi
_ZSHRC_ORIGINAL_PATH="${_ZSHRC_ORIGINAL_PATH:-$PATH}"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PATH="$HOME/bin:$PATH"

# Nix (early — needed by sheldon/smartcache which depend on Nix-installed tools)
if [[ -d "$HOME/.nix-profile/bin" ]]; then
  export PATH="$HOME/.nix-profile/bin:$PATH"
fi

# Disable zsh default completion menu (required for fzf-tab)
# Must be set before compinit to override /etc/zshrc defaults
zstyle ':completion:*' menu no
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# fzf-tab configuration
if [[ -n "$TMUX" ]]; then
  zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
  zstyle ':fzf-tab:*' popup-min-size 80 12
fi
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always $realpath'
zstyle ':fzf-tab:complete:(cat|bat|less|head|tail|vim|nvim):*' fzf-preview 'bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null || eza --color=always $realpath'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:kill:*' fzf-preview 'ps -p $word -o pid,user,%cpu,%mem,command'

# sheldon (plugin manager) - cached for faster startup
_sheldon_cache="${XDG_CACHE_HOME:-$HOME/.cache}/sheldon/source.zsh"
_sheldon_bin=$(command -v sheldon)
if [[ ! -f "$_sheldon_cache" || ~/.config/sheldon/plugins.toml -nt "$_sheldon_cache" || "$_sheldon_bin" -nt "$_sheldon_cache" ]]; then
  mkdir -p "${_sheldon_cache:h}"
  sheldon source > "${_sheldon_cache}.tmp" && mv "${_sheldon_cache}.tmp" "$_sheldon_cache"
fi
source "$_sheldon_cache"

# smartcache: cached init scripts (no defer - avoids first-keypress lag)
smartcache eval mise activate zsh
smartcache eval zoxide init zsh
smartcache eval direnv hook zsh

# starship - select theme config based on tmux palette
if [[ -n "$TMUX_THEME_PALETTE" && "$TMUX_THEME_PALETTE" != "dracula" ]]; then
  export STARSHIP_CONFIG="$HOME/.config/starship_personal.toml"
fi

# starship - cached for faster startup (per palette)
_starship_config="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
_starship_cache="${XDG_CACHE_HOME:-$HOME/.cache}/starship/init-${TMUX_THEME_PALETTE:-default}.zsh"
_starship_bin=$(command -v starship)
if [[ ! -f "$_starship_cache" || "$_starship_config" -nt "$_starship_cache" || "$_starship_bin" -nt "$_starship_cache" ]]; then
  mkdir -p "${_starship_cache:h}"
  starship init zsh > "${_starship_cache}.tmp" && mv "${_starship_cache}.tmp" "$_starship_cache"
fi
source "$_starship_cache"

# History configuration
HISTSIZE=100000
SAVEHIST=100000

# History patterns to exclude
HISTORY_IGNORE="(node 'node_modules/.bin/jest'*|cd server &&*|cd web &&*)"

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
setopt share_history # ターミナル間・マシン間でヒストリを共有する
setopt no_flow_control # Ctrl-S, Ctrl-Q でのフロー制御を無効化

# Local file sources
source ~/.config/zsh/fzf.zsh 2>/dev/null
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
# Local environment variables
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Aliases
alias rm='rmtrash'

# eza (ls replacement)
alias ls='eza --icons'
alias ll='eza -l --git --time-style=relative --icons'
alias la='eza -la --git --time-style=relative --icons'
alias lt='eza --tree --level=2 --icons'

# memos DB viewer
alias memos-db='scp memos:/var/opt/memos/memos_prod.db ~/memos.db && open -a "Beekeeper Studio" ~/memos.db'

# Playwright with persistent profiles
alias pw-work='npx playwright open --user-data-dir=~/.playwright/profiles/work'
alias pw-private='npx playwright open --user-data-dir=~/.playwright/profiles/private'

COMPLETION_WAITING_DOTS="true"

# Docker Desktop completions
if (( ! ${fpath[(Ie)$HOME/.docker/completions]} )); then
  fpath=($HOME/.docker/completions $fpath)
fi

# Kiro terminal integration
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# tmux pane border integration (dir / git / running command)
[ -f ~/.config/tmux/scripts/pane_border_hooks.zsh ] && source ~/.config/tmux/scripts/pane_border_hooks.zsh

# yazi - select theme config based on tmux palette (like starship above)
if [[ -n "$TMUX_THEME_PALETTE" && "$TMUX_THEME_PALETTE" != "dracula" ]]; then
  export YAZI_CONFIG_HOME="$HOME/.config/yazi-personal"
fi

# yazi wrapper: reset tmux pane_current_path after exit
yazi() {
  command yazi "$@"
  printf '\e]7;file://%s%s\e\\' "$HOST" "$PWD"
}

_ZSHRC_LOADED=1

alias claude-mem='bun "$HOME/.claude/plugins/cache/thedotmack/claude-mem/10.5.2/scripts/worker-service.cjs"'

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Added by git-ai installer on Fri Mar 13 15:25:30 JST 2026
export PATH="$HOME/.git-ai/bin:$PATH"

# LiteLLM Proxy (Claude Code with OpenAI models)
alias claude-gpt='~/.config/litellm/start.sh'

# Added by sonarqube-cli installer
export PATH="$HOME/.local/share/sonarqube-cli/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
