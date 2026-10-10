# What addons can change on item tooltips

Short answer: yes, an addon can change the text, the color and the font of any tooltip line.
It can also hide lines, add new lines, and put icons in them. Tooltips are not protected frames,
so all of this works in combat too.

## Where this comes from

ForeverProbe reported the client as build 1.60.1 (70009), interface 16001,
`WOW_PROJECT_ID = 1` (mainline). So the tooltip code is Retail's data-driven tooltip system, not
the old Classic `OnTooltipSetItem` script. Everything below is read from Blizzard's Retail UI
source (`Blizzard_SharedXMLGame/Tooltip/TooltipDataHandler.lua` and
`Blizzard_SharedXML/SharedTooltipTemplates.*` in Gethe/wow-ui-source). It has not been tested
in the Forever client yet; anything Forever changed could differ.

## How an item tooltip is built

1. The client returns the tooltip as data: `data.lines`, one table per line with `leftText`,
   `leftColor`, `rightText`, `rightColor`, `wrapText`, `leftOffset` and a `type`.
2. Tooltip pre-calls run (`TooltipDataProcessor.AddTooltipPreCall`). This addon hooks here today.
3. For each line: line pre-calls run (`AddLinePreCall`), then the line is added with
   `GameTooltip_AddColoredLine(tooltip, leftText, leftColor or NORMAL_FONT_COLOR, wrapText)`,
   then line post-calls run (`AddLinePostCall`) with `lineData.lineIndex` set.
4. Tooltip post-calls run (`AddTooltipPostCall`), then the tooltip is shown.

This runs for every tooltip that uses the data system: `GameTooltip`, the compare tooltips
(`ShoppingTooltip1/2`) and chat link tooltips (`ItemRefTooltip`), so a hook covers all of them.

## Text

Change `line.leftText` / `line.rightText` in a pre-call, as the addon does now. A `\n` in the text
splits it into two visual lines, but they share one color and one font.

## Color

Two ways, both in a pre-call:

- Whole line: `line.leftColor = CreateColor(r, g, b)` (values 0 to 1). Blizzard passes it
  straight to `AddColoredLine`.
- Part of a line: color escapes in the text, e.g. `"|cff00ff00+23|r Spell Power"`. These work in
  any font string, so one line can mix colors.

## Font

There is no inline font escape; a font belongs to the whole font string (one tooltip line side).

- One line: in a line post-call (or a tooltip post-call), get the line's font string with
  `tooltip:GetLeftLine(lineData.lineIndex)` and call `:SetFont(path, size, flags)` or
  `:SetFontObject(fontObject)`.
- Catch: the tooltip reuses its font strings and only sets their font objects once, when the
  tooltip loads (`SharedTooltip_OnLoad`). A font set on line 5 stays on line 5 of the next
  tooltip, so the addon must put the default back (`GameTooltipText`, or `GameTooltipHeaderText`
  for line 1) whenever the tooltip is cleared or before setting a new one.
- Every tooltip at once: change the shared font objects, e.g.
  `GameTooltipText:SetFont(path, size, flags)`. This also affects other UI that uses those
  objects.
- Font files: the client's own (`Fonts\FRIZQT__.TTF`, `Fonts\ARIALN.TTF`, `Fonts\skurri.ttf`,
  `Fonts\MORPHEUS.TTF`) or a `.ttf` shipped in the addon folder
  (`Interface\AddOns\carbs-improved-tooltips\fonts\...`). A font must exist when the UI loads;
  new files need a client restart, not just `/reload`.

## Other things an addon can do

- Hide a line: a line pre-call that returns `true` consumes the line, so it is never added.
- Add lines: `tooltip:AddLine(text, r, g, b, wrap)` or `AddDoubleLine` in a post-call.
- Icons: `|T<texture path or fileID>:<size>|t` or `|A<atlas>:<h>:<w>|a` inside the text, or
  `tooltip:AddTexture(...)`.
- Target lines by kind: line hooks are keyed by `Enum.TooltipDataLineType`, which includes
  `ItemSpellTriggerOnEquip`, `ItemSpellTriggerOnUse`, `ItemBinding`, `SellPrice`, `FlavorText`
  and others. Whether Forever tags classic "Equip:" stat lines as `ItemSpellTriggerOnEquip` is
  unverified; if it does, hooking that type alone would be cheaper than scanning every line.
- Rebuilds: when item data arrives late (`TOOLTIP_DATA_UPDATE`) the tooltip is rebuilt and the
  hooks run again. Rewrites must be safe to apply twice; the current ones are, because the
  rewritten text no longer matches the patterns.

## Limits

- Addon hooks run as insecure code (Blizzard wraps them in `forceinsecure()`). That is fine for
  tooltips, which are not protected.
- The tooltip's width follows its longest line, so a bigger font makes the tooltip wider.
- None of this is confirmed in the Forever client yet. A quick in-game probe that prints each
  line's `type` and tries `leftColor` and `SetFont` on one line would confirm it.
