vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

vim.wo.number = true
vim.wo.relativenumber = true

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

-- Enable clipboard support
vim.o.clipboard = "unnamedplus"

-- Remap Ctrl-c to copy to the system clipboard
vim.api.nvim_set_keymap('v', '<leader>y>', '"+y', { noremap = true, silent = true })

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      require "options"
    end,
  },

  { import = "plugins" },
}, lazy_config)

require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

local lsp = require('lspconfig')
lsp.pyright.setup{}
lsp.tsserver.setup{}

