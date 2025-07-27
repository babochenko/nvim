local M = {}

local tests = {}
local stats = { passed = 0, failed = 0 }

function M.describe(name, fn)
  print("Running tests for: " .. name)
  fn()
end

function M.it(description, fn)
  local status, result = pcall(fn)
  if status then
    print("  ✓ " .. description)
    stats.passed = stats.passed + 1
  else
    print("  ✗ " .. description .. " - " .. tostring(result))
    stats.failed = stats.failed + 1
  end
end

function M.assert_equals(actual, expected, message)
  if actual ~= expected then
    local msg = message or ("Expected " .. tostring(expected) .. " but got " .. tostring(actual))
    error(msg)
  end
end

function M.assert_true(value, message)
  if not value then
    local msg = message or ("Expected true but got " .. tostring(value))
    error(msg)
  end
end

function M.assert_false(value, message)
  if value then
    local msg = message or ("Expected false but got " .. tostring(value))
    error(msg)
  end
end

function M.assert_nil(value, message)
  if value ~= nil then
    local msg = message or ("Expected nil but got " .. tostring(value))
    error(msg)
  end
end

function M.assert_not_nil(value, message)
  if value == nil then
    local msg = message or "Expected non-nil value"
    error(msg)
  end
end

function M.assert_table_equals(actual, expected, message)
  local function deep_equals(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    
    for k, v in pairs(a) do
      if not deep_equals(v, b[k]) then return false end
    end
    
    for k, v in pairs(b) do
      if not deep_equals(v, a[k]) then return false end
    end
    
    return true
  end
  
  if not deep_equals(actual, expected) then
    local msg = message or "Tables are not equal"
    error(msg)
  end
end

function M.run_tests()
  print("\n=== Test Results ===")
  print("Passed: " .. stats.passed)
  print("Failed: " .. stats.failed)
  print("Total: " .. (stats.passed + stats.failed))
  
  if stats.failed > 0 then
    print("Status: FAILED")
    return false
  else
    print("Status: PASSED")
    return true
  end
end

return M