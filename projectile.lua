-- projectiles

projectiles = {}
    
projectiles.entities = {}


function projectiles.init()
    -- load images
    for projectileTypeName, projectileType in pairs(projectileTypes) do
        local possibleImage = imageFolder..'projectile/'..projectileTypeName..'.png'
        if love.filesystem.exists(possibleImage) then
            projectileType.image = love.graphics.newImage(possibleImage)
        end
    end
end


function projectiles.shoot(type, x, y)
    local entity = setmetatable({}, {__index = projectileTypes[type]})
    if entity.init then entity:init() end
    entity.type = type
    
    -- starting position
    entity.position = {
        x = x,
        y = y
    }
    
    table.insert(projectiles.entities, entity)

    return entity
end


function projectiles.update(dt)
    -- update positions
    for i, entity in ipairs(projectiles.entities) do
        entity:move(dt)
    end

    -- additional update if applicable
    for i, entity in ipairs(projectiles.entities) do
        if entity.update then entity:update(dt) end
    end

    --remove objects which are out of window
    for i = #projectiles.entities, 1, -1 do
        if projectiles.entities[i].position.y > love.window.getHeight() + projectiles.entities[i].collisionRadius or
           projectiles.entities[i].position.y < 0 - projectiles.entities[i].collisionRadius or
           projectiles.entities[i].remove then
            table.remove(projectiles.entities, i)
        end
    end
end


function projectiles.draw()
    for _, entity in ipairs(projectiles.entities) do
        entity:draw()
    end
end


-- projectile types

projectileTypes = {}


-- abstract projectile

projectileTypes.abstract = {}

projectileTypes.abstract.team   = nil
projectileTypes.abstract.damage = 0

projectileTypes.abstract.image = nil

projectileTypes.abstract.position = {x = 0, y = 0}
projectileTypes.abstract.speed    = {x = 0, y = 0}

projectileTypes.abstract.size = {x = 0, y = 0}

projectileTypes.abstract.collisionRadius       = nil
projectileTypes.abstract.collisionRadiusFactor = 1


function projectileTypes.abstract.init(self)
    -- size
    self.size = {x = self.image:getWidth(), y = self.image:getHeight()}
    self.radius = (self.size.x > self.size.y) and self.size.x or self.size.y

    self.collisionCenter = {x = self.position.x + self.size.x / 2, y = self.position.y + self.size.y / 2}

    self.collisionRadius = self.radius * self.collisionRadiusFactor
end


function projectileTypes.abstract.move(self, dt)
    self.position.x = self.position.x + self.speed.x * dt
    self.position.y = self.position.y + self.speed.y * dt * (self.team == 'friendly' and -1 or 1)
end


function projectileTypes.abstract.draw(self)
    love.graphics.setColor({255, 255, 255})
    love.graphics.draw(self.image, self.position.x, self.position.y, 0, 1, 1, self.size.x / 2, self.size.y / 2)

    if debugMode then
        love.graphics.setColor({255, 0, 0})
        love.graphics.circle('line', self.position.x, self.position.y, self.collisionRadius, 20)
    end
end


--  friendly shot

projectileTypes.friendlyShot = setmetatable({}, {__index = projectileTypes.abstract})

projectileTypes.friendlyShot.team   = 'friendly'
projectileTypes.friendlyShot.damage = 10

projectileTypes.friendlyShot.speed = {x = 0, y = 500}

projectileTypes.friendlyShot.collisionRadiusFactor = 0.2


-- hostile shot

projectileTypes.hostileShot = setmetatable({}, {__index = projectileTypes.friendlyShot})

projectileTypes.hostileShot.team   = 'hostile'
projectileTypes.hostileShot.damage = 20

projectileTypes.hostileShot.speed = {x = 0, y = 300}