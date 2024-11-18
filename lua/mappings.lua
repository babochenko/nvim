local map = vim.keymap.set

require 'nvchad.mappings'
local M = require 'mappingsfunc'
local DIA = vim.diagnostic
local TSC = require 'telescopeconf'
local LLM = require 'llm'
local GS = require 'gitsigns'
local MARK = require 'marks'

map('n', ';', ':', { desc = 'CMD enter command mode' })
map('i', 'jk', '<ESC>')

map('n', 'gd', vim.lsp.buf.definition, { desc = 'goto definition' });
map('n', 'gu', vim.lsp.buf.references, { desc = 'goto usages' });

map("n", "<leader>fo", M.open_system, { desc = 'open this file in system viewer' })
map('n', '<leader>fr', M.run_file, { desc = 'run file' });
map("n", "<leader>rt", M.test_func, { desc = "test this function" })
map("n", "<leader>rf", M.test_file, { desc = "test this file" })

map("n", "<leader>fw", M.find_words, { desc = "find words" })
map("n", "<leader>ft", M.find_test, { desc = "find test file" })
map("n", "<leader>fn", ':enew<CR>', { desc = "file new" })

map({ 'n', 'v' }, '<leader>k', LLM.run_completion, { desc = 'llm completion' })
map({ 'n', 'v' }, '<leader>l', LLM.run_help, { desc = 'llm help' })

map('n', 'cr', vim.lsp.buf.rename, { desc = 'rename symbol' });
map('n', '<leader>cs', vim.lsp.buf.signature_help, { desc = 'code function signature' });
map('n', '<leader>cd', function() DIA.open_float(nil, { focusable = false }) end, { desc = 'code show diagnostics' })
map('n', '<leader>cn', DIA.goto_next, { desc = 'code next diagnostic' });
map('n', '<leader>cp', DIA.goto_prev, { desc = 'code prev diagnostic' });
map('n', '<leader>fh', TSC.files_history, { desc = 'files history' })

map('n', 'gu', TSC.goto_usages, { desc = 'goto usages' })
map('n', 'gi', TSC.goto_implementations, { desc = 'goto implementations' })
map('n', '<leader>gB', GS.blame, { desc = 'git Blame the whole buffer' });
map('n', '<leader>gs', ':Git<CR>', { desc = 'git status' });
map('n', '<leader>db', ':DBUI<CR>', { desc = 'open database ui' });

map('n', '<leader>tm', M.toggle_mouse, { silent = true, desc = 'toggle mouse' })

map("n", "<leader>mm", MARK.toggle_mark, { desc = 'mark toggle' }) -- Add a mark
map("n", "<leader>mn", MARK.name_mark, { desc = 'mark name' }) -- Name the mark
map("n", "<leader>fm", MARK.list_marks, { desc = 'find marks' }) -- List marks
-- map("n", "<leader>j", MARK., { noremap = true, silent = true }) -- Jump to a mark

