local TSC = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local devicons = require("nvim-web-devicons")

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

local function global_entry_maker(entry)
  local path = entry.path or entry.filename or entry.value or entry
  local filename = vim.fn.fnamemodify(path, ":t")
  local dir = vim.fn.fnamemodify(path, ":h")
  local icon, icon_hl = devicons.get_icon_by_filetype(vim.fn.fnamemodify(filename, ":e"), { default = true })

  -- Handle path length
  dir = (dir == '.' and '')
    or (#dir <= 30 and dir)
    or string.format("%s...%s", string.sub(dir, 1, 20), string.sub(dir, -20))

  local display_icon = icon and (icon .. " ") or ""
  local padded_filename = filename .. string.rep(" ", 30 - #filename)

  return {
    value = path,
    display = string.format("%s%s  %s", display_icon, padded_filename, dir),
    ordinal = filename,
    path = path,
    icon = icon,
    icon_hl = icon_hl,
  }
end

local vertical = {
  layout_strategy = "vertical",
  layout_config = {
    vertical = {
      width = 0.8,
      preview_height = 0.5,
      prompt_position = "top",
      mirror = true
    }
  }
}

return {

  goto_usages = function()
    TSC.lsp_references(conf("LSP Usages"), {
      include_declaration = false,
      entry_maker = global_entry_maker,
      layout_config = vertical.layout_config,
      layout_strategy = vertical.layout_strategy,
    })
  end,

  goto_implementations = function()
    TSC.lsp_implementations(conf("LSP impls"))
  end,

  find_files_default = function()
    TSC.find_files({
      layout_config = {
        preview_width = 0 -- Disable preview pane
      },
      entry_maker = global_entry_maker,
      layout_config = vertical.layout_config,
      layout_strategy = vertical.layout_strategy,
    })
  end,

  files_history = function()
    TSC.oldfiles({
      only_cwd = true,
      entry_maker = global_entry_maker,
      layout_config = vertical.layout_config,
      layout_strategy = vertical.layout_strategy,
    })
  end,

}

