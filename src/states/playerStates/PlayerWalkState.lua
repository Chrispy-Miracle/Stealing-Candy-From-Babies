PlayerWalkState = Class{__includes = BaseState}

function PlayerWalkState:init(player)
    self.player = player
    
    gSounds['walking']:play()
    self.player:changeAnimation('walk-' .. self.player.direction)

end

function PlayerWalkState:update(dt)
    if love.keyboard.isDown('right') then
        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
    end
    
    if love.keyboard.isDown('left') then
        self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
    end
    
    if love.keyboard.isDown('up') then
        if self.player.y > VIRTUAL_HEIGHT / 3 then
            self.player.y = self.player.y - (PLAYER_WALK_SPEED / 2) * dt
        end
    end
    
    if love.keyboard.isDown('down') then
        if self.player.y < VIRTUAL_HEIGHT / 2 + 8 then
        self.player.y = self.player.y + (PLAYER_WALK_SPEED / 2) * dt
        end
    end

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