local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Per-workspace theme overrides.
-- Workspaces not listed here use the default color_scheme.
local workspace_config = {
  personal = {
    wezterm_theme = "Monokai (base16)",
    tmux_palette = "monokai",
  },
}

-- Validate workspace name: alphanumeric, dash, underscore only
local function valid_workspace_name(name)
  return name and name ~= "" and name:match("^[%w_-]+$") ~= nil
end

-- Build spawn args for a tmux socket
local function tmux_spawn(socket_name)
  local session = socket_name == "default" and "main" or socket_name
  local conf = workspace_config[socket_name] or {}
  local env = {}
  if conf.tmux_palette then
    env.TMUX_THEME_PALETTE = conf.tmux_palette
  end
  return {
    set_environment_variables = env,
    args = {
      "/bin/zsh", "-l", "-c",
      string.format("~/.config/wezterm/start-tmux.sh '%s' '%s'", socket_name, session),
    },
  }
end

-- Switch to a workspace, starting its tmux socket if needed
local function switch_workspace(window, pane, name)
  window:perform_action(
    act.SwitchToWorkspace({
      name = name,
      spawn = tmux_spawn(name),
    }),
    pane
  )
end

-- General
config.automatically_reload_config = true
local default_spawn = tmux_spawn("default")
config.default_prog = default_spawn.args
config.set_environment_variables = default_spawn.set_environment_variables
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
  "PlemolJP35 Console NF",
})
config.font_size = 12.5


-- Theme (managed by chezmoi — see .chezmoidata.yaml)
config.color_scheme = "Dracula (Official)"

-- Bell
config.audible_bell = "SystemBeep"

-- Hyperlinks (Cmd+Click to open)
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Apply per-workspace theme overrides from workspace_config
wezterm.on("update-status", function(window)
  local overrides = window:get_config_overrides() or {}
  local workspace = window:active_workspace()
  local conf = workspace_config[workspace]

  if conf and conf.wezterm_theme then
    if overrides.color_scheme ~= conf.wezterm_theme then
      overrides.color_scheme = conf.wezterm_theme
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
  -- Cmd+N: cycle through workspaces (creates personal on first use)
  {
    key = "n",
    mods = "CMD",
    action = wezterm.action_callback(function(window, pane)
      local workspaces = wezterm.mux.get_workspace_names() or {}
      local has_personal = false
      for _, name in ipairs(workspaces) do
        if name == "personal" then
          has_personal = true
          break
        end
      end
      if not has_personal then
        switch_workspace(window, pane, "personal")
      else
        window:perform_action(act.SwitchWorkspaceRelative(1), pane)
      end
    end),
  },
  -- Cmd+O: workspace picker — list running tmux sockets + create new
  {
    key = "o",
    mods = "CMD",
    action = wezterm.action_callback(function(window, pane)
      local wez_workspaces = wezterm.mux.get_workspace_names() or {}
      local active = window:active_workspace()

      -- Detect running tmux sockets
      local uid_ok, uid_out = wezterm.run_child_process({ "id", "-u" })
      local sockets = {}
      if uid_ok then
        local uid = uid_out:gsub("%s+", "")
        local ok, ls_out = wezterm.run_child_process({ "ls", "/tmp/tmux-" .. uid })
        if ok then
          for name in ls_out:gmatch("[^\n]+") do
            sockets[name] = true
          end
        end
      end

      -- Merge: WezTerm workspaces + tmux sockets
      local seen = {}
      local choices = {}

      for _, ws in ipairs(wez_workspaces) do
        seen[ws] = true
        local label = ws
        if ws == active then
          label = ws .. "  (active)"
        end
        if sockets[ws] then
          label = label .. "  [tmux]"
        end
        table.insert(choices, { label = label, id = ws })
      end

      for name, _ in pairs(sockets) do
        if not seen[name] then
          table.insert(choices, { label = name .. "  [tmux only]", id = name })
        end
      end

      table.insert(choices, { label = "+ New workspace...", id = "__new__" })

      window:perform_action(
        act.InputSelector({
          title = "Workspaces (tmux sockets)",
          choices = choices,
          fuzzy = true,
          action = wezterm.action_callback(function(inner_window, inner_pane, id)
            if not id then return end

            if id == "__new__" then
              inner_window:perform_action(
                act.PromptInputLine({
                  description = "New workspace name (= tmux socket name):",
                  action = wezterm.action_callback(function(w, p, line)
                    if not valid_workspace_name(line) then
                      wezterm.log_warn("Invalid workspace name: " .. tostring(line))
                      return
                    end
                    switch_workspace(w, p, line)
                  end),
                }),
                inner_pane
              )
            else
              switch_workspace(inner_window, inner_pane, id)
            end
          end),
        }),
        pane
      )
    end),
  },
}

return config
