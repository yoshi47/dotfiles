# tmux pane border integration: show dir / git branch / running command
#
# What this file does
# - Writes per-pane metadata into tmux user options so tmux can render them in pane borders.
# - tmux reads these values via: #{@pane_dir} / #{@git_branch} / #{@running_cmd}
#
# Expected tmux config (example)
#   set -g pane-border-status top
#   set -g pane-border-format '...#{@pane_dir}...#{@git_branch}...#{@running_cmd}...'
#
# Hooks used
# - preexec: before a command runs -> store the command line
# - precmd: before prompt is shown -> clear the running command (command finished)
# - chpwd : when directory changes -> refresh dir + git branch

autoload -Uz add-zsh-hook

# Resolve native git, bypassing git-ai proxy (uses system default PATH).
_tmux_native_git=$(command -p -v git 2>/dev/null || echo git)

# Update tmux pane-scoped metadata: directory (pretty) + git branch/commit.
_tmux_pane_meta_update() {
  [[ -n $TMUX && -n ${TMUX_PANE:-} ]] || return
  local dir branch abs

  # Pretty path (replace $HOME prefix with ~)
  abs=$PWD
  if [[ $abs == "$HOME" ]]; then
    dir="~"
  elif [[ $abs == "$HOME"/* ]]; then
    dir="~/${abs#"$HOME"/}"
  else
    dir="$abs"
  fi

  branch=""
  # Determine current git branch; fallback to short commit hash on detached HEAD.
  # Use native git to bypass git-ai proxy (~120ms → ~15ms per call).
  if $_tmux_native_git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$($_tmux_native_git symbolic-ref --quiet --short HEAD 2>/dev/null || $_tmux_native_git rev-parse --short HEAD 2>/dev/null || true)
  fi

  # Write values to tmux for *this* pane only (-p + $TMUX_PANE).
  tmux set -pt "$TMUX_PANE" @pane_dir "$dir" 2>/dev/null
  tmux set -pt "$TMUX_PANE" @git_branch "$branch" 2>/dev/null
}

# preexec: called with the command line ($1) right before execution.
_tmux_running_cmd_preexec() {
  [[ -n $TMUX && -n ${TMUX_PANE:-} ]] || return
  _tmux_pane_meta_update
  tmux set -pt "$TMUX_PANE" @running_cmd "$1" 2>/dev/null
}

# precmd: called before showing the next prompt (i.e. command completed).
_tmux_running_cmd_precmd() {
  [[ -n $TMUX && -n ${TMUX_PANE:-} ]] || return
  _tmux_pane_meta_update
  tmux set -pt "$TMUX_PANE" @running_cmd "" 2>/dev/null

  # Auto-reload zshrc if stale flag is set (e.g. after chezmoi apply while a server was running)
  local stale
  stale=$(tmux show-option -pt "$TMUX_PANE" @zshrc_stale 2>/dev/null | awk '{print $2}')
  if [[ "$stale" == "1" ]]; then
    tmux set -put "$TMUX_PANE" @zshrc_stale
    source ~/.zshrc
  fi

  # Clear claude stale flag when returning to shell (e.g. after /exit from Claude Code)
  tmux set -put "$TMUX_PANE" @claude_stale 2>/dev/null

  # Clear app-waiting / app-alert flags if this pane set them (TUI exited)
  local _window_id _flag_pane _flag
  _window_id=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null)
  if [[ -n "$_window_id" ]]; then
    for _flag in app_waiting app_alert; do
      _flag_pane=$(tmux show-option -wqvt "$_window_id" @${_flag}_pane 2>/dev/null)
      if [[ "$_flag_pane" == "$TMUX_PANE" ]]; then
        tmux set-option -wut "$_window_id" @${_flag} 2>/dev/null
        tmux set-option -wut "$_window_id" @${_flag}_pane 2>/dev/null
      fi
    done
  fi
}

# chpwd: called when PWD changes.
_tmux_running_cmd_chpwd() {
  _tmux_pane_meta_update
}

# De-dupe hooks to avoid duplicates when this file is sourced multiple times.
add-zsh-hook -d preexec _tmux_running_cmd_preexec 2>/dev/null || true
add-zsh-hook -d precmd _tmux_running_cmd_precmd 2>/dev/null || true
add-zsh-hook -d chpwd _tmux_running_cmd_chpwd 2>/dev/null || true

# Register hooks.
add-zsh-hook preexec _tmux_running_cmd_preexec
add-zsh-hook precmd _tmux_running_cmd_precmd
add-zsh-hook chpwd _tmux_running_cmd_chpwd

# Initialize for the current pane.
_tmux_pane_meta_update
