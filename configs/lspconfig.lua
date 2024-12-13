local configs = require("plugins.configs.lspconfig")
local on_attach = configs.on_attach
local capabilities = configs.capabilities

local lsp = require("lspconfig")

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

lsp.tsserver.setup{}
lsp.clangd.setup{}

-- JDTLS configuration for Java and Groovy
lsp.jdtls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "java", "groovy" },
  settings = {
    java = {
      codeGeneration = {
        toString = {
          template = "${object.className} [${member.name()}=${member.value}, ]",
          useFullyQualifiedNames = false,
          skipNullValues = false,
          listArrayContents = true,
        },
      },
      imports = {
        order = {
          "com",
          "org",
          "javax",
          "java",
          "#",
        },
        staticGroups = true,
      },
    },
  },
}

