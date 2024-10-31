PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    if params.player then  -- player already exists (level 2+)
        getPreExistingPlayer(self, params) 
    else 
        createNewPlayer(self) 
    end
    
    self.player.levelEnded = false   -- this restarts the play timer

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
    
    playWalkToStartAnimation(self)  -- this animation walks player onto scene

    -- table for spawned moms
    self.moms = {}

    -- table for spawned babies
    self.babies = {}
    self:spawnBabies()

    self.entitiesBehindPlayer = {}
    self.entitiesOverPlayer = {}

    -- to prevent strangeness when scrolling and are in transition to floating state
    self.isScrollingBack = false
end


function getPreExistingPlayer(self, params)
    self.player = params.player 
    self.player.playState = self
    gSounds['game-music-' .. tostring(self.player.level)]:stop()
    self.player:LevelUp()
end


function createNewPlayer(self)
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


function playWalkToStartAnimation(self)
    self.player.stateMachine:change('idle')
    self.player:changeAnimation('walk-' .. self.player.direction)
    gSounds['walking']:play()

    Timer.tween(1, {
        [self.player] = {x = 16}
    })
    :finish(function() 
        -- change to idlestate and start music
        self.player.stateMachine:change('idle')
        gSounds['game-music-' .. tostring(self.player.level)]:play()
    end)
end


function PlayState:spawnBabies()  -- 50/50 chance every second
    Timer.every(1, function ()
        if not self.player.isFloating then
            if math.random(2) == 1 then
                spawnBaby(self)
            end
        elseif self.player.isFloating then -- (storks if floating!)
            if math.random(2) == 1 then
                spawnStork(self)
            end
        end
    end)
end


function spawnBaby(self)
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


function spawnStork(self)
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


function PlayState:update(dt)
    -- if no health, game over
    checkForGameOver(self)

    self.player.stateMachine:update(dt)
    
    updateEntities(self.babies, dt)
    updatePlayerItems(self.player.items)
    updateEntities(self.moms, dt)

    -- sort moms relative to player, behind or in front (y-axis)
    for k, mom in pairs(self.moms) do
        local momY = mom.y + mom.height
        sortOnYAxis(mom, momY, self)
    end

    -- sort y axis relative to player
    for k, baby in pairs(self.babies) do
        local babyY = baby.hitBox.y + baby.hitBox.height
        sortOnYAxis(baby, babyY, self)
    end
end


function checkForGameOver(self)
    if self.player.health <= 0 then
        self.player.levelEnded = true
        gSounds['walking']:stop()
        gStateMachine:change('game-over', {
            gameStats = self.player.scoreDetails,
            level = self.player.level
        })
    end
end


function updateEntities(entities, dt)
    for k, entity in pairs(entities) do
        -- if the entity is still on screen
        if not entity.dead then
            entity:update(dt)
        else
            table.remove(entities, k)
        end
    end
end


function updatePlayerItems(items)
    for k, item in pairs(items['balloons']) do
        item:update(dt)
    end
    for k, item in pairs(items['lollipops']) do
        item:update(dt)
    end
end


function sortOnYAxis(entity, entityYAxis, self)
    if  entityYAxis < self.player.footHitBox.y + self.player.footHitBox.height / 2 then 
        table.insert(self.entitiesBehindPlayer, entity)
    else 
        table.insert(self.entitiesOverPlayer, entity)
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

    -- draw player and their items
    renderItems(self.player.items['balloons']) -- drawn behind player
    self.player.stateMachine:render() 
    renderItems(self.player.items['lollipops']) -- drawn in front of player

    -- render each baby and each mom in front of player
    if #self.entitiesOverPlayer > 0 then
        self:renderByYValue(self.entitiesOverPlayer)
    end
end


function renderItems(items)
    for k, item in pairs(items) do
        item:render()
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
    
    -- render entity with it's items
    renderEntityWithItems(currEntity)

    -- remove this entity from table 
    table.remove(entities, lowestIndex)
    -- and recursively render all entities in order :)
    if #entities > 0 then
        self:renderByYValue(entities)
    end
end


function renderEntityWithItems(currEntity)
    if currEntity.type == 'baby' or 'stork' then -- babies carry items behind themselves
        renderItems(currEntity.items)
    end

    currEntity:render() -- entity itself
    
    if currEntity.type == 'mom' then -- moms carry items in front of them 
        renderItems(currEntity.items)
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
