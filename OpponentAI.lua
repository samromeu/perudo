local OpponentAI = {
    bluffChance = 0.3,  -- Chance to bluff when making a bid
    challengeThreshold = 0.7,  -- Threshold for calling Dudo
    memory = {}  -- Track previous bids for pattern recognition
}

-- Calculate the probability of a certain number of dice being a specific value
function OpponentAI.calculateProbability(targetCount, targetValue, totalDice, knownDice)
    -- For now, we'll use a simple probability calculation
    -- In a real game, this would consider the opponent's known dice
    local probability = 1/6  -- Basic probability for any value
    return probability * (totalDice - #knownDice)  -- Approximate expected count
end

-- Make a bid based on current game state
function OpponentAI.makeBid(gameState, knownDice)
    -- If it's the first bid of the round
    if gameState.currentBid.value == 0 then
        -- Make a conservative first bid
        return {
            value = love.math.random(2, 4),  -- Avoid starting with 1s or 6s
            count = love.math.random(2, 3)   -- Start with a low count
        }
    end

    -- Calculate probabilities for different values
    local probabilities = {}
    for value = 1, 6 do
        probabilities[value] = OpponentAI.calculateProbability(
            gameState.currentBid.count,
            value,
            gameState.totalDice,
            knownDice
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
    -- Calculate the probability of the current bid being true
    local probability = OpponentAI.calculateProbability(
        gameState.currentBid.count,
        gameState.currentBid.value,
        gameState.totalDice,
        knownDice
    )

    -- More likely to call Dudo if:
    -- 1. The probability is low
    -- 2. We have few dice left
    -- 3. The bid seems suspiciously high
    local suspicionFactor = gameState.currentBid.count / gameState.totalDice
    local adjustedProbability = probability * (1 - suspicionFactor)

    return adjustedProbability < OpponentAI.challengeThreshold
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