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
    if love.keyboard.isDown('right') or love.keyboard.isDown('d') or is_joystick and joystick:getAxis(SNES_MAP.xDir) == 1 then            
        self.player.direction = 'right'
        self.player:changeAnimation('walk-' .. self.player.direction)

        -- if player is at right edge of screen scroll all things back to left
        if self.player.x > VIRTUAL_WIDTH - self.player.width * 2 then
            -- scroll player and background left
            Timer.tween(1.5, {
                [self.player] = {x = 16},
                [self.playState] = {backgroundScrollX = BACKGROUND_X_LOOP_POINT}
            })
            -- scroll babies left
            for k, entity in pairs(self.playState.babies) do
                Timer.tween(1.5, {
                    [entity] = {x = entity.x - BACKGROUND_X_LOOP_POINT + 16 + entity.walkSpeed * dt}
                })
            end 
            -- scroll moms left
            for k, entity in pairs(self.playState.moms) do
                Timer.tween(1.5, {
                    [entity] = {x = entity.x - BACKGROUND_X_LOOP_POINT + 16 + entity.walkSpeed * dt}
                })
            end
        else        
        
            --move player normally
            self.player.x = self.player.x + self.player.walkSpeed * dt
            -- scroll background accordingly
            self.playState.backgroundScrollX = (self.playState.backgroundScrollX + BACKGROUND_X_SCROLL_SPEED * dt) % BACKGROUND_X_LOOP_POINT
        end


    end

    if love.keyboard.isDown('left') or love.keyboard.isDown('a') or is_joystick and joystick:getAxis(SNES_MAP.xDir) == -1 then
        --move player
        self.player.direction = 'left'
        self.player:changeAnimation('walk-' .. self.player.direction)
        self.player.x = self.player.x - self.player.walkSpeed * dt

        -- scroll background accordingly
        self.playState.backgroundScrollX = (self.playState.backgroundScrollX - BACKGROUND_X_SCROLL_SPEED * dt) % BACKGROUND_X_LOOP_POINT

        -- if player hits left wall, do a bit of damage
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

    if love.keyboard.isDown('up') or love.keyboard.isDown('w') or is_joystick and joystick:getAxis(SNES_MAP.yDir) == -1 then
        --move player while confining y-axis movement
        if self.player.y > VIRTUAL_HEIGHT / 3 then
            self.player.y = self.player.y - (self.player.walkSpeed / 2) * dt
        end
    end

    if love.keyboard.isDown('down') or love.keyboard.isDown('s') or is_joystick and joystick:getAxis(SNES_MAP.yDir) == 1 then
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
    and not love.keyboard.isDown('up') and not love.keyboard.isDown('down') 
    and not love.keyboard.isDown('d') and not love.keyboard.isDown('a') 
    and not love.keyboard.isDown('w') and not love.keyboard.isDown('s') then
        if is_joystick and joystick:getAxis(SNES_MAP.xDir) == 0 
        and joystick:getAxis(SNES_MAP.yDir) == 0 
        or not is_joystick then
            gSounds['walking']:stop()
            self.player.stateMachine:change('idle')
        end
    end

    self.player:update(dt)
end


function PlayerWalkState:render()
    self.player:render()
end