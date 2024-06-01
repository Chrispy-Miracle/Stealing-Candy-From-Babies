PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(player)
    self.player = player

    -- stop walk sound and set animation to idle
    gSounds['walking']:stop()
    self.player:changeAnimation('idle-' .. self.player.direction)
end

function PlayerIdleState:update(dt)
    --change to floating state
    if self.player.balloonsCarried > 3 then
        self.player.stateMachine:change('float-state')
    end
    
    -- change to walk state if arrow buttons pushed
    if is_joystick then
        if joystick:getAxis(SNES_MAP.xDir) == -1
        or joystick:getAxis(SNES_MAP.xDir) == 1
        or joystick:getAxis(SNES_MAP.yDir) == -1
        or joystick:getAxis(SNES_MAP.yDir) == 1 then
            self.player.stateMachine:change('walk-state')
        end
    elseif love.keyboard.isDown('right') or love.keyboard.isDown('left') 
    or love.keyboard.isDown('up') or love.keyboard.isDown('down')
    or love.keyboard.isDown('d') or love.keyboard.isDown('a') 
    or love.keyboard.isDown('w') or love.keyboard.isDown('s') then 
        self.player.stateMachine:change('walk-state')
    end



    self.player:update(dt)
end

function PlayerIdleState:render()
    self.player:render()
end