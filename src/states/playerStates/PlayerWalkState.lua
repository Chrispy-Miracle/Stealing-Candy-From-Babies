PlayerWalkState = Class{__includes = BaseState}

function PlayerWalkState:init(player)
    self.player = player
    
    gSounds['walking']:play()
    self.player:changeAnimation('walk-right')

end

function PlayerWalkState:update(dt)
    self.player.x = self.player.x + PLAYER_WALK_SPEED * dt

    if not love.keyboard.isDown('right') then
        gSounds['walking']:stop()
        self.player.stateMachine:change('idle')
    end

    self.player:update(dt)

end

function PlayerWalkState:render()
    self.player:render()
end