-- glider

enemyTypes.glider = setmetatable({}, {__index = enemyTypes.abstract})

enemyTypes.glider.direction = 1

enemyTypes.glider.health = 30

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
    if self.position.x + self.size.x / 2 + 50 >= love.window.getWidth() then
        self.direction = -1
    end
    if self.position.x - self.size.x / 2 - 50 <= 0 then
        self.direction = 1
    end

    self.position.x = self.position.x + self.speed.x * self.direction * dt
    self.position.y = self.position.y + self.speed.y * dt
end