require "nvchad.mappings"

local map = vim.keymap.set
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

do -- LSP
  map('n', 'gd', function() vim.lsp.buf.definition(); end, { desc = "Go to [d]efinition" });
  map('n', 'gu', function() vim.lsp.buf.references(); end, { desc = "Go to [u]sages" });

  map('n', 'cr', function() vim.lsp.buf.rename() end, { desc = "[r]ename symbol" });
  map('n', '<leader>ca', function()
    vim.lsp.buf.code_action();
  end, { desc = "LSP [a]pply code action" });
  map('n', '<leader>cd', function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end, { noremap = true, desc = "Show [d]iagnostics" })
end

function term(command)
  vim.cmd('terminal')
  vim.cmd('startinsert')
  vim.fn.chansend(vim.b.terminal_job_id, command .. "\n")
end

function CloseCurrentBuffer()
  local current_buf = vim.api.nvim_get_current_buf()

  if vim.fn.bufnr('#') ~= -1 then
    vim.cmd('buffer #')
  else
    vim.cmd('enew')
  end

  vim.cmd('bd! ' .. current_buf)
end

map('n', '<leader>w',  ':lua CloseCurrentBuffer()<CR>', { noremap = true, silent = true, desc = "close the terminal" });
map('n', '<leader>gB', ":Gitsigns blame<CR>", { desc = "[B]lame the whole buffer" });
map('n', '<leader>gs', ":Git<CR>", { desc = "git [s]tatus" });
map('n', '<leader>db', ":DBUI<CR>", { desc = "open data[b]ase ui" });

map('n', '<leader>fr', function()
  -- Get the current file path
  local file_path = vim.fn.expand('%:p')

  -- Get the file extension to determine how to run the file
  local file_extension = vim.fn.expand('%:e')

  -- Determine the command based on the file extension
  local run_command

  if file_extension == "lua" then
      run_command = "lua " .. file_path
  elseif file_extension == "py" then
      run_command = "python3 " .. file_path
  elseif file_extension == "sh" then
      run_command = "bash " .. file_path
  else
      -- Add more conditions for other file types as needed
      print("No command defined for this file type")
      return
  end

  -- Open a terminal and run the command
  -- vim.cmd("split | terminal " .. run_command .. " ; read")
  term(run_command)
end, { desc = "[r]un this file" });

map('n', '<leader>fg', function()
  require("telescope").extensions.live_grep_args.live_grep_args();
end, { desc = "live [g]rep with args" });

map('n', '<leader>tm', function()
  if vim.o.mouse == 'a' then
    vim.o.mouse = ''
    print("Mouse disabled")
  else
    vim.o.mouse = 'a'
    print("Mouse enabled")
  end
end, { noremap = true, silent = true , desc = "toggle [m]ouse" })

map('n', '<leader>rc', function()
  vim.cmd('g/Connection refused/,+12d')
  vim.cmd('g/Error occurred while fetching list of Sub/,+54d')
  vim.cmd('g/Exception during processor/,+73d')
  vim.cmd('g/heartbeat/d')
  vim.cmd('g/Job/d')
  vim.cmd('g/RSocketFactory/d')
  vim.cmd('g/Thread.java:840/d')
end, { noremap = true, silent = true , desc = "[r]evolut [c]leanup log file" })

