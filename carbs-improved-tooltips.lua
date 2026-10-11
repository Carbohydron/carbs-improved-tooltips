-- Rewrites wordy "Equip:" stat lines on item tooltips into short "+X Stat" lines.
-- "Spell Power" always means spell damage; healing is shown separately as "Heal Power".

-- Each rule: an anchored pattern and a function that builds the new text from its captures.
-- Rules are tried in order; the first match wins. Anchoring on "^Equip: " makes most tooltip
-- lines fail each pattern within the first few characters.
local rules = {
    -- Damage and healing
    {
        pattern = "^Equip: Increases damage and healing done by magical spells and effects by up to (%d+)%.$",
        format = function(amount) return "+" .. amount .. " Spell Power\n+" .. amount .. " Heal Power" end,
    },
    -- Damage only
    {
        pattern = "^Equip: Increases damage done by magical spells and effects by up to (%d+)%.$",
        format = function(amount) return "+" .. amount .. " Spell Power" end,
    },
    -- Damage against a creature type
    {
        pattern = "^Equip: Increases damage done to (%a+) by magical spells and effects by up to (%d+)%.$",
        format = function(specific, amount) return "+" .. amount .. " Spell Power against " .. specific end,
    },
    -- Damage for one school
    {
        pattern = "^Equip: Increases damage done by (%a+) spells and effects by up to (%d+)%.$",
        format = function(specific, amount) return "+" .. amount .. " " .. specific .. " Spell Power" end,
    },
    -- Healing with a smaller damage bonus
    {
        pattern = "^Equip: Increases healing done by up to (%d+) and damage done by up to (%d+) for all magical spells and effects%.$",
        format = function(healing, damage) return "+" .. damage .. " Spell Power\n+" .. healing .. " Heal Power" end,
    },
    -- Healing only
    {
        pattern = "^Equip: Increases healing done by spells and effects by up to (%d+)%.$",
        format = function(amount) return "+" .. amount .. " Heal Power" end,
    },
    {
        pattern = "^Equip: %+(%d+) Attack Power%.?$",
        format = function(amount) return "+" .. amount .. " Attack Power" end,
    },
    -- Attack power against a creature type
    {
        pattern = "^Equip: %+(%d+) Attack Power against (%a+)%.?$",
        format = function(amount, specific) return "+" .. amount .. " Attack Power against " .. specific end,
    },
    {
        pattern = "^Equip: %+(%d+) [Rr]anged Attack Power%.?$",
        format = function(amount) return "+" .. amount .. " Ranged Attack Power" end,
    },
    {
        pattern = "^Equip: Improves your chance to hit by ([%d%.]+)%%%.?$",
        format = function(amount) return "+" .. amount .. "% Hit" end,
    },
    {
        pattern = "^Equip: Improves your chance to get a critical strike by ([%d%.]+)%%%.?$",
        format = function(amount) return "+" .. amount .. "% Critical Strike chance" end,
    },
    {
        pattern = "^Equip: Increases your chance to [Dd]odge an attack by ([%d%.]+)%%%.?$",
        format = function(amount) return "+" .. amount .. "% Dodge" end,
    },
    {
        pattern = "^Equip: Increased Defense %+(%d+)%.?$",
        format = function(amount) return "+" .. amount .. " Defense" end,
    },
    -- Weapon skill, e.g. "Two-Handed Axes" or "Daggers" (after Defense, which has the same shape)
    {
        pattern = "^Equip: Increased ([%a%- ]+) %+(%d+)%.?$",
        format = function(skill, amount) return "+" .. amount .. " " .. skill .. " skill" end,
    },
    {
        pattern = "^Equip: Restores (%d+) [Mm]ana per 5 sec%.?$",
        format = function(amount) return "+" .. amount .. " Mana per 5 sec." end,
    },
    {
        pattern = "^Equip: Restores (%d+) [Hh]ealth per 5 sec%.?$",
        format = function(amount) return "+" .. amount .. " Health per 5 sec." end,
    },
}

local function getReplacementText(text)
    for _, rule in ipairs(rules) do
        -- Patterns have at most two captures; one-capture rules just ignore the second
        local capture1, capture2 = text:match(rule.pattern)

        if capture1 then
            return rule.format(capture1, capture2)
        end
    end

    return text
end

local function rewriteTooltipLines(self, data)
    if not data or not data.lines then return end

    for _, line in ipairs(data.lines) do
        if line.leftText and type(line.leftText) == "string" then
            line.leftText = getReplacementText(line.leftText)
        end
    end
end

-- Items, plus spells: a profession recipe ("Leatherworking: ...") is a Spell tooltip that
-- lists the item it makes as ordinary lines after a NestedBlock line
TooltipDataProcessor.AddTooltipPreCall(Enum.TooltipDataType.Item, rewriteTooltipLines)
TooltipDataProcessor.AddTooltipPreCall(Enum.TooltipDataType.Spell, rewriteTooltipLines)
