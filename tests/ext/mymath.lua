local M = require 'ext/mymath'

describe("evaluates", function()
  it("sum", function()
    assert.equals("Result: 3", M._eval("1+2"))
  end)
end)

