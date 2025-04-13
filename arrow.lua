local function Arrow(x, y, w, h, text)
	return {
		height = h,
		width = w,
		transform = {
			x = x,
			y = y
		},
		text = text,

	increment = function(counter)
		counter = counter + 1
	end,

	draw = function(self, sprite, text)
		love.graphics.draw(sprite, self.transform.x, self.transform.y)
		if text ~= nil then
			love.graphics.printf(text, self.transform.x, self.transform.y, self.width, "center")
		else
			love.graphics.printf(self.text, self.transform.x, self.transform.y, self.width, "center")
		end
	end,

	isClicked = function(self, mx, my)
		return mx > self.transform.x and mx < self.transform.x + self.width 
		and my > self.transform.y and my < self.transform.y + self.height
	end	

	}
end

return Arrow