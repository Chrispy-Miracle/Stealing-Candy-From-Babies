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
    for l, levelStats in pairs(self.gameStats) do 
        for k, gameStat in pairs(levelStats) do
            self.gameStatTotals[k] = self.gameStatTotals[k] + gameStat
        end
    end
 
    -- delay input to not miss end screen
    self.canQuit = false
    Timer.after(3, function () self.canQuit = true end)
end

function WonGameState:update()
    -- quit game
    if self.canQuit then
        if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') or is_joystick and joystick:isDown({SNES_MAP.start}) then
            love.event.quit()
        end
    end
end

function WonGameState:render()
    -- "you win" 
    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(0, 170/255, 255/255, 1)
    love.graphics.printf("You Win!!!", 0, 10, VIRTUAL_WIDTH, 'center')

    -- Player level stats, small letters
    love.graphics.setFont(gFonts['small'])
    local keyNum = 1
    for k, item in pairs(self.gameStatTotals) do 
        love.graphics.printf(tostring(k) .. ':  ' .. tostring(item), 0, VIRTUAL_HEIGHT / 4 + keyNum * 15, VIRTUAL_WIDTH, 'center')
        keyNum = keyNum + 1
    end

    love.graphics.setColor(1,1,1,1)
   
end