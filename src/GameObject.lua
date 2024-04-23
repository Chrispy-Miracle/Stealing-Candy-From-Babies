GameObject = Class{}

function GameObject:init(def)
    self.type = def.type
    self.texture = def.texture
    self.frame = def.frame
    self.height = def.height
    self.width = def.width
    self.x = def.x
    self.y = def.y
    self.isCarried = def.isCarried

    if self.isCarried then
        self.carrier = def.carrier
        self.carrier_offset_x = def.carrier_offset_x
        self.carrier_offset_y = def.carrier_offset_y
    end
end

function GameObject:update()
    if self.isCarried then
        self.x = self.carrier.x - self.carrier_offset_x
        self.y = self.carrier.y - self.carrier_offset_y
    end
end

function GameObject:render()
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
end