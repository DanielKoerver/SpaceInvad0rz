-- enemies

enemies = {}
    
enemies.entities = {}

enemies.nextSpawn = love.timer.getTime() + 1


function enemies.init()
    -- load images
    for enemyTypeName, enemyType in pairs(enemyTypes) do
        for i=1,enemyType.imageAmount do
            enemyType.images[i] = love.graphics.newImage(imageFolder..enemyTypeName..i..'.png')
        end
    end
end


function enemies.spawn(type)
    local entity = setmetatable({}, {__index = enemyTypes[type]})
    if entity.init then entity:init() end
    
    entity.type = type

     -- random start
    entity.position = {
        x = love.math.random(0, love.window.getWidth()),
        y = 0
    }

    -- set random image
    entity.imageIndex = love.math.random(1, #entity.images)
    
    table.insert(enemies.entities, entity)
end


function enemies.update(dt)
    -- spawn new enemies
    if love.timer.getTime() > enemies.nextSpawn then
        enemies.spawn('weakAsteroid')
        enemies.nextSpawn = love.timer.getTime() + 2 + love.math.random()
    end

    -- update positions
    for i, entity in ipairs(enemies.entities) do
        enemyTypes[entity.type].move(entity, dt)
    end

    -- additional update if applicable
    for i, entity in ipairs(enemies.entities) do
        if entity.update then entity:update() end
    end

    -- remove objects which are out of window
    for i = #enemies.entities, 1, -1 do
        if enemies.entities[i].position.y > love.window.getHeight() + enemies.entities[i].radius or
           enemies.entities[i].remove then
            table.remove(enemies.entities, i)
        end
    end
end


function enemies.draw()
    for _, entity in ipairs(enemies.entities) do
        enemyTypes[entity.type].draw(entity)
    end
end


-- enemy types

enemyTypes = {}


-- enemy type asteroid

enemyTypes.asteroid = {}

enemyTypes.asteroid.remove = false

enemyTypes.asteroid.radius      = nil
enemyTypes.asteroid.radiusRange = {min = 50, max = 100}

enemyTypes.asteroid.imageIndex  = nil
enemyTypes.asteroid.imageAmount = 4
enemyTypes.asteroid.images      = {}

enemyTypes.asteroid.rotationSpeed       = nil
enemyTypes.asteroid.rotationSpeedRange  = {min = 0.3, max = 0.5}
    
enemyTypes.asteroid.speed       = nil
enemyTypes.asteroid.speedRange  = {min = 150, max = 220}

enemyTypes.asteroid.collisionRadius = nil

enemyTypes.asteroid.collisionDamage = 30

enemyTypes.asteroid.health = 50


function enemyTypes.asteroid.init(self)
    self.radius             = love.math.random(self.radiusRange.min, self.radiusRange.max)
    self.speed              = love.math.random(self.speedRange.min, self.speedRange.max)
    self.rotationSpeed      = self.rotationSpeedRange.min + love.math.random() * (self.rotationSpeedRange.max - self.rotationSpeedRange.min)
    self.collisionRadius    = self.radius * 0.8
end


function enemyTypes.asteroid.move(self, dt)
    self.position.y = self.position.y + self.speed * dt
end


function enemyTypes.asteroid.draw(self)
    local image = self.images[self.imageIndex]
    love.graphics.setColor({255, 255, 255})
    love.graphics.draw(image, self.position.x, self.position.y, self.rotationSpeed * love.timer.getTime(),
                       self.radius * 2 / image:getWidth(), self.radius * 2 / image:getHeight(), image:getWidth() / 2, image:getHeight() / 2)
    if debugMode then
        love.graphics.setColor({255, 0, 0})
        love.graphics.circle('line', self.position.x, self.position.y, self.radius, 20)
        love.graphics.print(self.health, self.position.x, self.position.y)
    end
end


-- enemy type weak asteroid

enemyTypes.weakAsteroid = {}

enemyTypes.weakAsteroid.remove = false

enemyTypes.weakAsteroid.radius      = nil
enemyTypes.weakAsteroid.radiusRange = {min = 50, max = 100}

enemyTypes.weakAsteroid.imageIndex  = nil
enemyTypes.weakAsteroid.imageAmount = 4
enemyTypes.weakAsteroid.images      = {}

enemyTypes.weakAsteroid.rotationSpeed       = nil
enemyTypes.weakAsteroid.rotationSpeedRange  = {min = 0.3, max = 0.5}
    
enemyTypes.weakAsteroid.speed       = nil
enemyTypes.weakAsteroid.speedRange  = {min = 150, max = 220}

enemyTypes.weakAsteroid.collisionRadius = nil

enemyTypes.weakAsteroid.collisionDamage = 30

enemyTypes.weakAsteroid.health = 50


function enemyTypes.weakAsteroid.init(self)
    self.radius             = love.math.random(self.radiusRange.min, self.radiusRange.max)
    self.speed              = love.math.random(self.speedRange.min, self.speedRange.max)
    self.rotationSpeed      = self.rotationSpeedRange.min + love.math.random() * (self.rotationSpeedRange.max - self.rotationSpeedRange.min)
    self.collisionRadius    = self.radius * 0.8
end


function enemyTypes.weakAsteroid.update(self)
    for _, entity in ipairs(projectiles.entities) do
        if (entity.team == 'friendly' and circlesCollide(self.position.x, self.position.y, self.collisionRadius, entity.collisionCenter.x, entity.collisionCenter.y, entity.collisionRadius)) then
            self:hit(entity.damage)
            entity.remove = true
        end
    end
end


function enemyTypes.weakAsteroid.hit(self, damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self.remove = true
    end
end


function enemyTypes.weakAsteroid.move(self, dt)
    self.position.y = self.position.y + self.speed * dt
end


function enemyTypes.weakAsteroid.draw(self)
    local image = self.images[self.imageIndex]
    love.graphics.setColor({255, 255, 255})
    love.graphics.draw(image, self.position.x, self.position.y, self.rotationSpeed * love.timer.getTime(),
                       self.radius * 2 / image:getWidth(), self.radius * 2 / image:getHeight(), image:getWidth() / 2, image:getHeight() / 2)
    if debugMode then
        love.graphics.setColor({255, 0, 0})
        love.graphics.circle('line', self.position.x, self.position.y, self.radius, 20)
        love.graphics.print(self.health, self.position.x, self.position.y)
    end
end