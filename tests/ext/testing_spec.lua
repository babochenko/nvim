local testing = require('ext.testing')

-- Store original vim functions
local original_expand = vim.fn.expand
local original_buf_get_lines = vim.api.nvim_buf_get_lines

function trim(str)
  local indent = str:match("\n([ \t]+)")
  if not indent then return str end
  return str:gsub("\n" .. indent, "\n"):gsub("^\n", ""):gsub("\n$", "")
end

-- Helper function to mock file and buffer content
local function mock_file(filename, buffer_content)
  local extension = filename:match("%.([^%.]+)$") or ""
  
  vim.fn.expand = function(arg)
    if arg == '%:p' then return '/path/to/' .. filename end
    if arg == '%:t' then return filename end
    if arg == '%:e' then return extension end
    if arg == '%:h' then return '/path/to' end
    return ''
  end
  
  local lines = {}
  if buffer_content then
    buffer_content = trim(buffer_content)
    for line in buffer_content:gmatch("[^\r\n]+") do
      table.insert(lines, line)
    end
  end
  
  vim.api.nvim_buf_get_lines = function()
    return lines
  end
end

-- Helper function to restore vim functions
local function restore_vim()
  vim.fn.expand = original_expand
  vim.api.nvim_buf_get_lines = original_buf_get_lines
end

describe("testing.lua module", function()

  describe("detect_language function", function()
    
    it("should detect Python test files", function()
      mock_file('test_example.py')
      local result = testing.detect_language()
      assert.equals(result, "python")
      restore_vim()
    end)
    
    it("should detect JavaScript test files", function()
      mock_file('example.test.js')
      local result = testing.detect_language()
      assert.equals(result, "javascript")
      restore_vim()
    end)
    
    it("should detect TypeScript test files", function()
      mock_file('example.test.ts')
      local result = testing.detect_language()
      assert.equals(result, "typescript")
      restore_vim()
    end)
    
    it("should detect Go test files", function()
      mock_file('example_test.go')
      local result = testing.detect_language()
      assert.equals(result, "go")
      restore_vim()
    end)
    
    it("should detect Rust test files with #[test] annotation", function()
      mock_file('lib.rs', [[
          #[test]
          fn test_something() {
          }
      ]])
      local result = testing.detect_language()
      assert.equals(result, "rust")
      restore_vim()
    end)
    
    it("should return nil for non-test files", function()
      mock_file('regular_file.py')
      local result = testing.detect_language()
      assert.equals(result, nil)
      restore_vim()
    end)
    
    it("should return nil for Rust files without #[test] annotation", function()
      mock_file('lib.rs', [[
          fn main() {
          }
      ]])
      local result = testing.detect_language()
      assert.equals(result, nil)
      restore_vim()
    end)
    
  end)

  describe("pattern matching behavior", function()
    
    it("should handle Python test function patterns", function()
      mock_file('test_example.py', [[
          def test_addition():
              pass
          def not_a_test():
              pass
          def test_subtraction():
              pass
      ]])
      local lang = testing.detect_language()
      assert.equals(lang, "python")
      restore_vim()
    end)
    
    it("should handle JavaScript test function patterns", function()
      mock_file('example.test.js', [[
          test("should add numbers", () => {
              expect(1 + 1).toBe(2);
          });
          it("should subtract numbers", () => {
              expect(2 - 1).toBe(1);
          });
      ]])
      local lang = testing.detect_language()
      assert.equals(lang, "javascript")
      restore_vim()
    end)
    
    it("should handle Go test function patterns", function()
      mock_file('example_test.go', [[
          func TestAddition(t *testing.T) {
              // test code
          }
          func TestSubtraction(t *testing.T) {
              // test code
          }
      ]])
      local lang = testing.detect_language()
      assert.equals(lang, "go")
      restore_vim()
    end)
    
    it("should handle Rust test function patterns", function()
      mock_file('lib.rs', [[
          #[test]
          fn test_addition() {
              assert_eq!(1 + 1, 2);
          }

          #[test]
          fn test_subtraction() {
              assert_eq!(2 - 1, 1);
          }
      ]])
      local lang = testing.detect_language()
      assert.equals(lang, "rust")
      restore_vim()
    end)
    
  end)

  describe("edge cases", function()
    
    it("should handle empty files", function()
      mock_file('test_empty.py', '')
      local lang = testing.detect_language()
      assert.equals(lang, "python")
      restore_vim()
    end)
    
    it("should handle files with comments only", function()
      mock_file('test_comments.py', [[
          # This is a test file
          # with only comments
      ]])
      local lang = testing.detect_language()
      assert.equals(lang, "python")
      restore_vim()
    end)
    
  end)

end)