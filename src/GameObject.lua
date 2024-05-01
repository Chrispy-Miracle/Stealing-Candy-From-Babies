GameObject = Class{}

function GameObject:init(def)
    self.type = def.object_def.type
    self.texture = def.object_def.texture
    
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
        self.carrier_offset_x = def.carrier_offset_x
        self.carrier_offset_y = def.carrier_offset_y

        self.x = self.carrier.x +  self.carrier_offset_x
        self.y = self.carrier.y + self.carrier_offset_y

        self.numBalloonsCarried = 0
    end

    self.balloonAngle = 0

end

function GameObject:update(dt)
    -- update object position in relation to carrier
    if self.isCarried then
            self.x = self.carrier.x + self.carrier_offset_x
            self.y = self.carrier.y + self.carrier_offset_y

        -- when there is more than one item (should be balloons)
        if #self.carrier.items > 1 then
            -- angle the balloons nicely
            for k, item in pairs(self.carrier.items) do
                if k % 2 == 0 then
                    item.balloonAngle =  math.rad(k * -10)
                else 
                    item.balloonAngle = math.rad(k * 10)
                end
            end
        else
            self.balloonAngle = 0
        end
    end
end


function GameObject:render()   
    if self.isCarried and self.carrier.type == 'player' and self.type == 'balloon' then 
        -- tilt balloons if need be                    
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x + ROTATED_BALLOON_OFFSET_X, self.y + ROTATED_BALLOON_OFFSET_Y, self.balloonAngle, 1, 1, self.width / 2, self.height)
    else
        -- or draw object normally
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
    end
end