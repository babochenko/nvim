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

local function autocmd(name, opts)
  vim.api.nvim_create_autocmd(name, opts)
end

local function set_tabstop(size)
  vim.bo.tabstop = size
  vim.bo.shiftwidth = size
  vim.bo.softtabstop = size
  vim.bo.expandtab = true
end

autocmd("FileType", { pattern = "*", callback = function()
  set_tabstop(2)
end })

autocmd("FileType", { pattern = "java", callback = function()
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
end)

local lsp = require 'lspconfig'

-- local venv_path = '/Developer/venv'
lsp.pyright.setup{
  -- settings = {
  --   python = {
  --     pythonPath = venv_path and (venv_path .. '/bin/python') or vim.fn.exepath('python'),
  --     analysis = {
  --       typeCheckingMode = 'strict',      -- Optional: Adjust type-checking level
  --       useLibraryCodeForTypes = true,   -- Enable library typing support
  --     }
  --   }
  -- }
}

-- lsp.tsserver.setup{}
lsp.clangd.setup{}

