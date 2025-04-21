local Utils = {}

-- Count the frequency of dice values
function Utils.countDice(dice)
    local freq = {}
    for _, die in ipairs(dice) do
        freq[die.value] = (freq[die.value] or 0) + 1
    end
    return freq
end

-- Add wild card (1) counts to all values
function Utils.addWildCards(valueCounts)
    if valueCounts[1] then
        local wildCount = valueCounts[1]
        for value = 2, 6 do
            valueCounts[value] = (valueCounts[value] or 0) + wildCount
        end
    end
    return valueCounts
end

return Utils 