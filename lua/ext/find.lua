local TSC = require("telescope.builtin")

local make_entry = require('telescope.make_entry')
local utils = require "telescope.utils"
local NvimTree = require("nvim-tree.api")

local function hlgroup(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
  return name
end

local HL_GREY = hlgroup("TelescopeGrey", { fg = "#808080" })
local HL_COMMENT = hlgroup("TelescopeResultsComment", { fg = "#808080", italic = true })
local HL_NAMED_BUFFER = hlgroup("TelescopeNamedBuffer", { underline = true })
local HL_TEST = hlgroup("TelescopeTest", { fg = "green" })

local function split_path(path)
  local filename = vim.fn.fnamemodify(path, ":t")
  local dir = vim.fn.fnamemodify(path, ":h")
  dir = vim.fn.fnamemodify(dir, ":~:.")

  -- Handle path length
  dir = (dir == '.' and '' or dir) -- Handle '.' as the current directory
  dir = dir:gsub('/src/main/java', '/...') -- Replace the specific part of the path
  dir = dir:gsub('/src/test/java', '/...') -- Replace the specific part of the path
  dir = dir:gsub('/src/testFunctional/java', '/...') -- Replace the specific part of the path
  dir = dir:gsub('/src/functionalTest/java', '/...') -- Replace the specific part of the path

  dir = dir:gsub('/src/test/groovy', '/...') -- Replace the specific part of the path
  dir = dir:gsub('/src/testFunctional/groovy', '/...') -- Replace the specific part of the path
  dir = dir:gsub('/src/functionalTest/groovy', '/...') -- Replace the specific part of the path

  return filename, dir
end

local function add_offset(offset, obj)
  return { obj[1] + offset, obj[2] + offset }
end

local do_merge_styles = function(style1, style2, offset)
  if not style2 then
    return style1
  end

  for _, item in ipairs(style2) do
    item[1] = add_offset(offset, item[1])
    table.insert(style1, item)
  end

  return style1
end

local function merge_styles(base, hl_group, start, size, after)
  local new = { { { 0, size }, hl_group } }
  if not after then
    return do_merge_styles(base, new, start)
  else
    return do_merge_styles(new, base, start)
  end
end

local display_modified_path = function(entry)
  local hl_group, icon
  local _display, style = utils.transform_path({}, entry.value)
  local filename, dir = split_path(_display)

  local name = filename .. string.rep(" ", 20 - #filename) .. "  "
  local display, filenamelen, namelen, pathlen = string.format("%s%s", name, dir), #filename, #name, #dir

  display, hl_group, icon = utils.transform_devicons(entry.value, display)

  if hl_group then
    style = merge_styles(style, hl_group, #icon + 1, #icon + 1, true)
  end

  if string.find(display, "Test") or string.find(display, "Spec") then
    style = merge_styles(style, HL_TEST, #icon + 1, filenamelen)
  end

  style = merge_styles(style, HL_COMMENT, #icon + namelen + 1, pathlen)

  return display, style
end

function merge(t1, t2)
  -- Copy all fields from t2 into t1
  for k, v in pairs(t2) do
    t1[k] = v
  end
end

local function vertical_layout(prompt, other)
  local opts = {
    show_line = false,
    path_display = { "tail" },
    prompt_title = prompt,
    layout_strategy = 'vertical',
    layout_config = {
      preview_cutoff = 0, -- Ensures previews are not disabled for narrow windows
      preview_height = 0.5,
      vertical = {
        width = 0.8,
        prompt_position = "top",
        mirror = true
      }
    }
  }
  if other then
    merge(opts, other)
  end
  return opts
end

local find_words = function(literal)
  local text
  if literal then
    text = "Find Words"
  else
    text = "Grep Words (regex)"
  end
  local opt = vertical_layout(text, {
    path_display = function(_, path)
      local filename = vim.fn.fnamemodify(path, ":t")
      filename = filename .. string.rep(" ", 20 - #filename) .. "  "

      local filepath = vim.fn.fnamemodify(path, ":~:.")
      filepath = filepath:match("(.*/)") or filepath -- Remove everything after the last "/"

      local display, filenamelen, pathlen = string.format("%s%s", filename, filepath), #filename, #filepath
      local style = merge_styles({}, HL_COMMENT, filenamelen + 1, pathlen)

      return display, style
    end
  })

  local node = NvimTree.tree.get_node_under_cursor()
  if node and node.type == "directory" then
    opt.cwd = vim.fn.fnamemodify(node.absolute_path, ":h")
  end

  if literal then
    opt.additional_args = function()
      return { "--fixed-strings" }
    end
  end

  TSC.live_grep(opt)
end

local function files_history(cwd)
  local prompt
  if cwd then
    prompt = "Old Files"
  else
    prompt = "All Old Files"
  end

  TSC.oldfiles(vertical_layout(prompt, {
    only_cwd = cwd,
    entry_maker = function(entry)
      entry = make_entry.gen_from_file({})(entry)
      entry.display = display_modified_path
      return entry
    end,
  }))
end

return {

  HL_COMMENT = HL_COMMENT,
  HL_GREY = HL_GREY,
  HL_NAMED_BUFFER = HL_NAMED_BUFFER,
  vertical_layout = vertical_layout,

  split_path = split_path,

  words = function()
    find_words(false)
  end,

  words_literal = function()
    find_words(true)
  end,

  usages = function()
    TSC.lsp_references(vertical_layout("Find Usages", {
      include_declaration = false,
      -- entry_maker = function(entry)
      --   entry = make_entry.gen_from_quickfix({})(entry)
      --   entry.display = display_modified_path
      --   return entry
      -- end,
    }))
  end,

  impls = function()
    TSC.lsp_implementations(vertical_layout("Find Implementations"))
  end,

  files = function()
    TSC.find_files(vertical_layout("Find Files", {
      entry_maker = function(entry)
        entry = make_entry.gen_from_file({})(entry)
        entry.display = display_modified_path
        return entry
      end
    }))
  end,

  files_history = function() files_history(true) end,
  all_files_history = function() files_history(false) end,

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

