PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    -- player from previous level 
    if params.player then
        self.player = params.player 
        self.player.playState = self
        gSounds['game-music-' .. tostring(self.player.level)]:stop()
        self.player:LevelUp()
    else 
        -- otherwise begin new player (level 1)
        self.player = Player {
            type = 'player',
            playState = self,
            entity_def = ENTITY_DEFS[1]['player'],
            x = - 16,
            y = VIRTUAL_HEIGHT - 70,
            direction = 'right',
            level = 1
        }
    end

    -- this restarts the play timer
    self.player.levelEnded = false

    self.level = self.player.level

    -- game music settings
    gSounds['game-music-' .. tostring(self.player.level)]:setLooping(true)
    gSounds['game-music-' .. tostring(self.player.level)]:setVolume(.7)

    self.background = 1 -- can be changed for extra backgrounds
    self.backgroundScrollX = 0
    self.backgroundScrollY = 0
        
    -- player's state machine
    self.player.stateMachine = StateMachine{
        ['idle'] = function () return PlayerIdleState(self) end,
        ['walk-state'] = function () return PlayerWalkState(self) end,
        ['float-state'] = function () return PlayerFloatingState(self) end,
        ['fall-state'] = function () return PlayerFallState(self) end,
        ['board-ship'] = function () return PlayerBoardShipState(self) end
    }
    self.player.stateMachine:change('idle')

    -- this animation walks player onto scene
    self.player:changeAnimation('walk-' .. self.player.direction)
    gSounds['walking']:play()
    Timer.tween(1, {
        [self.player] = {x = 16}
    })
    -- stop player (Ready to Play!)
    :finish(function() 
        -- change to idlestate and start music
        self.player.stateMachine:change('idle')
        gSounds['game-music-' .. tostring(self.player.level)]:play()
    end)

    -- table for spawned moms
    self.moms = {}

    -- table for spawned babies
    self.babies = {}
    self:spawnBabies()

    self.entitiesBehindPlayer = {}
    self.entitiesOverPlayer = {}


    -- to prevent strangeness when scrolling  and are in transition to floating state
    self.isScrollingBack = false
end


function PlayState:spawnBabies()  --(or storks if floating!)
    Timer.every(1, function ()
        
        if not self.player.isFloating then
            -- every second, 1 in 2 odds to spawn baby
            if math.random(2) == 1 then
                -- make a baby
                local baby
                baby = Baby {
                    type = 'baby',
                    playState = self,
                    entity_def = ENTITY_DEFS[self.level]['baby'],
                    x = VIRTUAL_WIDTH - 10,
                    y = math.random(VIRTUAL_HEIGHT - 32, VIRTUAL_HEIGHT / 2+ 16),
                    direction = 'left',
                    level = self.level
                }
                table.insert(self.babies, baby)
                baby:changeAnimation('crawl-left')
            end

        -- if player is floating try to make a stork baby
        elseif self.player.isFloating then
            -- 1 in 2 chance
            if math.random(2) == 1 then
                local stork
                stork = Baby {
                    type = 'stork',
                    playState = self,
                    entity_def = ENTITY_DEFS[self.level]['stork'],
                    x = VIRTUAL_WIDTH,
                    y = math.random(0, VIRTUAL_HEIGHT - ENTITY_DEFS[self.level]['stork'].height),
                    direction = 'left',
                    level = self.level
                }
                table.insert(self.babies, stork)
                stork:changeAnimation('fly-left')
            end
        end
    end)
end


function PlayState:update(dt)
    -- if no health, game over
    if self.player.health <= 0 then
        self.player.levelEnded = true
        gSounds['walking']:stop()
        gStateMachine:change('game-over', {
            gameStats = self.player.scoreDetails,
            level = self.player.level
        })
    end

    -- update player state machine
    self.player.stateMachine:update(dt)
    
    -- update babies
    for k, baby in pairs(self.babies) do
        -- if the baby is still on screen
        if not baby.dead then
            baby:update(dt)
        else
            table.remove(self.babies, k)
        end
    end
    
    -- update player's items
    for k, item in pairs(self.player.items['balloons']) do
        item:update(dt)
    end
    for k, item in pairs(self.player.items['lollipops']) do
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


    -- sort moms relative to player, behind or in front (y-axis)
    for k, mom in pairs(self.moms) do
        local momY = mom.y + mom.height
        if  momY < self.player.footHitBox.y + self.player.footHitBox.height / 2 then 
            table.insert(self.entitiesBehindPlayer, mom)
        else 
            table.insert(self.entitiesOverPlayer, mom)
        end
    end

    -- sort y axis relative to player
    for k, baby in pairs(self.babies) do
        local babyY = baby.hitBox.y + baby.hitBox.height
        if  babyY < self.player.footHitBox.y + self.player.footHitBox.height / 2 then 
            table.insert(self.entitiesBehindPlayer, baby)
        else
             table.insert(self.entitiesOverPlayer, baby)
        end
    end
end


function PlayState:render() 
    -- draw background
    self:renderBackground()
    -- draw health bar
    self:renderHealthBar()

    -- render each baby and each mom behind player
    if #self.entitiesBehindPlayer > 0 then
        self:renderByYValue(self.entitiesBehindPlayer)
    end

    -- draw player's balloons behind player
    for k, item in pairs(self.player.items['balloons']) do
        item:render()
    end 

    -- draw player
    self.player.stateMachine:render()

    -- draw player's lollipops in front of player
    for k, item in pairs(self.player.items['lollipops']) do
        item:render()
    end

    -- render each baby and each mom in front of player
    if #self.entitiesOverPlayer > 0 then
        self:renderByYValue(self.entitiesOverPlayer)
    end
end


function PlayState:renderByYValue(entities)
    local lowestYValue = VIRTUAL_HEIGHT
    local currEntity = entities[1]
    local lowestIndex = 1

    for k, entity in pairs(entities) do
        if entity.y + entity.height <= lowestYValue then
            lowestYValue = entity.y + entity.height
            currEntity = entity
            lowestIndex = k
        end
    end
    
    -- babies carry items behind themselves
    if currEntity.type == 'baby' or 'stork' then
        for k, item in pairs(currEntity.items) do
            item:render()
        end
    end
    
    currEntity:render()
    
    -- moms carry items in front of them (plane moms don't have items)
    if currEntity.type == 'mom' then
        for k, item in pairs(currEntity.items) do
            item:render()
        end
    end

    -- remove this entity from table 
    table.remove(entities, lowestIndex)
    -- and recursively render all entities in order :)
    if #entities > 0 then
        self:renderByYValue(entities)
    end
end

function PlayState:renderBackground()
    -- this is the normal centered scrollable background
    love.graphics.draw(gTextures[self.level]['background'], gFrames[self.level]['background'][self.background], 
        math.floor(-self.backgroundScrollX), 
        math.floor(-self.backgroundScrollY) - 144)

    -- this allows background to left and right to appear
    love.graphics.draw(gTextures[self.level]['background'], gFrames[self.level]['background'][self.background], 
        math.floor(-self.backgroundScrollX + BACKGROUND_X_LOOP_POINT), 
        math.floor(-self.backgroundScrollY) - 144)

    -- this allows background below to appear while floating or falling
    love.graphics.draw(gTextures[self.level]['background'], gFrames[self.level]['background'][self.background], 
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
        love.graphics.setColor(math.random(255)/255, math.random(255)/255, math.random(255)/255, 255)
    elseif self.player.health < 20 then
        -- make bar red if low health
        love.graphics.setColor(1, 0, 0, 1)
    end 

    -- draw health bar
    love.graphics.rectangle('fill', 64, 4, self.player.health, 6)
    love.graphics.setColor(255, 255, 255, 255)
end
