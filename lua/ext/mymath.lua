local _visual = require('ext/getvisual').getvisual

local function _writeln(line, l, r, value)
  local head = vim.fn.getline(line):sub(1, l-1)
  local tail = vim.fn.getline(line):sub(r+1)
  vim.fn.setline(line, head .. value .. tail)
end

local function _num_write(func)
  local v = _visual()
  if v == nil then return end

  for _, v in ipairs(v) do
    local _num, line, l, r = v[1], v[2], v[3], v[4]
    local number = tonumber(_num)
    if not number then
      vim.api.nvim_err_writeln("No valid number selected: " .. _num)
      return
    end

    _writeln(line, l, r, func(number))
  end
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

local function _eval(expr, l, r)
  if expr:gsub("%s", ""):match('^[0-9%+%-%*/()%%^]*$') then
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
end

make_cmd0('Eval', function()
  local v = _visual()
  if v == nil then return end

  for _, v in ipairs(v) do
    local expr, l, r = v[1], v[3], v[4]
    _eval(expr, l, r)
  end
end)

