local TSC = require("telescope.builtin")

local conf = {
  show_line = true,      -- Show line preview
  layout_strategy = "horizontal", -- Horizontal layout
  layout_config = {
    preview_width = 0.6, -- Preview window width
  },
  prompt_title = "LSP Usages",
}

return {

  goto_usages = function() TSC.lsp_references(conf) end,
  goto_implementations = function() TSC.lsp_implementations(conf) end,

  files_history = function()
    TSC.oldfiles { only_cwd = false }
  end,

}

