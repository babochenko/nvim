vim.g.base46_cache = vim.fn.stdpath 'data' .. '/nvchad/base46/'
vim.g.mapleader = ' '
vim.opt.fixendofline = false

vim.defer_fn(function()
  vim.opt.clipboard = 'unnamedplus'
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.smoothscroll = true
  vim.opt.timeoutlen = 200
end, 0)


require 'plugins'
require 'autocmd'
require 'ui'
require 'ext/mymath'

vim.schedule(function()
  require 'mappings'
  require 'python'
end)

if #vim.api.nvim_list_uis() == 0 then return end

local lsp = require 'lspconfig'

-- local venv_path = vim.fn.expand '~/Developer/venv'
lsp.pylsp.setup{
  -- settings = {
  --   python = {
  --     pythonPath = vim.fn.isdirectory(venv_path) and (venv_path .. '/bin/python') or vim.fn.exepath('python'),
  --     analysis = {
  --       useLibraryCodeForTypes = true,
  --     }
  --   }
  -- }
}

lsp.ts_ls.setup{}
lsp.clangd.setup{}

lsp.sourcekit.setup({
  cmd = { 'xcrun', 'sourcekit-lsp' },
  root_dir = require('lspconfig.util').root_pattern('*.xcodeproj', '*.xcworkspace', '.git'),
})

-- transparency
vim.cmd [[
  highlight Normal      ctermbg=none guibg=none
  highlight NormalNC    ctermbg=none guibg=none
  highlight SignColumn  ctermbg=none guibg=none
  highlight VertSplit   ctermbg=none guibg=none
  highlight StatusLine  ctermbg=none guibg=none
  highlight LineNr      ctermbg=none guibg=none
  highlight EndOfBuffer ctermbg=none guibg=none
]]


