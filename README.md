# Carbs Improved Tooltips

A World of Warcraft: Forever addon that makes item tooltips easier to read.

Classic-era items describe their bonuses in long sentences such as "Equip: Increases damage
and healing done by magical spells and effects by up to 23." Carbs Improved Tooltips replaces
those lines with short stat lines, so you can compare gear at a glance.

## Installation

Install it from CurseForge or Wago Addons with your addon manager, or download the zip from
the GitHub release and extract it into `Interface/AddOns/`.

## Usage

There is nothing to set up. Once the addon is enabled, hover over any item and its tooltip
uses the short lines below.

## What changes

"Spell Power" always means spell damage. Healing bonuses are shown separately as
"Heal Power".

| Original tooltip line | Shown as |
| --- | --- |
| Equip: Increases damage and healing done by magical spells and effects by up to 23. | +23 Spell Power<br>+23 Heal Power |
| Equip: Increases damage done by magical spells and effects by up to 12. | +12 Spell Power |
| Equip: Increases damage done by Fire spells and effects by up to 30. | +30 Fire Spell Power |
| Equip: Increases damage done to Undead by magical spells and effects by up to 48. | +48 Spell Power against Undead |
| Equip: Increases healing done by up to 44 and damage done by up to 15 for all magical spells and effects. | +15 Spell Power<br>+44 Heal Power |
| Equip: Increases healing done by spells and effects by up to 22. | +22 Heal Power |
| Equip: +28 Attack Power. | +28 Attack Power |

Every other tooltip line is left as it is.

## License

MIT, see [LICENSE](LICENSE).
