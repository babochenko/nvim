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

require 'plugins'
require 'autocmd'
require 'ui'
require 'ext/mymath'

vim.schedule(function()
  require 'mappings'
end)

local lsp = require 'lspconfig'

local venv_path = vim.fn.expand '~/Developer/venv'
lsp.pyright.setup{
  settings = {
    python = {
      pythonPath = vim.fn.isdirectory(venv_path) and (venv_path .. '/bin/python') or vim.fn.exepath('python'),
      analysis = {
        useLibraryCodeForTypes = true,
      }
    }
  }
}

lsp.ts_ls.setup{}
lsp.clangd.setup{}

