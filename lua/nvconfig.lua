---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",
  integrations = {},
  -- hl_override = {
  --   Comment = { italic = true },
  --   ["@comment"] = { italic = true },
  -- },
}

M.ui = {
  cmp = {
    icons_left = true,
    lspkind_text = true,
    style = "default",
  },
  telescope = { style = "borderless" },
  statusline = {
    theme = "default",
    separator_style = "default",
  },
  tabufline = {
    enabled = true,
    lazyload = true,
    order = { "treeOffset", "buffers", "tabs", "btns" },
    modules = {
      bufwidth = 22,
    },
  },
}

M.nvdash = {
  load_on_startup = false,
}

M.lsp = {
  signature = true,
}

M.colorify = {
  enabled = false,
  mode = "virtual",
}

M.term = {
  winopts = { winhl = "Normal:term,WinSeparator:WinSeparator" },
  sizes = { sp = 0.3, vsp = 0.2 },
  float = {
    relative = "editor",
    row = 0.3,
    col = 0.25,
    width = 0.5,
    height = 0.4,
    border = "single",
  },
}

return M