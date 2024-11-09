Mom = Class{__includes = Entity}

function Mom:init(def)
    Entity.init(self, def)
    --reference to player
    self.player = def.playState.player
    self.didHitPlayer = false
    self.attackSeconds = def.entity_def.attackSeconds  -- level 2 moms attack quicker

    -- moms on the ground get purses to attack with
    if self.type == 'mom' then
        Purse:new(self)
        self:changeAnimation('walk-left')
        
    elseif self.type == 'plane-mom' then
        self:changeAnimation('fly-left')
        self.sound = self.player.level == 1 and gSounds['plane'] or gSounds['zap']
        -- plane moms can crash into player to deal damage
        self.hitBox = HitBox{
            item = self,
            x = self.x,
            y = self.y,
            width = self.width,
            height = self.height
        }
        self.sound:play() 
    end
    
    self:attackPlayer()
end

function Mom:update(dt)
    self:handlePlaneMomCollisions()
    Entity.update(self, dt)
end

function Mom:render()
    Entity.render(self)
    if self.type == 'plane-mom' then
        self.hitBox:render()
    end
end

function Mom:spawnMom(momType, baby)
    local mom
    mom = Mom {
        type = momType,
        entity_def = ENTITY_DEFS[baby.level][momType],
        x = VIRTUAL_WIDTH,
        y = math.random(VIRTUAL_HEIGHT / 3, VIRTUAL_HEIGHT / 2 + 8),
        playState = baby.playState,
        direction = 'left',
        level = baby.level
    }
    table.insert(baby.playState.moms, mom)
    baby.momSpawned = true
end

function Mom:attackPlayer()
    -- play sound
    Timer.after(.7, function () gSounds['mad-mom-' .. tostring(math.random(6))]:play() end)
    -- race mom over to player
    Timer.tween(self.attackSeconds, {
        [self] ={x = self.player.x + self.player.width, y = self.player.y}
    })
    :finish(function () 
        if not self.player.isFloating and not self.player.isFalling then
            self:attackWithPurse() 
        end
    end)
end

function Mom:attackWithPurse()
    -- mom swings purse at player
    Timer.every(.3, function () self:purseSwing() end)
    :limit(4) -- this limit makes the full purse animation happen twice
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

function Mom:handlePlaneMomCollisions()
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
end
