local function get_visual_selection()
    -- Get visual mode and start/end positions
    local mode = vim.fn.visualmode()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")

    local start_row = start_pos[2] - 1
    local start_col = start_pos[3] - 1
    local end_row = end_pos[2] - 1
    local end_col = end_pos[3] - 1

    local lines = {}

    if mode == "v" or mode == "V" then
        -- Character-wise or line-wise selection
        lines = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col + 1, {})
    elseif mode == "\22" then  -- Block mode ("\22" is Ctrl+V)
        -- Handle block selection manually
        for row = start_row, end_row do
            local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
            local text = line:sub(start_col + 1, end_col + 1)
            table.insert(lines, text)
        end
    end

    return table.concat(lines, "\n")
end

local function _visual_line(lines, l1, lcol, rcol)
  local res = {}
  local liter = l1
  for i, v in ipairs(lines) do
    res[i] = {v, liter, -1, #v-1}
    liter = liter+1
  end

  res[1][1] = string.sub(lines[1], lcol)
  res[1][3] = lcol
  res[#lines][1] = string.sub(lines[#lines], 1, rcol)
  res[#lines][4] = rcol
  return res
end

local function _visual_block(l1, l2, lcol, rcol)
  local res = {}
  for row = l1, l2 do
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
    local text = line:sub(lcol+1, rcol+1)
    table.insert(res, text)
  end
  return res
end

local function _visual()
  local l = vim.fn.getpos("'<")
  local r = vim.fn.getpos("'>")
  local l1, lcol = l[2], l[3]
  local l2, rcol = r[2], r[3]

  local lines = vim.api.nvim_buf_get_lines(0, l1-1, l2, false)
  if #lines == 1 then
    return {{string.sub(lines[1], lcol, rcol), l1, lcol, rcol}}
  else
    local mode = vim.fn.visualmode()
    if mode == "v" or mode == "V" then
      return _visual_line(lines, l1, lcol, rcol)
    elseif mode == "\22" then -- Block mode ("\22" is Ctrl+V)
      return _visual_block(l1, l2, lcol, rcol)
    else
      return {}
    end
  end
end

return {
  getvisual = _visual,
}

