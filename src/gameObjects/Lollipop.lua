Lollipop = Class{__includes = GameObject}

function Lollipop:new(entity)
    local object = Lollipop {
        object_def = OBJECT_DEFS['lollipop'],
        x = entity.x + BABY_LOLLIPOP_OFFSET_X,
        y = entity.y + BABY_LOLLIPOP_OFFSET_Y,
        isCarried = true,
        carrier = entity,
        carrier_offset_x = BABY_LOLLIPOP_OFFSET_X,
        carrier_offset_y = BABY_LOLLIPOP_OFFSET_Y,
        level = entity.level
    }
    table.insert(entity.items, object)
end
