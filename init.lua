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

  local MARKS = require 'marks'
  MARKS.load_marks()
  autocmd("VimLeavePre", { callback = MARKS.save_marks, })
  autocmd("BufReadPost", { callback = MARKS.on_buf_read, })
end)

vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local message = result.message or ""
  local trimmed_message = message
  if #message > 80 then
    trimmed_message = message:sub(1, 77) .. "..."
  end
  vim.notify(client.name .. ": " .. trimmed_message, vim.log.levels.INFO)
end

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

lsp.jdtls.setup {
  settings = {
    java = {
      codeGeneration = {
        toString = {
          template = "${object.className} [${member.name()}=${member.value}, ]",
          useFullyQualifiedNames = false, -- Use short names for fields
          skipNullValues = false, -- Include null values in the output
          listArrayContents = true, -- Print array contents if fields are arrays
        },
      },
      imports = {
        order = {
          "com",
          "org",
          "javax",
          "java",             -- Regular imports
          "#",                -- Static imports first
        },
        staticGroups = true,  -- Group static imports together
      },
    },
  },
}

