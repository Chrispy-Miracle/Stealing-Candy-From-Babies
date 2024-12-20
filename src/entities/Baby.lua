Baby = Class{__includes = Entity}

function Baby:init(def)
    Entity.init(self, def)
    self.player = self.playState.player
    self.level = def.level
    self.momSpawned = false 
    self.timesSteppedOn = 0
    self:setUpHitboxes()
    self:equipBaby()
end

function Baby:update(dt)
   -- ensure babies still on screen
    if self.x > -self.width then
        Entity.update(self, dt)
        self:handleItemsUpdate()
    else
        self.dead = true  -- flag babies no longer on screen for removal
    end
    self:handleGotSteppedOn()
    self:updateHitboxes()
end

function Baby:render()
    Entity.render(self)
    self:renderHitboxes()
end


function Baby:equipBaby()
    -- potentially give baby balloon or lollipop
    if math.random(3) == 1 then
        Balloon:new(self)
    elseif math.random(3) == 1 then
        Lollipop:new(self)
    end 
end

function Baby:handleItemsUpdate()
    -- update baby's items, unless the item gets stolen!
    for k, item in pairs(self.items) do
        if wasSpaceOrBPressed() then
            self:handleItemStealAttempt(k, item)
        else
            -- update item if not stolen
            item:update(dt)
        end
    end
end

function Baby:handleGotSteppedOn()
    if self.hitBox:didCollide(self.player.footHitBox) and not self.momSpawned and not self.player.isFloating then
        Mom:spawnMom('mom', self)
        gSounds['baby-cry-' .. tostring(math.random(3))]:play()
    end
end

function Baby:handleItemStealAttempt(key, item)
    if self.player.handHitBox:didCollide(item.hitBox) then
        -- steal the item
        self.player:stealItem(self, item, key)
        -- spawn a mom 
        if not self.momSpawned then -- ensure 1 mom per baby!
            if self.player.isFloating then
               Mom:spawnMom('plane-mom', self)
            else Mom:spawnMom('mom', self) 
            end
        end
    end
end

function Baby:setUpHitboxes()
    -- hitbox for baby getting stepped on 
    self.hitBox = HitBox{
        item = {
            x = self.x,
            y = self.y + self.height / 2
        }, 
        x = self.x,
        y = self.y + self.height / 2 ,
        width = self.width,
        height = self.height / 2 - 5
    }
    -- hitbox for stork beaks
    if self.type == 'stork' then
        self.beakHitBox = HitBox{
            item = {
                x = self.x,
                y = self.y + self.height / 2 - 8
            }, 
            x = self.x,
            y = self.y + self.height / 2 - 8,
            width = 15,
            height = 5
        }  
    end
end

function Baby:updateHitboxes()
    if self.type == 'stork' then
        self.beakHitBox.item.x = self.x
        self.beakHitBox.item.y = self.y + self.height / 2 - 8
        self.beakHitBox:update(dt)
    else 
        self.hitBox.item.x = self.x
        self.hitBox.item.y = self.y + self.height / 2
        self.hitBox:update(dt)
    end
end

function Baby:renderHitboxes()  -- for debugging collisions 
    self.hitBox:render()
    if self.type == 'stork' then
        self.beakHitBox:render()
    end
end
