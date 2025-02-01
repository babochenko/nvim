local TREE = require('nvim-tree.api')

local function set_tabstop(size)
  vim.bo.tabstop = size
  vim.bo.shiftwidth = size
  vim.bo.softtabstop = size
  vim.bo.expandtab = true
end

local function autocmd(name, opts)
  vim.api.nvim_create_autocmd(name, opts)
end

autocmd('FileType', { pattern = '*', callback = function()
  set_tabstop(2)
end })

autocmd('FileType', { pattern = { 'java', 'groovy' }, callback = function()
  set_tabstop(4)
end })

autocmd('FileType', { pattern = 'sql', callback = function()
  vim.bo.commentstring = '-- %s'
end })

autocmd('FileType', { pattern = 'NvimTree', callback = function()
  vim.keymap.set('n', ',', TREE.node.open.edit, { buffer = true, noremap = true, silent = true })
end })

autocmd('TextYankPost', { callback = function()
  vim.highlight.on_yank()
end })

vim.schedule(function()
  local MARKS = require 'ext/marks'
  MARKS.load_marks()
  autocmd('VimLeavePre', { callback = MARKS.save_marks, })
  autocmd('BufReadPost', { callback = MARKS.on_buf_read, })
end)

-- user event that loads after UIEnter + only if file buf is there
autocmd({ 'UIEnter', 'BufReadPost', 'BufNewFile' }, {
  group = vim.api.nvim_create_augroup('NvFilePost', { clear = true }),
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = args.buf })

    if not vim.g.ui_entered and args.event == 'UIEnter' then
      vim.g.ui_entered = true
    end

    if file ~= '' and buftype ~= 'nofile' and vim.g.ui_entered then
      vim.api.nvim_exec_autocmds('User', { pattern = 'FilePost', modeline = false })
      vim.api.nvim_del_augroup_by_name 'NvFilePost'

      vim.schedule(function()
        vim.api.nvim_exec_autocmds('FileType', {})

        if vim.g.editorconfig then
          require('editorconfig').config(args.buf)
        end
      end)
    end
  end,
})

