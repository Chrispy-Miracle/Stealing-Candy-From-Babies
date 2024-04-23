PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.player = Entity {
        type = 'player',
        animations = ENTITY_DEFS['player'].animations,
        width = ENTITY_DEFS['player'].width,
        height = ENTITY_DEFS['player'].height,
        x = - 16,
        y = VIRTUAL_HEIGHT - 70
    }
    self.player:changeAnimation('walk-right')
    gSounds['walking']:play()
    Timer.tween(2, {
        [self.player] = {x = 32}
    })
    :finish(function() 
        self.player:changeAnimation('idle')
        gSounds['walking']:stop() 
    end)
end


function PlayState:update(dt)
    self.player:update(dt)
end

function PlayState:render()
    love.graphics.draw(gTextures['background'], gFrames['background'][1], 0, 0)
    
    self.player:render()
end
