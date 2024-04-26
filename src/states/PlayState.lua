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
        y = VIRTUAL_HEIGHT - 70
    }
    self.player.direction = 'right'
    self.player.items = {}
    
    -- player's state machine
    self.player.stateMachine = StateMachine{
        ['idle'] = function () return PlayerIdleState(self.player) end,
        ['walk-state'] = function () return PlayerWalkState(self.player) end
    }
    self.player.stateMachine:change('idle')


    -- this animation walks player onto scene
    self.player:changeAnimation('walk-' .. self.player.direction)
    gSounds['walking']:play()
    Timer.tween(2, {
        [self.player] = {x = 16}
    })
    -- stop player (Ready to Play!)
    :finish(function() 
        self.player.stateMachine:change('idle')
    end)


    -- table to hold spawned babies
    self.babies = {}
    self:spawnBabies()

    -- table for spawned moms
    self.moms = {}
    self:spawnMoms()

end




function PlayState:update(dt)
    if self.player.health <= 0 then
        gStateMachine:change('game-over')
    end

    self.backgroundScrollX = (self.backgroundScrollX + BACKGROUND_X_SCROLL_SPEED * dt) % BACKGROUND_X_LOOP_POINT
    
    if self.player.isFloating then
        local scrollGravity = self.player.balloonsCarried * 10
        self.backgroundScrollY = (self.backgroundScrollY - scrollGravity * dt) % BACKGROUND_Y_LOOP_POINT
        self.backgroundScrollX = 0
        self.background = 2
    else
        self.backgroundScrollY = 0
    end

    local playerHandPosition = {x = self.player.x + self.player.width / 2, y = self.player.y + self.player.height / 2}
    
    -- update player state machine
    self.player.stateMachine:update(dt)

    -- update babies
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
                end
                    
                item:update(dt)
            end
        else
            -- remove babies no longer on screen (along with their items!)
            table.remove(self.babies, k)
        end
    end


    -- update player's items
    for k, item in pairs(self.player.items) do
        item:update(dt)
    end

    -- update moms
    for k, mom in pairs(self.moms) do
        -- ensure moms still on screen
        if mom.x > -mom.width then
            mom.x = mom.x - mom.walkSpeed * dt
            mom:update(dt)

        else
            -- remove moms no longer on screen
            table.remove(self.moms, k)
        end
    end
end

function PlayState:render()
    -- draw background
    love.graphics.draw(gTextures['background'], gFrames['background'][self.background], math.floor(-self.backgroundScrollX), math.floor(-self.backgroundScrollY))
    love.graphics.draw(gTextures['background'], gFrames['background'][self.background], math.floor(-self.backgroundScrollX + BACKGROUND_X_LOOP_POINT), math.floor(-self.backgroundScrollY))
    love.graphics.draw(gTextures['background'], gFrames['background'][self.background], math.floor(-self.backgroundScrollX), math.floor(-self.backgroundScrollY + BACKGROUND_Y_LOOP_POINT))



    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Sugar Rush: ', 4, 2)
    love.graphics.setColor(0,0,0, 255)
    love.graphics.rectangle('fill', 63, 3, self.player.maxHealth, 8)
    love.graphics.setColor(255, 255, 255, 255)

    if self.player.hasLollipop then
        love.graphics.setColor(math.random(1, 255)/255, math.random(1, 255)/255, math.random(1, 255)/255, 255)
    elseif self.player.health < 20 then
        love.graphics.setColor(255, 0, 0, 255)
    end 
    love.graphics.rectangle('fill', 64, 4, self.player.health, 6)
    love.graphics.setColor(255, 255, 255, 255)
    
    
    
    local playerY = self.player.y + self.player.height

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

    for k, mom in pairs(self.moms) do
        local momY = mom.y + mom.height
        if  momY < playerY then
            mom:render()
        end
    end
    
    
    -- draw player
    self.player.stateMachine:render()

    for k, item in pairs(self.player.items) do
        item:render()
    end

   
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

    for k, mom in pairs(self.moms) do
        if mom.y + mom.height > self.player.y + self.player.height then
            mom:render()
        end

    end
end


function PlayState:spawnMoms()
    Timer.every(2, function ()
        if math.random(6) == 1 then
            local mom = Entity {
                type = 'mom',
                entity_def = ENTITY_DEFS['mom'],
                x = VIRTUAL_WIDTH,
                y = math.random(VIRTUAL_HEIGHT / 3, VIRTUAL_HEIGHT / 2 + 8)
            }
            mom:changeAnimation('walk-left')
            table.insert(self.moms, mom)
        end
    end)
end


function PlayState:spawnBabies()
    Timer.every(1, function ()
        -- every second, 1 in 3 odds to spawn baby
        if math.random(3) == 1 then
            -- make baby
            local baby = Entity {
                type = 'baby',
                entity_def = ENTITY_DEFS['baby'],
                x = VIRTUAL_WIDTH - 10,
                y = math.random(VIRTUAL_HEIGHT - 32, VIRTUAL_HEIGHT / 2+ 16),
            }
            baby:changeAnimation('crawl-left')

            -- table for items baby is holding
            baby.items = {}
            -- 1 in 3 three chance baby gets a balloon
            if math.random(3) == 1 then
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
