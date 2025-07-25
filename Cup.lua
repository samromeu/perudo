local DraggableObject = require "DraggableObject" 
local createDie = require "Die" 

local function createCup(x, y)
  local cup = DraggableObject(x, y, 128, 128)

  cup.showDice = true

  cup.dice = {}

  cup.addDie = function(self, die)
    table.insert(self.dice, die)
  end

  cup.fill = function(self, numberOfDice)
    for _ = 1, numberOfDice do 
      local newDie = createDie(--[[self.transform.x + (self.width / 4)]] -50, self.transform.y + (self.height / 4))
      table.insert(self.dice, newDie)
    end
    self:displayDice()
  end

  cup.displayDice = function(self)
    self.showDice = true
    local offset = 200
    for i, die in ipairs(self.dice) do
      -- Set initial position
      die.transform.x = self.transform.x
      die.transform.y = self.transform.y + (self.height / 4)
      -- Set target position
      die.target_transform.x = self.transform.x + offset
      die.target_transform.y = self.transform.y + (self.height / 4)
      offset = offset + die.width * 1.25
    end
  end

  cup.resetDice = function(self)
    for i, die in ipairs(self.dice) do
      die.target_transform.x = --[[self.transform.x + (self.width / 4)]] -50
      die.target_transform.y = self.transform.y + (self.height / 4)
      die.raised = false
      die.transform.x = die.target_transform.x
      die.transform.y = die.target_transform.y
    end
    self.showDice = false
  end

  cup.shake = function(self)
    for i, die in ipairs(self.dice) do
      die:roll()
    end
  end

  cup.count = function(self)
    local freq = {}
    for _, die in ipairs(self.dice) do
      if freq[die.value] == nil then
        freq[die.value] = 1
      else
        freq[die.value] = freq[die.value] + 1
      end
    end
    return freq
  end
  
  return cup
end

return createCup