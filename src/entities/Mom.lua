Mom = Class{__includes = Entity}

function Mom:init(def)
    Entity.init(self, def)
    --reference to player
    self.player = def.playState.player

    self.purse = GameObject {
        type = 'bad-bag',
        object_def = OBJECT_DEFS['bad-bag'],
        x =  self.x + MOM_BAG_OFFSET_X,
        y = self.y + MOM_BAG_OFFSET_Y,
        isCarried = true,
        carrier = self,
        carrier_offset_x = MOM_BAG_OFFSET_X,
        carrier_offset_y = MOM_BAG_OFFSET_Y
    }
    
    table.insert(self.items, self.purse)
    self:changeAnimation('walk-left')

    -- race mom over to player
    Timer.tween(1, {
        [self] ={x = self.player.x + self.player.width, y = self.player.y}
    })
    
    :finish(function () 
        Timer.every(.3, function ()
            -- mom's purse is animated to swing at player
            if self.items[1].frame == 1 then
                self.items[1].frame = 2 

                -- deal damage if mom's purse hits player
                if self.items[1].x < self.player.x + self.player.width then
                    gSounds['hit']:play()
                    self.player.health =  self.player.health - 5
                end
            else
                self.items[1].frame = 1 
            end
        -- this limit makes the full purse animation happen twice
        end):limit(4)
    end)
end

function Mom:update(dt)
    Entity.update(self, dt)
end

function Mom:render()
    Entity.render(self)
end