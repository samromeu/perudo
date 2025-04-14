local MessageSystem = {
    messages = {},
    fadeDuration = 2.0, -- seconds
    yOffset = 0,
    font = nil,
    defaultFont = nil
}

function MessageSystem.addMessage(text)
    if not MessageSystem.font then
        MessageSystem.font = love.graphics.newFont(24) -- Larger font size
        MessageSystem.defaultFont = love.graphics.getFont() -- Store the current font as default
    end
    table.insert(MessageSystem.messages, {
        text = text,
        alpha = 1.0,
        timer = 0
    })
end

function MessageSystem.update(dt)
    -- Update all messages
    for i = #MessageSystem.messages, 1, -1 do
        local message = MessageSystem.messages[i]
        message.timer = message.timer + dt
        
        -- Fade out the message
        message.alpha = 1 - (message.timer / MessageSystem.fadeDuration)
        
        -- Remove messages that have completely faded out
        if message.timer >= MessageSystem.fadeDuration then
            table.remove(MessageSystem.messages, i)
        end
    end
end

function MessageSystem.draw()
    if #MessageSystem.messages == 0 then return end
    
    -- Set the font
    love.graphics.setFont(MessageSystem.font)
    
    -- Calculate total height of all messages
    local totalHeight = #MessageSystem.messages * 40 -- Increased spacing between messages
    
    -- Calculate starting Y position to center all messages
    local startY = (love.graphics.getHeight() - totalHeight) / 2
    
    -- Draw each message
    for i, message in ipairs(MessageSystem.messages) do
        -- Set color with alpha
        love.graphics.setColor(1, 1, 1, message.alpha)
        -- Draw the message centered
        love.graphics.printf(message.text, 0, startY + (i-1) * 40, love.graphics.getWidth(), "center")
    end
    
    -- Reset color and font
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(MessageSystem.defaultFont)
end

return MessageSystem 