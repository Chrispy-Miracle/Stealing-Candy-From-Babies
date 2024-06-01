PlayerFloatingState = Class{__includes = BaseState}

function PlayerFloatingState:init(playState)
    self.playState = playState
    self.player = playState.player

    self.player.isFloating = true
    self.player:changeAnimation('idle-' .. self.player.direction)
    gSounds['walking']:stop()
    gSounds['fly-away']:play()
    
    self.playState.backgroundScrollX = 0

    -- make onground moms and babies go away with the ground
    for k, baby in pairs(self.playState.babies) do
        Timer.tween(2, {
            [baby] = {y = VIRTUAL_HEIGHT}
        })
    end

    for k, mom in pairs(self.playState.moms) do
        Timer.tween(2, {
            [mom] = {y = VIRTUAL_HEIGHT}
        })
    end

    -- change background to sky after you cant see the ground
    Timer.after(2.4, function () self.playState.background = 2 end)
end


function PlayerFloatingState:update(dt)
    if self.player.screensFloatedUp == 6 then
        self.player.stateMachine:change('board-ship')
    end

    -- set player gravity and background scoll according to number of balloons
    self.player.gravity = self.player.balloonsCarried * 10
    self.playState.backgroundScrollY = (self.playState.backgroundScrollY - self.player.gravity * dt) % BACKGROUND_Y_LOOP_POINT

    -- if player on screen,they float up
    if self.player.y > -self.player.height then
        self.player.y = self.player.y - self.player.gravity * dt
    else 
        -- wrap player back to bottom of sceen if they floated off
        self.player.y = VIRTUAL_HEIGHT
        self.player.gravity = 0
        --increase # of screens floated up
        self.player.screensFloatedUp = self.player.screensFloatedUp + 1
    end


    -- check items for balloon pops 
    for k, item in pairs(self.player.items['balloons']) do 
        -- check playState storks
        for j, stork in pairs(self.playState.babies) do 
            -- baby is a stork in this instance
            if stork.type == 'stork' then
                self.player:tryBalloonPop(stork, item, k)
            end
        end
    end

    -- change to falling state if not enough balloons to float
    if self.player.balloonsCarried <= 3 then
        self.player.stateMachine:change('fall-state')
    end

    -- allow for movement
    if love.keyboard.isDown('right') or love.keyboard.isDown('d') or is_joystick and joystick:getAxis(SNES_MAP.xDir) ==  1 then
        self.player.direction = 'right'
        self.player:changeAnimation('idle-' .. self.player.direction)
        self.player.x = self.player.x + self.player.walkSpeed * dt

        -- player to left side of screen if they float off right
        if self.player.x > VIRTUAL_WIDTH - 2 then
            self.player.x = -self.player.width - 2
        end
    end

    if love.keyboard.isDown('left') or love.keyboard.isDown('a') or is_joystick and joystick:getAxis(SNES_MAP.xDir) == -1 then
        self.player.direction = 'left'
        self.player:changeAnimation('idle-' .. self.player.direction)
        self.player.x = self.player.x - self.player.walkSpeed * dt

        -- player to right side of screen if they float off left
        if self.player.x < -self.player.width - 2 then
            self.player.x = VIRTUAL_WIDTH - 2
        end
    end

    if love.keyboard.isDown('up') or love.keyboard.isDown('w') or is_joystick and joystick:getAxis(SNES_MAP.yDir) == -1 then
        self.player.y = self.player.y - (self.player.walkSpeed / 2) * dt
    end

    if love.keyboard.isDown('down') or love.keyboard.isDown('s') or is_joystick and joystick:getAxis(SNES_MAP.yDir) == 1 then
        self.player.y = self.player.y + (self.player.walkSpeed / 2) * dt
    end

    -- update player
    self.player:update(dt)  
end


function PlayerFloatingState:render()
    self.player:render()
end
