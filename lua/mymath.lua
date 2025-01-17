local function _num()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  local selected_text = table.concat(lines, "\n"):sub(start_pos[3], end_pos[3])
  return tonumber(selected_text), start_pos, end_pos
end

local function _num_write(func)
  local number, start_pos, end_pos = _num()
  if not number then
    vim.api.nvim_err_writeln("No valid number selected.")
    return
  end

  local result = func(number)
  vim.fn.setline(start_pos[2], vim.fn.getline(start_pos[2]):sub(1, start_pos[3] - 1) .. result .. vim.fn.getline(end_pos[2]):sub(end_pos[3] + 1))
end

function _G.mul(factor)
  return _num_write(function(num) return num * factor end)
end

