Baby = Class{__includes = Entity}

function Baby:init(def)
    Entity.init(self, def)
    self.player = self.playState.player

    -- 1 in 2 chance baby gets a balloon
    if math.random(3) == 1 then
        local balloon = GameObject {
            object_def = OBJECT_DEFS['balloon'],
            x = self.x + BABY_BALLOON_OFFSET_X,
            y = self.y + BABY_BALLOON_OFFSET_Y,
            isCarried = true,
            carrier = self,
            carrier_offset_x = BABY_BALLOON_OFFSET_X,
            carrier_offset_y = BABY_BALLOON_OFFSET_Y
        }
        table.insert(self.items, balloon)
        self.hasBalloon = true
    end 

    -- 1 in 3 chance baby gets a lollipop
    if not self.hasBalloon and math.random(2) == 1 then
        
        local lollipop = GameObject {
            object_def = OBJECT_DEFS['lollipop'],
            x = self.x + BABY_LOLLIPOP_OFFSET_X,
            y = self.y + BABY_LOLLIPOP_OFFSET_Y,
            isCarried = true,
            carrier = self,
            carrier_offset_x = BABY_LOLLIPOP_OFFSET_X,
            carrier_offset_y = BABY_LOLLIPOP_OFFSET_Y
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
            
            if love.keyboard.wasPressed('space') and 
                playerHandPosition.x < item.x + 5 and playerHandPosition.x > item.x -5 then
                -- steal the item
                self.player:stealItem(self, item, k)
                local mom
                if not self.player.isFloating then
                    -- spawn a mom when item is stolen from baby
                     mom = Mom {
                        type = 'mom',
                        entity_def = ENTITY_DEFS['mom'],
                        x = VIRTUAL_WIDTH,
                        y = math.random(VIRTUAL_HEIGHT / 3, VIRTUAL_HEIGHT / 2 + 8),
                        playState = self.playState,
                        direction = 'left'
                    }
                elseif self.player.isFloating then
                    -- if floating, spawn a plane mom!
                    mom = Mom {
                        type = 'plane-mom',
                        entity_def = ENTITY_DEFS['plane-mom'],
                        x = VIRTUAL_WIDTH,
                        y = math.random(VIRTUAL_HEIGHT / 3, VIRTUAL_HEIGHT / 2 + 8),
                        playState = self.playState,
                        direction = 'left'
                    }
                end
                table.insert(self.playState.moms, mom)
            else
                -- update item if not stolen
                item:update(dt)
            end
        end
    else
        -- remove babies no longer on screen (along with their items!)
        self.dead = true
    end

end

function Baby:render()
    Entity.render(self)
end