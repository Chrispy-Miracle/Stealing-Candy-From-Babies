GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
    self.level = params.level
    self.gameStats = params.gameStats

    self.gameStatTotals = {
        ['Candies Stolen'] = 0,
        ['Balloons Stolen'] = 0,
        ['Damage Taken'] =  0,
        ['Time'] =  0
    }

    for l, levelStats in pairs(self.gameStats) do 
        for k, gameStat in pairs(levelStats) do
            self.gameStatTotals[k] = self.gameStatTotals[k] + gameStat
        end
    end
                
end


function GameOverState:update()
    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') or is_joystick and joystick:isDown({SNES_MAP.start}) then
        gStateMachine:change('start')
    end
end

function GameOverState:render()
    love.graphics.setColor(0, 170/255, 255/255, 1)
    love.graphics.setFont(gFonts['title'])
    love.graphics.printf("GAME OVER!", 0, 10, VIRTUAL_WIDTH, 'center')

    -- Player level stats, small letters
    love.graphics.setFont(gFonts['small'])
    local keyNum = 1
    for k, item in pairs(self.gameStatTotals) do 
        love.graphics.printf(tostring(k) .. ':  ' .. tostring(item), 0, VIRTUAL_HEIGHT / 4 + keyNum * 15, VIRTUAL_WIDTH, 'center')
        keyNum = keyNum + 1
    end

    love.graphics.setColor(255, 255, 255, 255)
end