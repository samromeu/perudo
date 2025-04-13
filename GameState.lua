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
    gameOver = false
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
end

-- Check if a bid is valid
function GameState.isValidBid(value, count)
    -- First bid of the round is always valid
    if GameState.currentBid.value == 0 then
        return true
    end
    
    -- Subsequent bids must be higher
    if count > GameState.currentBid.count then
        return true
    elseif count == GameState.currentBid.count then
        return value > GameState.currentBid.value
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
        GameState.currentPlayer = GameState.currentPlayer == "player" and "opponent" or "player"
        return true
    end
    return false
end

-- Handle a "Dudo" challenge
function GameState.handleDudo()
    GameState.gamePhase = "revealing"
    -- This will be implemented later with actual dice counting
    return true
end

-- Check if the game is over
function GameState.checkGameOver()
    if GameState.playerDiceCount == 0 or GameState.opponentDiceCount == 0 then
        GameState.gameOver = true
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
end

return GameState 