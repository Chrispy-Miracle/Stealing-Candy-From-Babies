Purse = Class{__includes = GameObject}

function Purse:init(def)
    GameObject.init(self, def)
    self.frame = 1
    self.hitBox = HitBox{
        item = {
            x = self.x,
            y = self.y + self.height / 4
        },
        x = self.x,
        y = self.y + self.height / 4,
        width = self.width / 2,
        height = self.height / 2
    }
end

function Purse:update(dt)
    self.hitBox.item = {
        x = self.x,
        y = self.y + self.height / 4
    }
    GameObject.update(self, dt)
end

function Purse:render()
    GameObject.render(self)
end

function Purse:new(entity)
    local object = Purse {
        object_def = OBJECT_DEFS['bad-bag'],
        x = entity.x + MOM_BAG_OFFSET_X,
        y = entity.y + MOM_BAG_OFFSET_Y,
        isCarried = true,
        carrier = entity,
        carrier_offset_x = MOM_BAG_OFFSET_X,
        carrier_offset_y = MOM_BAG_OFFSET_Y,
        level = entity.level
    }
    table.insert(entity.items, object)
end