local snip = require("luasnip")
local s = snip.snippet
local t = snip.text_node
local f = snip.function_node

local function get_db()
  local db = vim.b.db or ""
  return db:match(".*/([^/?]+)$") or ""
end

snip.add_snippets("python", {
  s("main", t({
    'if __name__ == "__main__":',
    '    ',
  })),
})

local function sql_snippets()
  local snippets = {}
  local db_name = get_db()
  vim.g.db = db_name

  if db_name == "authentication" then
    snippets = {
      s("devices", t({
        "select id, last_used_date, state, brand, app_name, device_token",
        "from devices",
        "where owner_id = ''",
        "order by last_used_date desc",
      })),
      s("apple", t({ "and brand = 'Apple'" })),
      s("browser", t({ "and brand = 'Browser'" })),
      s("active", t({ "and state = 'ACTIVE'" })),
    }

  end
  
  return snippets
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function()
    snip.add_snippets("sql", sql_snippets())
  end,
})

