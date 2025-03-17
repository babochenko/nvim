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

local function _visual()
  local l = vim.fn.getpos("'<")
  local r = vim.fn.getpos("'>")
  local l1, lcol = l[2], l[3]
  local l2, rcol = r[2], r[3]

  local lines = vim.api.nvim_buf_get_lines(0, l1-1, l2, false)
  local res = {}
  if #lines == 1 then
    res = {{string.sub(lines[1], lcol, rcol), l1, lcol, rcol}}
  else
    local liter = l1
    for i, v in ipairs(lines) do
      res[i] = {v, liter, -1, #v-1}
      liter = liter+1
    end

    res[1][1] = string.sub(lines[1], lcol)
    res[1][3] = lcol
    res[#lines][1] = string.sub(lines[#lines], 1, rcol)
    res[#lines][4] = rcol
  end

  return res
end

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
end

make_cmd0('Eval', function()
  local v = _visual()
  if v == nil then return end

  for _, v in ipairs(v) do
    local expr, l, r = v[1], v[3], v[4]
    _eval(expr, l, r)
  end
end)

