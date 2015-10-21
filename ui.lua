ui = {}

ui.font          = nil
ui.fontName      = 'silkscreen.ttf'
ui.fontSize      = 20
ui.endedFontSize = 40


function ui:init()
    ui.font      = love.graphics.newFont(fontFolder..ui.fontName, ui.fontSize)
    ui.endedFont = love.graphics.newFont(fontFolder..ui.fontName, ui.endedFontSize)
end


function ui:draw()
    if gameHasEnded then
        self:drawEnded()
    else
        self:drawInGame()
    end
end


function ui:drawEnded()
    love.graphics.setColor({0, 0, 0, 127})
    love.graphics.rectangle('fill', 0, 0, love.window.getWidth(), love.window.getHeight())
    
    love.graphics.setFont(ui.endedFont)
    love.graphics.setColor({255, 255, 200})
    love.graphics.print('Your score: '..ship.score, love.window.getWidth() / 2 - 200, love.window.getHeight() / 2 - 20)
end


function ui:drawInGame()
    love.graphics.setFont(ui.font)

    --draw health
    love.graphics.setColor({255, 255, 200})
    love.graphics.print('Health: '..ship.health, 20, 20)

    --draw score
    love.graphics.setColor({255, 255, 200})
    love.graphics.print('Score: '..ship.score, 20, 50)
end