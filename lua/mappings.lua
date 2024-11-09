require 'nvchad.mappings'

local map = vim.keymap.set
map('n', ';', ':', { desc = 'CMD enter command mode' })
map('i', 'jk', '<ESC>')

-- LSP
map('n', 'gd', vim.lsp.buf.definition, { desc = 'goto [d]efinition' });
map('n', 'gu', vim.lsp.buf.references, { desc = 'goto [u]sages' });

map('n', 'cr', vim.lsp.buf.rename, { desc = '[r]ename symbol' });
map('n', '<leader>cd', function() vim.diagnostic.open_float(nil, { focusable = false }) end, { desc = 'Show [d]iagnostics' })
map('n', '<leader>cn', vim.diagnostic.goto_next, { desc = '[n]ext diagnostic' });
map('n', '<leader>cp', vim.diagnostic.goto_prev, { desc = '[p]rev diagnostic' });

local GS = require 'gitsigns'
map('n', '<leader>gB', ':Gitsigns blame<CR>', { desc = 'git [B]lame the whole buffer' });
map('n', '<leader>gs', ':Git<CR>', { desc = 'git [s]tatus' });
map('n', '<leader>db', ':DBUI<CR>', { desc = 'open data[b]ase ui' });

map('n', '<leader>fr', function()
  local file_path = vim.fn.expand('%:p')
  local file_extension = vim.fn.expand('%:e')

  local cmd
  if file_extension == 'lua' then
      cmd = 'lua ' .. file_path
  elseif file_extension == 'py' then
      cmd = 'python3 ' .. file_path
  elseif file_extension == 'sh' then
      cmd = 'bash ' .. file_path
  else
      print('No command defined for this file type')
      return
  end

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

