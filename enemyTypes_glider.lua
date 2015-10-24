-- glider

enemyTypes.glider = setmetatable({}, {__index = enemyTypes.abstract})

enemyTypes.glider.direction = 1

enemyTypes.glider.health = 30

enemyTypes.glider.score = 20

enemyTypes.glider.shootfrequency  = 1
enemyTypes.glider.projectileType = 'hostileShot'


function enemyTypes.glider.init(self)
    enemyTypes.abstract.init(self)
    self.speed = {x = 200, y = 100}
    self.lastShot = love.timer.getTime()
end


function enemyTypes.glider.move(self, dt)
    -- fly down at the beginning
    if self.position.y >= self.size.y / 2 + 50 then
        self.speed.y = 0
    end

    -- toggle left and right
    if self.position.x + self.size.x / 2 + 10 >= love.window.getWidth() then
        self.direction = -1
    end
    if self.position.x - self.size.x / 2 - 10 <= 0 then
        self.direction = 1
    end

    self.position.x = self.position.x + self.speed.x * self.direction * dt
    self.position.y = self.position.y + self.speed.y * dt
end


-- kamikaze

enemyTypes.kamikaze = setmetatable({}, {__index = enemyTypes.abstract})

enemyTypes.kamikaze.direction = 1

enemyTypes.kamikaze.collisionDamage = 50
enemyTypes.kamikaze.health = 50

enemyTypes.kamikaze.score = 40


function enemyTypes.kamikaze.init(self)
    enemyTypes.abstract.init(self)
    self.speed = {x = 150, y = 250}
end


function enemyTypes.kamikaze.move(self, dt)

    -- follow the player
    self.direction = (self.position.x > ship.position.x and -1 or 1)
    if math.abs(self.position.x - ship.position.x) >= 10 then
        self.position.x = self.position.x + self.speed.x * self.direction * dt
    end

    self.position.y = self.position.y + self.speed.y * dt
end