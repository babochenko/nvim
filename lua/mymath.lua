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

function _G.add(factor)
  return _num_write(function(num) return num + factor end)
end

function _G.sub(factor)
  return _num_write(function(num) return num - factor end)
end

function _G.mul(factor)
  return _num_write(function(num) return num * factor end)
end

function _G.div(factor)
  return _num_write(function(num) return num / factor end)
end

function _G.pow(factor)
  return _num_write(function(num) return num ^ factor end)
end

