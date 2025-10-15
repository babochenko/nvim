local snip = require("luasnip")
local s = snip.snippet
local t = snip.text_node
local f = snip.function_node

local function get_db()
  local db = vim.b.db or ""
  return db:match(".*/([^/?]+)$") or ""
end

local function concat(a, b)
  local result = {}
  for i = 1, #a do
    result[#result+1] = a[i]
  end
  for i = 1, #b do
    result[#result+1] = b[i]
  end
  return result
end

snip.add_snippets("python", {
  s("main", t({
    'if __name__ == "__main__":',
    '    ',
  })),
})

local function sql_snippets()
  local snippets = {
      s('1d', t({ "and created_date > now() - interval '1 day'" }))
  }

  local db_name = get_db()
  vim.g.db = db_name

  if db_name == "authentication" then
    snippets = concat(snippets, {
      s("devices", t({
        "select id, last_used_date, state, brand, app_name, device_token",
        "from devices",
        "where 1 = 1",
        "-- and owner_id = ''",
        "-- and brand = 'Apple'",
        "-- and brand = 'Browser'",
        "-- and state = 'ACTIVE'",
        "order by last_used_date desc",
      })),
    })

  elseif db_name == 'market-comms' then
    snippets = concat(snippets, {
        s('recipients', t({
            "select * from NOTIFICATION_RECIPIENTS",
            "where 1 = 1",
            "-- and user_id = ''",
            "-- and base_currency = ''",
            "order by created_date desc",
        })),
    })

  end
  
  return snippets
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function()
    snip.add_snippets("sql", sql_snippets())
  end,
})

