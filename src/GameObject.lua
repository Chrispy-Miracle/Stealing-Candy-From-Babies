GameObject = Class{}

function GameObject:init(def)
    self.type = def.object_def.type
    self.texture = def.object_def.texture
    self.level = def.level
    
    -- mom's purse changes frames when mom attacks
    if self.type == 'bad-bag' then
        self.frame = 1
    else
        -- all other gameobjects can have a random frame
        self.frame = math.random(#def.object_def.frames)
    end

    self.height = def.object_def.height
    self.width = def.object_def.width
    self.x = def.x
    self.y = def.y

    -- is object being carried
    self.isCarried = def.isCarried

    

    if self.isCarried then
        self.carrier = def.carrier
        -- used to position item with carrier
        if self.carrier.direction == 'right' then
            self.carrier_offset_x = def.carrier_offset_x
        elseif self.carrier.direction == 'left' then
            self.carrier_offset_x = -def.carrier_offset_x
        end

        self.carrier_offset_y = def.carrier_offset_y

        self.x = self.carrier.x + self.carrier_offset_x
        self.y = self.carrier.y + self.carrier_offset_y

        self.numBalloonsCarried = 0
    end

    self.balloonAngle = 0
    self.angledXY = {x = 0, y = 0}

    self.hitBox = HitBox{
        item = self,
        x = self.x,
        y = self.y,
        width = self.width,
        height = self.height,
        rotation = 0
    }



end

function GameObject:update(dt)  
    
    -- update object position in relation to carrier
    if self.isCarried then
        if self.carrier.direction == 'right' then
            self.x = self.carrier.x + self.carrier_offset_x
        elseif self.carrier.direction == 'left' then
            self.x = self.carrier.x - self.carrier_offset_x
        end

        self.y = self.carrier.y + self.carrier_offset_y
    end

    if self.isCarried and self.carrier.type == 'player' and self.type == 'balloon' then
        self.hitBox.item = {
                x = self.x + ROTATED_BALLOON_OFFSET_X + self.width / 2 + self.angledXY.x, 
                y = self.y + ROTATED_BALLOON_OFFSET_Y - self.height / 2 + self.angledXY.y,
                rotation = self.balloonAngle + math.rad(180)           
            }
        self.hitBox.x = self.x + ROTATED_BALLOON_OFFSET_X + self.width / 2 + self.angledXY.x
        self.hitBox.y = self.y + ROTATED_BALLOON_OFFSET_Y - self.height / 2 + self.angledXY.y
        self.hitBox.height = self.height / 2
    end

    self.hitBox:update(dt)
    
end


function GameObject:render()   
    if self.isCarried and self.carrier.type == 'player' and self.type == 'balloon' then 
        -- tilt balloons if need be                    
        love.graphics.draw(gTextures[self.level][self.texture], gFrames[self.level][self.texture][self.frame], self.x + ROTATED_BALLOON_OFFSET_X, self.y + ROTATED_BALLOON_OFFSET_Y, self.balloonAngle, 1, 1, self.width / 2, self.height)
        
        -- for debugging collisions
        -- self.hitBox:render()
        -- love.graphics.setColor(0,1,0,1)
        -- drawRotatedRectangle('line', self.x + ROTATED_BALLOON_OFFSET_X + self.width / 2 + self.angledXY.x, self.y + ROTATED_BALLOON_OFFSET_Y - self.height / 2 + self.angledXY.y, self.width, self.height / 2, self.balloonAngle +math.rad(180))
        -- love.graphics.setColor(1,1,1,1)
    else
        -- or draw object normally
        love.graphics.draw(gTextures[self.level][self.texture], gFrames[self.level][self.texture][self.frame], self.x, self.y)

        -- self.hitBox:render()
    end
    
    -- for debugging collisions
    self.hitBox:render()
end