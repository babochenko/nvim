local map = vim.keymap.set

local DIA = vim.diagnostic
local GS = require 'gitsigns'
local TABS = require 'nvchad.tabufline'
local TERM = require "nvchad.term"

local LLM = require 'ext/llm'
local Find = require 'ext/find'
local Buf = require 'ext/buffers'
local Code = require 'ext/code'
local Mark = require 'ext/marks'
local Sys = require 'ext/system'

-- map("n", "<leader>th", function()
--   require("nvchad.themes").open()
-- end, { desc = "telescope nvchad themes" })
--
-- map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })
--
-- map("n", "<leader>wk", function()
--   vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
-- end, { desc = "whichkey query lookup" })

local general_helpers = {
  map('n', '<leader>fo', Sys.open_system, { desc = 'open this file in system viewer' }),
  map('n', '<leader>tm', Sys.toggle_mouse, { silent = true, desc = 'toggle mouse' }),
  map('n', ';', ':', { desc = 'command mode' }),
  map('n', '<Esc>', '<cmd>noh<CR>', { desc = 'general clear highlights' }),
  map('n', '<leader>db', ':DBUI<CR>', { desc = 'open database ui' }),
  map('n', '<leader>fp', '<cmd>echo expand("%:p")<CR>' , { desc = 'show file path' }),
}

local buffers = {
  create = {
    map('n', '<leader>nn', ':enew<CR>', { desc = 'new file' }),
    map('n', '<leader>tt', ':term<CR>', { desc = 'new terminal' }),
    map("n", "<leader>th", function() TERM.new { pos = "sp" } end, { desc = "terminal new h" }),
    map("n", "<leader>tv", function() TERM.new { pos = "vsp" } end, { desc = "terminal new v" }),
  },
  modify = {
    map('n', '<leader>bb', Buf.rename, { desc = 'buffer rename' }),
    map('n', '<leader>bn', Buf.move_right, { desc = 'buffer move right' }),
    map('n', '<leader>bp', Buf.move_left, { desc = 'buffer move left' }),
    map('n', '<leader>fb', Buf.find_all, { desc = 'find buffers' }),
    map('n', '<leader>X', Buf.close_other_buffers, { desc = 'buffer close all but current' }),
  },
}

local code = {
  navigate = {
    map('n', '<leader>cs', vim.lsp.buf.signature_help, { desc = 'code function signature' }),
    map('n', '<leader>cd', function() DIA.open_float(nil, { focusable = false }) end, { desc = 'code show diagnostics' }),
    map('n', '<leader>cD', vim.diagnostic.setloclist, { desc = 'code show all diagnostics' }),
    map('n', '<leader>cn', DIA.goto_next, { desc = 'code next diagnostic' }),
    map('n', '<leader>cp', DIA.goto_prev, { desc = 'code prev diagnostic' }),
    map('n', 'gd', vim.lsp.buf.definition, { desc = 'goto definition' }),
    map('n', 'gu', Find.usages, { desc = 'goto usages' }),
    map('n', 'gi', Find.impls, { desc = 'goto implementations' }),
  },
  edit = {
    map('n', 'cr', vim.lsp.buf.rename, { desc = 'rename symbol' }),
    map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true }),
    map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true }),
  },
  run = {
    map('n', '<leader>fr', Code.run_file, { desc = 'run file' }),
    map('n', '<leader>rt', Code.test_func, { desc = 'test this function' }),
    map('n', '<leader>rf', Code.test_file, { desc = 'test this file' }),
  },
}

local tabs = {
  map('n', '<C-h>', '<C-w>h', { desc = 'switch window left' }),
  map('n', '<C-l>', '<C-w>l', { desc = 'switch window right' }),
  map('n', '<C-j>', '<C-w>j', { desc = 'switch window down' }),
  map('n', '<C-k>', '<C-w>k', { desc = 'switch window up' }),
  map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" }),
  map('n', '<tab>', TABS.next, { desc = 'buffer goto next' }),
  map('n', '<S-tab>', TABS.prev, { desc = 'buffer goto prev' }),
  map('n', '<leader>x', TABS.close_buffer, { desc = 'buffer close' }),
  map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" }),
}

local search = {
  map('n', '<leader>ff', Find.files, { desc = 'find files' }),
  map('n', '<leader>fw', Find.words, { desc = 'find words' }),
  map('n', '<leader>ft', Find.testfile, { desc = 'find test file' }),
  map('n', '<leader>fh', Find.files_history, { desc = 'files history' }),
  map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "find in current buffer" }),
  map("n", "<leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", { desc = "telescope find all files" }),
}

local llm = {
  map({ 'n', 'v' }, '<leader>k', LLM.run_completion, { desc = 'llm completion' }),
  map({ 'n', 'v' }, '<leader>l', LLM.run_help, { desc = 'llm help' }),
}

local git = {
  map('n', '<leader>gB', GS.blame, { desc = 'git blame' }),
  map('n', '<leader>gb', GS.blame_line, { desc = 'git blame line' }),
  map('n', '<leader>gs', ':Git<CR>', { desc = 'git status' }),
  map("n", "<leader>gh", "<cmd>Telescope git_commits<CR>", { desc = "git history" }),
  map("n", "<leader>gg", "<cmd>Flog<CR>", { desc = "git graph" }),
}

local marks = {
  map('n', '<leader>mm', Mark.toggle_mark, { desc = 'mark toggle' }),
  map('n', '<leader>mn', Mark.name_mark, { desc = 'mark name' }),
  map('n', '<leader>fm', Mark.list_marks, { desc = 'find marks in current project' }),
  map('n', '<leader>fM', Mark.list_all_marks, { desc = 'find all marks' }),
}

