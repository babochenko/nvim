local Java = require('jdtls')

local Runs = {
  ['lua'] = 'lua',
  ['py'] = 'python3',
  ['sh'] = 'bash',
}

return {

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

}

