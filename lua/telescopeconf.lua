local TSC = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

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

local function find_files_default()
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then return end

  telescope.find_files({
    layout_config = {
      preview_width = 0 -- Disable preview pane
    },
    path_display = function(_, path)
      local filename = vim.fn.fnamemodify(path, ":t")
      local dir = vim.fn.fnamemodify(path, ":h")
      
      -- Pad filename to 30 chars with spaces
      local padded_filename = filename .. string.rep(" ", 30 - #filename)
      
      -- Handle path length
      dir = #dir <= 30
        and dir
        or string.format("%s...%s", string.sub(dir, 1, 20), string.sub(dir, -20))
      return string.format("%s  %s", padded_filename, dir)
    end
  })
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

local function usages()
  TSC.lsp_references(conf("LSP Usages"), {
    include_declaration = false
  })
end

local function goto_usages()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, 'textDocument/references', params, function(err, result)
    if err or not result then
      usages()
      return
    end
    
    -- Filter out declaration
    local refs = vim.tbl_filter(function(ref)
      local is_decl = ref.isDeclaration or false
      return not is_decl
    end, result)

    if #refs == 0 then
      vim.notify("No usages found")

    elseif #refs == 1 then
      -- Jump directly if only one usage
      local ref = refs[1]
      vim.cmd(string.format('edit %s', vim.uri_to_fname(ref.uri)))
      vim.api.nvim_win_set_cursor(0, {ref.range.start.line + 1, ref.range.start.character})
    else
      -- Show telescope picker for multiple results
      usages()
    end
  end)
end

return {
  goto_usages = function()
     TSC.lsp_references(conf("LSP Usages"), { include_declaration = false })
  end,

  goto_implementations = function() TSC.lsp_implementations(conf("LSP impls")) end,

  find_files = find_files,
  find_files_default = find_files_default,

  files_history = function()
    TSC.oldfiles { only_cwd = true }
  end,

}

