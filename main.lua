require 'helper'
require 'ship'
require 'enemy'
require 'enemyTypes_asteroid'
require 'enemyTypes_glider'
require 'projectile'


imageFolder = 'assets/images/'

debugMode = false


function love.load()
    ship:init()
    enemies.init()
    projectiles.init()
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