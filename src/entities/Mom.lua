Mom = Class{__includes = Entity}

function Mom:init(def)
    Entity.init(self, def)
    --reference to player
    self.player = def.playState.player
    self.didHitPlayer = false

    -- moms on the ground get purses to attack with
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
        table.insert(self.items, self.purse)
        self:changeAnimation('walk-left')
        
    elseif self.type == 'plane-mom' then
        self:changeAnimation('fly-left')
        -- plane moms can crash into player to deal damage
        self.hitBox = HitBox{
            item = self,
            x = self.x,
            y = self.y,
            width = self.width,
            height = self.height
        }
    end
    
    self.attackSpeed = self.player.level == 1 and 1 or .5  -- level 2 moms attack quicker

    -- race mom over to player
    Timer.tween(self.attackSpeed, {
        [self] ={x = self.player.x + self.player.width, y = self.player.y}
    })
    :finish(function () self:attackWithPurse() end)
end

function Mom:update(dt)
    -- only plane moms have hitboxes
    if self.hitBox then
        self.hitBox:update(dt)
    end

    -- detect and resolve collisions between plane moms and player
    if self.player.isFloating and self.type == 'plane-mom' and not self.didHitPlayer then
        if self.player.hitBox:didCollide(self.hitBox) then  
        gSounds['hit-ground']:play()
            self.player.health =  self.player.health - 10
            self.player.scoreDetails[self.player.level]['Damage Taken'] = self.player.scoreDetails[self.player.level]['Damage Taken'] + 10
            self.didHitPlayer = true
        end
    end

    Entity.update(self, dt)
end


function Mom:attackWithPurse()
    -- mom swings purse twice at player
    if not self.player.isFloating and not self.player.isFalling then
        Timer.every(.3, function () self:purseSwing() end)
        :limit(4)-- this limit makes the full purse animation happen twice
    end
end

function Mom:purseSwing()
    if self.items[1] then
        -- mom's purse is animated to swing at player
        if self.items[1].frame == 1 then
            self.items[1].frame = 2 
            self:handlePurseCollision()
        else
            self.items[1].frame = 1 
        end
    end
end

function Mom:handlePurseCollision()  -- deal damage if mom's purse hits player
    if self.items[1].hitBox:didCollide(self.player.hitBox) then
        gSounds['hit']:play()
        self.player.health =  self.player.health - 5
        self.player.scoreDetails[self.player.level]['Damage Taken'] = self.player.scoreDetails[self.player.level]['Damage Taken'] + 5
    end
end


function Mom:render()
    Entity.render(self)
    
    if self.type == 'plane-mom' then
        self.hitBox:render()
    end

end