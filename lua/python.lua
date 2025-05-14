local snip = require("luasnip")
local s = snip.snippet
local t = snip.text_node

snip.add_snippets("python", {
  s("main", t({
    'if __name__ == "__main__":',
    '    ',
  })),
})

