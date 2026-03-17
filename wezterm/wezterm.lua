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

-- Validate remote target name (alphanumeric, dash, underscore, dot only)
local function valid_remote_target(name)
  return name and name ~= "" and name:match("^[%w_.%-]+$") ~= nil
end

-- Pad string to fixed width
local function pad(s, width)
  if #s >= width then return s end
  return s .. string.rep(" ", width - #s)
end

-- SSH config parser
local function parse_ssh_hosts()
  local hosts = {}
  local f = io.open((os.getenv("HOME") or "") .. "/.ssh/config", "r")
  if not f then return hosts end
  local ok, err = pcall(function()
    for line in f:lines() do
      local host = line:match("^%s*Host%s+(.+)")
      if host then
        for entry in host:gmatch("%S+") do
          if not entry:find("[*?!]") then
            table.insert(hosts, entry)
          end
        end
      end
    end
  end)
  f:close()
  if not ok then
    wezterm.log_warn("Error reading SSH config: " .. tostring(err))
  end
  return hosts
end

-- OrbStack VM detector
local function list_orb_vms()
  local vms = {}
  local ok, out = wezterm.run_child_process({ "/usr/local/bin/orb", "list", "-f", "json" })
  if not ok then return vms end
  if out == "" then return vms end
  local parse_ok, data = pcall(wezterm.json_parse, out)
  if not parse_ok or not data then
    wezterm.log_warn("Failed to parse orb list output")
    return vms
  end
  for _, vm in ipairs(data) do
    if vm.state == "running" then
      table.insert(vms, vm.name)
    end
  end
  return vms
end

-- Spawn functions for remote connections
-- Uses /bin/zsh -l -c to get proper PATH; inputs are validated by valid_remote_target
local function ssh_spawn(host)
  return {
    args = { "/bin/zsh", "-l", "-c",
      string.format("exec ssh -t '%s' 'tmux new-session -A -s main'", host) },
  }
end

local function orb_spawn(vm_name)
  return {
    args = { "/bin/zsh", "-l", "-c",
      string.format("orb -m '%s' bash -lc 'command -v tmux >/dev/null && exec tmux new-session -A -s main || exec $SHELL -l'", vm_name) },
  }
end

local function docker_spawn(container)
  return {
    args = { "/bin/zsh", "-l", "-c",
      string.format("exec docker exec -it '%s' sh -c 'command -v tmux >/dev/null && exec tmux new-session -A -s main || exec sh'", container) },
  }
end

-- Remote spawn dispatch table: prefix → spawn function
local remote_spawners = {
  ["ssh:"] = ssh_spawn,
  ["orb:"] = orb_spawn,
}

-- Docker: detect containers lazily via sub-picker to avoid blocking GUI
local function show_docker_picker(window, pane)
  local ok, out = wezterm.run_child_process({ "/Applications/OrbStack.app/Contents/MacOS/xbin/docker", "ps", "--format", "{{.Names}}" })
  if not ok or out == "" then
    wezterm.log_warn("No running Docker containers found")
    return
  end
  local choices = {}
  for name in out:gmatch("[^\n]+") do
    table.insert(choices, { label = name, id = "docker:" .. name })
  end
  window:perform_action(
    act.InputSelector({
      title = "Docker containers",
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(w, p, id)
        if not id then return end
        local container = id:sub(#"docker:" + 1)
        if valid_remote_target(container) then
          w:perform_action(
            act.SwitchToWorkspace({ name = id, spawn = docker_spawn(container) }),
            p
          )
        end
      end),
    }),
    pane
  )
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
  local desired = conf and conf.wezterm_theme or nil

  if overrides.color_scheme ~= desired then
    overrides.color_scheme = desired
    window:set_config_overrides(overrides)
  end
end)

-- Title bar: show workspace name
wezterm.on("format-window-title", function()
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
  -- Cmd+N: cycle through workspaces
  {
    key = "n",
    mods = "CMD",
    action = act.SwitchWorkspaceRelative(1),
  },
  -- Cmd+O: workspace picker — local tmux, SSH, OrbStack VMs, Docker containers
  {
    key = "o",
    mods = "CMD",
    action = wezterm.action_callback(function(window, pane)
      local ok, err = pcall(function()
        local wez_workspaces = wezterm.mux.get_workspace_names() or {}
        local active = window:active_workspace()

        local choices = {}
        local NAME_W = 24
        local n = 0

        local function add(label, id)
          n = n + 1
          table.insert(choices, { label = string.format("%2d. %s", n, label), id = id })
        end

        -- Local tmux sockets
        local uid_ok, uid_out = wezterm.run_child_process({ "id", "-u" })
        local sockets = {}
        if uid_ok then
          local uid = uid_out:gsub("%s+", "")
          local ls_ok, ls_out = wezterm.run_child_process({ "ls", "/tmp/tmux-" .. uid })
          if ls_ok then
            for name in ls_out:gmatch("[^\n]+") do
              sockets[name] = true
            end
          end
        end

        local seen = {}
        for _, ws in ipairs(wez_workspaces) do
          seen[ws] = true
          local status = ws == active and "(active)" or ""
          local tag = sockets[ws] and "[tmux]" or ""
          add(pad(ws, NAME_W) .. pad(status, 10) .. tag, ws)
        end

        for name, _ in pairs(sockets) do
          if not seen[name] then
            add(pad(name, NAME_W) .. pad("", 10) .. "[tmux]", name)
          end
        end

        -- SSH hosts
        local hosts = parse_ssh_hosts()
        for _, host in ipairs(hosts) do
          add(pad(host, NAME_W) .. pad("", 10) .. "[ssh]", "ssh:" .. host)
        end

        -- OrbStack VMs
        local vms = list_orb_vms()
        for _, vm in ipairs(vms) do
          add(pad(vm, NAME_W) .. pad("", 10) .. "[orb]", "orb:" .. vm)
        end

        -- Docker containers (lazy — opens sub-picker to avoid blocking)
        add(pad("Docker...", NAME_W) .. pad("", 10) .. "[docker]", "__docker__")

        -- New workspace
        table.insert(choices, { label = " +  New workspace...", id = "__new__" })

        window:perform_action(
          act.InputSelector({
            title = "Workspaces",
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
              elseif id == "__docker__" then
                show_docker_picker(inner_window, inner_pane)
              else
                -- Check remote spawners
                local handled = false
                for prefix, spawner in pairs(remote_spawners) do
                  if id:sub(1, #prefix) == prefix then
                    local target = id:sub(#prefix + 1)
                    if valid_remote_target(target) then
                      inner_window:perform_action(
                        act.SwitchToWorkspace({
                          name = id,
                          spawn = spawner(target),
                        }),
                        inner_pane
                      )
                    else
                      wezterm.log_warn("Invalid remote target: " .. tostring(target))
                    end
                    handled = true
                    break
                  end
                end
                if not handled then
                  switch_workspace(inner_window, inner_pane, id)
                end
              end
            end),
          }),
          pane
        )
      end)
      if not ok then
        wezterm.log_error("Workspace picker error: " .. tostring(err))
      end
    end),
  },
}

return config
