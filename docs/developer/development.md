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

- A plain `string.find` for "spells and effects", "Attack Power" or "Increased Defense" filters out most lines
  before any pattern matching runs.
- Each known sentence has an anchored pattern, so lines that only look similar are left alone.
- A line that becomes two stats (damage and healing) returns both joined with `\n`.

The client is interface 16001: a Retail-style API with classic-era item text.
