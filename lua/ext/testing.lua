-- Test runners for different languages
local TestRunners = {
  python = {
    file_pattern = "test_.*%.py$",
    test_function_pattern = "def (test_[%w_]+)",
    run_file = "python -m pytest %s -v",
    run_function = "python -m pytest %s::%s -v",
  },
  javascript = {
    file_pattern = ".*%.test%.js$",
    test_function_pattern = "(test|it)%s*%(%s*['\"]([^'\"]+)['\"]",
    run_file = "npm test %s",
    run_function = "npm test -- --testNamePattern='%s'",
  },
  typescript = {
    file_pattern = ".*%.test%.ts$",
    test_function_pattern = "(test|it)%s*%(%s*['\"]([^'\"]+)['\"]",
    run_file = "npm test %s",
    run_function = "npm test -- --testNamePattern='%s'",
  },
  go = {
    file_pattern = ".*_test%.go$",
    test_function_pattern = "func (Test[%w_]+)",
    run_file = "go test %s -v",
    run_function = "go test %s -run %s -v",
  },
  rust = {
    file_pattern = ".*%.rs$",
    test_function_pattern = "#%[test%]%s*fn ([%w_]+)",
    run_file = "cargo test",
    run_function = "cargo test %s",
  },
}

-- Namespace for virtual text signs
local ns_id = vim.api.nvim_create_namespace("test_indicators")

-- Detect current language based on file extension and content
local function detect_language()
  local file_path = vim.fn.expand('%:p')
  local file_name = vim.fn.expand('%:t')
  local ext = vim.fn.expand('%:e')
  
  -- Python detection
  if ext == "py" and (string.match(file_name, "test_.*%.py$") or string.match(file_name, ".*_test%.py$")) then
    return "python"
  end
  
  -- JavaScript/TypeScript detection
  if (ext == "js" or ext == "ts") and string.match(file_name, ".*%.test%." .. ext .. "$") then
    return ext == "js" and "javascript" or "typescript"
  end
  
  -- Go detection
  if ext == "go" and string.match(file_name, ".*_test%.go$") then
    return "go"
  end
  
  -- Rust detection (check for #[test] in content)
  if ext == "rs" then
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for _, line in ipairs(lines) do
      if string.match(line, "#%[test%]") then
        return "rust"
      end
    end
  end
  
  return nil
end

-- Extract test functions from current buffer
local function get_test_functions()
  local lang = detect_language()
  if not lang then return {} end
  
  local runner = TestRunners[lang]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local tests = {}
  
  for i, line in ipairs(lines) do
    local test_name = string.match(line, runner.test_function_pattern)
    if test_name then
      table.insert(tests, {
        name = test_name,
        line = i,
      })
    end
  end
  
  return tests
end

-- Run terminal command
local function run_in_terminal(cmd)
  vim.cmd('tabnew')
  vim.cmd('terminal')
  vim.cmd('startinsert')
  vim.fn.chansend(vim.b.terminal_job_id, cmd .. '\n')
end

-- Run specific test function
local function run_test_function(test_name)
  local lang = detect_language()
  if not lang then
    print("No test runner configured for this file type")
    return
  end
  
  local runner = TestRunners[lang]
  local file_path = vim.fn.expand('%:p')
  local cmd
  
  if lang == "python" then
    cmd = string.format(runner.run_function, file_path, test_name)
  elseif lang == "javascript" or lang == "typescript" then
    cmd = string.format(runner.run_function, test_name)
  elseif lang == "go" then
    local dir = vim.fn.expand('%:h')
    cmd = string.format("cd %s && " .. runner.run_function, dir, ".", test_name)
  elseif lang == "rust" then
    cmd = string.format(runner.run_function, test_name)
  end
  
  if cmd then
    run_in_terminal(cmd)
  end
end

-- Run all tests in current file
local function run_file_tests()
  local lang = detect_language()
  if not lang then
    print("No test runner configured for this file type")
    return
  end
  
  local runner = TestRunners[lang]
  local file_path = vim.fn.expand('%:p')
  local cmd
  
  if lang == "python" then
    cmd = string.format(runner.run_file, file_path)
  elseif lang == "javascript" or lang == "typescript" then
    cmd = string.format(runner.run_file, file_path)
  elseif lang == "go" then
    local dir = vim.fn.expand('%:h')
    cmd = string.format("cd %s && " .. runner.run_file, dir, ".")
  elseif lang == "rust" then
    cmd = runner.run_file
  end
  
  if cmd then
    run_in_terminal(cmd)
  end
end

-- Add visual indicators for test functions
local function add_test_indicators()
  local tests = get_test_functions()
  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Clear existing signs
  vim.fn.sign_unplace("TestGroup", { buffer = bufnr })
  
  for _, test in ipairs(tests) do
    -- Add green triangle sign
    vim.fn.sign_place(0, "TestGroup", "TestSign", bufnr, { lnum = test.line })
  end
end

-- Get test function at current cursor position
local function get_test_at_cursor()
  local cursor_line = vim.fn.line('.')
  local tests = get_test_functions()
  
  for _, test in ipairs(tests) do
    if test.line == cursor_line then
      return test.name
    end
  end
  
  return nil
end

-- Define test sign with green triangle
vim.fn.sign_define("TestSign", { text = "▶", texthl = "String", numhl = "" })

local function run_test_at_cursor()
  local test_name = get_test_at_cursor()
  if test_name then
    run_test_function(test_name)
  else
    print("No test function found at cursor position")
  end
end

-- Auto-add indicators when entering a test file
local function setup_autocmds()
  local group = vim.api.nvim_create_augroup("TestIndicators", { clear = true })
  
  vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
    group = group,
    callback = function()
      if detect_language() then
        add_test_indicators()
      end
    end,
  })
end

return {
    run_test_at_cursor = run_test_at_cursor,
    run_file_tests = run_file_tests,
    add_test_indicators = add_test_indicators,
    detect_language = detect_language,
    setup_autocmds = setup_autocmds,
}

