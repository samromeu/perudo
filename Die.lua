local DraggableObject = require "DraggableObject" 

local function Die(x, y)
  local die = DraggableObject(x, y, 64, 64)
  die.value = love.math.random(1, 6)

  die.showDie = false
  
  die.reset = function(self, dice)   
    self.value = love.math.random(1, 6)
    self.isDragging = false
    table.insert(dice, self)
  end

  die.roll = function(self)
    self.value = love.math.random(1, 6)
  end

  die.closestdie = function(self, dice)
    local closestdie = nil
    local mindist = math.huge
      for _, die in ipairs(dice) do
        if die ~= self then
          local dx = die.transform.x - self.transform.x
          local dy = die.transform.y - self.transform.y
          local dist = math.sqrt(dx * dx + dy * dy)
          if dist < mindist then
            closestdie = die
            mindist = dist
          end
        end
      end
    return closestdie
  end

  die.overlapping = function(self, closestdie)
    local xoverlap = self.transform.x < closestdie.transform.x + closestdie.width and
                     self.transform.x + self.width > closestdie.transform.x
    local yoverlap = self.transform.y < closestdie.transform.y + closestdie.height and
                     self.transform.y + self.height > closestdie.transform.y
    return (xoverlap and yoverlap)
  end

  die.separate = function(self, closestdie)

    
    local center1 = {x = self.transform.x + (self.width / 2), y = self.transform.y + (self.height / 2)}
    local center2 = {x = closestdie.transform.x + (closestdie.width / 2), y = closestdie.transform.y + (closestdie.height / 2)}

    local dx = center2.x - center1.x
    local dy = center2.y - center1.y

    local theta = math.atan2(dy, dx)

    local mindist = (math.abs(math.sin(theta)) * self.height) + (math.abs(math.cos(theta)) * self.width)

    local dist = math.sqrt(dx * dx + dy * dy)

    local nx = dx / dist
    local ny = dy / dist 

    local overlap = (mindist - dist) / 2
    local offset = {x = nx * overlap, y = ny * overlap}

    self.target_transform = {x = self.transform.x - offset.x, y = self.transform.y - offset.y}
    closestdie.target_transform = {x = closestdie.transform.x + offset.x, y = closestdie.transform.y + offset.y}

  end


  return die
end

return Die