vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

vim.defer_fn(function()
  vim.opt.clipboard = "unnamedplus"
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.smoothscroll = true
  vim.opt.timeoutlen = 200
end, 0)

dofile(vim.g.base46_cache .. "statusline")

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function() vim.bo.commentstring = "-- %s" end,
})

require "plugins"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

local lsp = require('lspconfig')
lsp.pyright.setup{}
-- lsp.tsserver.setup{}
lsp.clangd.setup{}

