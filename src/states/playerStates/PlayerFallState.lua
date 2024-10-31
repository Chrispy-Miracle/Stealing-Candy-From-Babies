PlayerFallState = Class{__includes = BaseState}

-- when player was floating but then gets balloons popped and now has less than 4
function PlayerFallState:init(playState)
    self.playState = playState
    self.player = playState.player

    self.player.isFalling = true
    gSounds['falling']:play()

    self.player.gravity =  100 - self.player.balloonsCarried * 20
    self.playState.backgroundScrollX = 0

    -- if player is already near ground, crash them down
    if self.player.screensFloatedUp < 1 then
        self.player:crashDown()
    end
end


function PlayerFallState:update(dt)
    -- check for grabbed balloons
    if self.player.balloonsCarried > 3 then
        self.player.isFalling = false
        self.player.stateMachine:change('float-state')
    end

    -- check items for balloon pops 
    for k, item in pairs(self.player.items['balloons']) do
        -- check playState storks
        for j, stork in pairs(self.playState.babies) do 
            -- baby is a stork in this instance
            if stork.type == 'stork' then
                self.player:tryBalloonPop(stork.beakHitBox, item.hitBox, k)
            end
        end
    end

    -- player falls
    self.player.y = self.player.y + self.player.gravity * dt 

    -- player wraps to top of screen if falls below bottom 
    if self.player.y > VIRTUAL_HEIGHT then

        -- if player is nearing the ground, they crash down
        if self.player.screensFloatedUp < 1 then
            self.player.y = -self.player.height
            self.player:crashDown()
        else 
            -- wrap player back to top if fell past bottom of screen
            self.player.y = -self.player.height
            self.player.screensFloatedUp = self.player.screensFloatedUp - 1
        end
    end

    -- update player gravity and background Y scroll
    self.player.gravity = 100 - self.player.balloonsCarried * 20
    self.playState.backgroundScrollY = (self.player.gravity * dt + self.playState.backgroundScrollY) % BACKGROUND_Y_LOOP_POINT
    
    -- allow for movement (no up or down in fall state)
    -- fall right
    if wasRightPressed() then
        self.player.direction = 'right'
        self.player:changeAnimation('idle-' .. self.player.direction)
        self.player.x = self.player.x + self.player.walkSpeed * dt

        -- player to left side of screen if they float off right
        if self.player.x > VIRTUAL_WIDTH - 2 then
            self.player.x = -self.player.width - 2
        end
    end

    -- fall left
    if wasLeftPressed() then
        self.player.direction = 'left'
        self.player:changeAnimation('idle-' .. self.player.direction)
        self.player.x = self.player.x - self.player.walkSpeed * dt

        -- player to right side of screen if they float off left
        if self.player.x < -self.player.width - 2 then
            self.player.x = VIRTUAL_WIDTH - 2
        end
    end

    self.player:update(dt)
end


function PlayerFallState:render()
    self.player:render()
end



