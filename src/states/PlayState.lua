PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.background = 1 -- can be changed for extra backgrounds
    self.backgroundScrollX = 0
    self.backgroundScrollY = 0

    -- player
    self.player = Entity {
        type = 'player',
        entity_def = ENTITY_DEFS['player'],
        x = - 16,
        y = VIRTUAL_HEIGHT - 70,
        direction = 'right',
    }
    
    
    -- player's state machine
    self.player.stateMachine = StateMachine{
        ['idle'] = function () return PlayerIdleState(self.player) end,
        ['walk-state'] = function () return PlayerWalkState(self) end,
        ['float-state'] = function () return PlayerFloatingState(self) end
    }
    self.player.stateMachine:change('idle')


    -- this animation walks player onto scene
    self.player.isWalking = true
    self.player:changeAnimation('walk-' .. self.player.direction)
    gSounds['walking']:play()
    Timer.tween(1, {
        [self.player] = {x = 16}
    })
    -- stop player (Ready to Play!)
    :finish(function() 
        self.player.isWalking = false
        self.player.stateMachine:change('idle')
    end)



    -- table to hold spawned babies
    self.babies = {}
    self:spawnBabies()

    -- table for spawned moms
    self.moms = {}

    -- table for storks (the slow ones)
    self.storks = {}
    self.storksSpawned = false

end


function PlayState:update(dt)
    if self.player.health <= 0 then
        gStateMachine:change('game-over')
    end
    
    -- after player has enough balloons, then they start floating away
    if self.player.isFloating then --and not self.player.isFalling then
        self.player.stateMachine:change('float-state')
    end

        -- local scrollGravity = self.player.balloonsCarried * 10
        -- self.backgroundScrollY = (self.backgroundScrollY - scrollGravity * dt) % BACKGROUND_Y_LOOP_POINT
        -- self.backgroundScrollX = 0
        -- Timer.after(2.4, function () self.background = 2 end)
        -- if not self.storksSpawned then
        --    self:spawnStorks()
        --    self.storksSpawned = true
        -- end

        -- -- check for stork beaks hitting balloons
        -- for k, stork in pairs(self.storks) do
        --     -- check each balloon
        --     for k, item in pairs(self.player.items) do
        --         if item.type == 'balloon' then
        --             if stork.x < item.x + item.width + 10 and 
        --                 stork.x > item.x + item.width - 10 and
        --                 stork.y < item.y + 30 and 
        --                 stork.y > item.y then
        --                 table.remove(self.player.items, k)
        --                 gSounds['hit']:play()
        --                 self.player.balloonsCarried = self.player.balloonsCarried - 1
        --                 self.backgroundScrollY = (self.backgroundScrollY + self.player.gravity * dt) % BACKGROUND_Y_LOOP_POINT
        --                 self.backgroundScrollX = 0
        --             end
        --         end
        --     end
        -- end

    -- end


    -- local playerHandPosition = {x = self.player.x + self.player.width / 2, y = self.player.y + self.player.height / 2}
    
    -- update player state machine
    self.player.stateMachine:update(dt)

    -- update babies
    self:updateBabies(dt)
    -- for k, baby in pairs(self.babies) do
    --     baby:update(dt)
    -- end
    

    -- update player's items
    for k, item in pairs(self.player.items) do
        item:update(dt)
    end

    for k, stork in pairs(self.storks) do
        if stork.x > -stork.width then
            stork.x = stork.x - stork.walkSpeed * dt
            stork:update(dt)
        else
            table.remove(self.storks, k)
        end
    end

    -- update moms
    for k, mom in pairs(self.moms) do
        mom:update(dt)
    end
end



function PlayState:render() 
    -- draw background
    love.graphics.draw(gTextures['background'], gFrames['background'][self.background], 
        math.floor(-self.backgroundScrollX), 
        math.floor(-self.backgroundScrollY) - 144)

    love.graphics.draw(gTextures['background'], gFrames['background'][self.background], 
        math.floor(-self.backgroundScrollX + BACKGROUND_X_LOOP_POINT), 
        math.floor(-self.backgroundScrollY) - 144)

    love.graphics.draw(gTextures['background'], gFrames['background'][self.background], 
        math.floor(-self.backgroundScrollX), 
        math.floor(-self.backgroundScrollY + BACKGROUND_Y_LOOP_POINT) - 144) 


    -- draw health (sugar-rush) bar
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Sugar Rush: ', 4, 2)
    love.graphics.setColor(0,0,0, 255)
    love.graphics.rectangle('fill', 63, 3, self.player.maxHealth + 2, 8)
    love.graphics.setColor(255, 255, 255, 255)
    -- make bar flash if gaining health
    if self.player.hasLollipop then
        love.graphics.setColor(math.random(1, 255)/255, math.random(1, 255)/255, math.random(1, 255)/255, 255)
    -- make bar red if low health
    elseif self.player.health < 20 then
        love.graphics.setColor(255, 0, 0, 255)
    end 
    love.graphics.rectangle('fill', 64, 4, self.player.health, 6)
    love.graphics.setColor(255, 255, 255, 255)
    
    
    -- used to render NPCs behind or in front of player
    local playerY = self.player.y + self.player.height

    -- draw babies
    for k, baby in pairs(self.babies) do
        local babyY = baby.y + baby.height
        if  babyY < playerY then 
            -- draw babies items behind player
            for k, item in pairs(baby.items) do
                item:render()
            end
            -- draw babies behind player
            baby:render()
        end
    end


    
    -- draw player's balloons behind player
    for k, item in pairs(self.player.items) do
        if item.type == 'balloon' then
            item:render()
        end 
    end 


    -- draw player
    self.player.stateMachine:render()

    -- draw player's lollipops in front of player
    for k, item in pairs(self.player.items) do
        if item.type == 'lollipop' then
            item:render()
        end 
    end


   -- babies
    for k, baby in pairs(self.babies) do
        -- draw babies' items in front of player
        if baby.y + baby.height > self.player.y + self.player.height then 
            for k, item in pairs(baby.items) do
                item:render()
            end
            -- draw babies in front of player
            baby:render()
        end
    end


    -- moms
    for k, mom in pairs(self.moms) do
        -- moms in front of player
        -- if mom.y + mom.height > self.player.y + self.player.height then
            mom:render()
            -- mom's items
            for k, item in pairs(mom.items) do
                item:render()
            end
        -- end
    end

    -- storks
    for k, stork in pairs(self.storks) do
        stork:render()
    end
end


-- This is called once and makes "the slow storks"
function PlayState:spawnStorks()
    Timer.every(2, function ()
        if math.random(3) == 1 then
            local stork = Entity {
                type = 'stork',
                entity_def = ENTITY_DEFS['stork'],
                x = VIRTUAL_WIDTH,
                y = math.random(0, VIRTUAL_HEIGHT - ENTITY_DEFS['stork'].height)
            }
            stork:changeAnimation('fly')
            table.insert(self.storks, stork)
        end
    end)
end


function PlayState:spawnBabies()
    Timer.every(1, function ()
        local baby
        if not self.player.isFloating then
            -- every second, 1 in 3 odds to spawn baby
            if math.random(3) == 1 then
                -- make baby
                baby = Entity {
                    type = 'baby',
                    playState = self,
                    entity_def = ENTITY_DEFS['baby'],
                    x = VIRTUAL_WIDTH - 10,
                    y = math.random(VIRTUAL_HEIGHT - 32, VIRTUAL_HEIGHT / 2+ 16),
                }
                baby:changeAnimation('crawl-left')
            end
        elseif self.player.isFloating then
            --maybe make a stork (as the baby!)
            if math.random(3) == 1 then
                baby = Entity {
                    type = 'stork',
                    entity_def = ENTITY_DEFS['stork'],
                    x = VIRTUAL_WIDTH,
                    y = math.random(0, VIRTUAL_HEIGHT - ENTITY_DEFS['stork'].height)
                }
                baby:changeAnimation('fly')
                table.insert(self.babies, baby)
            end
        end

        if baby then
        
            -- 1 in 3 three chance baby gets a balloon
            if math.random(2) == 1 then
                baby.hasBalloon = true
                local balloon = GameObject {
                    object_def = OBJECT_DEFS['balloon'],
                    x = baby.x + BABY_BALLOON_OFFSET_X,
                    y = baby.y + BABY_BALLOON_OFFSET_Y,
                    isCarried = true,
                    carrier = baby,
                    carrier_offset_x = BABY_BALLOON_OFFSET_X,
                    carrier_offset_y = BABY_BALLOON_OFFSET_Y
                }
                table.insert(baby.items, balloon)
            end 

            -- 1 in 3 chance baby gets a lollipop
            if not baby.hasBalloon and math.random(3) == 1 then
                baby.hasLollipop = true
                local lollipop = GameObject {
                    object_def = OBJECT_DEFS['lollipop'],
                    x = baby.x + BABY_LOLLIPOP_OFFSET_X,
                    y = baby.y + BABY_LOLLIPOP_OFFSET_Y,
                    isCarried = true,
                    carrier = baby,
                    carrier_offset_x = BABY_LOLLIPOP_OFFSET_X,
                    carrier_offset_y = BABY_LOLLIPOP_OFFSET_Y
                }

                table.insert(baby.items, lollipop)
            end 

            table.insert(self.babies, baby)
        end
    end)
end


function PlayState:updateBabies(dt)
    local playerHandPosition = {
        x = self.player.x + self.player.width / 2, 
        y = self.player.y + self.player.height / 2
    }

    for k, baby in pairs(self.babies) do
        -- ensure babies still on screen
        if baby.x > -baby.width then
            baby.x = baby.x - baby.walkSpeed * dt
            baby:update(dt)
            -- update baby's items
            for k, item in pairs(baby.items) do
                -- unless the item gets stolen!
                if playerHandPosition.x < item.x + 5 and playerHandPosition.x > item.x -5 and
                    love.keyboard.wasPressed('space') then
                    self.player:stealItem(baby, item, k)
                    -- spawn a mom if the item is stolen
                    local mom = Mom {
                        type = 'mom',
                        entity_def = ENTITY_DEFS['mom'],
                        x = VIRTUAL_WIDTH,
                        y = math.random(VIRTUAL_HEIGHT / 3, VIRTUAL_HEIGHT / 2 + 8),
                        playState = self
                    }
                    table.insert(self.moms, mom)
                end
                --or the item is a balloon and it got popped by a stork
                if item.type == 'balloon' then
                    -- baby is a stork in this instance
                    if baby.x < item.x + item.width + 10 and 
                        baby.x > item.x + item.width - 10 and
                        baby.y < item.y + 30 and 
                        baby.y > item.y then
                        table.remove(self.player.items, k)
                        gSounds['hit']:play()
                        self.player.balloonsCarried = self.player.balloonsCarried - 1
                        self.backgroundScrollY = (-self.backgroundScrollY + self.player.gravity * dt) % BACKGROUND_Y_LOOP_POINT
                        self.backgroundScrollX = 0
                    end
                end

                item:update(dt)
            end
        else
            -- remove babies no longer on screen (along with their items!)
            table.remove(self.babies, k)
        end
    end
end
