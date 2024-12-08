local map = vim.keymap.set

require 'nvchad.mappings'
local DIA = vim.diagnostic
local GS = require 'gitsigns'

local LLM = require 'ext/llm'
local Find = require 'ext/find'
local Buf = require 'ext/buffers'
local Code = require 'ext/code'
local Mark = require 'ext/marks'
local Sys = require 'ext/system'

map('n', ';', ':', { desc = 'CMD enter command mode' })
map('i', 'jk', '<ESC>')

map('n', '<leader>ff', Find.files, { desc = 'find files' });
map("n", "<leader>X", Buf.close_other_buffers, { desc = 'buffer close all but current' })

map("n", "<leader>bn", Buf.rename, { desc = 'buffer rename ' })
map("n", "<leader>fb", Buf.find_all, { desc = 'buffers find' })

map('n', '<leader>fr', Code.run_file, { desc = 'run file' });
map("n", "<leader>rt", Code.test_func, { desc = "test this function" })
map("n", "<leader>rf", Code.test_file, { desc = "test this file" })

map("n", "<leader>fw", Find.words, { desc = "find words" })
map("n", "<leader>ft", Find.testfile, { desc = "find test file" })

map("n", "<leader>nf", ':enew<CR>', { desc = "new file" })
map("n", "<leader>nt", ':term<CR>', { desc = "new terminal" })

map({ 'n', 'v' }, '<leader>k', LLM.run_completion, { desc = 'llm completion' })
map({ 'n', 'v' }, '<leader>l', LLM.run_help, { desc = 'llm help' })

map('n', 'cr', vim.lsp.buf.rename, { desc = 'rename symbol' });
map('n', '<leader>cs', vim.lsp.buf.signature_help, { desc = 'code function signature' });
map('n', '<leader>cd', function() DIA.open_float(nil, { focusable = false }) end, { desc = 'code show diagnostics' })
map('n', '<leader>cn', DIA.goto_next, { desc = 'code next diagnostic' });
map('n', '<leader>cp', DIA.goto_prev, { desc = 'code prev diagnostic' });
map('n', '<leader>fh', Find.files_history, { desc = 'files history' })

map('n', 'gd', vim.lsp.buf.definition, { desc = 'goto definition' });
map('n', 'gu', Find.usages, { desc = 'goto usages' })
map('n', 'gi', Find.impls, { desc = 'goto implementations' })
map('n', '<leader>gB', GS.blame, { desc = 'git Blame the whole buffer' });
map('n', '<leader>gs', ':Git<CR>', { desc = 'git status' });
map('n', '<leader>db', ':DBUI<CR>', { desc = 'open database ui' });

map("n", "<leader>fo", Sys.open_system, { desc = 'open this file in system viewer' })
map('n', '<leader>tm', Sys.toggle_mouse, { silent = true, desc = 'toggle mouse' })

map("n", "<leader>mm", Mark.toggle_mark, { desc = 'mark toggle' })
map("n", "<leader>mn", Mark.name_mark, { desc = 'mark name' })
map("n", "<leader>fm", function() Mark.list_marks(false) end, { desc = 'find marks in current project' })
map("n", "<leader>fM", function() Mark.list_marks(true) end, { desc = 'find all marks' })

