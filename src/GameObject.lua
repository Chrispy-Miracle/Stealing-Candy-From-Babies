GameObject = Class{}

function GameObject:init(def)
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
    end
end

function GameObject:update()
    -- update object position in relation to carrier
    if self.isCarried then
        self.x = self.carrier.x - self.carrier_offset_x
        self.y = self.carrier.y - self.carrier_offset_y
    end
end

function GameObject:render()
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
end