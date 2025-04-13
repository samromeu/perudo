local velocityScale = 20

local function DraggableObject(x, y, h, w)
  return {
    isDragging = false,
    scale = 1,
    height = h,
    width = w,
    velocity = {
     x = 0,
     y = 0
    },
    transform = {
      x = x,
      y = y
    },
    target_transform = {
     x = x,
     y= y
    },

    move = function(self, dt)
      local momentum = 0.75
      if (self.transform.x ~= self.target_transform.x or self.velocity.x ~= 0) or (self.transform.y ~= self.target_transform.y or self.velocity.y ~= 0) then

        self.velocity.x = momentum * self.velocity.x +
        (1 - momentum) * (self.target_transform.x - self.transform.x) * velocityScale * dt

        self.velocity.y = momentum * self.velocity.y +
        (1 - momentum) * (self.target_transform.y - self.transform.y) * velocityScale * dt

        self.transform.x = self.transform.x + self.velocity.x
        self.transform.y = self.transform.y + self.velocity.y
      end
    end,

    draw = function(self, sprite)
      love.graphics.draw(sprite, self.transform.x, self.transform.y, 0, self.scale, self.scale)
    end,

    isClicked = function(self, mx, my)
      return mx > self.transform.x and mx < self.transform.x + self.width 
      and my > self.transform.y and my < self.transform.y + self.height
    end 
  }
end

return DraggableObject