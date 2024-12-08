local TSC = require("telescope.builtin")

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local devicons = require("nvim-web-devicons")
local make_entry = require('telescope.make_entry')
local utils = require "telescope.utils"

vim.api.nvim_set_hl(0, "TelescopeResultsComment", { fg = "#808080", italic = true })
vim.api.nvim_set_hl(0, "TelescopeTest", { fg = "green" })

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
          -- highlight as a test
        end
        actions.select_default(prompt_bufnr)
      end)
      return true
    end,
  }
end

local function modify_path(path)
  local filename = vim.fn.fnamemodify(path, ":t")
  local dir = vim.fn.fnamemodify(path, ":h")
  dir = vim.fn.fnamemodify(dir, ":~:.")

  -- Handle path length
  dir = (dir == '.' and '')
    or (#dir <= 30 and dir)
    or string.format("%s...%s", string.sub(dir, 1, 20), string.sub(dir, -20))

  local name = filename .. string.rep(" ", 20 - #filename) .. "  "
  return string.format("%s%s", name, dir), #name, #dir
end

local function merge_styles(base, hl_group, start, size, after)
  local new = { { { 0, size }, hl_group } }
  if not after then
    return utils.merge_styles(base, new, start)
  else
    return utils.merge_styles(new, base, start)
  end
end

local display_modified_path = function(entry)
  local hl_group, icon
  local _display, style = utils.transform_path({}, entry.value)
  local display, namelen, pathlen = modify_path(_display)

  display, hl_group, icon = utils.transform_devicons(entry.value, display)

  if hl_group then
    style = merge_styles(style, hl_group, #icon + 1, #icon + 1, true)
  end

  style = merge_styles(style, "TelescopeResultsComment", #icon + namelen + 1, pathlen)

  return display, style
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
      entry_maker = function(entry)
        entry = make_entry.gen_from_file({})(entry)
        entry.display = display_modified_path
        return entry
      end,
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
      entry_maker = function(entry)
        entry = make_entry.gen_from_file({})(entry)
        entry.display = display_modified_path
        return entry
      end,
      layout_config = vertical.layout_config,
      layout_strategy = vertical.layout_strategy,
    })
  end,

  files_history = function()
    TSC.oldfiles({
      only_cwd = true,
      entry_maker = function(entry)
        entry = make_entry.gen_from_file({})(entry)
        entry.display = display_modified_path
        return entry
      end,
      layout_config = vertical.layout_config,
      layout_strategy = vertical.layout_strategy,
    })
  end,

}

