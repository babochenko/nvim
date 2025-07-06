vim.g.mapleader = ' '
vim.opt.fixendofline = false

vim.defer_fn(function()
  vim.opt.clipboard = 'unnamedplus'
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.smoothscroll = true
  vim.opt.timeoutlen = 200
end, 0)


require 'plugins'
require 'autocmd'
require 'ui'
require 'ext/mymath'

vim.schedule(function()
  require 'mappings'
  require 'python'
end)

if #vim.api.nvim_list_uis() == 0 then return end

-- Add error handling for invalid window operations
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    -- Suppress treesitter errors for invalid windows
    local original_nvim_redraw = vim.api.nvim__redraw
    vim.api.nvim__redraw = function(opts)
      local ok, err = pcall(original_nvim_redraw, opts)
      if not ok and string.match(err, "Invalid window id") then
        -- Silently ignore invalid window errors
        return
      elseif not ok then
        error(err)
      end
    end
  end,
})

-- transparency
vim.cmd [[
  highlight Normal      ctermbg=none guibg=none
  highlight NormalNC    ctermbg=none guibg=none
  highlight SignColumn  ctermbg=none guibg=none
  highlight VertSplit   ctermbg=none guibg=none
  highlight StatusLine  ctermbg=none guibg=none
  highlight LineNr      ctermbg=none guibg=none
  highlight EndOfBuffer ctermbg=none guibg=none
]]


