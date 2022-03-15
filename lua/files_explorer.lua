if not pcall(require, 'fzf') then return end

local core = require('fzf-lua.core')
local config = require "fzf-lua.config"
local actions = require "fzf-lua.actions"
local helpers = require("fzf.helpers")

local M = {}

local function get_bookmarks(files, opts)
  opts = opts or {}
  local bookmarks = {}

  for _, file in ipairs(files) do
    for _, line in ipairs(vim.fn['bm#all_lines'](file)) do
      local bookmark = vim.fn['bm#get_bookmark_by_line'](file, line)

      local text = bookmark.annotation ~= "" and "Annotation: " ..
                       bookmark.annotation or bookmark.content
      if text == "" then text = "(empty line)" end

      local only_annotated = opts.only_annotated or false

      if not (only_annotated and bookmark.annotation == "") then
        table.insert(bookmarks, {
          filename = file,
          lnum = tonumber(line),
          col = 1,
          text = text,
          sign_idx = bookmark.sign_idx
        })
      end
    end
  end

  return bookmarks
end

M.show = function()

  coroutine.wrap(function()
    local opts = config.normalize_opts({}, config.globals.files)
    opts.prompt = 'File Explorer❯ '
    opts.actions = {}
    opts.actions['default'] = function(selected)
      local item = {}
      if selected[1] == "" then
        item = items[selected[2]]
      else
        item = items[selected[1]]
      end
      vim.cmd(string.format('e +%d  %s', item.lnum, item.filename))
    end

    local cmd = "ls -a"
    while true do
      local selected = core.fzf(opts, cmd, core.build_fzf_cli(opts),
                                config.globals.winopts)
      if vim.fn.isdirectory(selected[1]) == 1 then
        cmd = "ls .. -a"
      else
        break
      end
    end

  end)()
end

return M
