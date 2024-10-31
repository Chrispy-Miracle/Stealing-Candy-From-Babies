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
    if anyDirectionPressed() then
        self.player.stateMachine:change('walk-state')
    end

    self.player:update(dt)
end


function PlayerIdleState:render()
    self.player:render()
end