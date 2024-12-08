local TSC = require("telescope.builtin")

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local make_entry = require('telescope.make_entry')
local utils = require "telescope.utils"
local NvimTree = require("nvim-tree.api")

local HL_COMMENT = "TelescopeResultsComment"
local HL_TEST = "TelescopeTest"
vim.api.nvim_set_hl(0, HL_COMMENT, { fg = "#808080", italic = true })
vim.api.nvim_set_hl(0, HL_TEST, { fg = "green" })

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

  style = merge_styles(style, HL_COMMENT, #icon + namelen + 1, pathlen)

  return display, style
end

local function vertical(prompt)
  return {
    prompt_title = prompt,
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
end

return {

  HL_COMMENT = HL_COMMENT,

  words = function()
    local opt = vertical("Find Words")

    local node = NvimTree.tree.get_node_under_cursor()
    if node and node.type == "directory" then
      opt.cwd = vim.fn.fnamemodify(node.absolute_path, ":h")
    end

    TSC.live_grep(opt)
  end,

  usages = function()
    local opt = vertical("Find Usages")
    TSC.lsp_references(conf("LSP Usages"), {
      include_declaration = false,
      entry_maker = function(entry)
        entry = make_entry.gen_from_file({})(entry)
        entry.display = display_modified_path
        return entry
      end,
      layout_config = opt.layout_config,
      layout_strategy = opt.layout_strategy,
    })
  end,

  impls = function()
    TSC.lsp_implementations(conf("LSP impls"))
  end,

  files = function()
    local opts = vertical("Find Files")

    TSC.find_files({
      layout_config = {
        preview_width = 0 -- Disable preview pane
      },
      entry_maker = function(entry)
        entry = make_entry.gen_from_file({})(entry)
        entry.display = display_modified_path
        return entry
      end,
      layout_config = opts.layout_config,
      layout_strategy = opts.layout_strategy,
    })
  end,

  files_history = function()
    local opts = vertical("Old Files")

    TSC.oldfiles({
      only_cwd = true,
      entry_maker = function(entry)
        entry = make_entry.gen_from_file({})(entry)
        entry.display = display_modified_path
        return entry
      end,
      layout_config = opts.layout_config,
      layout_strategy = opts.layout_strategy,
    })
  end,

  testfile = function()
    local full_path = vim.fn.expand("%:p") -- Full path of the current file

    -- Replace "main" with "test" and "testFunctional"
    local test_path = full_path:gsub("/main/", "/test/")
    local test_functional_path = full_path:gsub("/main/", "/testFunctional/")

    -- Extract the base name and test possible file paths
    local file_name = vim.fn.fnamemodify(full_path, ":t:r") -- Base name without extension
    local extensions = { ".java", ".groovy" }
    local target_files = {}

    -- Check if files exist in the target paths
    for _, ext in ipairs(extensions) do
      local test_file = test_path:gsub("%.java$", ext)
      local test_functional_file = test_functional_path:gsub("%.java$", ext)

      if vim.loop.fs_stat(test_file) then
        table.insert(target_files, test_file)
      end
      if vim.loop.fs_stat(test_functional_file) then
        table.insert(target_files, test_functional_file)
      end
    end

    -- Handle results
    if #target_files == 0 then
      vim.notify("No matching test files found!", vim.log.levels.WARN)
    elseif #target_files == 1 then
      -- Open the single match
      vim.cmd("edit " .. target_files[1])
    else
      -- Prompt user to choose from multiple matches
      vim.ui.select(target_files, {
        prompt = "Select a file to open:",
        format_item = function(item)
          return vim.fn.fnamemodify(item, ":.")
        end,
      }, function(choice)
        if choice then vim.cmd("edit " .. choice) end
      end)
    end
  end,

}

