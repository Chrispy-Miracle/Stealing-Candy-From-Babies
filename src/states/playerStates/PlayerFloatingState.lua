PlayerFloatingState = Class{__includes = BaseState}

function PlayerFloatingState:init(playState)
    self.playState = playState
    self.player = playState.player

    self.player.isFloating = true
    self.player:changeAnimation('idle')
    gSounds['walking']:stop()
    
    self.playState.backgroundScrollX = 0

    Timer.after(2.4, function () self.playState.background = 2 end)

    -- self.storks = {}
    -- self.storksSpawned = false

    -- if not self.storksSpawned then
    --    self:spawnStorks()
    --    self.storksSpawned = true
    -- end
end

-- This is called once and makes "the slow storks"
-- function PlayerFloatingState:spawnStorks()
--     Timer.every(2, function ()
--         if math.random(3) == 1 then
--             local stork = Entity {
--                 type = 'stork',
--                 entity_def = ENTITY_DEFS['stork'],
--                 x = VIRTUAL_WIDTH,
--                 y = math.random(0, VIRTUAL_HEIGHT - ENTITY_DEFS['stork'].height)
--             }
--             stork:changeAnimation('fly')
--             table.insert(self.storks, stork)
--         end
--     end)
-- end


function PlayerFloatingState:update(dt)
    -- change to falling state TODO !
                
    -- or the item is a balloon and it got popped by a stork
    for k, item in pairs(self.player.items) do 
        if item.type == 'balloon' then
            for j, stork in pairs(self.playState.babies) do 
                -- baby is a stork in this instance
                if stork.type == 'stork' and 
                    stork.x < item.x + item.width + 10 and stork.x > item.x + item.width - 10 and
                    stork.y < item.y + 30 and stork.y > item.y then
                        
                    table.remove(self.player.items, k)
                    gSounds['hit']:play()
                    self.player.balloonsCarried = self.player.balloonsCarried - 1
                    -- self.playState.backgroundScrollY = (-self.playState.backgroundScrollY + self.player.gravity * dt) % BACKGROUND_Y_LOOP_POINT
                    -- self.playState.backgroundScrollX = 0
                end
            end
        end
    end


    if self.player.balloonsCarried <= 3 then
        self.player.stateMachine:change('fall-state')
    else

        self.scrollGravity = self.playState.player.balloonsCarried * 10
        self.playState.backgroundScrollY = (self.playState.backgroundScrollY - self.scrollGravity * dt) % BACKGROUND_Y_LOOP_POINT

        self.player.gravity = self.player.balloonsCarried * 10

        if self.player.y > -self.player.height then
            self.player.y = self.player.y - self.player.gravity * dt
        else 
            self.player.y = VIRTUAL_HEIGHT
            self.player.gravity = 0
        end

    end

    -- update non-baby storks (and potentially pop balloons)
    -- for k, stork in pairs(self.storks) do
        
    --     -- update storks (the slow ones)
    --     if stork.x > -stork.width then
    --         stork.x = stork.x - stork.walkSpeed * dt
    --         stork:update(dt)

    --         -- check for stork beaks hitting balloons
    --         for k, item in pairs(self.player.items) do
    --             if item.type == 'balloon' then
    --                 if stork.x < item.x + item.width + 10 and 
    --                     stork.x > item.x + item.width - 10 and
    --                     stork.y < item.y + 30 and stork.y > item.y then
    --                     table.remove(self.player.items, k)
    --                     gSounds['hit']:play()
    --                     self.player.balloonsCarried = self.player.balloonsCarried - 1
    --                     self.playState.backgroundScrollY = (self.playState.backgroundScrollY + self.player.gravity * dt) % BACKGROUND_Y_LOOP_POINT
    --                     self.playState.backgroundScrollX = 0
    --                 end
    --             end
    --         end            
    --     else
    --         table.remove(self.storks, k)
    --     end


    -- end

    -- allow for movement
    if love.keyboard.isDown('right') then
        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
    end

    if love.keyboard.isDown('left') then
        self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
    end

    if love.keyboard.isDown('up') then
        self.player.y = self.player.y - (PLAYER_WALK_SPEED / 2) * dt
    end

    if love.keyboard.isDown('down') then
        self.player.y = self.player.y + (PLAYER_WALK_SPEED / 2) * dt
    end

    self.player:update(dt)
    
end


function PlayerFloatingState:render()
    self.player:render()

    -- storks
    -- for k, stork in pairs(self.storks) do
    --     stork:render()
    -- end
end
