-- buffers.lua
--
-- adds custom names to buffers
-- <leader>fb shows open buffers, with a custom name if exists
-- useful for naming terminals
--
local Find = require 'ext/find'

local Tabs = require "nvchad.tabufline" 
local Telescope = require("telescope.builtin")
local strings = require "plenary.strings"
local utils = require "telescope.utils"
local make_entry = require('telescope.make_entry')
local entry_display = require "telescope.pickers.entry_display"

local bufnrs = vim.tbl_filter(function(bufnr)
  return 1 == vim.fn.buflisted(bufnr)
end, vim.api.nvim_list_bufs())
local max_bufnr = math.max(unpack(bufnrs))
local bufnr_width = #tostring(max_bufnr)

local do_display_name = function(name, opts)
  return function(entry)
    local icon, _ = utils.get_devicons("fname", false)
    local icon_width = strings.strdisplaywidth(icon)
    opts.__prefix = opts.bufnr_width + 4 + icon_width + 3 + 1 + #tostring(entry.lnum)
    local display_bufname, path_style = utils.transform_path(opts, entry.filename)
    local _, path = Find.split_path(entry.filename)

    icon, hl_group = utils.get_devicons(entry.filename, false)

    local filename, filepath, filestyle
    if name then
      filename = name
      filepath = " (" .. path .. ":" .. entry.lnum .. ")"
      filestyle = { filename, Find.HL_NAMED_BUFFER }
    else
      filename = vim.fn.fnamemodify(entry.filename, ":t") .. ":" .. entry.lnum
      filepath = path
      filestyle = { filename }
    end
    local displayer = entry_display.create {
      separator = " ",
      items = {
        { width = opts.bufnr_width },
        { width = 4 },
        { width = icon_width },
        { width = #filename },
        { width = #filepath },
      },
    }

    return displayer {
      { entry.bufnr, "TelescopeResultsNumber" },
      { entry.indicator, Find.HL_COMMENT },
      { icon, hl_group },
      filestyle,
      { filepath, Find.HL_COMMENT },
    }
  end
end

local function make_custom_name_entry(entry)
  local opts = { bufnr_width = bufnr_width }

  entry = make_entry.gen_from_buffer(opts)(entry)

  local ok, name = pcall(vim.api.nvim_buf_get_var, entry.bufnr, "buf_custom_name")
  if ok and name ~= "" then
    entry.display = do_display_name(name, opts)
    -- Add ordinal with custom name for searching
    entry.ordinal = name .. " " .. entry.ordinal
  else
    entry.display = do_display_name(nil, opts)
  end
  return entry
end

return {
  find_all = function()
    Telescope.buffers(Find.vertical_layout("Open Buffers", {
      entry_maker = make_custom_name_entry,
    }))
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

  move_left = function()
    Tabs.move_buf(-1)
  end,

  move_right = function()
    Tabs.move_buf(1)
  end,

}

