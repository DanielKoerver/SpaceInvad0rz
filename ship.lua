ship = {}

ship.size       = {x = nil, y = nil}
ship.position   = {x = nil, y = nil}
    
ship.velocity               = {x = 0, y = 0}
ship.minimalVelocity        = 10
ship.acceleration           = 1300
ship.maxSpeed               = 800
ship.decellerationFactor    = 3
ship.frictionFactor         = 4

ship.collisionRadius = nil

ship.health = 100


function ship:init()
    shipImage               = love.graphics.newImage(imageFolder..'ship.png')
    ship.size               = {x = shipImage:getWidth(), y = shipImage:getHeight()}
    ship.position           = {x = love.window.getWidth()/2, y = love.window.getHeight()-ship.size.y-50}
    ship.collisionRadius    = distance(0, 0, ship.size.x, ship.size.y) / 2 * 0.7
end;


function ship:update(dt)
    ship:move(dt)
    ship:collide(dt)
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


function ship:collide(dt)
    for _, entity in ipairs(enemies.entities) do
        if (circlesCollide(self.position.x, self.position.y + (self.size.y / 2), self.collisionRadius, entity.position.x, entity.position.y, entity.radius)) then
            self.velocity.x = self.maxSpeed * ((self.position.x >= entity.position.x) and 1 or -1)
        end
    end
end


function ship:draw()
    love.graphics.setColor({255, 255, 255})
    love.graphics.draw(shipImage, self.position.x + self.velocity.x / self.maxSpeed * 20, self.position.y + (self.size.y / 2),
                       0, (1.0 - math.abs(self.velocity.x) / self.maxSpeed * 0.15), 1, self.size.x/2, self.size.y/2)
    if debugMode then
        love.graphics.setColor({255, 0, 0})
        love.graphics.circle('line', self.position.x, self.position.y + (self.size.y / 2), self.collisionRadius, 20)
    end
end