-- enemies

enemies = {}
    
enemies.entities = {}

enemies.nextSpawn = love.timer.getTime() + 1


function enemies.init()
    -- load images
    for enemyTypeName, enemyType in pairs(enemyTypes) do
        enemyType.images = {}
        for i = 1, enemyType.imageAmount do
            local possibleImage = ''
            if enemyType.imageAmount == 1 then
                possibleImage = imageFolder..'enemy_'..enemyTypeName..'.png'
            else
                possibleImage = imageFolder..'enemy_'..enemyTypeName..i..'.png'
            end
            print(possibleImage)
            if love.filesystem.exists(possibleImage) then 
                enemyType.images[i] = love.graphics.newImage(possibleImage)
            end
        end
    end
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
        spawnEnemyTypes = {'asteroid', 'weakAsteroid'}
        enemies.spawn(spawnEnemyTypes[love.math.random(1, 2)])
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


-- abstract anemy

enemyTypes.abstract = {}

enemyTypes.abstract.type = nil

enemyTypes.abstract.remove = false

enemyTypes.abstract.imageIndex  = 0
enemyTypes.abstract.imageAmount = 1
enemyTypes.abstract.images      = {}

enemyTypes.abstract.position = {x = 0, y = 0}
enemyTypes.abstract.speed    = {x = 0, y = 0}

enemyTypes.abstract.radius                = 0
enemyTypes.abstract.collisionRadius       = 0
enemyTypes.abstract.collisionRadiusFactor = 1

enemyTypes.abstract.collisionDamage = 0
enemyTypes.abstract.health          = nil


function enemyTypes.abstract.init(self)
    -- set random image
    self.imageIndex = love.math.random(1, #self.images)

    -- size
    local imageWith   = self.images[self.imageIndex]:getWidth()
    local imageHeight = self.images[self.imageIndex]:getHeight()
    self.radius = (imageWith > imageHeight) and imageWith or imageHeight

    -- random start
    self.position = {
        x = love.math.random(0, love.window.getWidth()),
        y = 0 - self.radius / 2
    }

    self.collisionRadius = self.radius * self.collisionRadiusFactor
end


function enemyTypes.abstract.update(self, dt)
    for i = #projectiles.entities, 1, -1 do
        local entity = projectiles.entities[i]
        if (entity.team == 'friendly' and circlesCollide(self.position.x, self.position.y, self.collisionRadius, entity.position.x, entity.position.y, entity.collisionRadius)) then
            self:hit(entity.damage)
            table.remove(projectiles.entities, i)
        end
    end
end


function enemyTypes.abstract.hit(self, damage)
    if self.health ~= nil then
        self.health = self.health - damage
        if self.health <= 0 then
            self:die()
        end
    end
end


function enemyTypes.abstract.die(self, damage)
    self.remove = true
end


function enemyTypes.abstract.move(self, dt)
    self.position.x = self.position.x + self.speed.x * dt
    self.position.y = self.position.y + self.speed.y * dt
end


function enemyTypes.abstract.draw(self)
    local image = self.images[self.imageIndex]
    
    love.graphics.setColor({255, 255, 255})
    love.graphics.draw(image, self.position.x, self.position.y, self.rotationSpeed * love.timer.getTime(),
                       self.radius * 2 / image:getWidth(), self.radius * 2 / image:getHeight(), image:getWidth() / 2, image:getHeight() / 2)
   
    if debugMode then
        love.graphics.setColor({255, 0, 0})
        love.graphics.circle('line', self.position.x, self.position.y, self.radius, 20)
        love.graphics.print(self.type, self.position.x - 50, self.position.y - 10)
        love.graphics.print((self.health and self.health or 'nil'), self.position.x - 10, self.position.y + 10)
    end
end