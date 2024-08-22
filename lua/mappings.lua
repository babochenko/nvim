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

map('n', '<leader>gB', ":Gitsigns blame<CR>", { desc = "[B]lame the whole buffer" });
map('n', '<leader>gs', ":Git<CR>", { desc = "git [s]tatus" });
map('n', '<leader>db', ":DBUI<CR>", { desc = "open data[b]ase ui" });

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

