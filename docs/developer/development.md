# Development

## Testing in game

The repo root is the addon folder. Link it into the client's AddOns folder so edits show up
after a `/reload`:

```
mklink /J "E:\Program Files (x86)\World of Warcraft\_classic_beta_\Interface\AddOns\carbs-improved-tooltips" "D:\workspace\carbs-improved-tooltips"
```

## How the tooltip rewrite works

`carbs-improved-tooltips.lua` registers a `TooltipDataProcessor.AddTooltipPreCall` for item tooltips and runs
every left-hand line through `getReplacementText` before the tooltip is drawn.

- Every rewrite is one entry in the `rules` table: an anchored `pattern` and a `format`
  function that receives the pattern's captures and returns the new text.
- Rules are tried in order and the first match wins. Each line runs one `text:match` per rule,
  and its captures go straight into `format`, so nothing is matched twice.
- Every pattern starts with `^Equip: `, so a line that isn't an Equip line fails each pattern
  within its first few characters. Anchoring also leaves lines that only look similar alone.
- A line that becomes two stats (damage and healing) returns both joined with `\n`.
- To add a rewrite, add a rule and a row to the README table.

The client is interface 16001: a Retail-style API with classic-era item text.
