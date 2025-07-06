local plugins_cfg = {
  defaults = { lazy = true },
  install = { colorscheme = { 'onedark' } },

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
  {
    "rbong/vim-flog",
    lazy = true,
    cmd = { "Flog", "Flogsplit", "Floggit" },
    dependencies = {
      "tpope/vim-fugitive",
    },
  },
  { 'nvim-telescope/telescope.nvim' },
  -- { 'rcarriga/nvim-notify' }, -- just to stop prompting me to press ENTER on notifications

  -- Replace NvChad with individual plugins
  { 'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup({
        view = { width = 30 },
        filters = { dotfiles = false },
        disable_netrw = true,
        hijack_netrw = true,
      })
    end,
  },
  
  { 'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup({
        options = {
          diagnostics = "nvim_lsp",
          separator_style = "none",
          indicator_style = "none",
          show_buffer_close_icons = true,
          show_close_icon = true,
        }
      })
    end,
  },
  
  { 'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      require('luasnip.loaders.from_vscode').lazy_load()
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'nvim_lua' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },
  
  { 'neovim/nvim-lspconfig',
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require('lspconfig')
      
      lspconfig.pylsp.setup({ capabilities = capabilities })
      lspconfig.ts_ls.setup({ capabilities = capabilities })
      lspconfig.clangd.setup({ capabilities = capabilities })
      lspconfig.sourcekit.setup({
        cmd = { 'xcrun', 'sourcekit-lsp' },
        root_dir = require('lspconfig.util').root_pattern('*.xcodeproj', '*.xcworkspace', '.git'),
        capabilities = capabilities,
      })
    end,
  },
  
  { 'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end,
  },
  
  { 'folke/which-key.nvim',
    event = "VeryLazy",
    config = function()
      require('which-key').setup()
    end,
  },
  
  { 'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    config = function()
      require('ibl').setup({
        indent = { char = "│" },
        scope = { enabled = false },
      })
    end,
  },
  
  { 'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require('toggleterm').setup({
        size = 20,
        open_mapping = [[<c-\>]],
        direction = 'float',
        float_opts = {
          border = 'curved',
        },
      })
    end,
  },
  
  { 'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      require('onedark').setup({
        style = 'dark'
      })
      require('onedark').load()
    end,
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

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },

  -- used for tests only now
  { "nvim-lua/plenary.nvim", lazy = true },

  {
    'chrisbra/csv.vim',
    ft = { 'csv' }  -- load only for CSV files
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

