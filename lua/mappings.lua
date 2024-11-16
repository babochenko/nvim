require 'nvchad.mappings'

local map = vim.keymap.set
map('n', ';', ':', { desc = 'CMD enter command mode' })
map('i', 'jk', '<ESC>')

-- LSP
map('n', 'gd', vim.lsp.buf.definition, { desc = 'goto [d]efinition' });
map('n', 'gu', vim.lsp.buf.references, { desc = 'goto [u]sages' });

local function find_words()
  local node = require("nvim-tree.api").tree.get_node_under_cursor()
  if not node or node.type ~= "directory" then
    require("telescope.builtin").live_grep()
    return
  end

  local dir = vim.fn.fnamemodify(node.absolute_path, ":h")
  require("telescope.builtin").live_grep({ cwd = dir })
end

local function find_test()
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
end

local Java = require('jdtls')

local function run_test()
  Java.test_nearest_method()
end

local function run_file()
  Java.test_class()
end

map("n", "<leader>rt", run_test, { desc = "run test case" })
map("n", "<leader>rf", run_file, { desc = "run test file" })
map("n", "<leader>fw", find_words, { desc = "find words" })
map("n", "<leader>ft", find_test, { desc = "find test file" })
map("n", "<leader>fn", ':enew<CR>', { desc = "file new" })

local LLM = require 'llm'

map({ 'n', 'v' }, '<leader>l', LLM.run_completion, { desc = 'llm completion' })
map({ 'n', 'v' }, '<leader>k', LLM.run_help, { desc = 'llm help' })

local Dia = vim.diagnostic
local Tsc = require 'telescope.builtin'
map('n', 'cr', vim.lsp.buf.rename, { desc = '[r]ename symbol' });
map('n', '<leader>cs', vim.lsp.buf.signature_help, { desc = 'code function [s]ignature' });
map('n', '<leader>cd', function() Dia.open_float(nil, { focusable = false }) end, { desc = 'code show [d]iagnostics' })
map('n', '<leader>cn', Dia.goto_next, { desc = 'code [n]ext diagnostic' });
map('n', '<leader>cp', Dia.goto_prev, { desc = 'code [p]rev diagnostic' });
map('n', '<leader>fh', function() Tsc.oldfiles { only_cwd = false } end, { desc = 'files [h]istory' })

local GS = require 'gitsigns'
map('n', '<leader>gB', GS.blame, { desc = 'git [B]lame the whole buffer' });
map('n', '<leader>gs', ':Git<CR>', { desc = 'git [s]tatus' });
map('n', '<leader>db', ':DBUI<CR>', { desc = 'open data[b]ase ui' });

local Runs = {
  ['lua'] = 'lua',
  ['py'] = 'python3',
  ['sh'] = 'bash',
}
map('n', '<leader>fr', function()
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
end, { desc = '[r]un this file' });

map('n', '<leader>tm', function()
  if vim.o.mouse == 'a' then
    vim.o.mouse = ''
    print('Mouse disabled')
  else
    vim.o.mouse = 'a'
    print('Mouse enabled')
  end
end, { silent = true, desc = 'toggle [m]ouse' })

map('n', '<leader>rc', function()
  vim.cmd('g/Connection refused/,+12d')
  vim.cmd('g/Error occurred while fetching list of Sub/,+54d')
  vim.cmd('g/Exception during processor/,+73d')
  vim.cmd('g/heartbeat/d')
  vim.cmd('g/Job/d')
  vim.cmd('g/RSocketFactory/d')
  vim.cmd('g/Thread.java:840/d')
end, { silent = true, desc = '[c]leanup log file' })

