require 'helper'
require 'ship'
require 'enemy'


imageFolder = 'assets/images/'

debugMode = false


function love.load()
    ship:init()
    enemies.init()
end


function love.keypressed(key, isrepeat)
    if key == 'f11' then
        debugMode = not debugMode
    end
end


function love.update(dt)
    enemies.update(dt)
    ship:update(dt)
end


function love.draw()
    enemies.draw()
    ship:draw()
end