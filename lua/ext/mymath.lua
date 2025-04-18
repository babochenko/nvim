local _visual = require('ext/getvisual').getvisual

local function _writeln(line, value)
  local head = vim.fn.getline(line.line):sub(1, line.lcol-1)
  local tail = vim.fn.getline(line.line):sub(line.rcol+1)
  vim.fn.setline(line.line, head .. value .. tail)
end

local function _num_write(func)
  local vis = _visual()
  if vis == nil then return end

  for _, line in ipairs(vis) do
    local number = tonumber(line.text)
    if not number then
      vim.api.nvim_err_writeln("No valid number selected: " .. line.text)
      return
    end

    _writeln(line, func(number))
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

local function _eval(line)
  local expr = line.text
  if expr:gsub("%s", ""):match('^[.,0-9%+%-%*/()%%^]*$') then
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

function _G.EvalAndInsert()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  if line:sub(col - 1, col + 1) == " = " then
    local expr = vim.trim(line:sub(1, col - 2))
    local ok, result = pcall(vim.fn.eval, expr)
    if ok then
      local new_line = line:sub(1, col + 1) .. tostring(result)
      vim.api.nvim_set_current_line(new_line)
    else
      print("Eval error")
    end
  else
    print("Cursor not after ' = '")
  end
end

make_cmd0('Eval', function()
  local vis = _visual()
  if vis == nil then return end

  for _, line in ipairs(vis) do
    _eval(line)
  end
end)

