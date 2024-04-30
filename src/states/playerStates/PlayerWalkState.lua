PlayerWalkState = Class{__includes = BaseState}

function PlayerWalkState:init(playState)
    self.playState = playState
    self.player = playState.player
    
    -- start walking sound and animation
    self.player.isWalking = true
    if not self.player.isFloating then
        gSounds['walking']:play()
        self.player:changeAnimation('walk-' .. self.player.direction)
    end

end

function PlayerWalkState:update(dt)
    -- check each direction button, and update player position if pressed
    if love.keyboard.isDown('right') then
        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
        if not self.player.isFloating then
            self.playState.backgroundScrollX = (self.playState.backgroundScrollX + BACKGROUND_X_SCROLL_SPEED * dt) % BACKGROUND_X_LOOP_POINT
            self.playState.backgroundScrollY = 0
        end
    end

    if love.keyboard.isDown('left') then
        self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
        if not self.player.isFloating then
            self.playState.backgroundScrollX = (self.playState.backgroundScrollX - BACKGROUND_X_SCROLL_SPEED * dt) % BACKGROUND_X_LOOP_POINT
            self.playState.backgroundScrollY = 0
        end
    end

    if love.keyboard.isDown('up') then
        -- confine y-axis movement
        if self.player.y > VIRTUAL_HEIGHT / 3 then
            self.player.y = self.player.y - (PLAYER_WALK_SPEED / 2) * dt
        end
    end

    if love.keyboard.isDown('down') then
        -- confine y-axis movement
        if self.player.y < VIRTUAL_HEIGHT / 2 + 8 then
        self.player.y = self.player.y + (PLAYER_WALK_SPEED / 2) * dt
        end
    end

    -- return to idle state if no direction buttons pushed
    if not love.keyboard.isDown('right') and not love.keyboard.isDown('left') 
        and not love.keyboard.isDown('up') and not love.keyboard.isDown('down') then

        gSounds['walking']:stop()
        self.player.stateMachine:change('idle')
    end

    self.player:update(dt)


end

function PlayerWalkState:render()
    self.player:render()
end