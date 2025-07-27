local test = require('tests.test_framework')
local testing = require('lua.ext.testing')

-- Mock vim functions for testing
local mock_vim = {
  fn = {
    expand = function(arg)
      if arg == '%:p' then return '/path/to/test_example.py' end
      if arg == '%:t' then return 'test_example.py' end
      if arg == '%:e' then return 'py' end
      if arg == '%:h' then return '/path/to' end
      return ''
    end,
    line = function() return 1 end,
  },
  api = {
    nvim_buf_get_lines = function() return {'def test_something():', '    pass'} end,
    nvim_get_current_buf = function() return 1 end,
    nvim_create_namespace = function() return 1 end,
    nvim_create_augroup = function() return 1 end,
    nvim_create_autocmd = function() end,
  },
  cmd = function() end,
  b = { terminal_job_id = 1 }
}

-- Store original vim reference
local original_vim = vim
vim = mock_vim

test.describe("testing.lua module", function()

  test.describe("detect_language function", function()
    
    test.it("should detect Python test files", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'test_example.py' end
        if arg == '%:e' then return 'py' end
        return ''
      end
      
      local result = testing.detect_language()
      test.assert_equals(result, "python")
    end)
    
    test.it("should detect JavaScript test files", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'example.test.js' end
        if arg == '%:e' then return 'js' end
        return ''
      end
      
      local result = testing.detect_language()
      test.assert_equals(result, "javascript")
    end)
    
    test.it("should detect TypeScript test files", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'example.test.ts' end
        if arg == '%:e' then return 'ts' end
        return ''
      end
      
      local result = testing.detect_language()
      test.assert_equals(result, "typescript")
    end)
    
    test.it("should detect Go test files", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'example_test.go' end
        if arg == '%:e' then return 'go' end
        return ''
      end
      
      local result = testing.detect_language()
      test.assert_equals(result, "go")
    end)
    
    test.it("should detect Rust test files with #[test] annotation", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'lib.rs' end
        if arg == '%:e' then return 'rs' end
        return ''
      end
      
      vim.api.nvim_buf_get_lines = function()
        return {'#[test]', 'fn test_something() {', '}'}
      end
      
      local result = testing.detect_language()
      test.assert_equals(result, "rust")
    end)
    
    test.it("should return nil for non-test files", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'regular_file.py' end
        if arg == '%:e' then return 'py' end
        return ''
      end
      
      local result = testing.detect_language()
      test.assert_nil(result)
    end)
    
    test.it("should return nil for Rust files without #[test] annotation", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'lib.rs' end
        if arg == '%:e' then return 'rs' end
        return ''
      end
      
      vim.api.nvim_buf_get_lines = function()
        return {'fn main() {', '}'}
      end
      
      local result = testing.detect_language()
      test.assert_nil(result)
    end)
    
  end)

  test.describe("pattern matching behavior", function()
    
    test.it("should handle Python test function patterns", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'test_example.py' end
        if arg == '%:e' then return 'py' end
        return ''
      end
      
      vim.api.nvim_buf_get_lines = function() 
        return {
          'def test_addition():',
          '    pass',
          'def not_a_test():',
          '    pass',
          'def test_subtraction():',
          '    pass'
        }
      end
      
      local lang = testing.detect_language()
      test.assert_equals(lang, "python")
    end)
    
    test.it("should handle JavaScript test function patterns", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'example.test.js' end
        if arg == '%:e' then return 'js' end
        return ''
      end
      
      vim.api.nvim_buf_get_lines = function()
        return {
          'test("should add numbers", () => {',
          '  expect(1 + 1).toBe(2);',
          '});',
          'it("should subtract numbers", () => {',
          '  expect(2 - 1).toBe(1);',
          '});'
        }
      end
      
      local lang = testing.detect_language()
      test.assert_equals(lang, "javascript")
    end)
    
    test.it("should handle Go test function patterns", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'example_test.go' end
        if arg == '%:e' then return 'go' end
        return ''
      end
      
      vim.api.nvim_buf_get_lines = function()
        return {
          'func TestAddition(t *testing.T) {',
          '  // test code',
          '}',
          'func TestSubtraction(t *testing.T) {',
          '  // test code',
          '}'
        }
      end
      
      local lang = testing.detect_language()
      test.assert_equals(lang, "go")
    end)
    
    test.it("should handle Rust test function patterns", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'lib.rs' end
        if arg == '%:e' then return 'rs' end
        return ''
      end
      
      vim.api.nvim_buf_get_lines = function()
        return {
          '#[test]',
          'fn test_addition() {',
          '  assert_eq!(1 + 1, 2);',
          '}',
          '#[test]',
          'fn test_subtraction() {',
          '  assert_eq!(2 - 1, 1);',
          '}'
        }
      end
      
      local lang = testing.detect_language()
      test.assert_equals(lang, "rust")
    end)
    
  end)

  test.describe("edge cases", function()
    
    test.it("should handle empty files", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'test_empty.py' end
        if arg == '%:e' then return 'py' end
        return ''
      end
      
      vim.api.nvim_buf_get_lines = function()
        return {}
      end
      
      local lang = testing.detect_language()
      test.assert_equals(lang, "python")
    end)
    
    test.it("should handle files with comments only", function()
      vim.fn.expand = function(arg)
        if arg == '%:t' then return 'test_comments.py' end
        if arg == '%:e' then return 'py' end
        return ''
      end
      
      vim.api.nvim_buf_get_lines = function()
        return {'# This is a test file', '# with only comments'}
      end
      
      local lang = testing.detect_language()
      test.assert_equals(lang, "python")
    end)
    
  end)

end)

-- Restore original vim
vim = original_vim

-- Run the tests
test.run_tests()
