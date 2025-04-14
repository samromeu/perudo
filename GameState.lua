local MessageSystem = require "MessageSystem"

local GameState = {
    currentRound = 1,
    currentPlayer = "player", -- "player" or "opponent"
    currentBid = {
        value = 0,
        count = 0,
        player = nil
    },
    gamePhase = "bidding", -- "bidding", "challenging", "revealing"
    playerDiceCount = 6,
    opponentDiceCount = 6,
    gameOver = false,
    totalDice = 12, -- Total dice in play
    lastAction = nil -- Track the last action taken
}

-- Initialize a new round
function GameState.newRound()
    GameState.currentRound = GameState.currentRound + 1
    GameState.currentPlayer = "player"
    GameState.currentBid = {
        value = 0,
        count = 0,
        player = nil
    }
    GameState.gamePhase = "bidding"
    GameState.lastAction = nil
    print("New round started. Player's turn.")
end

-- Get the maximum possible count for a given value
function GameState.getMaxCount(value)
    return GameState.totalDice
end

-- Get the minimum possible count for a given value
function GameState.getMinCount(value)
    return 1
end

-- Get the maximum possible value
function GameState.getMaxValue()
    return 6
end

-- Get the minimum possible value
function GameState.getMinValue()
    return 1
end

-- Check if a bid is valid
function GameState.isValidBid(value, count)
    -- First bid of the round is always valid if within bounds
    if GameState.currentBid.value == 0 then
        return value >= GameState.getMinValue() and 
               value <= GameState.getMaxValue() and
               count >= GameState.getMinCount(value) and
               count <= GameState.getMaxCount(value)
    end
    
    -- Subsequent bids must be higher
    if count > GameState.currentBid.count then
        return value >= GameState.getMinValue() and 
               value <= GameState.getMaxValue()
    elseif count == GameState.currentBid.count then
        return value > GameState.currentBid.value and
               value <= GameState.getMaxValue()
    end
    
    return false
end

-- Submit a bid
function GameState.submitBid(value, count)
    if GameState.isValidBid(value, count) then
        GameState.currentBid = {
            value = value,
            count = count,
            player = GameState.currentPlayer
        }
        GameState.lastAction = "bid"
        print(GameState.currentPlayer .. " bid " .. count .. " dice of value " .. value)
        
        -- Switch turns
        GameState.currentPlayer = GameState.currentPlayer == "player" and "opponent" or "player"
        print("Switching to " .. GameState.currentPlayer .. "'s turn")
        return true
    end
    return false
end

-- Handle a "Dudo" challenge
function GameState.handleDudo(playerDice, opponentDice)
    GameState.gamePhase = "revealing"
    GameState.lastAction = "dudo"
    print(GameState.currentPlayer .. " called Dudo!")
    
    -- After Dudo, we need to:
    -- 1. Count the actual dice
    -- 2. Determine who loses a die
    -- 3. Start a new round
    local actualCount = 0
    for _, die in ipairs(playerDice) do
        if die.value == GameState.currentBid.value then
            actualCount = actualCount + 1
        end
    end
    for _, die in ipairs(opponentDice) do
        if die.value == GameState.currentBid.value then
            actualCount = actualCount + 1
        end
    end
    
    -- Determine who loses a die
    if actualCount >= GameState.currentBid.count then
        -- Bid was correct, challenger loses
        if GameState.currentPlayer == "player" then
            GameState.playerDiceCount = GameState.playerDiceCount - 1
            MessageSystem.addMessage("Player loses the round!", 3.0)
        else
            GameState.opponentDiceCount = GameState.opponentDiceCount - 1
            MessageSystem.addMessage("Opponent loses the round!", 3.0)
        end
    else
        -- Bid was incorrect, bidder loses
        if GameState.currentBid.player == "player" then
            GameState.playerDiceCount = GameState.playerDiceCount - 1
            MessageSystem.addMessage("Player loses the round!", 3.0)
        else
            GameState.opponentDiceCount = GameState.opponentDiceCount - 1
            MessageSystem.addMessage("Opponent loses the round!", 3.0)
        end
    end
    
    -- Check if game is over
    if not GameState.checkGameOver() then
        -- Start a new round
        GameState.newRound()
    end
    
    return true
end

-- Check if the game is over
function GameState.checkGameOver()
    if GameState.playerDiceCount == 0 or GameState.opponentDiceCount == 0 then
        GameState.gameOver = true
        print("Game Over! " .. (GameState.playerDiceCount == 0 and "Opponent" or "Player") .. " wins!")
        return true
    end
    return false
end

-- Reset the game state
function GameState.reset()
    GameState.currentRound = 1
    GameState.currentPlayer = "player"
    GameState.currentBid = {
        value = 0,
        count = 0,
        player = nil
    }
    GameState.gamePhase = "bidding"
    GameState.playerDiceCount = 6
    GameState.opponentDiceCount = 6
    GameState.gameOver = false
    GameState.totalDice = 12
    GameState.lastAction = nil
    print("Game reset. Player's turn.")
end

return GameState 