ship = {}

ship.size       = {x = 0, y = 0}
ship.position   = {x = 0, y = 0}
    
ship.velocity               = {x = 0, y = 0}
ship.minimalVelocity        = 10
ship.acceleration           = 1300
ship.maxSpeed               = 800
ship.decellerationFactor    = 3
ship.frictionFactor         = 4
ship.collisionRadius        = 0

ship.collisionInvicibilityTime  = 0.8
ship.maxHealth                  = 100
ship.health                     = nil
ship.lastHit                    = 0
ship.hitFlashTime               = 0.05
ship.invincibilityEnd           = 0
ship.isInvincible               = false

ship.score = 0

ship.soundVolume = 1


function ship:init()
    shipImage               = love.graphics.newImage(imageFolder..'ship.png')
    self.size               = {x = shipImage:getWidth(), y = shipImage:getHeight()}
    self.position           = {x = love.window.getWidth() / 2, y = love.window.getHeight() - ship.size.y / 2 - 50}
    self.collisionRadius    = distance(0, 0, ship.size.x, ship.size.y) / 2 * 0.7

    sound.load(soundFolder..'hits/shipHit.wav', 'shipHit', 'static')

    self.health = self.maxHealth
end;


function ship:restart()
    self.size     = {x = shipImage:getWidth(), y = shipImage:getHeight()}
    self.position = {x = love.window.getWidth() / 2, y = love.window.getHeight() - ship.size.y / 2 - 50}
    self.velocity = {x = 0, y = 0}
    self.health   = self.maxHealth
    ship.score    = 0
end;


function ship:update(dt)
    self:move(dt)
    self:collide()

    self.isInvincible = (self.invincibilityEnd > love.timer.getTime())

    -- die
    if self.health <= 0 then
        self:die()
    end
end


function ship:move(dt)
    local delta = 0 
    
    -- delta
    delta = delta - (love.keyboard.isDown('left') and 1 or 0)
    delta = delta + (love.keyboard.isDown('right') and 1 or 0)
    delta = delta * self.acceleration

    -- decellerate if other direction
    if self.velocity.x * delta < 0 then delta = delta * self.decellerationFactor end

    if delta == 0 then
        -- use friction if no key pressed
        self.velocity.x = self.velocity.x - self.frictionFactor * self.velocity.x * dt
        if math.abs(self.velocity.x) < self.minimalVelocity then self.velocity.x = 0 end
    else
        -- integrate velocity
        self.velocity.x = self.velocity.x + delta * dt
    end

    -- set max speed
    if self.velocity.x > self.maxSpeed then self.velocity.x = self.maxSpeed end
    if self.velocity.x < -self.maxSpeed then self.velocity.x = -self.maxSpeed end

    -- integrate ship position
    self.position.x = self.position.x + self.velocity.x * dt

    -- stop ship at window border
    if self.position.x + self.size.x / 2 > love.window.getWidth() then
        self.velocity.x = 0
        self.position.x = love.window.getWidth() - self.size.x / 2
    end
    if self.position.x - self.size.x / 2 < 0 then
        self.velocity.x = 0
        self.position.x = self.size.x / 2
    end
end


function ship:collide()
    -- collide with enemies
    for _, entity in ipairs(enemies.entities) do
        if (circlesCollide(self.position.x, self.position.y, self.collisionRadius, entity.position.x, entity.position.y, entity.radius)) then
            self:hit(entity.collisionDamage, ship.collisionInvicibilityTime)
            self.velocity.x = self.maxSpeed / 2 * (self.position.x >= entity.position.x and 1 or -1)
        end
    end

    -- collide with projectiles
    for i = #projectiles.entities, 1, -1 do
        local entity = projectiles.entities[i]
        if (entity.team == 'hostile' and circlesCollide(self.position.x, self.position.y, self.collisionRadius, entity.position.x, entity.position.y, entity.collisionRadius)) then
            self:hit(entity.damage)
            table.remove(projectiles.entities, i)
        end
    end
end


function ship:hit(damage, invincibilityTime)
    if (not self.isInvincible) then
        self.health = self.health - damage
        self.lastHit = love.timer.getTime()

        sound.play('shipHit', ship.soundVolume)
        
        if invincibilityTime ~= nil then
            self.invincibilityEnd = love.timer.getTime() + invincibilityTime
        end
    end
end


function ship:die()
    if godMode then
        self.health = 100
    else
        gameHasEnded = true
    end
end


function ship:shoot()
    projectiles.shoot('friendlyShot', self.position.x, self.position.y - self.size.y / 2)
end


function ship:addScore(score)
    self.score = self.score + score
end


function ship:draw()
    -- flash on hit
    if (self.lastHit + ship.hitFlashTime > love.timer.getTime() and self.lastHit < love.timer.getTime()) then
        love.graphics.setColor({255, 100, 100})
    else
        love.graphics.setColor({255, 255, 255})
    end

    -- draw ship
    love.graphics.draw(shipImage, self.position.x + self.velocity.x / self.maxSpeed * 20, self.position.y,
                       0, (1.0 - math.abs(self.velocity.x) / self.maxSpeed * 0.15), 1, self.size.x / 2, self.size.y / 2)

    if debugMode then
        love.graphics.setColor({255, 0, 0})
        love.graphics.circle('line', self.position.x, self.position.y, self.collisionRadius, 20)
    end
end