# Tooltip data types in WoW: Forever

Source: Blizzard's own UI code for the Forever client, `forever` branch of
[Gethe/wow-ui-source](https://github.com/Gethe/wow-ui-source/tree/forever) (build 1.60.1),
mainly `Blizzard_APIDocumentationGenerated/TooltipInfoSharedDocumentation.lua` and
`Blizzard_SharedXMLGame/Tooltip/TooltipDataHandler.lua`. Forever ships Retail's tooltip code
and API docs, so the enums list Retail-only systems too (Azerite, conduits, battle pets). They
exist in the API but have no content in a classic-era world.

## How tooltip types are used

Every `GameTooltip:SetX(...)` call maps to a `C_TooltipInfo.GetX(...)` function that returns a
data table. `data.type` is an `Enum.TooltipDataType`, and each `data.lines[i].type` is an
`Enum.TooltipDataLineType`. `TooltipDataProcessor.AddTooltipPreCall(type, func)` runs `func` only
for tooltips whose `data.type` matches; `TooltipDataProcessor.AllTypes` (the string `"ALL"`)
runs it for every tooltip.

## Enum.TooltipDataType

| Value | Name | Shown for | Relevant to stat lines |
| --- | --- | --- | --- |
| 0 | Item | Any item: bags, equipped, links, loot, vendors, mail, trade, quest rewards, recipe results in the profession window | Yes, the main source |
| 1 | Spell | Spells, spellbook, action buttons with spells, talents, trainer services | No |
| 2 | Unit | Players, NPCs, mobs | No; text can be secret in combat |
| 3 | Corpse | Corpses under the cursor | No |
| 4 | Object | World objects (chests, herbs, mailboxes) | No |
| 5 | Currency | Currencies and tokens | No |
| 6 | BattlePet | Battle pets (Retail system) | No |
| 7 | UnitAura | Buffs and debuffs | No |
| 8 | AzeriteEssence | Retail system | No |
| 9 | CompanionPet | Companion pets | No |
| 10 | Mount | Mounts | No |
| 11 | PetAction | Pet action bar buttons | No |
| 12 | Achievement | Achievements | No |
| 13 | EnhancedConduit | Retail system | No |
| 14 | EquipmentSet | Equipment manager sets | No |
| 15 | InstanceLock | Raid and dungeon lockouts | No |
| 16 | PvPBrawl | PvP brawls | No |
| 17 | RecipeRankInfo | Retail profession recipe ranks | Possibly, if it lists an item |
| 18 | Totem | Totem bar | No |
| 19 | Toy | Toy box | No |
| 20 | CorruptionCleanser | Retail system | No |
| 21 | MinimapMouseover | Things under the cursor on the minimap | No |
| 22 | Flyout | Action bar flyouts | No |
| 23 | Quest | Quests | No |
| 24 | QuestPartyProgress | Party members' quest progress | No |
| 25 | Macro | Macros | Possibly, a `#showtooltip` item macro |
| 26 | Debug | Developer use | No |
| 27 | Outfit | Outfits | No |

There is no separate "recipe" item type. A recipe in your bags (Plans, Pattern, Formula) is an
`Item` tooltip. How the item it makes is attached (flat lines, a `NestedBlock` line, or a
separate appended tooltip) is decided by the client, not the Lua code, and has not been
confirmed in game yet.

## Enum.TooltipDataLineType

Line types label each line so hooks can target one kind of line with
`TooltipDataProcessor.AddLinePreCall(lineType, func)`. Ones that matter for this addon:

| Value | Name | Notes |
| --- | --- | --- |
| 0 | None | Most plain text lines |
| 19 | NestedBlock | A block of lines from another tooltip inside this one; no Lua handler, so its text is added as-is |
| 22 | ItemName | The item's name line |
| 20 | ItemBinding | Soulbound, Binds when picked up, ... |
| 21 | EquipSlot | Head, Chest, Two-Hand, ... |
| 43 | UsageRequirement | Requires level, class, skill |
| 44, 45, 46 | ItemSpellTriggerOnUse / OnEquip / OnProc | "Use:", "Equip:" and "Chance on hit:" lines |
| 11 | SellPrice | Vendor price |
| 37 | FlavorText | The yellow quote text |

The full list has 52 values (0 to 51): None, Blank, UnitName, GemSocket, AzeriteEssenceSlot,
AzeriteEssencePower, LearnableSpell, UnitThreat, QuestObjective, AzeriteItemPowerDescription,
RuneforgeLegendaryPowerDescription, SellPrice, ProfessionCraftingQuality, SpellName,
CurrencyTotal, ItemEnchantmentPermanent, UnitOwner, QuestTitle, QuestPlayer, NestedBlock,
ItemBinding, EquipSlot, ItemName, Separator, ToyName, ToyText, ToyEffect, ToyDuration,
ToyDescription, ToySource, GemSocketEnchantment, ItemLevel, ItemUpgradeLevel, SpellPassive,
SpellDescription, ItemQuality, TradeTimeRemaining, FlavorText, ItemSpellTriggerLearn,
LearnTransmogSet, LearnTransmogIllusion, ErrorLine, DisabledLine, UsageRequirement,
ItemSpellTriggerOnUse, ItemSpellTriggerOnEquip, ItemSpellTriggerOnProc, UnitLevel, UnitType,
UnitDead, UnitCriteriaProgress, AuraCaster.

## What this means for the addon

- The addon hooks `TooltipDataProcessor.AllTypes`, so stat lines are rewritten whatever kind of
  tooltip they appear in. Lines whose text is a secret value are skipped, because reading them
  from addon code errors.
- A single line's text can hold several lines joined with `\n` (a nested block such as the item
  a recipe makes). The patterns are anchored to the whole string, so the addon splits such text
  and rewrites each line on its own.
- Forever's client also has secret values (`issecretvalue`, `canaccessvalue`), mostly for unit
  and combat data. Item text is not expected to be secret.
