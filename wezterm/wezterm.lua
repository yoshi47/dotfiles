local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- General
config.automatically_reload_config = true
config.default_prog = {
  "/bin/zsh", "-l", "-c",
  "if command -v tmux >/dev/null 2>&1; then tmux a -t main || tmux new -s main; else echo 'WARNING: tmux not found. Install it with: brew install tmux'; exec zsh; fi",
}
config.window_close_confirmation = "NeverPrompt"
config.front_end = "WebGpu"
config.max_fps = 120
config.scrollback_lines = 0
config.term = "xterm-256color"

-- Tab bar (hidden — using tmux instead)
config.enable_tab_bar = false

-- Window
config.initial_cols = 135
config.initial_rows = 50
config.window_padding = { left = 1, right = 1, top = 1, bottom = 1 }
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_decorations = "TITLE | RESIZE"

-- Font
config.font = wezterm.font_with_fallback({
  "Hack Nerd Font Mono",
  "HackGen Console NF",
})
config.font_size = 12.5


-- Theme (managed by chezmoi — see .chezmoidata.yaml)
config.color_scheme = "Dracula (Official)"

-- Bell
config.audible_bell = "SystemBeep"

-- Hyperlinks (Cmd+Click to open)
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Apply personal theme to personal workspace windows
-- The Cmd+N callback creates a "personal" workspace (or cycles if it exists).
-- This event handler detects the workspace name and applies the color scheme override.
wezterm.on("update-status", function(window)
  local overrides = window:get_config_overrides() or {}
  local workspace = window:active_workspace()
  if workspace == "personal" then
    if overrides.color_scheme ~= "Monokai (base16)" then
      overrides.color_scheme = "Monokai (base16)"
      window:set_config_overrides(overrides)
    end
  else
    if overrides.color_scheme then
      overrides.color_scheme = nil
      window:set_config_overrides(overrides)
    end
  end
end)

-- Title bar: show workspace name
wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
  return wezterm.mux.get_active_workspace()
end)

-- Key bindings
config.keys = {
  -- Shift+Return: send ESC + CR (same as Alacritty \x1b\r)
  {
    key = "Enter",
    mods = "SHIFT",
    action = act.SendString("\x1b\r"),
  },
  -- Cmd+N: toggle/cycle workspaces — spawns a dedicated personal tmux session on first use,
  --        then cycles through all workspaces with SwitchWorkspaceRelative
  {
    key = "n",
    mods = "CMD",
    action = wezterm.action_callback(function(window, pane)
      local workspaces = wezterm.mux.get_workspace_names() or {}
      -- If personal workspace doesn't exist yet, create it
      local has_personal = false
      for _, name in ipairs(workspaces) do
        if name == "personal" then
          has_personal = true
          break
        end
      end
      if not has_personal then
        window:perform_action(
          act.SwitchToWorkspace({
            name = "personal",
            spawn = {
              set_environment_variables = {
                TMUX_THEME_PALETTE = "monokai",
              },
              args = { "/bin/zsh", "-l", "-c", "~/.config/wezterm/start-personal-tmux.sh" },
            },
          }),
          pane
        )
      else
        -- Cycle to next workspace
        window:perform_action(act.SwitchWorkspaceRelative(1), pane)
      end
    end),
  },
}

return config
