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
    local bookmarkes = get_bookmarks(vim.fn['bm#all_files'](), nil)

    local items = {}
    for _, bookmark in pairs(bookmarkes) do
      setmetatable(bookmark, {
        __tostring = function(table)
          return string.format("%s         %s:%d", table.text, table.filename,
                               table.lnum)
        end
      })

      table.insert(items, bookmark)
      items[tostring(bookmark)] = bookmark
    end

    local opts = config.normalize_opts({}, config.globals.files)
    opts.prompt = 'Bookmarks❯ '
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

    local selected = core.fzf(opts, items, core.build_fzf_cli(opts),
                              config.globals.winopts)
    actions.act(opts.actions, selected)
  end)()
end

return M
