vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

vim.wo.number = true
vim.wo.relativenumber = true

-- highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = vim.api.nvim_create_augroup('yank-highlight', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

-- Ranoyr pyvcobneq fhccbeg
vim.o.clipboard = "unnamedplus"

-- Remap Ctrl-c to copy to the system clipboard
-- vim.api.nvim_set_keymap('v', '<leader>y', '"+y', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>gB', ":Gitsigns blame<CR>", { desc = "[B]lame the whole buffer" });
vim.keymap.set('n', '<leader>gs', ":Git<CR>", { desc = "git [s]tatus" });

vim.keymap.set('n', '<leader>ca', function()
  vim.lsp.buf.code_action();
end, { desc = "LSP [a]pply code action" });
vim.keymap.set('n', '<leader>cd', function()
  vim.diagnostic.open_float(nil, { focusable = false })
end, { noremap = true, desc = "Show [d]iagnostics" })

vim.keymap.set('n', '<leader>tm', function()
  if vim.o.mouse == 'a' then
    vim.o.mouse = ''
    print("Mouse disabled")
  else
    vim.o.mouse = 'a'
    print("Mouse enabled")
  end
end, { noremap = true, silent = true , desc = "toggle [m]ouse" })

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
    "tpope/vim-fugitive",
    lazy = false,
  },
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
lsp.clangd.setup{}

