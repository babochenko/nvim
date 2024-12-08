local Java = require('jdtls')
local Telescope = require("telescope.builtin")

local strings = require "plenary.strings"
local utils = require "telescope.utils"
local make_entry = require('telescope.make_entry')
local entry_display = require "telescope.pickers.entry_display"

local Runs = {
  ['lua'] = 'lua',
  ['py'] = 'python3',
  ['sh'] = 'bash',
}

local bufnrs = vim.tbl_filter(function(bufnr)
  return 1 == vim.fn.buflisted(bufnr)
end, vim.api.nvim_list_bufs())

local do_display = function(name, opts)
  return function(entry)
    -- bufnr_width + modes + icon + 3 spaces + : + lnum
    local icon, _ = utils.get_devicons("fname", false)
    local icon_width = strings.strdisplaywidth(icon)
    opts.__prefix = opts.bufnr_width + 4 + icon_width + 3 + 1 + #tostring(entry.lnum)
    local display_bufname, path_style = utils.transform_path(opts, entry.filename)

    icon, hl_group = utils.get_devicons(entry.filename, false)

    local displayer = entry_display.create {
      separator = " ",
      items = {
        { width = opts.bufnr_width },
        { width = 4 },
        { width = icon_width },
        { remaining = true },
      },
    }

    return displayer {
      { entry.bufnr, "TelescopeResultsNumber" },
      { entry.indicator, "TelescopeResultsComment" },
      { icon, hl_group },
      { name .. " (" .. display_bufname .. ":" .. entry.lnum .. ")" },
    }
  end
end

return {
  buffers_find = function()
    local max_bufnr = math.max(unpack(bufnrs))
    local bufnr_width = #tostring(max_bufnr)

    Telescope.buffers({
      entry_maker = function(entry)
        local opts = {
          bufnr_width = bufnr_width
        }

        entry = make_entry.gen_from_buffer(opts)(entry)

        local ok, name = pcall(vim.api.nvim_buf_get_var, entry.bufnr, "buf_custom_name")
        if ok then
          entry.display = do_display(name, opts)
        end

        return entry
      end
    })
  end,

  buffer_rename = function()
    local prev_name = ""
    local ok, custom_name = pcall(vim.api.nvim_buf_get_var, 0, "buf_custom_name")
    if ok then
      prev_name = custom_name
    end

    local name = vim.fn.input({
      prompt = "Enter buffer name: ",
      default = prev_name or "",
    })

    if name == "" then
      print("Can't set an empty name for a buffer")
    elseif name == prev_name then
      print("Buffer name didn't change")
    else
      vim.api.nvim_buf_set_var(0, "buf_custom_name", name)
    end
  end,

  find_words = function()
    local node = require("nvim-tree.api").tree.get_node_under_cursor()
    if not node or node.type ~= "directory" then
      require("telescope.builtin").live_grep()
      return
    end

    local dir = vim.fn.fnamemodify(node.absolute_path, ":h")
    require("telescope.builtin").live_grep({ cwd = dir })
  end,

  find_test = function()
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

  test_func = function()
    Java.test_nearest_method()
  end,

  test_file = function()
    Java.test_class()
  end,

  run_file = function()
    local file_path = vim.fn.expand('%:p')
    local file_extension = vim.fn.expand('%:e')

    local cmd = Runs[file_extension]
    if cmd == nil then
        print('No command defined for this file type')
        return
    end

    cmd = cmd .. ' ' .. file_path
    vim.cmd('terminal')
    vim.cmd('startinsert')
    vim.fn.chansend(vim.b.terminal_job_id, cmd .. '\n')
  end,

  toggle_mouse = function()
    if vim.o.mouse == 'a' then
      vim.o.mouse = ''
      print('Mouse disabled')
    else
      vim.o.mouse = 'a'
      print('Mouse enabled')
    end
  end,

  open_system = function()
    local file_path = vim.fn.expand("%:p") -- Get the full path of the current file
    if file_path == "" then
      print("No file is currently open.")
      return
    end

    -- Command for macOS, Linux, or Windows
    local command
    if vim.fn.has("mac") == 1 then
      command = "open " .. vim.fn.shellescape(file_path)
    elseif vim.fn.has("unix") == 1 then
      command = "xdg-open " .. vim.fn.shellescape(file_path)
    elseif vim.fn.has("win32") == 1 then
      command = "start " .. vim.fn.shellescape(file_path)
    else
      print("Unsupported system.")
      return
    end

    -- Execute the command
    vim.fn.system(command)
    print("Opened file in system editor: " .. file_path)
  end,

  close_other_buffers = function()
    local current_buf = vim.api.nvim_get_current_buf()

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and buf ~= current_buf then
        local success, err = pcall(function()
          vim.api.nvim_buf_delete(buf, {force = true})
        end)

        if not success then
          print("Error closing buffer " .. buf .. ": " .. tostring(err))
        end
      end
    end
  end,

}

