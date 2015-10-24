-- enemies

enemies = {}
    
enemies.entities = {}

enemies.nextSpawn = love.timer.getTime() + 1


function enemies.init()
    for enemyTypeName, enemyType in pairs(enemyTypes) do
        -- load images
        enemyType.images = {}
        for i = 1, enemyType.imageAmount do
            local possibleImage = ''
            if enemyType.imageAmount == 1 then
                possibleImage = imageFolder..'enemy/'..enemyTypeName..'.png'
            else
                possibleImage = imageFolder..'enemy/'..enemyTypeName..i..'.png'
            end
            if love.filesystem.exists(possibleImage) then 
                enemyType.images[i] = love.graphics.newImage(possibleImage)
            end
        end

        -- load sounds
        sound.load(soundFolder..'hits/'..enemyType.hitSound..'.wav', enemyType.hitSound, 'static')
    end
end


function enemies.restart()
    enemies.entities = {}
    enemies.nextSpawn = love.timer.getTime() + 1
end


function enemies.spawn(type)
    local entity = setmetatable({}, {__index = enemyTypes[type]})
    
    entity.type = type
    if entity.init then entity:init() end

    table.insert(enemies.entities, entity)
end


function enemies.update(dt)
    -- spawn new enemies
    if love.timer.getTime() > enemies.nextSpawn then
        spawnEnemyTypes = {'asteroid', 'weakAsteroid', 'glider', 'kamikaze'}
        enemies.spawn(spawnEnemyTypes[love.math.random(1, #spawnEnemyTypes)])
        enemies.nextSpawn = love.timer.getTime() + 2 + love.math.random()
    end

    -- update positions
    for i, entity in ipairs(enemies.entities) do
        entity:move(dt)
    end

    -- additional update if applicable
    for i, entity in ipairs(enemies.entities) do
        if entity.update then entity:update(dt) end
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
        entity:draw()
    end
end


-- enemy types

enemyTypes = {}


-- abstract enemy

enemyTypes.abstract = {}

enemyTypes.abstract.type = nil

enemyTypes.abstract.remove = false

enemyTypes.abstract.imageIndex  = 0
enemyTypes.abstract.imageAmount = 1
enemyTypes.abstract.images      = {}

enemyTypes.abstract.size = {x = 0, y = 0}

enemyTypes.abstract.radius                = 0
enemyTypes.abstract.collisionRadius       = 0
enemyTypes.abstract.collisionRadiusFactor = 1

enemyTypes.abstract.collisionDamage = 0
enemyTypes.abstract.health          = nil

enemyTypes.abstract.lastHit      = 0
enemyTypes.abstract.hitFlashTime = 0.05

enemyTypes.abstract.shootfrequency  = 0
enemyTypes.abstract.projectileType = nil

enemyTypes.abstract.score = 0

enemyTypes.abstract.hitSound       = 'enemyHit'
enemyTypes.abstract.hitSoundVolume = 0.7


function enemyTypes.abstract.init(self)
    -- set random image
    self.imageIndex = love.math.random(1, #self.images)

    -- size
    self.size = {x = self.images[self.imageIndex]:getWidth(), y = self.images[self.imageIndex]:getHeight()}
    self.radius = (self.size.x > self.size.y) and self.size.x / 2 or self.size.y / 2

    -- random start
    self.position = { x = love.math.random(0, love.window.getWidth()), y = 0 - self.radius / 2}

    -- speed
    self.speed = {x = 0, y = 0}

    -- lastshot
    self.lastShot = love.timer.getTime()

    self.collisionRadius = self.radius * self.collisionRadiusFactor
end


function enemyTypes.abstract.update(self, dt)
    -- collision
    for i = #projectiles.entities, 1, -1 do
        local entity = projectiles.entities[i]
        if (circlesCollide(self.position.x, self.position.y, self.collisionRadius, entity.position.x, entity.position.y, entity.collisionRadius)) then
            if entity.team == 'friendly' then
                self:hit(entity.damage)
            end
            table.remove(projectiles.entities, i)
        end
    end
    
    -- shoot
    if self.shootfrequency > 0 and self.lastShot + self.shootfrequency < love.timer.getTime() then
        self.lastShot = love.timer.getTime()
        self:shoot()
    end

    -- die
    if self.health ~= nil and self.health <= 0 then
        self:die()
    end
end


function enemyTypes.abstract.hit(self, damage)
    sound.play(self.hitSound, self.hitSoundVolume)
    if self.health ~= nil then
        self.health = self.health - damage
        self.lastHit = love.timer.getTime()
    end
end


function enemyTypes.abstract.collideWithShip(self)
    self:die()
end


function enemyTypes.abstract.die(self)
    self.remove = true
    ship:addScore(self.score)
end


function enemyTypes.abstract.shoot(self)
    if self.projectileType ~= nil then
        local projectile = projectiles.shoot(self.projectileType, self.position.x, self.position.y + self.collisionRadius)
        projectile.position.y = projectile.position.y + projectile.collisionRadius
    end
end


function enemyTypes.abstract.move(self, dt)
    self.position.x = self.position.x + self.speed.x * dt
    self.position.y = self.position.y + self.speed.y * dt
end


function enemyTypes.abstract.draw(self)
    local image = self.images[self.imageIndex]
    local rotation = (self.rotationSpeed ~= nil and self.rotationSpeed * love.timer.getTime() or 0)

    -- flash on hit
    if (self.health ~= nil and self.lastHit + ship.hitFlashTime > love.timer.getTime() and self.lastHit < love.timer.getTime()) then
        love.graphics.setColor({255, 150, 150})
    else
        love.graphics.setColor({255, 255, 255})
    end
    
    love.graphics.draw(image, self.position.x, self.position.y, 0, 1, 1, self.size.x / 2, self.size.y / 2)
   
    if debugMode then
        love.graphics.setColor({255, 0, 0})
        love.graphics.circle('line', self.position.x, self.position.y, self.radius, 20)
        love.graphics.print(self.type, self.position.x - 50, self.position.y - 10)
        love.graphics.print((self.health and self.health or 'nil'), self.position.x - 10, self.position.y + 10)
    end
end