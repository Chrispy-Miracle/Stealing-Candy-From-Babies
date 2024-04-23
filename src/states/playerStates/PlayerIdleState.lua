PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(player)
    self.player = player

    self.player:changeAnimation('idle')
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('right') then
        self.player.stateMachine:change('walk-state')
    end

    self.player:update(dt)
end

function PlayerIdleState:render()
    self.player:render()
end