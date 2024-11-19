local TSC = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function conf(prompt)
  return {
    show_line = false,      -- Show line preview
    layout_strategy = "horizontal", -- Horizontal layout
    layout_config = {
      preview_width = 0.6, -- Preview window width
    },
    path_display = { "tail" },
    prompt_title = prompt,
    attach_mappings = function(_, map)
      map('i', '<CR>', function(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if entry and entry.filename and (entry.filename:match("Test") or entry.filename:match("Spec")) then
          vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = "green" })
        end
        actions.select_default(prompt_bufnr)
      end)
      return true
    end,
  }
end

return {

  goto_usages = function() TSC.lsp_references(conf("LSP Usages")) end,

  goto_implementations = function() TSC.lsp_implementations(conf("LSP impls")) end,

  files_history = function()
    TSC.oldfiles { only_cwd = true }
  end,

}

