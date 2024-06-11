PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(playstate)
    self.playState = playstate
    self.player = playstate.player

    -- stop walk sound and set animation to idle
    gSounds['walking']:stop()
    self.player:changeAnimation('idle-' .. self.player.direction)
end

function PlayerIdleState:update(dt)
    
    -- change to walk state if arrow buttons pushed
    if is_joystick and joystick:getAxis(SNES_MAP.xDir) == -1
    or is_joystick and joystick:getAxis(SNES_MAP.xDir) == 1
    or is_joystick and joystick:getAxis(SNES_MAP.yDir) == -1
    or is_joystick and joystick:getAxis(SNES_MAP.yDir) == 1 
    or love.keyboard.isDown('right') or love.keyboard.isDown('left') 
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