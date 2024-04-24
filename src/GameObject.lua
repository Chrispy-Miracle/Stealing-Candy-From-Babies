GameObject = Class{}

function GameObject:init(def)
    self.type = def.object_def.type
    self.texture = def.object_def.texture
    self.frame = math.random(#def.object_def.frames)
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

    --     if #self.carrier.items > 3 and self.type == 'balloon' then
    --         self.balloonAngle =  2.5-- math.rad(math.deg(math.random(-30,30)))
    --     else
    --         self.balloonAngle = 0
    --     end
    end

end

function GameObject:update(dt)
    -- update object position in relation to carrier
    if self.isCarried then
            self.x = self.carrier.x + self.carrier_offset_x
            self.y = self.carrier.y + self.carrier_offset_y
    end
end

function GameObject:render()   
    -- if self.carrier.type == 'player' and self.type == 'balloon' then                     
    --     love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y, self.balloonAngle, 1, 1, self.width / 2, self.height / 2)
    -- else
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
    -- end
end