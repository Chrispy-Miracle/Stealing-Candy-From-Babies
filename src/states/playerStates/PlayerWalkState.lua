PlayerWalkState = Class{__includes = BaseState}

function PlayerWalkState:init(playState)
    self.playState = playState
    self.player = playState.player

    self.player.isFalling =  false
    self.player.isFloating = false
    self.playState.backgroundScrollY = 0

    -- start walking sound and animation
    gSounds['walking']:play()
    self.player:changeAnimation('walk-' .. self.player.direction)

end

function PlayerWalkState:update(dt)
    -- check each direction button, and update player position if pressed
    if love.keyboard.isDown('right') then
        --move player
        self.player.direction = 'right'
        self.player:changeAnimation('walk-' .. self.player.direction)
        self.player.x = self.player.x + self.player.walkSpeed * dt
        -- scroll background accordingly
        self.playState.backgroundScrollX = (self.playState.backgroundScrollX + BACKGROUND_X_SCROLL_SPEED * dt) % BACKGROUND_X_LOOP_POINT
        
    end

    if love.keyboard.isDown('left') then
        --move player
        self.player.direction = 'left'
        self.player:changeAnimation('walk-' .. self.player.direction)
        self.player.x = self.player.x - self.player.walkSpeed * dt

        -- scroll background accordingly
        self.playState.backgroundScrollX = (self.playState.backgroundScrollX - BACKGROUND_X_SCROLL_SPEED * dt) % BACKGROUND_X_LOOP_POINT

        if self.player.x < -self.player.width / 2 then
            gSounds['hit-wall']:play()
            self.player.health = self.player.health - 2
            self.player.scoreDetails[self.player.level]['Damage Taken'] = self.player.scoreDetails[self.player.level]['Damage Taken'] + 5
            -- move player back
            self.player.x = self.player.x + self.player.width / 2
            -- scroll background accordingly
            self.playState.backgroundScrollX = (self.playState.backgroundScrollX + BACKGROUND_X_SCROLL_SPEED * dt) % BACKGROUND_X_LOOP_POINT
            
        end

    end

    if love.keyboard.isDown('up') then
        --move player while confining y-axis movement
        if self.player.y > VIRTUAL_HEIGHT / 3 then
            self.player.y = self.player.y - (self.player.walkSpeed / 2) * dt
        end
    end

    if love.keyboard.isDown('down') then
        --move player while confining y-axis movement
        if self.player.y < VIRTUAL_HEIGHT / 2 + 8 then
            self.player.y = self.player.y + (self.player.walkSpeed / 2) * dt
        end
    end

    --change to floating state
    if self.player.balloonsCarried > 3 then
        self.player.stateMachine:change('float-state')
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