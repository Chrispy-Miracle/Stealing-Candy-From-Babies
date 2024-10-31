LevelUpState = Class{__includes = BaseState}

function LevelUpState:enter(params)
    self.player = params.player

    -- check for win
    if self.player.level == NUMBER_OF_LEVELS then
        self.didWin = true 
    else 
        self.didWin = false
    end

    -- delay input to prevent accidentally missing level up screen
    self.timerDone = false
    Timer.after(1.5, function () self.timerDone = true end )
end

function LevelUpState:update(dt)
    if self.timerDone then
        if wasEnterPressed() then
            if self.didWin then
                -- go to You Won! screen
                gStateMachine:change('won-game', {
                    gameStats = self.player.scoreDetails, 
                    level = self.player.level
                })
            else
                -- go to next level
                gStateMachine:change('play', {player = self.player})
            end
        end
    end
end


function LevelUpState:render()
    -- Level up Big letters
    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(0, 170/255, 255/255, 1)
    love.graphics.printf('Level ' .. tostring(self.player.level) .. ' Clear!', 0, 10, VIRTUAL_WIDTH, 'center')

    -- Player level stats, small letters
    love.graphics.setFont(gFonts['small'])
    local keyNum = 1
    for k, item in pairs(self.player.scoreDetails[self.player.level]) do 
        love.graphics.printf(tostring(k) .. ':  ' .. tostring(item), 0, VIRTUAL_HEIGHT / 4 + keyNum * 15, VIRTUAL_WIDTH, 'center')
        keyNum = keyNum + 1
    end

    -- display "press enter" once input is allowed
    if self.timerDone then
        love.graphics.setFont(gFonts['small-title'])
        love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT - 30, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setColor(1,1,1,1)
end

