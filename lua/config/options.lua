-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"

local uv = vim.uv or vim.loop

local function path_exists(path)
  return path and uv.fs_stat(path) ~= nil
end

local function find_pixi_root(start_path)
  if not start_path or start_path == "" then
    start_path = vim.fn.getcwd()
  end

  local project_root = vim.env.PIXI_PROJECT_ROOT
  if project_root and path_exists(project_root .. "/pixi.toml") then
    return project_root
  end

  local manifest = vim.fs.find("pixi.toml", {
    path = start_path,
    upward = true,
    limit = 1,
  })[1]

  if manifest then
    return vim.fs.dirname(manifest)
  end
end

local function pixi_environment_for(root_dir)
  local pixi_root = find_pixi_root(root_dir)
  if not pixi_root then
    return nil
  end

  local candidate_names = {
    vim.env.PIXI_ENVIRONMENT_NAME,
    vim.env.CONDA_DEFAULT_ENV,
    "default",
  }

  for _, environment_name in ipairs(candidate_names) do
    if environment_name and environment_name ~= "" then
      local environment_dir = pixi_root .. "/.pixi/envs/" .. environment_name
      if path_exists(environment_dir .. "/bin/python") then
        return pixi_root, environment_dir, environment_name
      end
    end
  end

  local matches = vim.fn.globpath(pixi_root .. "/.pixi/envs", "*/bin/python", false, true)
  if type(matches) == "table" and #matches > 0 then
    table.sort(matches)
    local environment_dir = vim.fs.dirname(vim.fs.dirname(matches[1]))
    if path_exists(environment_dir .. "/bin/python") then
      return pixi_root, environment_dir, vim.fs.basename(environment_dir)
    end
  end

  return pixi_root
end

local function python_path_for(root_dir)
  -- Use the environment inherited from the shell that launched Neovim.
  local conda_prefix = vim.env.CONDA_PREFIX
  if conda_prefix and conda_prefix ~= "" then
    local conda_python = conda_prefix .. "/bin/python"
    if path_exists(conda_python) then
      return conda_python
    end
  end

  local _, environment_dir = pixi_environment_for(root_dir)
  if environment_dir then
    return environment_dir .. "/bin/python"
  end

  local system_python = vim.fn.exepath("python3")
  if system_python ~= "" then
    return system_python
  end

  return "python"
end

local pyright_root_markers = { "pixi.toml", "pyrightconfig.json", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" }

vim.lsp.config("pyright", {
  cmd = function(dispatchers, config)
    local root_dir = config and config.root_dir or vim.fn.getcwd()
    local _, environment_dir = pixi_environment_for(root_dir)
    local server = vim.fn.exepath("pyright-langserver")

    -- Prefer the project's server when installed; otherwise use the shared server.
    if environment_dir and vim.fn.executable(environment_dir .. "/bin/pyright-langserver") == 1 then
      server = environment_dir .. "/bin/pyright-langserver"
    end

    return vim.lsp.rpc.start({ server, "--stdio" }, dispatchers, { cwd = root_dir })
  end,
  root_markers = pyright_root_markers,
  settings = {
    pyright = {
      disableTaggedHints = true,
    },
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
  on_init = function(client)
    local root_dir = client.config and client.config.root_dir or vim.fn.getcwd()
    local selected_python = python_path_for(root_dir)

    client.config.settings = client.config.settings or {}
    client.config.settings.python = client.config.settings.python or {}
    client.config.settings.python.pythonPath = selected_python
    client.config.settings.python.defaultInterpreterPath = selected_python
    client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })

    vim.schedule(function()
      vim.notify(
        "🐍 Pyright 啟動！\nPython: " .. selected_python,
        vim.log.levels.INFO,
        { title = "LSP Python Environment" }
      )
    end)
  end,
})

vim.lsp.enable("pyright")

local has_osc52, osc52 = pcall(require, "vim.ui.clipboard.osc52")
local is_remote = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil

-- Use normal Vim registers for yy/p to avoid the "No provider" error in SSH sessions.
-- If OSC 52 is available and the terminal supports it, we still try to sync yank
-- content to the local clipboard after the yank completes.
vim.opt.clipboard = ""

if has_osc52 and is_remote then
  local augroup = vim.api.nvim_create_augroup("osc52_remote_yank", { clear = true })
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
      if vim.v.event.operator ~= "y" then
        return
      end

      local reg = vim.v.event.regname ~= "" and vim.v.event.regname or ""
      local text = vim.fn.getreg(reg)

      if text and text ~= "" then
        pcall(function()
          osc52.copy("+")(text)
          osc52.copy("*")(text)
        end)
      end
    end,
  })
end