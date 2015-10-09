-- enemies

enemies = {}
    
enemies.entities = {}

enemies.nextSpawn = love.timer.getTime() + 1


function enemies.init()
    -- bilder laden
    for enemyTypeName, enemyType in pairs(enemyTypes) do
        for i=1,enemyType.imageAmount do
            enemyType.images[i] = love.graphics.newImage(imageFolder..enemyTypeName..i..'.png')
        end
    end
end


function enemies.spawn(type)
    local entity = setmetatable({}, {__index = enemyTypes[type]})
    if entity.init then entity:init() end
    
    -- random start
    entity.type = type
    entity.position = {
        x = love.math.random(0, love.window.getWidth()),
        y = 0
    }

    -- bild laden
    entity.imageIndex = love.math.random(1, #entity.images)
    
    table.insert(enemies.entities, entity)
end


function enemies.update(dt)
    -- spawn new enemies
    if love.timer.getTime() > enemies.nextSpawn then
        enemies.spawn('asteroid')
        enemies.nextSpawn = love.timer.getTime() + 2 + love.math.random()
    end

    --update positions
    for i, entity in ipairs(enemies.entities) do
        enemyTypes[entity.type].move(entity, dt)
    end

    -- remove objects which are out of window
    for i = #enemies.entities, 1, -1 do
        if enemies.entities[i].position.y > love.window.getHeight() + enemies.entities[i].radius then
            table.remove(enemies.entities, i)
        end
    end
end


function enemies.draw()
    for _, entity in ipairs(enemies.entities) do
        enemyTypes[entity.type].draw(entity)
    end
end


enemyTypes  = {}


-- enemy type asteroid

enemyTypes.asteroid = {}

enemyTypes.asteroid.radius      = nil
enemyTypes.asteroid.radiusRange = {min = 50, max = 100}

enemyTypes.asteroid.imageIndex  = nil
enemyTypes.asteroid.imageAmount = 4
enemyTypes.asteroid.images      = {}

enemyTypes.asteroid.rotationSpeed       = nil
enemyTypes.asteroid.rotationSpeedRange  = {min = 0.3, max = 0.5}
    
enemyTypes.asteroid.speed       = nil
enemyTypes.asteroid.speedRange  = {min = 150, max = 220}

enemyTypes.asteroid.colissionRadius = nil

enemyTypes.asteroid.health = 50


function enemyTypes.asteroid.init(self)
    self.radius             = love.math.random(self.radiusRange.min, self.radiusRange.max)
    self.speed              = love.math.random(self.speedRange.min, self.speedRange.max)
    self.rotationSpeed      = self.rotationSpeedRange.min + love.math.random() * (self.rotationSpeedRange.max - self.rotationSpeedRange.min)
    self.colissionRadius    = self.radius * 0.8
end


function enemyTypes.asteroid.move(self, dt)
    self.position.y = self.position.y + self.speed * dt
end


function enemyTypes.asteroid.draw (self)
    local image = self.images[self.imageIndex]
    love.graphics.setColor({255, 255, 255})
    love.graphics.draw(image, self.position.x, self.position.y, self.rotationSpeed * love.timer.getTime(),
                       self.radius * 2 / image:getWidth(), self.radius * 2 / image:getHeight(), image:getWidth() / 2, image:getHeight() / 2)
    if debugMode then
        love.graphics.setColor({255, 0, 0})
        love.graphics.circle('line', self.position.x, self.position.y, self.radius, 20)
    end
end