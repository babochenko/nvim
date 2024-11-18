local marks_file = vim.fn.stdpath("data") .. "/marks.json" -- File to save marks
local global_marks = {} -- Stores all marks with file, line, and optional name

local function save_marks()
  local json = vim.fn.json_encode(global_marks)
  local file = io.open(marks_file, "w")
  if file then
    file:write(json)
    file:close()
    print("Marks saved!")
  else
    print("Failed to save marks.")
  end
end

local function load_marks()
  local file = io.open(marks_file, "r")
  if file then
    local json = file:read("*a")
    file:close()
    global_marks = vim.fn.json_decode(json) or {}
    print("Marks loaded!")
  else
    global_marks = {}
    print("No marks file found.")
  end
end

local function add_mark()
  local file = vim.fn.expand("%:p") -- Get full path of the current file
  local line = vim.fn.line(".") -- Get the current line number
  global_marks[#global_marks + 1] = { file = file, line = line, name = nil }
  vim.fn.sign_place(0, "MarksGroup", "MarkSign", vim.fn.bufnr("%"), { lnum = line })
  save_marks() -- Save marks immediately
  print("Mark added at " .. file .. ":" .. line)
end

local function name_mark()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  for _, mark in ipairs(global_marks) do
    if mark.file == file and mark.line == line then
      local name = vim.fn.input("Enter mark name: ")
      mark.name = name
      save_marks() -- Save marks immediately
      print("Mark at " .. file .. ":" .. line .. " named '" .. name .. "'")
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
    -- Extract the filename from the full path
    local filename = vim.fn.fnamemodify(mark.file, ":t")
    local snippet = vim.fn.getbufline(vim.fn.bufnr(mark.file), mark.line)[1] or ""
    table.insert(mark_list, string.format(
      "%s:%d: %s [%s]",
      filename, mark.line, snippet:sub(1, 50), mark.name or "Unnamed"
    ))
  end

  print(table.concat(mark_list, "\n"))
end

local function jump_to_mark()
  if #global_marks == 0 then
    print("No marks set!")
    return
  end

  local mark_list = {}
  for _, mark in ipairs(global_marks) do
    local snippet = vim.fn.getbufline(vim.fn.bufnr(mark.file), mark.line)[1] or ""
    table.insert(mark_list, { 
      file = mark.file,
      line = mark.line,
      text = string.format("%s:%d: %s [%s]", mark.file, mark.line, snippet:sub(1, 50), mark.name or "Unnamed")
    })
  end

  vim.ui.select(mark_list, {
    prompt = "Select a mark to jump to:",
    format_item = function(item)
      return item.text
    end,
  }, function(choice)
    if choice then
      vim.cmd("edit " .. choice.file) -- Open the file
      vim.cmd(choice.line) -- Jump to the line
      print("Jumped to " .. choice.file .. ":" .. choice.line)
    end
  end)
end

-- display a red "m" where the mark is
vim.fn.sign_define("MarkSign", { text = "m", texthl = "Error", numhl = "" })

vim.api.nvim_create_autocmd("VimEnter", {
  callback = load_marks,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = save_marks,
})

vim.api.nvim_set_keymap("n", "<leader>m", ":lua add_mark()<CR>", { noremap = true, silent = true }) -- Add a mark
vim.api.nvim_set_keymap("n", "<leader>n", ":lua name_mark()<CR>", { noremap = true, silent = true }) -- Name the mark
vim.api.nvim_set_keymap("n", "<leader>l", ":lua list_marks()<CR>", { noremap = true, silent = true }) -- List marks
vim.api.nvim_set_keymap("n", "<leader>j", ":lua jump_to_mark()<CR>", { noremap = true, silent = true }) -- Jump to a mark

