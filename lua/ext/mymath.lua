local function _num()
  local l = vim.fn.getpos("'<")
  local r = vim.fn.getpos("'>")
  local lines = vim.fn.getline(l[2], r[2])
  local selected_text = table.concat(lines, "\n"):sub(l[3], r[3])
  return tonumber(selected_text), l, r
end

local function _num_write(func)
  local number, l, r = _num()
  if not number then
    vim.api.nvim_err_writeln("No valid number selected.")
    return
  end

  local result = func(number)
  local head = vim.fn.getline(l[2]):sub(1, l[3] - 1)
  local tail = vim.fn.getline(r[2]):sub(r[3] + 1)
  vim.fn.setline(l[2], head .. result .. tail)
end

local function make_cmd(name, func)
  vim.api.nvim_create_user_command(name, function(opts)
    local factor = tonumber(opts.args)
    if factor then
      func(factor)
    else
      print("Invalid number")
    end
  end, { nargs = 1, range = true })
end

local MyMath = {
  Add = function(factor) _num_write(function(num) return num + factor end) end,
  Sub = function(factor) _num_write(function(num) return num - factor end) end,
  Mul = function(factor) _num_write(function(num) return num * factor end) end,
  Div = function(factor) _num_write(function(num) return num / factor end) end,
  Pow = function(factor) _num_write(function(num) return num ^ factor end) end,
}

for name, func in pairs(MyMath) do
  make_cmd(name, func)
end

make_cmd('Eval', function()
  local expr = vim.fn.expand('<cword>')
  if expr:match('^[0-9%+%-%*/()%%^]*$') then
    local safe_expr = expr:gsub("%^", "**")
    local result = load("return " .. safe_expr)
    if result then
      print("Result: " .. result())
    else
      print("Invalid expression!")
    end
  else
    print("Invalid expression!")
  end
end)

