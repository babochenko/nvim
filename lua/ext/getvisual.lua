---@return table<string, number, number, number>
local function _visual_line(l1, lcol, rcol)
  local lines = vim.api.nvim_buf_get_lines(0, l1-1, l1, false)
  return {{
    text=string.sub(lines[1], lcol, rcol),
    line=l1,
    lcol=lcol,
    rcol=rcol,
  }}
end

local function _visual_lines(l1, l2, lcol, rcol)
  local res = {}
  local liter = l1
  local lines = vim.api.nvim_buf_get_lines(0, l1-1, l2, false)
  for i, v in ipairs(lines) do
    res[i] = {
      text=v,
      line=liter,
      lcol=-1,
      rcol=#v-1,
    }
    liter = liter+1
  end

  res[1].text = string.sub(lines[1], lcol)
  res[1].lcol = lcol
  res[#lines].text = string.sub(lines[#lines], 1, rcol)
  res[#lines].rcol = rcol
  return res
end

local function _visual_block(l1, l2, lcol, rcol)
  local res = {}
  for row = l1, l2 do
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
    local text = line:sub(lcol+1, rcol+1)
    table.insert(res, {
      text=text,
      line=row,
      lcol=lcol,
      rcol=rcol,
    })
  end
  return res
end

local function _visual()
  local l = vim.fn.getpos("'<")
  local r = vim.fn.getpos("'>")
  local l1, lcol = l[2], l[3]
  local l2, rcol = r[2], r[3]

  if l1 == l2 then
    return _visual_line(l1, lcol, rcol)
  else
    local mode = vim.fn.visualmode()
    if mode == "v" or mode == "V" then
      return _visual_lines(l1, l2, lcol, rcol)
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

