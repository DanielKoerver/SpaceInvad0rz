require 'helper'
require 'ship'
require 'enemy'
require 'projectile'


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

    if key == ' ' then
        ship:shoot()
    end
end


function love.update(dt)
    enemies.update(dt)
    projectiles.update(dt)
    ship:update(dt)
end


function love.draw()
    enemies.draw()
    projectiles.draw()
    ship:draw()
end