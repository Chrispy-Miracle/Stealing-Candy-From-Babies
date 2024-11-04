PlayerFallState = Class{__includes = BaseState}

-- when player was floating but then gets balloons popped and now has less than 4
function PlayerFallState:init(playState)
    self.playState = playState
    self.player = playState.player
    self.player.isFalling = true
    self.player.gravity =  100 - self.player.balloonsCarried * 20
    self.playState.backgroundScrollX = 0
    gSounds['falling']:play()
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
    self.player:checkForBalloonPops()
    self:handlePlayerFalling(dt)

    -- allow for horizontal movement (no up or down in fall state)
    if wasRightPressed() then -- fall right
        self:movePlayerHorizontal("right", dt)
    end
    if wasLeftPressed() then -- fall left
        self:movePlayerHorizontal("left", dt)
    end
    self.player:update(dt)
end

function PlayerFallState:render()
    self.player:render()
end


function PlayerFallState:handlePlayerFalling(dt)
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
end

function PlayerFallState:movePlayerHorizontal(direction, dt)
    self.player.direction = direction
    self.player:changeAnimation('idle-' .. direction)
    if direction =="right" then
        self.player.x = self.player.x + self.player.walkSpeed * dt
        -- player to left side of screen if they float off right
        if self.player.x > VIRTUAL_WIDTH - 2 then
            self.player.x = -self.player.width - 2
        end        
    elseif direction == 'left' then
        self.player.x = self.player.x - self.player.walkSpeed * dt
        -- player to right side of screen if they float off left
        if self.player.x < -self.player.width - 2 then
            self.player.x = VIRTUAL_WIDTH - 2
        end
    end
end

