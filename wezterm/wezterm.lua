local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Palette name → wezterm color_scheme (from chezmoidata)
local palette_to_wezterm = {
  ["catppuccin_mocha"] = "Catppuccin Mocha",
  ["dracula"] = "Dracula (Official)",
  ["monokai"] = "Monokai (base16)",
  ["tokyo_night"] = "Tokyo Night",
}

-- Determine wezterm theme for a workspace name
local function workspace_theme(name)
  -- OrbStack VMs → linux default theme
  if name:find("^orb:") then
    return palette_to_wezterm["monokai"]
  end
  -- Default workspace and remote workspaces (ssh:, docker:, etc.) use the base color_scheme
  if name == "default" or name:find(":") then
    return nil
  end
  -- Local tmux socket named after a palette (e.g. "tokyo_night")
  return palette_to_wezterm[name]
end

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

-- OrbStack VM detector (returns list of {name, user} tables)
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
      local user = vm.config and vm.config.default_username or nil
      table.insert(vms, { name = vm.name, user = user })
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

local function orb_spawn(vm_name, user)
  local user_flag = (user and valid_remote_target(user)) and string.format("-u '%s' ", user) or ""
  return {
    args = { "/bin/zsh", "-l", "-c",
      string.format("orb run -m '%s' %sbash -lc 'command -v tmux >/dev/null && exec tmux new-session -A -s main || exec $SHELL -l'", vm_name, user_flag) },
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
}

-- Docker: detect containers lazily via sub-picker to avoid blocking GUI
local function show_docker_picker(window)
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
      action = wezterm.action_callback(function(w, _p, id)
        if not id then return end
        local container = id:sub(#"docker:" + 1)
        if valid_remote_target(container) then
          w:perform_action(
            act.SwitchToWorkspace({ name = id, spawn = docker_spawn(container) }),
            w:mux_window():active_pane()
          )
        end
      end),
    }),
    window:mux_window():active_pane()
  )
end

-- Build spawn args for a tmux socket
local function tmux_spawn(socket_name)
  local session = socket_name == "default" and "main" or socket_name
  return {
    args = {
      "/bin/zsh", "-l", "-c",
      string.format("~/.config/wezterm/start-tmux.sh '%s' '%s'", socket_name, session),
    },
  }
end

-- Switch to a workspace, starting its tmux socket if needed
local function switch_workspace(window, _pane, name)
  -- Use fresh active pane — captured pane may become stale after InputSelector
  local pane = window:mux_window():active_pane()
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
config.default_prog = tmux_spawn("default").args
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

-- Apply per-workspace theme overrides
wezterm.on("update-status", function(window)
  local overrides = window:get_config_overrides() or {}
  local desired = workspace_theme(window:active_workspace())
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
        local orb_users = {}
        for _, vm in ipairs(vms) do
          orb_users[vm.name] = vm.user
          add(pad(vm.name, NAME_W) .. pad("", 10) .. "[orb]", "orb:" .. vm.name)
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
            action = wezterm.action_callback(function(inner_window, _inner_pane, id)
              if not id then return end

              if id == "__new__" then
                inner_window:perform_action(
                  act.PromptInputLine({
                    description = "New workspace name (= tmux socket name):",
                    action = wezterm.action_callback(function(w, _p, line)
                      if not valid_workspace_name(line) then
                        wezterm.log_warn("Invalid workspace name: " .. tostring(line))
                        return
                      end
                      switch_workspace(w, nil, line)
                    end),
                  }),
                  inner_window:mux_window():active_pane()
                )
              elseif id == "__docker__" then
                show_docker_picker(inner_window)
              else
                -- Check remote spawners
                local handled = false
                -- OrbStack VMs (need user param)
                local orb_prefix = "orb:"
                if id:sub(1, #orb_prefix) == orb_prefix then
                  local vm_name = id:sub(#orb_prefix + 1)
                  if valid_remote_target(vm_name) then
                    inner_window:perform_action(
                      act.SwitchToWorkspace({
                        name = id,
                        spawn = orb_spawn(vm_name, orb_users[vm_name]),
                      }),
                      inner_window:mux_window():active_pane()
                    )
                  end
                  handled = true
                end
                -- Other remote spawners (ssh, etc.)
                if not handled then
                  for prefix, spawner in pairs(remote_spawners) do
                    if id:sub(1, #prefix) == prefix then
                      local target = id:sub(#prefix + 1)
                      if valid_remote_target(target) then
                        inner_window:perform_action(
                          act.SwitchToWorkspace({
                            name = id,
                            spawn = spawner(target),
                          }),
                          inner_window:mux_window():active_pane()
                        )
                      else
                        wezterm.log_warn("Invalid remote target: " .. tostring(target))
                      end
                      handled = true
                      break
                    end
                  end
                end
                if not handled then
                  switch_workspace(inner_window, nil, id)
                end
              end
            end),
          }),
          window:mux_window():active_pane()
        )
      end)
      if not ok then
        wezterm.log_error("Workspace picker error: " .. tostring(err))
      end
    end),
  },
}

return config
