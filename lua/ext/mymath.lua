local function _visual()
  local l = vim.fn.getpos("'<")
  local r = vim.fn.getpos("'>")
  local l1, lcol = l[2], l[3]
  local l2, rcol = r[2], r[3]

  local lines = vim.api.nvim_buf_get_lines(0, l1-1, l2, false)
  if #lines == 0 then
    return {}
  elseif #lines == 1 then
    return {string.sub(lines[1], lcol, rcol)}
  else
    lines[1] = string.sub(lines[1], lcol)
    lines[#lines] = string.sub(lines[#lines], 1, rcol)
    return table
  end
end

local function _num()
  local l = vim.fn.getpos("'<")
  local r = vim.fn.getpos("'>")
  local lines = vim.fn.getline(l[2], r[2])
  local selected_text = table.concat(lines, "\n"):sub(l[3], r[3])
  return tonumber(selected_text), l, r
end

local function _writeln(line, l, r, value)
  local head = vim.fn.getline(line):sub(1, l-1)
  local tail = vim.fn.getline(line):sub(r+1)
  vim.fn.setline(line, head .. value .. tail)
end

local function _num_write(func)
  local number, l, r = _num()
  if not number then
    vim.api.nvim_err_writeln("No valid number selected.")
    return
  end

  _writeln(l[2], l[3], r[3], func(number))
end

local function make_cmd1(name, func)
  vim.api.nvim_create_user_command(name, function(opts)
    local factor = tonumber(opts.args)
    if factor then
      func(factor)
    else
      print("Invalid number")
    end
  end, { nargs = 1, range = true })
end

local function make_cmd0(name, func)
  vim.api.nvim_create_user_command(name, func, { nargs = 0, range = true })
end

local MyMath = {
  Add = function(factor) _num_write(function(num) return num + factor end) end,
  Sub = function(factor) _num_write(function(num) return num - factor end) end,
  Mul = function(factor) _num_write(function(num) return num * factor end) end,
  Div = function(factor) _num_write(function(num) return num / factor end) end,
  Pow = function(factor) _num_write(function(num) return num ^ factor end) end,
}

for name, func in pairs(MyMath) do
  make_cmd1(name, func)
end

make_cmd0('Eval', function()
  local v = _visual()
  if v == nil then return end

  local expr = v[1]
  if expr:match('^[0-9%+%-%*/()%% ^]*$') then
    local safe_expr = expr:gsub("%^", "**")
    local result = load("return " .. safe_expr)
    if result then
      print("Result: " .. result())
    else
      print("Invalid expression: " .. safe_expr)
    end
  else
    print("Invalid expression: " .. expr)
  end
end)

