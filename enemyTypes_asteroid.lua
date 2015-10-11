-- asteroid

enemyTypes.asteroid = setmetatable({}, {__index = enemyTypes.abstract})

enemyTypes.asteroid.imageAmount = 4

enemyTypes.asteroid.speedRange         = {y = {min = 150, max = 220}}
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

    -- random start
    self.position = {
        x = love.math.random(0, love.window.getWidth()),
        y = 0 - self.radius / 2
    }

    -- random speed and rotation
    self.speed         = {x = 0, y = love.math.random(self.speedRange.y.min, self.speedRange.y.max)}
    self.rotationSpeed = self.rotationSpeedRange.min + love.math.random() * (self.rotationSpeedRange.max - self.rotationSpeedRange.min)
end


-- weak asteroid

enemyTypes.weakAsteroid = setmetatable({}, {__index = enemyTypes.asteroid})

enemyTypes.weakAsteroid.health = 50