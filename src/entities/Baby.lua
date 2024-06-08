Baby = Class{__includes = Entity}

function Baby:init(def)
    Entity.init(self, def)
    self.player = self.playState.player
    self.level = def.level

    self.momSpawned = false 

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

    
    if math.random(3) == 1 then
        -- 1 in 3 chance baby gets a balloon
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
 
    elseif math.random(3) == 1 then
        -- 1 in 3 chance baby gets a lollipop
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
    end 
end

function Baby:update(dt)
   -- ensure babies still on screen
    if self.x > -self.width then
        Entity.update(self, dt)

        -- update baby's items, unless the item gets stolen!
        for k, item in pairs(self.items) do
            if love.keyboard.wasPressed('space') or is_joystick and joystick:isDown({SNES_MAP.b}) then
                if self.player.handHitBox:didCollide(item.hitBox) then
                    -- steal the item
                    self.player:stealItem(self, item, k)

                    -- spawn a mom when item is stolen from baby
                    if not self.momSpawned then
                        local mom
                        -- ground mom if player not floating
                        if not self.player.isFloating then
                            mom = Mom {
                                type = 'mom',
                                entity_def = ENTITY_DEFS[self.level]['mom'],
                                x = VIRTUAL_WIDTH,
                                y = math.random(VIRTUAL_HEIGHT / 3, VIRTUAL_HEIGHT / 2 + 8),
                                playState = self.playState,
                                direction = 'left',
                                level = self.level
                            }
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
                            -- different plane mom sounds for different levels
                            if self.level == 1 then
                                gSounds['plane']:play()
                            elseif self.level == 2 then
                                gSounds['zap']:play()
                            end
                        end
                        table.insert(self.playState.moms, mom)
                        self.momSpawned = true
                    end
                end
                
            else
                -- update item if not stolen
                item:update(dt)
            end
        end
    else
        -- flag babies no longer on screen for removal (along with their items!)
        self.dead = true
    end

    -- spawn a mom if baby is stepped on
    if self.hitBox:didCollide(self.player.footHitBox) and not self.momSpawned and not self.player.isFloating then
            local mom
            mom = Mom {
                type = 'mom',
                entity_def = ENTITY_DEFS[self.level]['mom'],
                x = VIRTUAL_WIDTH,
                y = math.random(VIRTUAL_HEIGHT / 3, VIRTUAL_HEIGHT / 2 + 8),
                playState = self.playState,
                direction = 'left',
                level = self.level
            }
            gSounds['baby-cry-' .. tostring(math.random(3))]:play()
            Timer.after(.7, function () gSounds['mad-mom-' .. tostring(math.random(6))]:play() end)
            table.insert(self.playState.moms, mom)
            self.momSpawned = true
    end

    -- update hitboxes
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

function Baby:render()
    Entity.render(self)

    -- for debugging collisions 
    self.hitBox:render()

    if self.type == 'stork' then
        self.beakHitBox:render()
    end
end

