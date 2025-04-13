local function createButton(x, y, width, height, text, onClick)
	return{
		x = x,
		y = y,
		width = width,
		height = height,
		text = text,
		onClick = onClick,

		draw = function(self)
			love.graphics.setColor(0.2, 0.6, 0.8) -- Button background color
			love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
			love.graphics.setColor(1, 1, 1)       -- Text color
    		love.graphics.printf(self.text, self.x, self.y + self.height / 4, self.width, "center")
    	end,

    	isClicked = function(self, mx, my)
    		return mx > self.x and mx < self.x + self.width 
    		and my > self.y and my < self.y + self.height
    	end
    }
end

return createButton