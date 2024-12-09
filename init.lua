vim.g.base46_cache = vim.fn.stdpath 'data' .. '/nvchad/base46/'
vim.g.mapleader = ' '

vim.defer_fn(function()
  vim.opt.clipboard = 'unnamedplus'
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.smoothscroll = true
  vim.opt.timeoutlen = 200
end, 0)

dofile(vim.g.base46_cache .. 'statusline')

local function set_tabstop(size)
  vim.bo.tabstop = size
  vim.bo.shiftwidth = size
  vim.bo.softtabstop = size
  vim.bo.expandtab = true
end

local function autocmd(name, opts)
  vim.api.nvim_create_autocmd(name, opts)
end

autocmd("FileType", { pattern = "*", callback = function()
  set_tabstop(2)
end })

autocmd("FileType", { pattern = { "java", "groovy" }, callback = function()
  set_tabstop(4)
end })

autocmd('FileType', { pattern = 'sql', callback = function()
  vim.bo.commentstring = '-- %s'
end })

autocmd('TextYankPost', { callback = function()
  vim.highlight.on_yank()
end })

require 'plugins'
require 'nvchad.autocmds'

vim.schedule(function()
  require 'mappings'

  local MARKS = require 'ext/marks'
  MARKS.load_marks()
  autocmd("VimLeavePre", { callback = MARKS.save_marks, })
  autocmd("BufReadPost", { callback = MARKS.on_buf_read, })
end)

vim.diagnostic.config({
  virtual_text = false,  -- Disable inline virtual text
  signs = true,          -- Keep gutter signs
  underline = true,      -- Keep underline
  update_in_insert = false, -- Disable updates in insert mode
  severity_sort = true,  -- Sort by severity
  float = { border = "rounded" }, -- Customize floating windows
})

require('telescope').setup {
  defaults = {
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }, -- Customize border style
    win_options = {
      winblend = 10, -- Add transparency if desired
    },
    border = true, -- Enable the border
  }
}
vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#657088", bg = "#1c1f26" })

