# Tooltip data types in WoW: Forever

Source: Blizzard's own UI code for the Forever client, `forever` branch of
[Gethe/wow-ui-source](https://github.com/Gethe/wow-ui-source/tree/forever) (build 1.60.1),
mainly `Blizzard_APIDocumentationGenerated/TooltipInfoSharedDocumentation.lua` and
`Blizzard_SharedXMLGame/Tooltip/TooltipDataHandler.lua`. Forever ships Retail's tooltip code
and API docs, so the enums list Retail-only systems too (Azerite, conduits, battle pets). They
exist in the API but have no content in a classic-era world. The enum values below were also
confirmed in game with a probe addon on build 1.60.1 (70338).

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
| 1 | Spell | Spells, spellbook, action buttons with spells, talents, trainer services, and profession recipes ("Blacksmithing: ...") | Yes: a recipe lists the item it makes |
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

There is no separate "recipe" type. What the probe showed in game:

- A recipe item (Plans, Pattern, Formula) in bags, on a vendor or in AtlasLoot is an `Item`
  tooltip.
- A recipe in the profession window, the spellbook or a chat link ("Leatherworking: Helm of the
  Great Chief") is a `Spell` tooltip (`GetSpellByID`, or `GetHyperlink` for links).
- Both list the item they make the same way: a `NestedBlock` line with empty text and
  `tooltipID` / `tooltipType` fields naming that item, followed by the item's own lines as
  ordinary entries in `data.lines` (its name line starts with `\n`). So a pre-call on the outer
  tooltip's type sees every stat line one per entry.
- The item itself in the profession window's result slot is an `Item` tooltip
  (`GetRecipeResultItem`).

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

- The addon hooks `Item` and `Spell`. `Spell` is what was missing for profession recipes. Other
  types (units, auras, objects) never show item stats, so they are left unhooked rather than
  hooking `TooltipDataProcessor.AllTypes`.
- Forever's client also has secret values (`issecretvalue`, `canaccessvalue`), mostly for unit
  and combat data, which addon code can't read. Item and spell text has not been seen as secret;
  if that changes, the hook would need an `issecretvalue` check.
