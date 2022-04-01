if not pcall(require, 'fzf') then return end

local core = require('fzf-lua.core')
local config = require "fzf-lua.config"
local libuv = require "fzf-lua.libuv"
local win = require "fzf-lua.win"

local M = {}

local function parent_dir(file) return vim.fn.fnamemodify(file, ':p:h') end

M.projects = function(opts)
  opts = config.normalize_opts(opts, config.globals.files)
  opts.prompt = 'Projects❯ '
  opts.file_icons = false
  opts.color_icons = false
  opts.git_icons = false

  opts.autoclose = false;
  opts.actions = {
    ['default'] = function(selected)
      local project = core.my_make_entry_file(opts, selected[1])
      win.win_leave()
      return require('fzf-lua').my_files({cwd = project})
    end,
    ['ctrl-c'] = function() win.win_leave() end
  }

  opts.fzf_fn = require("project_nvim").get_recent_projects()
  return core.fzf_files(opts)
end

M.file_explorer = function(opts)
  opts = config.normalize_opts(opts, config.globals.files)
  if not opts then return end
  opts.prompt = 'File Explorer❯ '
  opts.file_icons = false
  opts.color_icons = false
  opts.git_icons = false

  local dir = parent_dir(vim.fn.fnamemodify(opts.startdir or '%', ':p'))
  local cmd = string.format("ls --color -A %s", vim.fn.fnamemodify(dir, ':p'))
  opts.fzf_opts['--header'] = dir

  opts.autoclose = false;
  opts.actions = {
    ['default'] = function(selected)
      local item = core.make_entry_file(opts, selected[1])
      local path = string.format("%s/%s", dir, item)
      if vim.fn.isdirectory(path) == 1 then
        opts.startdir = path
        M.file_explorer(opts)
      else
        win.win_leave()
        local actions = require "fzf-lua.actions"
        selected[1] = path
        actions.file_edit(selected, opts)
      end
    end,

    ['ctrl-w'] = function()
      local path = string.format("%s/%s", dir, "..")
      opts.startdir = path
      return M.file_explorer(opts)
    end,
    ['ctrl-c'] = function() win.win_leave() end
  }

  opts.fzf_fn = libuv.spawn_nvim_fzf_cmd({
    cmd = cmd,
    cwd = opts.cwd,
    pid_cb = opts._pid_cb
  }, function(x) return core.make_entry_file(opts, x) end)

  return core.fzf_files(opts)
end

return M
