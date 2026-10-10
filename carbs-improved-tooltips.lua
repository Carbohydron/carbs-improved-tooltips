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
    -- Classic wording of the same bonus
    {
        pattern = "^Equip: %+(%d+) Attack Power when fighting (%a+)%.?$",
        format = function(amount, specific) return "+" .. amount .. " Attack Power against " .. specific end,
    },
    {
        pattern = "^Equip: Increased Defense %+(%d+)%.?$",
        format = function(amount) return "+" .. amount .. " Defense" end,
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

TooltipDataProcessor.AddTooltipPreCall(Enum.TooltipDataType.Item, function (self, data)
    if not data or not data.lines then return end

    for _, line in ipairs(data.lines) do
        if line.leftText and type(line.leftText) == "string" then
            line.leftText = getReplacementText(line.leftText)
        end
    end
end)
