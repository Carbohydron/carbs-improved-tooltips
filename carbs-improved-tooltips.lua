-- Rewrites wordy "Equip:" stat lines on item tooltips into short "+X Stat" lines.
-- "Spell Power" always means spell damage; healing is shown separately as "Heal Power".

-- One-number stat lines: a cheap plain-text check, the full pattern, and the text after "+X"
local simpleRules = {
    { find = "Attack Power", pattern = "^Equip: %+(%d+) Attack Power%.?$", label = " Attack Power" },
    { find = "Increased Defense", pattern = "^Equip: Increased Defense %+(%d+)%.?$", label = " Defense" },
    { find = "per 5 sec", pattern = "^Equip: Restores (%d+) [Mm]ana per 5 sec%.?$", label = " Mana per 5 sec." },
}

local function getReplacementText(text)
    -- Cheap plain-text checks first so most tooltip lines skip the pattern matches below
    if not string.find(text, "spells and effects", 1, true) then
        for _, rule in ipairs(simpleRules) do
            if string.find(text, rule.find, 1, true) then
                local amount = text:match(rule.pattern)

                if amount then
                    return "+" .. amount .. rule.label
                end

                return text
            end
        end

        return text
    end

    local amount, amount2, specific

    -- Damage and healing
    amount = text:match("^Equip: Increases damage and healing done by magical spells and effects by up to (%d+)%.$")

    if amount then
        return "+" .. amount .. " Spell Power\n+" .. amount .. " Heal Power"
    end

    -- Damage only
    amount = text:match("^Equip: Increases damage done by magical spells and effects by up to (%d+)%.$")

    if amount then
        return "+" .. amount .. " Spell Power"
    end

    -- Damage against a creature type
    specific, amount = text:match("^Equip: Increases damage done to (%a+) by magical spells and effects by up to (%d+)%.$")

    if specific and amount then
        return "+" .. amount .. " Spell Power against " .. specific
    end

    -- Damage for one school
    specific, amount = text:match("^Equip: Increases damage done by (%a+) spells and effects by up to (%d+)%.$")

    if specific and amount then
        return "+" .. amount .. " " .. specific .. " Spell Power"
    end

    -- Healing with a smaller damage bonus
    amount, amount2 = text:match("^Equip: Increases healing done by up to (%d+) and damage done by up to (%d+) for all magical spells and effects%.$")

    if amount and amount2 then
        return "+" .. amount2 .. " Spell Power\n+" .. amount .. " Heal Power"
    end

    -- Healing only
    amount = text:match("^Equip: Increases healing done by spells and effects by up to (%d+)%.$")

    if amount then
        return "+" .. amount .. " Heal Power"
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
