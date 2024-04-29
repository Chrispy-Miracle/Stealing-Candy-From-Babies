Entity = Class{}

function Entity:init(def)
    self.type = def.entity_def.type

    self.animations = self:createAnimations(def.entity_def.animations)

    self.x = def.x
    self.y = def.y

    self.height = def.entity_def.height
    self.width = def.entity_def.width 

    self.walkSpeed = def.entity_def.walkSpeed

    -- health (or sugar buzz)
    self.health = def.entity_def.startingHealth
    self.maxHealth = def.entity_def.maxHealth

    if self.type == 'player' then
        Timer.every(1, function () self.health = self.health - 1 end)
    end

    self.balloonsCarried = 0
    self.gravity = 0
    -- self.antiGravity = 0


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


function Entity:stealItem(baby, item, itemKey)
                    
    local playerHandPosition = {x = self.x + self.width, y = self.y + self.height / 2}

    gSounds['steal']:play()
    -- item.x = playerHandPosition.x
    -- item.y = playerHandPosition.y

    if item.type == 'balloon' then
        item.carrier_offset_x = PLAYER_BALLOON_OFFSET_X
        item.carrier_offset_y = PLAYER_BALLOON_OFFSET_Y
        self.balloonsCarried = self.balloonsCarried + 1
        
    elseif item.type == 'lollipop' then
        self.hasLollipop = true
        item.carrier_offset_x = PLAYER_LOLLIPOP_OFFSET_X
        item.carrier_offset_y = PLAYER_LOLLIPOP_OFFSET_Y 
        Timer.every(.2, function () 
            if self.health < self.maxHealth then
                self.health = self.health + 1
            end
        end)
        :limit(15)
        :finish(function () 
            self.hasLollipop = false
            table.remove(self.items, k) 
        end)
        
    end 
    table.remove(baby.items, itemKey)
    
    table.insert(self.items, item)  
    item.carrier = self              
end



function Entity:update(dt)
    if self.balloonsCarried > 3 then
        self.gravity = self.balloonsCarried * 10
        self.isFloating = true

        if self.y > -self.height then
            self.y = self.y - self.gravity * dt
        else 
            self.y = VIRTUAL_HEIGHT
            -- Timer.tween(1.5, {
            --     [self] = {y = VIRTUAL_HEIGHT / 3}
            -- })
            self.gravity = 0
        end

    else
        self.isFloating = false
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
