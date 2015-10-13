-- asteroid

enemyTypes.asteroid = setmetatable({}, {__index = enemyTypes.abstract})

enemyTypes.asteroid.imageAmount = 4

enemyTypes.asteroid.speedRange         = {y = {min = 150, max = 220}}
enemyTypes.asteroid.rotationSpeed      = 0
enemyTypes.asteroid.rotationSpeedRange = {min = -0.4, max = 0.4}

enemyTypes.asteroid.radiusRange           = {min = 50, max = 100}
enemyTypes.asteroid.collisionRadiusFactor = 0.8

enemyTypes.asteroid.collisionDamage = 30
enemyTypes.asteroid.health          = nil


function enemyTypes.asteroid.init(self)
    enemyTypes.abstract.init(self)
   
    -- random radius
    self.radius          = love.math.random(self.radiusRange.min, self.radiusRange.max)
    self.collisionRadius = self.radius * self.collisionRadiusFactor

    -- random speed and rotation
    self.speed         = {x = 0, y = love.math.random(self.speedRange.y.min, self.speedRange.y.max)}
    self.rotationSpeed = self.rotationSpeedRange.min + love.math.random() * (self.rotationSpeedRange.max - self.rotationSpeedRange.min)
end


function enemyTypes.asteroid.draw(self)
    local image = self.images[self.imageIndex]
    local rotation = (self.rotationSpeed ~= nil and self.rotationSpeed * love.timer.getTime() or 0)

    -- flash on hit
    if (self.lastHit + ship.hitFlashTime > love.timer.getTime() and self.lastHit < love.timer.getTime()) then
        love.graphics.setColor({255, 150, 150})
    else
        love.graphics.setColor({255, 255, 255})
    end
    
    love.graphics.draw(image, self.position.x, self.position.y, rotation, self.radius * 2 / self.size.x, self.radius * 2 / self.size.y, self.size.x / 2, self.size.y / 2)
   
    if debugMode then
        love.graphics.setColor({255, 0, 0})
        love.graphics.circle('line', self.position.x, self.position.y, self.radius, 20)
        love.graphics.print(self.type, self.position.x - 50, self.position.y - 10)
        love.graphics.print((self.health and self.health or 'nil'), self.position.x - 10, self.position.y + 10)
    end
end


-- weak asteroid

enemyTypes.weakAsteroid = setmetatable({}, {__index = enemyTypes.asteroid})

enemyTypes.weakAsteroid.health = 50