HitBox = Class{__includes = BaseState}

function HitBox:init(def)
    self.item = def.item
    self.x = def.x
    self.y = def.y
    self.height = def.height
    self.width = def.width

    self.showHitBoxes = true
end

function HitBox:update(dt)
    self.x = self.item.x
    self.y = self.item.y
end

function HitBox:didCollide(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                self.y + self.height < target.y or self.y > target.y + target.height)
end

function HitBox:render()
    if self.showHitBoxes then
        love.graphics.setColor(0,1,0,1)
        love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
        love.graphics.setColor(1,1,1,1)
    end
end