local Utils = require("utils")

local OpponentAI = {
    bluffChance = 0.3,  -- Chance to bluff when making a bid
    challengeThreshold = 0.7,  -- Threshold for calling Dudo
    memory = {}  -- Track previous bids for pattern recognition
}

-- Calculate combinations (n choose k)
local function combinations(n, k)
    if k > n then return 0 end
    if k == 0 or k == n then return 1 end
    k = math.min(k, n - k)  -- Take advantage of symmetry
    local result = 1
    for i = 1, k do
        result = result * (n - k + i) / i
    end
    return result
end

-- Calculate the probability of a certain number of dice being a specific value
function OpponentAI.calculateProbability(targetCount, targetValue, totalDice, knownDice, isDudoDecision)
    -- Count how many dice we already know match the target value or are wild (1s)
    local knownMatches = 0
    for _, die in ipairs(knownDice) do
        if die == targetValue or die == 1 then
            knownMatches = knownMatches + 1
        end
    end

    -- Calculate how many more matches we need
    local neededMatches = targetCount - knownMatches
    if neededMatches <= 0 then
        return 1.0  -- We already have enough matches
    end

    -- Calculate the number of unknown dice
    local unknownDice = totalDice - #knownDice
    if unknownDice < neededMatches then
        return 0.0  -- Not enough dice left to reach the target count
    end

    -- Calculate probability of getting needed matches in unknown dice
    -- For each unknown die, it can be either the target value (1/6) or a wild card (1/6)
    local singleDieProbability = 1/6 + 1/6  -- Probability of matching either way
    local nonMatchProbability = 1 - singleDieProbability

    -- Use binomial probability to calculate chance of getting at least neededMatches
    local probability = 0
    for i = neededMatches, unknownDice do
        local comb = combinations(unknownDice, i)
        probability = probability + comb * 
                     (singleDieProbability ^ i) * 
                     (nonMatchProbability ^ (unknownDice - i))
    end

    -- Only print if this is being used for a Dudo decision
    if isDudoDecision then
        print(string.format("Probability of %d or more %ds (including wild 1s) in %d unknown dice: %.2f%%", 
            targetCount, targetValue, unknownDice, probability * 100))
    end

    return probability
end

-- Make a bid based on current game state
function OpponentAI.makeBid(gameState, knownDice)
    -- If it's the first bid of the round
    if gameState.currentBid.value == 0 then
        -- Count dice values and add wild cards
        local valueCounts = Utils.addWildCards(Utils.countDice(knownDice))

        -- Find the value with the highest count
        local bestValue = 2  -- Start with 2 as default
        local bestCount = 0
        for value = 2, 6 do  -- Skip 1s as they're wild
            if (valueCounts[value] or 0) > bestCount then
                bestValue = value
                bestCount = valueCounts[value]
            end
        end

        -- Make a bid based on the counts
        -- If we have good information, make a more confident bid
        if bestCount >= 2 then
            return {
                value = bestValue,
                count = bestCount
            }
        else
            -- If we don't have much information, make a conservative bid
            return {
                value = love.math.random(2, 4),  -- Avoid starting with 1s or 6s
                count = 2  -- Start with a low count
            }
        end
    end

    -- Calculate probabilities for different values
    local probabilities = {}
    for value = 1, 6 do
        probabilities[value] = OpponentAI.calculateProbability(
            gameState.currentBid.count,
            value,
            gameState.totalDice,
            knownDice,
            false  -- Not a Dudo decision
        )
    end

    -- Decide whether to bluff
    local willBluff = love.math.random() < OpponentAI.bluffChance

    if willBluff then
        -- Make a slightly higher bid with a random value
        return {
            value = love.math.random(1, 6),
            count = gameState.currentBid.count + 1
        }
    else
        -- Make a logical bid based on probabilities
        local bestValue = 1
        local bestProbability = 0

        for value, prob in pairs(probabilities) do
            if prob > bestProbability then
                bestValue = value
                bestProbability = prob
            end
        end

        -- Make a bid slightly higher than the current one
        if gameState.currentBid.value < bestValue then
            return {
                value = bestValue,
                count = gameState.currentBid.count
            }
        else
            return {
                value = gameState.currentBid.value,
                count = gameState.currentBid.count + 1
            }
        end
    end
end

-- Decide whether to call Dudo
function OpponentAI.shouldCallDudo(gameState, knownDice)
    -- Calculate the probability of the current bid being true, considering 1s as wild
    local probability = OpponentAI.calculateProbability(
        gameState.currentBid.count,
        gameState.currentBid.value,
        gameState.totalDice,
        knownDice,
        true  -- This is a Dudo decision
    )

    print(string.format("Dudo decision - Raw probability: %.2f%%, Threshold: %.2f%%", 
        probability * 100, OpponentAI.challengeThreshold * 100))

    -- Only call Dudo if the probability is below our threshold
    return probability < OpponentAI.challengeThreshold
end

-- Update the AI's memory with the latest bid
function OpponentAI.updateMemory(bid)
    table.insert(OpponentAI.memory, bid)
    -- Keep only the last 5 bids in memory
    if #OpponentAI.memory > 5 then
        table.remove(OpponentAI.memory, 1)
    end
end

-- Reset the AI's memory
function OpponentAI.reset()
    OpponentAI.memory = {}
end

return OpponentAI 