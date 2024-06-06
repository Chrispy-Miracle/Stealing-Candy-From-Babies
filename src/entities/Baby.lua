Baby = Class{__includes = Entity}

function Baby:init(def)
    Entity.init(self, def)
    self.player = self.playState.player
    self.level = def.level

    self.hitBox = HitBox{
        item = self, 
        x = self.x,
        y = self.y,
        width = self.width,
        height = self.height,
        rotation = 0
    }

    if self.type == 'stork' then
        self.beakHitBox = HitBox{
            item = {
                x = self.x,
                y = self.y + self.height / 2 - 8
            }, 
            x = self.x,
            y = self.y + self.height / 2 - 8,
            width = 15,
            height = 5,
            rotation = 0
        }  
    end

    -- 1 in 2 chance baby gets a balloon
    if math.random(2) == 1 then
        local balloon = GameObject {
            object_def = OBJECT_DEFS['balloon'],
            x = self.x + BABY_BALLOON_OFFSET_X,
            y = self.y + BABY_BALLOON_OFFSET_Y,
            isCarried = true,
            carrier = self,
            carrier_offset_x = BABY_BALLOON_OFFSET_X,
            carrier_offset_y = BABY_BALLOON_OFFSET_Y,
            level = self.level
        }
        table.insert(self.items, balloon)
        self.hasBalloon = true
    end 

    -- 1 in 2 chance baby gets a lollipop
    if not self.hasBalloon and math.random(2) == 1 then
        
        local lollipop = GameObject {
            object_def = OBJECT_DEFS['lollipop'],
            x = self.x + BABY_LOLLIPOP_OFFSET_X,
            y = self.y + BABY_LOLLIPOP_OFFSET_Y,
            isCarried = true,
            carrier = self,
            carrier_offset_x = BABY_LOLLIPOP_OFFSET_X,
            carrier_offset_y = BABY_LOLLIPOP_OFFSET_Y,
            level = self.level
        }

        table.insert(self.items, lollipop)
        self.hasLollipop = true
    end 
end

function Baby:update(dt)
   -- ensure babies still on screen
    if self.x > -self.width then
        Entity.update(self, dt)

        -- update baby's items, unless the item gets stolen!
        for k, item in pairs(self.items) do
            local playerHandPosition
            -- to check for item's stealability
            if self.player.direction == 'right' then
                playerHandPosition = {x = self.player.x + self.player.width / 2, y = self.player.y + self.player.height / 2}
            elseif self.player.direction == 'left' then
                playerHandPosition = {x = self.player.x, y = self.player.y + self.player.height / 2}
            end
            
            if love.keyboard.wasPressed('space') or is_joystick and joystick:isDown({SNES_MAP.b}) then
                if playerHandPosition.x < item.x + item.width and playerHandPosition.x > item.x 
                and playerHandPosition.y < item.y + item.height and playerHandPosition.y > item.y then
                    -- steal the item
                    self.player:stealItem(self, item, k)
                    local mom
                    if not self.player.isFloating then
                        -- spawn a mom when item is stolen from baby
                        mom = Mom {
                            type = 'mom',
                            entity_def = ENTITY_DEFS[self.level]['mom'],
                            x = VIRTUAL_WIDTH,
                            y = math.random(VIRTUAL_HEIGHT / 3, VIRTUAL_HEIGHT / 2 + 8),
                            playState = self.playState,
                            direction = 'left',
                            level = self.level
                        }
                        gSounds['walking']:play()
                    elseif self.player.isFloating then
                        -- if floating, spawn a plane mom!
                        mom = Mom {
                            type = 'plane-mom',
                            entity_def = ENTITY_DEFS[self.level]['plane-mom'],
                            x = VIRTUAL_WIDTH,
                            y = math.random(VIRTUAL_HEIGHT / 3, VIRTUAL_HEIGHT / 2 + 8),
                            playState = self.playState,
                            direction = 'left',
                            level = self.level
                        }
                        if self.level == 1 then
                            gSounds['plane']:play()
                        elseif self.level == 2 then
                            gSounds['zap']:play()
                        end
                    end
                    table.insert(self.playState.moms, mom)
                end
                
            else
                -- update item if not stolen
                item:update(dt)
            end
        end
    else
        -- remove babies no longer on screen (along with their items!)
        self.dead = true
    end

    self.hitBox:update(dt)

    if self.type == 'stork' then
        self.beakHitBox.item.x = self.x
        self.beakHitBox.item.y = self.y + self.height / 2 - 8
        self.beakHitBox:update(dt)
    end

end

function Baby:render()
    Entity.render(self)
    self.hitBox:render()

    -- for debugging collisions
    -- love.graphics.setColor(0,1,0,1)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)

    if self.type == 'stork' then
        self.beakHitBox:render()
        -- love.graphics.rectangle('line', self.x, self.y + self.height / 2 - 5, 15, 5)
    end
    -- love.graphics.setColor(1,1,1,1)
end

