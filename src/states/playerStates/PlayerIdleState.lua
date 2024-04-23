PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(player)
    self.player = player

    gSounds['walking']:stop()
    self.player:changeAnimation('idle')
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('right') or love.keyboard.isDown('left') 
        or love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.player.stateMachine:change('walk-state')
    end

    self.player:update(dt)
end

function PlayerIdleState:render()
    self.player:render()
end