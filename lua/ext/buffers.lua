-- buffers.lua
--
-- adds custom names to buffers
-- <leader>fb shows open buffers, with a custom name if exists
-- useful for naming terminals
--
local Find = require 'ext/find'

local Telescope = require("telescope.builtin")
local strings = require "plenary.strings"
local utils = require "telescope.utils"
local make_entry = require('telescope.make_entry')
local entry_display = require "telescope.pickers.entry_display"

local bufnrs = vim.tbl_filter(function(bufnr)
  return 1 == vim.fn.buflisted(bufnr)
end, vim.api.nvim_list_bufs())

local do_display = function(name, opts)
  return function(entry)
    -- bufnr_width + modes + icon + 3 spaces + : + lnum
    local icon, _ = utils.get_devicons("fname", false)
    local icon_width = strings.strdisplaywidth(icon)
    opts.__prefix = opts.bufnr_width + 4 + icon_width + 3 + 1 + #tostring(entry.lnum)
    local display_bufname, path_style = utils.transform_path(opts, entry.filename)

    icon, hl_group = utils.get_devicons(entry.filename, false)

    local bufname = " (" .. display_bufname .. ":" .. entry.lnum .. ")"
    local displayer = entry_display.create {
      separator = " ",
      items = {
        { width = opts.bufnr_width },
        { width = 4 },
        { width = icon_width },
        { remaining = true },
        { width = #bufname },
      },
    }

    return displayer {
      { entry.bufnr, "TelescopeResultsNumber" },
      { entry.indicator, Find.HL_COMMENT },
      { icon, hl_group },
      { name },
      { bufname, Find.HL_COMMENT },
    }
  end
end

return {
  find_all = function()
    local max_bufnr = math.max(unpack(bufnrs))
    local bufnr_width = #tostring(max_bufnr)

    Telescope.buffers({
      entry_maker = function(entry)
        local opts = {
          bufnr_width = bufnr_width
        }

        entry = make_entry.gen_from_buffer(opts)(entry)

        local ok, name = pcall(vim.api.nvim_buf_get_var, entry.bufnr, "buf_custom_name")
        if ok and name ~= "" then
          entry.display = do_display(name, opts)
        end

        return entry
      end
    })
  end,

  rename = function()
    local prev_name = ""
    local ok, custom_name = pcall(vim.api.nvim_buf_get_var, 0, "buf_custom_name")
    if ok then
      prev_name = custom_name
    end

    local name = vim.fn.input({
      prompt = "Enter buffer name: ",
      default = prev_name or "",
    })

    if name == prev_name then
      print("Buffer name didn't change")
    else
      vim.api.nvim_buf_set_var(0, "buf_custom_name", name)
      if name == "" then
        print("Removed buffer name")
      else
        print("Set buffer name to " .. name)
      end
    end
  end,

  close_other_buffers = function()
    local current_buf = vim.api.nvim_get_current_buf()

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and buf ~= current_buf then
        local success, err = pcall(function()
          vim.api.nvim_buf_delete(buf, {force = true})
        end)

        if not success then
          print("Error closing buffer " .. buf .. ": " .. tostring(err))
        end
      end
    end
  end,

}
