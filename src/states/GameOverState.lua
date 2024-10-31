GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
    self.level = params.level
    self.gameStats = params.gameStats

    -- for showing whole game stats
    self.gameStatTotals = {
        ['Candies Stolen'] = 0,
        ['Balloons Stolen'] = 0,
        ['Damage Taken'] =  0,
        ['Time'] =  0
    }

    compileGameStats(self)      
end


function GameOverState:update()
    -- restart game
    if wasEnterPressed() then
        gSounds['game-music-' .. tostring(self.level)]:stop()
        gStateMachine:change('start')
    end
end

function GameOverState:render()
    love.graphics.setColor(0, 170/255, 255/255, 1)
    love.graphics.setFont(gFonts['title'])
    love.graphics.printf("GAME OVER!", 0, 10, VIRTUAL_WIDTH, 'center')

    -- Player level stats, small letters
    renderGameStats(self.gameStatTotals)

    love.graphics.setColor(1,1,1,1)
end


