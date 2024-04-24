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
    item.x = playerHandPosition.x
    item.y = playerHandPosition.y

    if item.type == 'balloon' then
        item.carrier_offset_x = PLAYER_BALLOON_OFFSET_X
        item.carrier_offset_y = PLAYER_BALLOON_OFFSET_Y
        
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
            table.remove(self.items) 
        end)
        
    end 
    table.remove(baby.items, itemKey)
    
    table.insert(self.items, item)  
    item.carrier = self              
end



function Entity:update(dt)

    if self.currentAnimation then
        self.currentAnimation:update(dt)
    end
end


function Entity:render()
    local anim = self.currentAnimation
    love.graphics.draw(gTextures[anim.texture], 
        gFrames[anim.texture][anim:getCurrentFrame()], self.x, self.y)
end
