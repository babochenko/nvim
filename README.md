## convert sec.gov reports to epub

First, clean up the DOM:
```javascript
[
  ['page headers', 'div[style="min-height:72pt;width:100%"]'],
  ['page footers', 'div[style="height:72pt;position:relative;width:100%"]'],
  ['page breaks', 'hr[style="page-break-after:always"]'],
  ['top nav', 'div[id="topNavs"]'],
  ['bottom nav', 'nav'],
].forEach(it => {
  $$(it[1]).forEach(e => e.remove())
})
```

then, save as htmlx and convert to epub:
```bash
pandoc full.html -o report.epub --metadata title="Robinhood 10-K"
```

