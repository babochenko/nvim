-- Test runners for different languages
local TestRunners = {
  python = {
    regex_file = ".*%.py$",
    regex_line = "def (test_[%w_]+)",
    run_file = "venv; python -m pytest %s -v",
    run_line = "venv; python -m pytest %s::%s -v",
  },
  javascript = {
    regex_file = ".*%.test%.js$",
    regex_line = "(test|it)%s*%(%s*['\"]([^'\"]+)['\"]",
    run_file = "npm test %s",
    run_line = "npm test -- --testNamePattern='%s'",
  },
  typescript = {
    regex_file = ".*%.test%.ts$",
    regex_line = "(test|it)%s*%(%s*['\"]([^'\"]+)['\"]",
    run_file = "npm test %s",
    run_line = "npm test -- --testNamePattern='%s'",
  },
  go = {
    regex_file = ".*_test%.go$",
    regex_line = "func (Test[%w_]+)",
    run_file = "go test %s -v",
    run_line = "go test %s -run %s -v",
  },
  rust = {
    regex_file = ".*%.rs$",
    regex_line = "#%[test%]%s*fn ([%w_]+)",
    run_file = "cargo test",
    run_line = "cargo test %s",
  },
  http = {
    regex_file = ".*%.http$",
    regex_line = "^%s*([A-Z]+%s+https?://.*)",
    run_file = ":Rest run",
    run_line = ":Rest run",
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
  if ext == "py" then
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
  
  -- HTTP detection
  if ext == "http" then
    return "http"
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

  local function _add(test_name, i)
      if test_name then
        table.insert(tests, {
          name = test_name,
          line = i,
        })
      end
  end
  
  for i, line in ipairs(lines) do
    if lang == "javascript" or lang == "typescript" then
      -- For JS/TS, we need the second capture group
      local _, test = string.match(line, runner.regex_line)
      _add(test, i)

    else
      local test = string.match(line, runner.regex_line)
      _add(test, i)
    end
  end
  
  return tests
end

-- Run terminal command or vim command
local function run_in_terminal(cmd)
  local iscmd = cmd:sub(1, 1) == ":"
  if iscmd then
    vim.cmd(cmd)
  else
    vim.cmd('tabnew')
    vim.cmd('terminal')
    vim.cmd('startinsert')
    vim.fn.chansend(vim.b.terminal_job_id, cmd .. '\n')
  end
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
    cmd = string.format(runner.run_line, file_path, test_name)
  elseif lang == "javascript" or lang == "typescript" then
    cmd = string.format(runner.run_line, test_name)
  elseif lang == "go" then
    local dir = vim.fn.expand('%:h')
    cmd = string.format("cd %s && " .. runner.run_line, dir, ".", test_name)
  elseif lang == "rust" then
    cmd = string.format(runner.run_line, test_name)
  elseif lang == "http" then
    cmd = runner.run_line
  end
  
  if cmd then
    run_in_terminal(cmd)
  end
end

-- Run all tests in current file
local function run_file()
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
  elseif lang == "http" then
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

local function run_line()
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
        vim.defer_fn(function()
          add_test_indicators()
        end, 0)
      end
    end,
  })
end

return {
    run_line = run_line,
    run_file = run_file,
    add_test_indicators = add_test_indicators,
    detect_language = detect_language,
    get_test_functions = get_test_functions,
    setup_autocmds = setup_autocmds,
}

