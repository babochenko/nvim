-- inspired by https://github.com/chentoast/marks.nvim
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local conf = require('telescope.config').values
local previewers = require('telescope.previewers')

local marks_file = vim.fn.expand("~/.local/share/nvim/marks.json") -- File to save marks
local global_marks = {} -- Stores all marks with file, line, and optional name

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

load_marks() -- Ensure marks are loaded when the module is required

local function toggle_mark()
  local file = vim.fn.expand("%:p") -- Get full path of the current file
  local line = vim.fn.line(".") -- Get the current line number
  local mark_exists = false

  for i, mark in ipairs(global_marks) do
    if mark.file == file and mark.line == line then
      table.remove(global_marks, i)
      vim.fn.sign_unplace("MarksGroup", { buffer = vim.fn.bufnr("%"), id = 0 })
      print("Mark removed from " .. file .. ":" .. line)
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

local function name_mark()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  for _, mark in ipairs(global_marks) do
    if mark.file == file and mark.line == line then
      local current_name = mark.name or ""
      local prompt = "Enter mark name"
      if current_name ~= "" then
        prompt = prompt .. " (current: '" .. current_name .. "')"
      end
      local name = vim.fn.input(prompt .. ": ")
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

local function list_marks()
  if #global_marks == 0 then
    print("No marks set!")
    return
  end

  local mark_list = {}
  for _, mark in ipairs(global_marks) do
    local display_name = mark.name or string.format("%s:%d", vim.fn.fnamemodify(mark.file, ":t"), mark.line)
    table.insert(mark_list, {
      display = display_name,
      value = mark,
      ordinal = display_name,
    })
  end

  -- Create a custom previewer
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
          local win_height = vim.api.nvim_win_get_height(self.state.preview_win)
          local scroll_offset = math.floor(win_height / 2)
          vim.api.nvim_win_set_cursor(self.state.preview_win, {line_nr, 0})
          vim.api.nvim_win_call(self.state.preview_win, function()
            vim.cmd('normal! zz')
          end)
        end
      end, 10)
    end
  })

  pickers.new({}, {
    prompt_title = "Marks",
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
    attach_mappings = function(prompt_bufnr, map)
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
  }):find()
end

-- display a red "m" where the mark is
vim.fn.sign_define("MarkSign", { text = "m", texthl = "Error", numhl = "" })
local function place_marks()
  for _, mark in ipairs(global_marks) do
    if vim.fn.bufexists(mark.file) == 1 then
      vim.fn.sign_place(0, '', 'MarkSign', mark.file, { lnum = mark.line, priority = 10 })
    else
      -- print("Warning: Buffer does not exist for file " .. mark.file)
    end
  end
end

return {
  save_marks = save_marks,
  load_marks = load_marks,
  toggle_mark = toggle_mark,
  name_mark = name_mark,
  list_marks = list_marks,
  on_buf_read = place_marks,

  global_marks = global_marks,
}

