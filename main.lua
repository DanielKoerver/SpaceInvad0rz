require 'helper'
require 'sound'
require 'ui'
require 'ship'
require 'enemy'
require 'enemyTypes_asteroid'
require 'enemyTypes_glider'
require 'projectile'


imageFolder = 'assets/images/'
soundFolder = 'assets/sound/'
fontFolder = 'assets/font/'


debugMode = false
godMode   = false

gameHasEnded = false


function love.load()
    ship:init()
    enemies.init()
    projectiles.init()
    ui:init()
end


function love.restart()
    ship:restart()
    enemies.restart()
    projectiles.restart()
    gameHasEnded = false
end


function love.keypressed(key, isrepeat)
    if key == 'f11' then
        debugMode = not debugMode
    end

    if key == 'f10' then
        godMode = not godMode
    end

    if key == ' ' and not gameHasEnded then
        ship:shoot()
    end

    if key == ' ' and gameHasEnded then
        love.restart()
    end
end


function love.update(dt)
    if not gameHasEnded then
        enemies.update(dt)
        projectiles.update(dt)
        ship:update(dt)
    end
    sound.clean()
end


function love.draw()
    ship:draw()
    enemies.draw()
    projectiles.draw()
    ui:draw()
end