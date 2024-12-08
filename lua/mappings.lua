local map = vim.keymap.set

require 'nvchad.mappings'
local M = require 'mappingsfunc'
local DIA = vim.diagnostic
local LLM = require 'llm'
local GS = require 'gitsigns'

local TSC = require 'telescope/files'
local BUF = require 'telescope/buffers'
local MARK = require 'telescope/marks'

map('n', ';', ':', { desc = 'CMD enter command mode' })
map('i', 'jk', '<ESC>')

map('n', '<leader>ff', TSC.find_files_default, { desc = 'find files' });
map("n", "<leader>X", M.close_other_buffers, { desc = 'buffer close all but current' })
map('n', 'gd', vim.lsp.buf.definition, { desc = 'goto definition' });
map('n', 'gu', vim.lsp.buf.references, { desc = 'goto usages' });

map("n", "<leader>bn", BUF.rename, { desc = 'buffer rename ' })
map("n", "<leader>fb", BUF.find_all, { desc = 'buffers find' })

map("n", "<leader>fo", M.open_system, { desc = 'open this file in system viewer' })
map('n', '<leader>fr', M.run_file, { desc = 'run file' });
map("n", "<leader>rt", M.test_func, { desc = "test this function" })
map("n", "<leader>rf", M.test_file, { desc = "test this file" })

map("n", "<leader>fw", M.find_words, { desc = "find words" })
map("n", "<leader>ft", M.find_test, { desc = "find test file" })

map("n", "<leader>nf", ':enew<CR>', { desc = "new file" })
map("n", "<leader>nt", ':term<CR>', { desc = "new terminal" })

map({ 'n', 'v' }, '<leader>k', LLM.run_completion, { desc = 'llm completion' })
map({ 'n', 'v' }, '<leader>l', LLM.run_help, { desc = 'llm help' })

map('n', 'cr', vim.lsp.buf.rename, { desc = 'rename symbol' });
map('n', '<leader>cs', vim.lsp.buf.signature_help, { desc = 'code function signature' });
map('n', '<leader>cd', function() DIA.open_float(nil, { focusable = false }) end, { desc = 'code show diagnostics' })
map('n', '<leader>cn', DIA.goto_next, { desc = 'code next diagnostic' });
map('n', '<leader>cp', DIA.goto_prev, { desc = 'code prev diagnostic' });
map('n', '<leader>fh', TSC.files_history, { desc = 'files history' })

-- map('n', 'gd', TSC.goto_definitions, { desc = 'goto definitions' })
map('n', 'gu', TSC.goto_usages, { desc = 'goto usages' })
map('n', 'gi', TSC.goto_implementations, { desc = 'goto implementations' })
map('n', '<leader>gB', GS.blame, { desc = 'git Blame the whole buffer' });
map('n', '<leader>gs', ':Git<CR>', { desc = 'git status' });
map('n', '<leader>db', ':DBUI<CR>', { desc = 'open database ui' });

map('n', '<leader>tm', M.toggle_mouse, { silent = true, desc = 'toggle mouse' })

map("n", "<leader>mm", MARK.toggle_mark, { desc = 'mark toggle' }) -- Add a mark
map("n", "<leader>mn", MARK.name_mark, { desc = 'mark name' }) -- Name the mark
map("n", "<leader>fm", function() MARK.list_marks(false) end, { desc = 'find marks in current project' }) -- List marks
map("n", "<leader>fM", function() MARK.list_marks(true) end, { desc = 'find all marks' }) -- List marks
-- map("n", "<leader>j", MARK., { noremap = true, silent = true }) -- Jump to a mark

