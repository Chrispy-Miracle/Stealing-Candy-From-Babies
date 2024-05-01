PlayerFloatingState = Class{__includes = BaseState}

function PlayerFloatingState:init(playState)
    self.playState = playState
    self.player = playState.player

    self.player:changeAnimation('idle')
    gSounds['walking']:stop()
    
    self.playState.backgroundScrollX = 0

    Timer.after(2.4, function () self.playState.background = 2 end)

    if not self.playState.storksSpawned then
       self.playState:spawnStorks()
       self.playState.storksSpawned = true
    end
end


function PlayerFloatingState:update(dt)
    self.scrollGravity = self.playState.player.balloonsCarried * 10
    self.playState.backgroundScrollY = (self.playState.backgroundScrollY - self.scrollGravity * dt) % BACKGROUND_Y_LOOP_POINT

    self.player.gravity = self.player.balloonsCarried * 10

    if self.player.y > -self.player.height then
        self.player.y = self.player.y - self.player.gravity * dt
    else 
        self.player.y = VIRTUAL_HEIGHT
        self.player.gravity = 0
    end

    -- check for stork beaks hitting balloons
    for k, stork in pairs(self.playState.storks) do
        -- check each balloon
        for k, item in pairs(self.player.items) do
            if item.type == 'balloon' then
                if stork.x < item.x + item.width + 10 and 
                    stork.x > item.x + item.width - 10 and
                    stork.y < item.y + 30 and stork.y > item.y then
                    table.remove(self.player.items, k)
                    gSounds['hit']:play()
                    self.player.balloonsCarried = self.player.balloonsCarried - 1
                    self.playState.backgroundScrollY = (self.playState.backgroundScrollY + self.player.gravity * dt) % BACKGROUND_Y_LOOP_POINT
                    self.playState.backgroundScrollX = 0
                end
            end
        end
    end

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
end
