#!/usr/bin/env bash
# Apply theme colors to tmux session.
# All colour-containing format strings live here so palette shell variables get expanded.
# Palette is selected by TMUX_THEME_PALETTE env var (default: dracula).

# Clear segment caches on reload
rm -f /tmp/tmux-weather.cache

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPTS_DIR/common.sh" || { tmux display-message "ERROR: common.sh failed to load"; exit 1; }

if [ -z "$THEME_TEXT" ]; then
	tmux display-message "ERROR: palette not loaded (THEME_TEXT is empty)"
	exit 1
fi

FMT_OPTS="nobold,noitalics,nounderscore"

# --- existing: status bar base styles ---
tmux set -g status-style "fg=${THEME_TEXT},bg=${THEME_SURFACE}"
tmux set -g status-left-style "fg=${THEME_TEXT},bg=${THEME_SURFACE}"
tmux set -g status-right-style "fg=${THEME_TEXT},bg=${THEME_SURFACE}"
tmux set -g message-style "fg=${THEME_TEXT},bg=${THEME_SURFACE}"
tmux set -g message-command-style "fg=${THEME_TEXT},bg=${THEME_SURFACE}"
tmux set -g pane-border-style "fg=${THEME_SURFACE}"
tmux set -g pane-active-border-style "fg=${THEME_BLUE}"

# --- existing: pane border format ---
fmt=""
fmt+="#{?window_zoomed_flag,#[fg=${THEME_YELLOW}] #[default],}"
fmt+=" #[fg=${THEME_OVERLAY}]#P#[default]"
fmt+="#{?#{@running_cmd}, #[fg=${THEME_GREEN}]#{=60:#{@running_cmd}}#[default],} "
fmt+="#[fg=${THEME_CYAN},bold]#{=48:#{@pane_dir}}#[default] "
fmt+="#{?#{@git_branch},#[fg=${THEME_PURPLE}] #{=32:#{@git_branch}}#[default],} "
fmt+="#{?#{@zshrc_stale},#[align=right] #[fg=${THEME_ORANGE}]reload zshrc#{?#{@claude_stale}, / claude,} ,#{?#{@claude_stale},#[align=right] #[fg=${THEME_ORANGE}]reload claude ,}}"
tmux set -g pane-border-format "$fmt"

# --- new: window list formats (used in status-format[1]) ---

# Current window: overlay-bg pill with bold separators
wc=""
wc+="#[fg=${THEME_SURFACE},bg=${THEME_OVERLAY},${FMT_OPTS}]"
wc+="${SEP_RIGHT_BOLD}"
wc+="#[fg=${THEME_TEXT},bg=${THEME_OVERLAY},${FMT_OPTS}]"
wc+=" #I ${SEP_RIGHT_THIN} #{?window_zoomed_flag, ,}#W "
wc+="#[fg=${THEME_OVERLAY},bg=${THEME_SURFACE},${FMT_OPTS}]"
wc+="${SEP_RIGHT_BOLD}"
tmux set -g window-status-current-format "$wc"

# Non-current window: flat on surface (invisible bold sep for alignment)
# Bell windows get TEXT background with OVERLAY text to indicate notification
wf=""
wf+="#{?window_bell_flag,#[fg=${THEME_SURFACE}]#[bg=${THEME_TEXT}],#[fg=${THEME_SURFACE}]#[bg=${THEME_SURFACE}]}#[${FMT_OPTS}]"
wf+="${SEP_RIGHT_BOLD}"
wf+="#{?window_bell_flag,#[fg=${THEME_OVERLAY}]#[bg=${THEME_TEXT}],#[fg=${THEME_TEXT}]#[bg=${THEME_SURFACE}]}#[${FMT_OPTS}]"
wf+=" #I ${SEP_RIGHT_THIN} #{?window_zoomed_flag, ,}#W "
wf+="#{?window_bell_flag,#[fg=${THEME_TEXT}],#[fg=${THEME_SURFACE}]}#[bg=${THEME_SURFACE}]#[${FMT_OPTS}]"
wf+="${SEP_RIGHT_BOLD}"
tmux set -g window-status-format "$wf"

tmux set -g window-status-style "fg=${THEME_TEXT},bg=${THEME_SURFACE},${FMT_OPTS}"
tmux set -g window-status-separator ""

# --- new: dual status lines ---

# Line 0 (top): window list
tmux set -g status-format[0] "#[align=left fg=${THEME_TEXT},bg=${THEME_SURFACE}]#[list=on]#{W:#[range=window|#{window_index}]#{E:window-status-format}#[norange],#[range=window|#{window_index} list=focus]#{E:window-status-current-format}#[norange list=on]}#[nolist]"

# Line 1 (bottom): left segments + right segments
sf1_left="#[align=left range=left fg=${THEME_TEXT},bg=${THEME_SURFACE}]"
sf1_left+="#[push-default]#{T;=/#{status-left-length}:status-left}#[pop-default]"
sf1_left+="#[norange fg=${THEME_TEXT},bg=${THEME_SURFACE}]"

sf1_right="#[nolist align=right range=right fg=${THEME_TEXT},bg=${THEME_SURFACE}]"
sf1_right+="#[push-default]#{T;=/#{status-right-length}:status-right}#[pop-default]"
sf1_right+="#[norange fg=${THEME_TEXT},bg=${THEME_SURFACE}]"

tmux set -g status-format[1] "${sf1_left}${sf1_right}"

# --- new: status-left / status-right content ---
tmux set -g status-left "#(~/.config/tmux/scripts/status_left.sh)"

tmux set -g status-right "#(~/.config/tmux/scripts/status_right.sh)"
