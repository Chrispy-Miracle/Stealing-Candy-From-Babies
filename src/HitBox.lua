HitBox = Class{__includes = BaseState}

function HitBox:init(def)
    self.item = def.item
    self.x = def.x
    self.y = def.y
    self.height = def.height
    self.width = def.width
    self.rotation = def.rotation
end

function HitBox:update(dt)
    self.x = self.item.x
    self.y = self.item.y
end

function HitBox:collide(other)

    return 
end

function HitBox:render()
    love.graphics.setColor(0,1,0,1)
    if self.rotation == 0 then
        love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    else
        drawRotatedRectangle('line', self.x, self.y, self.width, self.height, self.rotation)
    end
    love.graphics.setColor(1,1,1,1)
end