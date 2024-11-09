Balloon = Class{__includes = GameObject}

function Balloon:init(def)
    GameObject.init(self, def)
    self.balloonAngle = 0
    self.angledXY = {x = 0, y = 0} -- for balloon hitboxes
end

function Balloon:update(dt)
    GameObject.update(self, dt)
    self.hitBox.item = {
        x = self.x + self.width / 2 + self.angledXY.x,
        y = self.y + self.angledXY.y            
    }
    self.hitBox.x = self.x + self.width / 2 + self.angledXY.x  
    self.hitBox.y = self.y + self.angledXY.y  
    self.hitBox.height = self.height / 2
end

function Balloon:render() 
    if self.carrier.type == "player" then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x + ROTATED_BALLOON_OFFSET_X, self.y + ROTATED_BALLOON_OFFSET_Y, self.balloonAngle, 1, 1, self.width / 2, self.height)
    else 
        GameObject.render(self)
    end
end

function Balloon:new(entity)
    local object = Balloon {
        object_def = OBJECT_DEFS['balloon'],
        x = entity.x + BABY_BALLOON_OFFSET_X,
        y = entity.y +  BABY_BALLOON_OFFSET_Y,
        isCarried = true,
        carrier = entity,
        carrier_offset_x = BABY_BALLOON_OFFSET_X,
        carrier_offset_y = BABY_BALLOON_OFFSET_Y,
        level = entity.level
    }
    table.insert(entity.items, object)
end
