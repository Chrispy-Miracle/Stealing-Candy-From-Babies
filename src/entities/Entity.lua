Entity = Class{}

function Entity:init(def)
    self.type = def.entity_def.type
    self.playState = def.playState

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


function Entity:stealItem(prevOwner, item, itemKey)
                    
    gSounds['steal']:play()

    if item.type == 'balloon' then
        item.carrier_offset_x = PLAYER_BALLOON_OFFSET_X
        item.carrier_offset_y = PLAYER_BALLOON_OFFSET_Y
        self.balloonsCarried = self.balloonsCarried + 1

        -- take out of previous carrier's items
        table.remove(prevOwner.items, itemKey)
        -- put into player's items
        item.carrier = self
        table.insert(self.items, item) 
        
    elseif item.type == 'lollipop' then
        self.hasLollipop = true
        item.carrier_offset_x = PLAYER_LOLLIPOP_OFFSET_X
        item.carrier_offset_y = PLAYER_LOLLIPOP_OFFSET_Y

        -- take out of previous carrier's items
        table.remove(prevOwner.items, itemKey)
        -- put into player's items
        item.carrier = self
        table.insert(self.items, item)  
        

        -- this animates health bar going up 1 point every .2 seconds
        Timer.every(.2, function () 
            if self.health < self.maxHealth then
                self.health = self.health + 1
            end
        end)
        :limit(15)
        :finish(function () 
            self.hasLollipop = false
            -- remove lollipop from items
            if self.items[#self.items].type == 'lollipop' then
                table.remove(self.items, #self.items)
            else
                table.remove(self.items, #self.items - 1) 
            end
        end)
    end 
  
end



function Entity:update(dt)

    if self.type ~= 'player' then
        -- update NPCs that are still on screen
        if self.x > -self.width then
            self.x = self.x - self.walkSpeed * dt
            -- update player's items
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
    love.graphics.draw(gTextures[anim.texture], 
        gFrames[anim.texture][anim:getCurrentFrame()], self.x, self.y)
end
