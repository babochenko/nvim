local TSC = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local devicons = require("nvim-web-devicons")

local function conf(prompt)
  return {
    show_line = false,      -- Show line preview
    layout_strategy = "horizontal", -- Horizontal layout
    layout_config = {
      preview_width = 0.6, -- Preview window width
    },
    path_display = { "tail" },
    prompt_title = prompt,
    attach_mappings = function(_, map)
      map('i', '<CR>', function(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if entry and entry.filename and (entry.filename:match("Test") or entry.filename:match("Spec")) then
          vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = "green" })
        end
        actions.select_default(prompt_bufnr)
      end)
      return true
    end,
  }
end

local function find_files()
  local function get_input_parts(input)
    local parts = {}
    for part in input:gmatch("%S+") do
      table.insert(parts, part)
    end
    return parts
  end

  local function matches_abbreviation(filename, pattern)
    -- Convert pattern to uppercase for abbreviation matching
    pattern = pattern:upper()
    filename = filename:upper()
    
    local j = 1
    for i = 1, #pattern do
      j = filename:find(pattern:sub(i,i), j)
      if not j then return false end
      j = j + 1
    end
    return true
  end

  local function custom_sorter(prompt, items)
    local input = prompt:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    
    -- Return all items if no input
    if input == "" then
      return items
    end

    local has_uppercase = input:match("%u")
    local parts = get_input_parts(input)
    local has_path_separator = input:match("[/%s]")

    -- Filter and score results
    local results = {}
    for _, item in ipairs(items) do
      local filename = item.filename or vim.fn.fnamemodify(item.value or item.path, ":p")
      local score = 0
      local match = true

      if has_path_separator then
        -- Check if all parts match the path
        for _, part in ipairs(parts) do
          part = part:gsub("^/", "") -- Remove leading slash
          if not filename:lower():match(vim.pesc(part:lower())) then
            match = false
            break
          end
        end
      else
        local search_term = table.concat(parts, "")
        if has_uppercase then
          match = matches_abbreviation(filename, search_term)
          if match then score = score + 100 end -- Prioritize abbreviation matches
        end
        
        if not match then
          match = filename:lower():match(vim.pesc(search_term:lower()))
        end
      end

      if match then
        table.insert(results, {item = item, score = score})
      end
    end

    -- Sort results by score
    table.sort(results, function(a, b) return a.score > b.score end)

    -- Extract just the items
    local filtered = {}
    for _, result in ipairs(results) do
      table.insert(filtered, result.item)
    end

    return filtered
  end

  TSC.find_files({
    attach_mappings = function(prompt_bufnr, map)
      -- Restore default mappings for navigation
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd("edit " .. selection.value)
        end
      end)
      
      local refresh_results = function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local prompt = picker:_get_prompt()
        local finder = picker.finder
        
        -- Apply custom sorting
        local filtered = custom_sorter(prompt, finder.original_results or finder.results)
        
        -- Store original results if not already stored
        if not finder.original_results then
          finder.original_results = finder.results
        end
        
        picker:refresh(require("telescope.finders").new_table({
          results = filtered,
          entry_maker = finder.entry_maker
        }), {reset_prompt = false})
      end

      -- Refresh results on each keystroke
      vim.api.nvim_buf_attach(prompt_bufnr, false, {
        on_lines = function()
          vim.defer_fn(refresh_results, 50) -- Small delay for better performance
        end
      })
      
      return true
    end,
    
    -- Remove the custom finder that starts with empty results
    -- Let telescope use its default file finder
  })
end

local function global_entry_maker(entry)
  local path = entry.path or entry.filename or entry.value or entry
  local filename = vim.fn.fnamemodify(path, ":t")
  local dir = vim.fn.fnamemodify(path, ":h")
  local icon, icon_hl = devicons.get_icon_by_filetype(vim.fn.fnamemodify(filename, ":e"), { default = true })

  -- Handle path length
  dir = (dir == '.' and '')
    or (#dir <= 30 and dir)
    or string.format("%s...%s", string.sub(dir, 1, 20), string.sub(dir, -20))

  local display_icon = icon and (icon .. " ") or ""
  local padded_filename = filename .. string.rep(" ", 30 - #filename)

  return {
    value = path,
    display = string.format("%s%s  %s", display_icon, padded_filename, dir),
    ordinal = filename,
    path = path,
    icon = icon,
    icon_hl = icon_hl,
  }
end

local vertical = {
  layout_strategy = "vertical",
  layout_config = {
    vertical = {
      width = 0.8,
      preview_height = 0.5
    }
  }
}

return {

  goto_usages = function()
    TSC.lsp_references(conf("LSP Usages"), {
      include_declaration = false,
      entry_maker = global_entry_maker,
      layout_config = vertical.layout_config,
      layout_strategy = vertical.layout_strategy,
    })
  end,

  goto_implementations = function()
    TSC.lsp_implementations(conf("LSP impls"))
  end,

  find_files_default = function()
    TSC.find_files({
      layout_config = {
        preview_width = 0 -- Disable preview pane
      },
      entry_maker = global_entry_maker,
      layout_config = vertical.layout_config,
      layout_strategy = vertical.layout_strategy,
    })
  end,

  files_history = function()
    TSC.oldfiles({
      only_cwd = true,
      entry_maker = global_entry_maker,
      layout_config = vertical.layout_config,
      layout_strategy = vertical.layout_strategy,
    })
  end,

}

