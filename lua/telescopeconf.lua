local TSC = require("telescope.builtin")

local function conf(prompt)
  return {
    show_line = false,      -- Show line preview
    layout_strategy = "horizontal", -- Horizontal layout
    layout_config = {
      preview_width = 0.6, -- Preview window width
    },
    path_display = { "tail" },
    prompt_title = prompt,
  }
end

return {

  goto_usages = function() TSC.lsp_references(conf("LSP Usages")) end,
  goto_implementations = function() TSC.lsp_implementations(conf("LSP impls")) end,

  files_history = function()
    TSC.oldfiles { only_cwd = false }
  end,

}

