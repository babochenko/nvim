local plugins_cfg = {
  defaults = { lazy = true },
  install = { colorscheme = { 'nvchad' } },

  ui = {
    icons = {
      ft = '',
      lazy = '󰂠 ',
      loaded = '',
      not_loaded = '',
    },
  },

  performance = {
    rtp = {
      disabled_plugins = {
        '2html_plugin',
        'tohtml',
        'getscript',
        'getscriptPlugin',
        'gzip',
        'logipat',
        'netrw',
        'netrwPlugin',
        'netrwSettings',
        'netrwFileHandlers',
        'matchit',
        'tar',
        'tarPlugin',
        'rrhelper',
        'spellfile_plugin',
        'vimball',
        'vimballPlugin',
        'zip',
        'zipPlugin',
        'tutor',
        'rplugin',
        'syntax',
        'synmenu',
        'optwin',
        'compiler',
        'bugreport',
        'ftplugin',
      },
    },
  },
}

function EnsureLazy()
  local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

  if not vim.loop.fs_stat(lazypath) then
    local repo = 'https://github.com/folke/lazy.nvim.git'
    vim.fn.system { 'git', 'clone', '--filter=blob:none', repo, '--branch=stable', lazypath }
  end

  vim.opt.rtp:prepend(lazypath)

  return require 'lazy'
end

EnsureLazy().setup({
  { 'mfussenegger/nvim-jdtls' },

  { 'tpope/vim-fugitive', lazy = false, },
  { 'nvim-telescope/telescope.nvim' },

  { 'NvChad/NvChad', lazy = false,
    branch = 'v2.5',
    import = 'nvchad.plugins',
    config = function() require 'nvchad.options' end,
  },

  { 'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },

  { 'stevearc/conform.nvim',
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          lua = { 'stylua' },
          -- css = { 'prettier' },
          -- html = { 'prettier' },
        },

        -- format_on_save = {
        --   -- These options will be passed to conform.format()
        --   timeout_ms = 500,
        --   lsp_fallback = true,
        -- },
      }
    end,
  },

  { 'nvim-treesitter/nvim-treesitter',
  	opts = {
  		ensure_installed = { 'vim', 'lua', 'vimdoc', 'html', 'css' },
  	},
  },

  -- These are some examples, uncomment them if you want to see them work!
  -- {
  --   'neovim/nvim-lspconfig',
  --   config = function()
  --     require('nvchad.configs.lspconfig').defaults()
  --     require 'configs.lspconfig'
  --   end,
  -- },
  --
  -- {
  -- 	'williamboman/mason.nvim',
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			'lua-language-server', 'stylua',
  -- 			'html-lsp', 'css-lsp' , 'prettier'
  -- 		},
  -- 	},
  -- },
  --
}, plugins_cfg)

