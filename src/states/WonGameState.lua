WonGameState = Class{__includes = BaseState}

function WonGameState:enter(params)
    self.level = params.level
    self.gameStats = params.gameStats

    -- for displaying whole game stats
    self.gameStatTotals = {
        ['Candies Stolen'] = 0,
        ['Balloons Stolen'] = 0,
        ['Damage Taken'] =  0,
        ['Time'] =  0
    }
    --compile whole game stats from level stats
    compileGameStats(self)
 
    -- delay input to not miss end screen
    self.canQuit = false
    Timer.after(3, function () self.canQuit = true end)
end

function WonGameState:update()
    -- quit game
    if self.canQuit then
        if wasEnterPressed() then
            love.event.quit()
        end
    end
end

function WonGameState:render()
    -- "you win" 
    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(0, 170/255, 255/255, 1)
    love.graphics.printf("You Win!!!", 0, 10, VIRTUAL_WIDTH, 'center')

    -- Player level stats
    renderGameStats(self.gameStatTotals)

    love.graphics.setColor(1,1,1,1)
   
end