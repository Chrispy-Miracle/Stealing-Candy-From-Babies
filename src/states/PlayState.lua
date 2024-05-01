PlayState = Class{__includes = BaseState}

function PlayState:init()
    --background
    self.background = 1 -- can be changed for extra backgrounds
    self.backgroundScrollX = 0
    self.backgroundScrollY = 0

    -- player
    self.player = Player {
        type = 'player',
        playState = self,
        entity_def = ENTITY_DEFS['player'],
        x = - 16,
        y = VIRTUAL_HEIGHT - 70,
        direction = 'right',
    }
    
    -- player's state machine
    self.player.stateMachine = StateMachine{
        ['idle'] = function () return PlayerIdleState(self.player) end,
        ['walk-state'] = function () return PlayerWalkState(self) end,
        ['float-state'] = function () return PlayerFloatingState(self) end,
        ['fall-state'] = function () return PlayerFallState(self) end
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

    -- table for spawned moms
    self.moms = {}

    -- table for spawned babies
    self.babies = {}
    self:spawnBabies()
end


function PlayState:spawnBabies()  --(or storks!)
    Timer.every(1, function ()
        local baby
        if not self.player.isFloating then
            -- every second, 1 in 3 odds to spawn baby
            if math.random(3) == 1 then
                -- make baby
                baby = Baby {
                    type = 'baby',
                    playState = self,
                    entity_def = ENTITY_DEFS['baby'],
                    x = VIRTUAL_WIDTH - 10,
                    y = math.random(VIRTUAL_HEIGHT - 32, VIRTUAL_HEIGHT / 2+ 16),
                }
                baby:changeAnimation('crawl-left')
            end

        -- if player is floating try to make a stork 
        elseif self.player.isFloating then
            -- 1 in 3 chance
            if math.random(3) == 1 then
                baby = Baby {
                    type = 'stork',
                    playState = self,
                    entity_def = ENTITY_DEFS['stork'],
                    x = VIRTUAL_WIDTH,
                    y = math.random(0, VIRTUAL_HEIGHT - ENTITY_DEFS['stork'].height)
                }
                baby:changeAnimation('fly')
            end
        end
        table.insert(self.babies, baby)
    end)
end


function PlayState:update(dt)
    -- if no health, game over
    if self.player.health <= 0 then
        gStateMachine:change('game-over')
    end

    -- update player state machine
    self.player.stateMachine:update(dt)
    
    -- update babies
    for k, baby in pairs(self.babies) do
        if not baby.dead then
            baby:update(dt)
        else 
            table.remove(self.babies, k)
        end
    end
    
    -- update player's items
    for k, item in pairs(self.player.items) do
        item:update(dt)
    end

    -- update moms
    for k, mom in pairs(self.moms) do
        if not mom.dead then
            mom:update(dt)
        else
            table.remove(self.moms, k)
        end
    end
end


function PlayState:render() 
    -- draw background
    self:renderBackground()
    -- draw health bar
    self:renderHealthBar()
    
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

    -- moms  (All moms now drawn in front of player)
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
end


function PlayState:renderBackground()
    love.graphics.draw(gTextures['background'], gFrames['background'][self.background], 
        math.floor(-self.backgroundScrollX), 
        math.floor(-self.backgroundScrollY) - 144)

    love.graphics.draw(gTextures['background'], gFrames['background'][self.background], 
        math.floor(-self.backgroundScrollX + BACKGROUND_X_LOOP_POINT), 
        math.floor(-self.backgroundScrollY) - 144)

    love.graphics.draw(gTextures['background'], gFrames['background'][self.background], 
        math.floor(-self.backgroundScrollX), 
        math.floor(-self.backgroundScrollY + BACKGROUND_Y_LOOP_POINT) - 144)
end


function PlayState:renderHealthBar()
    -- draw health (sugar-rush) bar outline
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Sugar Rush: ', 4, 2)
    love.graphics.setColor(0,0,0, 255)
    love.graphics.rectangle('fill', 63, 3, self.player.maxHealth + 2, 8)
    love.graphics.setColor(255, 255, 255, 255)

    
    if self.player.hasLollipop then
        -- make bar flash if gaining health
        love.graphics.setColor(math.random(1, 255)/255, math.random(1, 255)/255, math.random(1, 255)/255, 255)
    elseif self.player.health < 20 then
        -- make bar red if low health
        love.graphics.setColor(255, 0, 0, 255)
    end 

    -- draw health bar
    love.graphics.rectangle('fill', 64, 4, self.player.health, 6)
    love.graphics.setColor(255, 255, 255, 255)
end
