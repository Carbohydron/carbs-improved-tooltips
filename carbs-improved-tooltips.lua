-- Rewrites wordy "Equip:" stat lines on item tooltips into short "+X Stat" lines.
-- "Spell Power" always means spell damage; healing is shown separately as "Heal Power".

-- Each rule: a cheap plain-text check, the full anchored pattern, and a function that builds
-- the new text from the pattern's captures. Rules are tried in order; the first match wins.
local rules = {
    -- Damage and healing
    {
        find = "spells and effects",
        pattern = "^Equip: Increases damage and healing done by magical spells and effects by up to (%d+)%.$",
        format = function(amount) return "+" .. amount .. " Spell Power\n+" .. amount .. " Heal Power" end,
    },
    -- Damage only
    {
        find = "spells and effects",
        pattern = "^Equip: Increases damage done by magical spells and effects by up to (%d+)%.$",
        format = function(amount) return "+" .. amount .. " Spell Power" end,
    },
    -- Damage against a creature type
    {
        find = "spells and effects",
        pattern = "^Equip: Increases damage done to (%a+) by magical spells and effects by up to (%d+)%.$",
        format = function(specific, amount) return "+" .. amount .. " Spell Power against " .. specific end,
    },
    -- Damage for one school
    {
        find = "spells and effects",
        pattern = "^Equip: Increases damage done by (%a+) spells and effects by up to (%d+)%.$",
        format = function(specific, amount) return "+" .. amount .. " " .. specific .. " Spell Power" end,
    },
    -- Healing with a smaller damage bonus
    {
        find = "spells and effects",
        pattern = "^Equip: Increases healing done by up to (%d+) and damage done by up to (%d+) for all magical spells and effects%.$",
        format = function(healing, damage) return "+" .. damage .. " Spell Power\n+" .. healing .. " Heal Power" end,
    },
    -- Healing only
    {
        find = "spells and effects",
        pattern = "^Equip: Increases healing done by spells and effects by up to (%d+)%.$",
        format = function(amount) return "+" .. amount .. " Heal Power" end,
    },
    {
        find = "Attack Power",
        pattern = "^Equip: %+(%d+) Attack Power%.?$",
        format = function(amount) return "+" .. amount .. " Attack Power" end,
    },
    {
        find = "Increased Defense",
        pattern = "^Equip: Increased Defense %+(%d+)%.?$",
        format = function(amount) return "+" .. amount .. " Defense" end,
    },
    {
        find = "per 5 sec",
        pattern = "^Equip: Restores (%d+) [Mm]ana per 5 sec%.?$",
        format = function(amount) return "+" .. amount .. " Mana per 5 sec." end,
    },
}

-- Calls format with the pattern's captures, or returns nil when the pattern didn't match
local function applyRule(format, ...)
    if ... then
        return format(...)
    end
end

local function getReplacementText(text)
    for _, rule in ipairs(rules) do
        -- Cheap plain-text check first so most tooltip lines skip the pattern match
        if string.find(text, rule.find, 1, true) then
            local replacement = applyRule(rule.format, text:match(rule.pattern))

            if replacement then
                return replacement
            end
        end
    end

    return text
end

TooltipDataProcessor.AddTooltipPreCall(Enum.TooltipDataType.Item, function (self, data)
    if not data or not data.lines then return end

    for _, line in ipairs(data.lines) do
        if line.leftText and type(line.leftText) == "string" then
            line.leftText = getReplacementText(line.leftText)
        end
    end
end)
