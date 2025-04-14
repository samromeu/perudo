local die = require "Die" 
local createCup = require "Cup"
local createButton = require "button" 
local arrow = require "Arrow"
local GameState = require "GameState"
local OpponentAI = require "OpponentAI"
local MessageSystem = require "MessageSystem"

-- Make center coordinates global
local centerX, centerY

local diceConfig = {
    total = 6,
    initialdieXpos = 250,
    spacing = 75
}

local dice = {}
local playerCup
local dieSprites
local isReleased = false

local guess = {
  value = 0,
  count = 0
}

-- Add new buttons for game actions
local bidButton
local dudoButton

function love.load()
  local face1 = love.graphics.newImage("assets/die.png")
  local face2 = love.graphics.newImage("assets/2die.png")
  local face3 = love.graphics.newImage("assets/3die.png")
  local face4 = love.graphics.newImage("assets/4die.png")
  local face5 = love.graphics.newImage("assets/5die.png")
  local face6 = love.graphics.newImage("assets/6die.png")

  playerSprite = love.graphics.newImage("assets/cup.png")
  opponentSprite = love.graphics.newImage("assets/opponentcup.png")
  
  upArrowSprite = love.graphics.newImage("assets/uparrow.png")
  downArrowSprite = love.graphics.newImage("assets/downarrow.png")
  bidButtonSprite = love.graphics.newImage("assets/bidbutton.png")
  dudoButtonSprite = love.graphics.newImage("assets/dudobutton.png")

  dieSprites = {face1, face2, face3, face4, face5, face6}

  playerCup = createCup(25, 450)
  playerCup:fill(6)

  opponentCup = createCup(650, 25)
  opponentCup:fill(6)
  
  -- Set the center coordinates
  centerX = love.graphics.getWidth() / 2
  centerY = love.graphics.getHeight() / 2


  valueUparrow = arrow(centerX - 100, centerY - 50, 64, 64, guess.value)
  valueDownarrow = arrow(centerX - 100, centerY + 14, 64, 64, "")

  countUparrow = arrow(centerX - 30, centerY - 50, 64, 64, guess.count)
  countDownarrow = arrow(centerX - 30, centerY + 14, 64, 64, "")

  -- Create new game action buttons
  bidButton = createButton(centerX + 50, centerY - 50, 32, 32, "", function()
    if GameState.submitBid(guess.value, guess.count) then
      -- Reset guess values after successful bid
      guess.value = GameState.currentBid.value
      guess.count = 0
    end
  end, bidButtonSprite)

  dudoButton = createButton(centerX + 50, centerY + 50, 32, 32, "", function()
    GameState.handleDudo(playerCup.dice, opponentCup.dice)
  end, dudoButtonSprite)

  resetButton = createButton(playerCup.transform.x + 125, playerCup.transform.y + 100, 25, 25, "R", function() 
    playerCup:shake()
    opponentCup:shake()
  end)

  addButton = createButton(playerCup.transform.x + 125, playerCup.transform.y + 50, 25, 25, "+", function()
    for _, die in ipairs(dice) do
      die.isDragging = false
      die.target_transform = {x = playerCup.transform.x + playerCup.width / 2, y = playerCup.transform.y + playerCup.height / 2}
    end
  end)

  -- Reset AI when starting a new game
  OpponentAI.reset()
  GameState.reset()
end

function love.draw()
  --Draw the player and opponent cups
  playerCup:draw(playerSprite)
  opponentCup:draw(opponentSprite)

  --Draw the arrows for the guesses
  valueUparrow:draw(upArrowSprite, "Value: " .. guess.value)
  valueDownarrow:draw(downArrowSprite)

  countUparrow:draw(upArrowSprite, "Count: " .. guess.count)
  countDownarrow:draw(downArrowSprite)

  --Draw game action buttons
  bidButton:draw()
  dudoButton:draw()

  --Draw current bid if there is one
  if GameState.currentBid.value > 0 then
    love.graphics.printf("Current Bid: " .. GameState.currentBid.count .. " dice of value " .. GameState.currentBid.value, 
      0, centerY - 100, love.graphics.getWidth(), "center")
  end

  --Draw whose turn it is
  love.graphics.printf("Current Turn: " .. GameState.currentPlayer, 0, centerY - 80, love.graphics.getWidth(), "center")

  if playerCup.showDice == true then
    for _, die in ipairs(playerCup.dice) do
      die:draw(dieSprites[die.value])
    end
  end

  --Loop over all dice on the table (not in cups) and draw them 
  for _, die in ipairs(dice) do
    die:draw(dieSprites[die.value])

    --[[
    CODE FOR DRAWING LINES BETWEEN DICE

    local closestdie = die:closestdie(dice)
    if closestdie ~= nil then
      love.graphics.setLineWidth(2)   -- Line width
      if die:overlapping(closestdie) then 
        love.graphics.setColor(0, 0, 1) -- Blue line
      else
        love.graphics.setColor(1, 0, 0) -- Red line
      end
      love.graphics.line(die.transform.x + die.width / 2, die.transform.y + die.height / 2, closestdie.transform.x + closestdie.width / 2, closestdie.transform.y
        + closestdie.height / 2)
    end
    love.graphics.reset()
    ]]
  end
  resetButton:draw()
  addButton:draw()

  -- Draw messages
  MessageSystem.draw()
end

function love.update(dt)
  -- Update message system
  MessageSystem.update(dt)

  -- Handle opponent's turn
  if GameState.currentPlayer == "opponent" and not GameState.gameOver then
    -- Get opponent's known dice (their own dice)
    local knownDice = {}
    for _, die in ipairs(opponentCup.dice) do
      table.insert(knownDice, die.value)
    end

    -- Add a small delay between opponent moves
    if not GameState.opponentMoveTimer then
      GameState.opponentMoveTimer = 0
    end
    
    GameState.opponentMoveTimer = GameState.opponentMoveTimer + dt
    
    if GameState.opponentMoveTimer >= 1.0 then -- Wait 1 second between moves
      -- Only make a move if we're in the bidding phase
      if GameState.gamePhase == "bidding" then
        -- Decide whether to call Dudo
        if OpponentAI.shouldCallDudo(GameState, knownDice) then
          GameState.handleDudo(playerCup.dice, opponentCup.dice)
          MessageSystem.addMessage("Opponent calls Dudo!")
        else
          -- Make a bid
          local bid = OpponentAI.makeBid(GameState, knownDice)
          if GameState.submitBid(bid.value, bid.count) then
            OpponentAI.updateMemory(bid)
            MessageSystem.addMessage("Opponent bids " .. bid.count .. " dice of value " .. bid.value)
          end
        end
      end
      GameState.opponentMoveTimer = 0
    end
  end

  for i = #playerCup.dice, 1, -1 do
    local die = playerCup.dice[i]
    if die.value == guess.value then
      if die.raised == false then 
        die:raise()
      end
    else
      if die.raised == true then
        die:lower()
      end
    end
    if die.isDragging then
      mouseX, mouseY = love.mouse.getPosition()
      die.target_transform.x = mouseX - die.width/2
      die.target_transform.y = mouseY - die.height/2
    end

    die:move(dt) -- Apply movement based on target_transform

    --[[REMOVED -- conflicted with dice setting/resetting logic

    if die.transform.x > playerCup.transform.x and die.transform.x < playerCup.transform.x + playerCup.width and
      die.transform.y > playerCup.transform.y and die.transform.y < playerCup.transform.y + playerCup.height then
        playerCup:addDie(die)
        table.remove(dice, i)
      end
    ]]

    --Check if dice are overlapping when released
    if isReleased then
      local overlapsResolved = true
      for j = #playerCup.dice, 1, -1 do
        local otherdie = playerCup.dice[j]
        if otherdie ~= die then
          if die:overlapping(otherdie) then
            die:separate(otherdie)
            overlapsResolved = false
          end
        end
      end
    end

    if overlapsResolved then
      isReleased = false
    end

  end
end


function love.mousepressed(x, y, button)
  if button == 1 then
    isReleased = false
    for _, die in ipairs(playerCup.dice) do
      if x > die.transform.x and x < die.transform.x + die.width and
         y > die.transform.y and y < die.transform.y + die.height then
          die.isDragging = true
        end
    end
  end

  -- Handle button clicks
  if button == 1 and resetButton:isClicked(x, y) then
    resetButton.onClick()
  end
  if button == 1 and addButton:isClicked(x,y) then
    addButton.onClick()
  end
  if button == 1 and bidButton:isClicked(x, y) then
    bidButton.onClick()
  end
  if button == 1 and dudoButton:isClicked(x, y) then
    dudoButton.onClick()
  end

  if button == 1 and playerCup:isClicked(x, y) and playerCup.showDice == false then
    playerCup:displayDice()
  elseif button == 1 and playerCup:isClicked(x, y) and playerCup.showDice == true then
    playerCup:resetDice()
  end

  --[[Arrow clicking logic]]
  --Value arrows
  if button == 1 and valueUparrow:isClicked(x, y) then
    local newValue = guess.value + 1
    if newValue <= GameState.getMaxValue() then
      guess.value = newValue
      -- Ensure count is valid for the new value
      guess.count = math.max(guess.count, GameState.getMinCount(guess.value))
    end
  end
  if button == 1 and valueDownarrow:isClicked(x, y) then
    local newValue = guess.value - 1
    if newValue >= GameState.getMinValue() then
      guess.value = newValue
      -- Ensure count is valid for the new value
      guess.count = math.max(guess.count, GameState.getMinCount(guess.value))
    end
  end

  --Count arrows
  if button == 1 and countUparrow:isClicked(x, y) then
    local newCount = guess.count + 1
    if newCount <= GameState.getMaxCount(guess.value) then
      guess.count = newCount
    end
  end
  if button == 1 and countDownarrow:isClicked(x, y) then
    local newCount = guess.count - 1
    if newCount >= GameState.getMinCount(guess.value) then
      guess.count = newCount
    end
  end
end


function love.mousereleased(x, y, button)
  if button == 1 then
    for i, die in ipairs(playerCup.dice) do
      if die.isDragging == true then
        die.isDragging = false
        isReleased = true
        die.scale = 1
      end
    end
  end
end