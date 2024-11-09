GameObject = Class{}

function GameObject:init(def)
    self.type = def.object_def.type
    self.texture = def.object_def.texture
    self.level = def.level
    self.height = def.object_def.height
    self.width = def.object_def.width
    self.x = def.x
    self.y = def.y    
    -- most gameobjects can have a random frame
    self.frame = math.random(#def.object_def.frames)
    -- is object being carried
    self.isCarried = def.isCarried

    -- position item with carrier
    if self.isCarried then
        self.carrier = def.carrier
        self.carrier_offset_y = def.carrier_offset_y
        self.carrier_offset_x = def.carrier_offset_x
        self.x = self.carrier.x + self.carrier_offset_x
        self.y = self.carrier.y + self.carrier_offset_y
    end
    
    -- most game object hitboxes
    self.hitBox = HitBox{
        item = self,
        x = self.x,
        y = self.y,
        width = self.width,
        height = self.height
    }
end


function GameObject:update(dt)  
    -- update object position in relation to carrier
    if self.isCarried then
        -- udpate x for carrier direction offset
        if self.carrier.direction == 'right' or self.type =='lollipop' and self.carrier.type == 'player' then
            self.x = self.carrier.x + self.carrier_offset_x
        elseif self.carrier.direction == 'left' then
            self.x = self.carrier.x - self.carrier_offset_x
        end
        -- update y
        self.y = self.carrier.y + self.carrier_offset_y
    end
    self.hitBox:update(dt)
end


function GameObject:render()   
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
    
    -- for debugging collisions
    self.hitBox:render()
end
