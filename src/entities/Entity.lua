Entity = Class{}

function Entity:init(def)
    self.type = def.entity_def.type
    self.playState = def.playState
    self.level = def.level

    self.animations = self:createAnimations(def.entity_def.animations)

    self.x = def.x
    self.y = def.y

    self.height = def.entity_def.height
    self.width = def.entity_def.width 

    self.walkSpeed = def.entity_def.walkSpeed
    self.direction = def.direction

    self.items = {}
    self.dead = false
    self.groundOnly = def.groundOnly
end


function Entity:createAnimations(animations)
    local animationsReturned = {}

    for k, animationDef in pairs(animations) do
        animationsReturned[k] = Animation {
            texture = animationDef.texture,
            frames = animationDef.frames,
            interval = animationDef.interval
        }
    end

    return animationsReturned
end


function Entity:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end


function Entity:update(dt)

    if self.type ~= 'player' then
        -- update NPCs that are still on screen
        if self.x > -self.width and self.y < VIRTUAL_HEIGHT then
            self.x = self.x - self.walkSpeed * dt
            -- update entity's items
            for k, item in pairs(self.items) do
                item:update(dt)
            end
        else
            -- flag as dead for removal in playstate if no longer on screen
            self.dead = true
        end
    end

    if self.currentAnimation then
        self.currentAnimation:update(dt)
    end
end


function Entity:render()
    local anim = self.currentAnimation
    love.graphics.draw(gTextures[self.level][anim.texture], 
        gFrames[self.level][anim.texture][anim:getCurrentFrame()], self.x, self.y)
end


function Entity:spawnGameObject(objType, offsetX, offsetY)
    local object = GameObject {
        object_def = OBJECT_DEFS[objType],
        x = self.x + offsetX,
        y = self.y + offsetY,
        isCarried = true,
        carrier = self,
        carrier_offset_x = offsetX,
        carrier_offset_y = offsetY,
        level = self.level
    }
    table.insert(self.items, object)
end