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
        live_filter = {
          prefix = "[FILTER]: ",
          always_show_folders = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
          },
        },
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
          indicator = {
            style = "none",
          },
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = false,
          enforce_regular_tabs = true,
          always_show_bufferline = true,
        },
        highlights = {
          separator = {
            fg = {attribute = "bg", highlight = "TabLine"},
            bg = {attribute = "bg", highlight = "TabLine"},
          },
          separator_selected = {
            fg = {attribute = "bg", highlight = "Normal"},
            bg = {attribute = "bg", highlight = "Normal"},
          },
          separator_visible = {
            fg = {attribute = "bg", highlight = "TabLine"},
            bg = {attribute = "bg", highlight = "TabLine"},
          },
        },
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
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require('lspconfig')

      -- Add on_attach function for keybindings
      local on_attach = function(client, bufnr)
        local opts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      end

      lspconfig.pylsp.setup({ 
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = { enabled = false },
              mccabe = { enabled = false },
              pyflakes = { enabled = false },
              jedi_completion = { fuzzy = true },
              jedi_hover = { enabled = true },
              jedi_references = { enabled = true },
              jedi_signature_help = { enabled = true },
              jedi_symbols = { enabled = true, all_scopes = true },
            },
          },
        },
        before_init = function(_, config)
          -- Auto-detect virtual environment
          local venv_path = os.getenv("VIRTUAL_ENV")
          if venv_path then
            config.settings.pylsp.plugins.jedi = {
              environment = venv_path .. "/bin/python"
            }
          end
        end,
      })
      lspconfig.ts_ls.setup({ 
        capabilities = capabilities,
        on_attach = on_attach,
      })
      lspconfig.clangd.setup({ 
        capabilities = capabilities,
        on_attach = on_attach,
      })
      lspconfig.sourcekit.setup({
        cmd = { 'xcrun', 'sourcekit-lsp' },
        root_dir = require('lspconfig.util').root_pattern('*.xcodeproj', '*.xcworkspace', '.git'),
        capabilities = capabilities,
        on_attach = on_attach,
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

