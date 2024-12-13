-- inspired by https://github.com/chentoast/marks.nvi pickers = require('telescope.pickers')marks
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local conf = require('telescope.config').values
local previewers = require('telescope.previewers')
local pickers = require "telescope.pickers"
local entry_display = require "telescope.pickers.entry_display"
local strings = require "plenary.strings"
local utils = require "telescope.utils"

local Find = require 'ext/find'

local marks_file = vim.fn.expand("~/.local/share/nvim/marks.json") -- File to save marks
local global_marks = {} -- Stores all marks with file, line, and optional name

local icon, _ = utils.get_devicons("fname", false)
local icon_width = strings.strdisplaywidth(icon)

local function save_marks()
  local json = vim.fn.json_encode(global_marks)
  if json and #json > 0 then
    local file = io.open(marks_file, "w")
    if file then
      file:write(json)
      file:close()
      print("Marks saved!")
    else
      print("Failed to save marks.")
    end
  else
    print("No marks to save.")
  end
end

local function load_marks()
  local file = io.open(marks_file, "r")
  if file then
    local json = file:read("*a")
    file:close()
    if json and #json > 0 then
      global_marks = vim.fn.json_decode(json) or {}
      print("Marks loaded!")
    else
      global_marks = {}
      print("Marks file is empty.")
    end
  else
    global_marks = {}
    print("No marks file found.")
  end
end

local function toggle_mark()
  local file = vim.fn.expand("%:p") -- Get full path of the current file
  local line = vim.fn.line(".") -- Get the current line number
  local mark_exists = false

  for i, mark in ipairs(global_marks) do
    if mark.file == file and mark.line == line then
      local confirm = vim.fn.input("Remove mark? (y/n): ")
      if confirm:lower() == "y" or confirm:lower() == "yes" then
        table.remove(global_marks, i)
        vim.fn.sign_unplace("MarksGroup", { buffer = vim.fn.bufnr("%"), id = 0 })
        print("Mark removed from " .. file .. ":" .. line)
      else
        print("Mark removal cancelled")
      end
      mark_exists = true
      break
    end
  end

  if not mark_exists then
    global_marks[#global_marks + 1] = { file = file, line = line, name = nil }
    vim.fn.sign_place(0, "MarksGroup", "MarkSign", vim.fn.bufnr("%"), { lnum = line })
    print("Mark added at " .. file .. ":" .. line)
  end

  save_marks() -- Save marks immediately
end

local marks_previewer = previewers.new_buffer_previewer({
  title = "File Preview",
  get_buffer_by_name = function(_, entry)
    return entry.value.file
  end,
  define_preview = function(self, entry)
    -- Read the file content
    local bufnr = self.state.bufnr

    -- Set filetype using bo instead of nvim_buf_set_option
    vim.bo[bufnr].filetype = vim.filetype.match({ filename = entry.value.file }) or ""

    -- Load the file content
    local lines = vim.fn.readfile(entry.value.file)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

    -- Highlight the marked line
    local line_nr = entry.value.line
    local ns_id = vim.api.nvim_create_namespace('TelescopeMarkPreview')
    vim.api.nvim_buf_add_highlight(bufnr, ns_id, "TelescopePreviewLine", line_nr - 1, 0, -1)

    -- Center the view on the marked line
    vim.defer_fn(function()
      self.state.preview_win = vim.fn.bufwinid(bufnr)
      if self.state.preview_win ~= -1 then
        vim.api.nvim_win_set_cursor(self.state.preview_win, {line_nr, 0})
        vim.api.nvim_win_call(self.state.preview_win, function()
          vim.cmd('normal! zz')
        end)
      end
    end, 10)
  end
})

local function name_mark()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  for _, mark in ipairs(global_marks) do
    if mark.file == file and mark.line == line then
      local current_name = mark.name or ""
      local name = vim.fn.input({
        prompt = "Enter mark name: ",
        default = current_name,
      })
      if name ~= "" then
        mark.name = name
        save_marks() -- Save marks immediately
        print("Mark at " .. file .. ":" .. line .. " named '" .. name .. "'")
      else
        print("Mark name not changed.")
      end
      return
    end
  end
  print("No mark found on this line!")
end

local function display_mark(name, file, path)
  local icon, hl_group = utils.get_devicons(file, false)

  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = icon_width },
      { width = #name },
      { width = 1 },
      { width = #file },
      { width = 1 },
      { width = #path },
    },
  }

  return displayer {
    { icon, hl_group },
    { name, Find.HL_NAMED_BUFFER },
    { ' ' },
    { file, Find.HL_GREY },
    { ' ' },
    { path, Find.HL_COMMENT },
  }
end

local function list_marks(all_marks)
  if #global_marks == 0 then
    print("No marks set!")
    return
  end

  local project_root = vim.fn.getcwd() -- Get the current working directory (project root)
  local mark_list = {}
  for _, mark in ipairs(global_marks) do
    if all_marks or vim.startswith(mark.file, project_root) then -- Check if showing all marks or if mark is within project root
      local file, dir = Find.split_path(mark.file)
      local mark_name = mark.name or string.format("%s:%d", vim.fn.fnamemodify(mark.file, ":t"), mark.line)
      local ordinal = mark.name .. ' ' .. file .. ' ' .. dir

      table.insert(mark_list, {
        display = function() return display_mark(mark_name, file, dir) end,
        value = mark,
        ordinal = ordinal,
      })
    end
  end

  if #mark_list == 0 then
    print(all_marks and "No marks set!" or "No marks set in the current project!")
    return
  end

  local title = "Marks"
  if all_marks then
    title = "All Marks"
  end

  pickers.new({}, Find.vertical_layout(title, {
    finder = finders.new_table {
      results = mark_list,
      entry_maker = function(entry)
        return {
          value = entry.value,
          display = entry.display,
          ordinal = entry.ordinal,
        }
      end
    },
    previewer = marks_previewer,
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd("edit " .. selection.value.file)
          vim.fn.cursor(selection.value.line, 0)
          print("Jumped to " .. selection.value.file .. ":" .. selection.value.line)
        end
      end)
      return true
    end,
  })):find()
end

local function place_marks()
  for _, mark in ipairs(global_marks) do
    if vim.fn.bufexists(mark.file) == 1 then
      vim.fn.sign_place(0, '', 'MarkSign', mark.file, { lnum = mark.line, priority = 10 })
    else
      -- print("Warning: Buffer does not exist for file " .. mark.file)
    end
  end
end

-- display a red "m" where the mark is
vim.fn.sign_define("MarkSign", { text = "m", texthl = "Error", numhl = "" })

load_marks() -- Ensure marks are loaded when the module is required

return {
  save_marks = save_marks,
  load_marks = load_marks,
  toggle_mark = toggle_mark,
  name_mark = name_mark,
  list_marks = function() list_marks(false) end,
  list_all_marks = function() list_marks(true) end,
  on_buf_read = place_marks,

  global_marks = global_marks,
}

