Mom = Class{__includes = Entity}

function Mom:init(def)
    Entity.init(self, def)
    --reference to player
    self.player = def.playState.player

    self.didHitPlayer = false

    -- if spawned on the ground
    if self.type == 'mom' then
        self.purse = GameObject {
            type = 'bad-bag',
            object_def = OBJECT_DEFS['bad-bag'],
            x =  self.x + MOM_BAG_OFFSET_X,
            y = self.y + MOM_BAG_OFFSET_Y,
            isCarried = true,
            carrier = self,
            carrier_offset_x = MOM_BAG_OFFSET_X,
            carrier_offset_y = MOM_BAG_OFFSET_Y,
            level = self.player.level
        }
        self:changeAnimation('walk-left')
        table.insert(self.items, self.purse)
    elseif self.type == 'plane-mom' then
        self:changeAnimation('fly-left')
    end

    

    -- race mom over to player
    Timer.tween(1, {
        [self] ={x = self.player.x + self.player.width, y = self.player.y}
    })
    
    :finish(function () 

        if not self.player.isFloating and not self.player.isFalling then
            Timer.every(.3, function ()
                -- mom's purse is animated to swing at player
                if self.items[1].frame == 1 then
                    self.items[1].frame = 2 

                    -- deal damage if mom's purse hits player
                    if self.items[1].x < self.player.x + self.player.width then
                        gSounds['hit']:play()
                        self.player.health =  self.player.health - 5
                        self.player.scoreDetails[self.player.level]['Damage Taken'] = self.player.scoreDetails[self.player.level]['Damage Taken'] + 5
                    end
                else
                    self.items[1].frame = 1 
                end
            -- this limit makes the full purse animation happen twice
            end):limit(4)
        end
    end)
end

function Mom:update(dt)
    if self.player.isFloating and self.type == 'plane-mom' and not self.didHitPlayer then
        if self.x < self.player.x + self.player.width and self.x > self.player.x + self.player.width - 10 and self.y > self.player.y and self.y < self.player.y + self.player.height then
            gSounds['hit-ground']:play()
            self.player.health =  self.player.health - 10
            self.player.scoreDetails[self.player.level]['Damage Taken'] = self.player.scoreDetails[self.player.level]['Damage Taken'] + 10
            self.didHitPlayer = true
        end
    end

    -- if not self.player.isFloating then
        Entity.update(self, dt)
    -- elseif self.player.isFloating and self.groundOnly == false or then
    --     En
end

function Mom:render()
    Entity.render(self)
end