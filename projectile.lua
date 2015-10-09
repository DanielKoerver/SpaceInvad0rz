-- projectiles

projectiles = {}
    
projectiles.entities = {}


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
end


function projectiles.update(dt)
    --update positions
    for i, entity in ipairs(projectiles.entities) do
        entity.position.y = entity.position.y + entity.speed * dt * (entity.team == 'friendly' and -1 or 1)
    end

    -- additional update if applicable
    for i, entity in ipairs(projectiles.entities) do
        if entity.update then entity:update() end
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
       love.graphics.setColor(entity.color)
       if entity.shape == 'rectangle' then
            love.graphics.rectangle('fill', entity.position.x, entity.position.y, entity.size.x, entity.size.y)
       end

        if debugMode then
            love.graphics.setColor({255, 0, 0})
            love.graphics.circle('line', entity.collisionCenter.x, entity.collisionCenter.y, entity.collisionRadius, 20)
        end
    end
end


-- projectile types

projectileTypes = {}


-- projectile type shot

projectileTypes.shot = {}

projectileTypes.shot.remove = false 

projectileTypes.shot.team   = 'friendly'
projectileTypes.shot.damage = 10

projectileTypes.shot.speed  = 300

projectileTypes.shot.collisionRadius = nil
projectileTypes.shot.collisionCenter = {x = 0, y = 0}

projectileTypes.shot.shape  = 'rectangle'
projectileTypes.shot.size   = {x = 3, y = 8}
projectileTypes.shot.color  = {200, 255, 200}


function projectileTypes.shot.init(self)
    self.collisionRadius = self.size.y
end

function projectileTypes.shot.update(self)
    self.collisionCenter = {x = self.position.x + self.size.x / 2, y = self.position.y + self.size.y / 2}
end