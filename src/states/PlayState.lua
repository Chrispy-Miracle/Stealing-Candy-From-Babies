PlayState = Class{__includes = BaseState}

function PlayState:init()
    -- player
    self.player = Entity {
        type = 'player',
        animations = ENTITY_DEFS['player'].animations,
        width = ENTITY_DEFS['player'].width,
        height = ENTITY_DEFS['player'].height,
        x = - 16,
        y = VIRTUAL_HEIGHT - 70
    }
    
    -- player's state machine
    self.player.stateMachine = StateMachine{
        ['idle'] = function () return PlayerIdleState(self.player) end,
        ['walk-state'] = function () return PlayerWalkState(self.player) end
    }
    self.player.stateMachine:change('idle')

    -- walk player onto scene
    self.player:changeAnimation('walk-right')
    gSounds['walking']:play()
    Timer.tween(2, {
        [self.player] = {x = 16}
    })
    -- stop player
    :finish(function() 
        self.player.stateMachine:change('idle')
    end)




end


function PlayState:update(dt)
    if love.keyboard.wasPressed('right') then
        self.player.stateMachine:change('walk-state')
    end

    self.player:update(dt)
    self.player.stateMachine:update(dt)
end

function PlayState:render()
    love.graphics.draw(gTextures['background'], gFrames['background'][1], 0, 0)
    
    self.player.stateMachine:render()
end
