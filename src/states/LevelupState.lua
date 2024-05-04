LevelUpState = Class{__includes = BaseState}

function LevelUpState:enter(params)
    self.player = params.player

    if self.player.level == NUMBER_OF_LEVELS then
        self.didWin = true 
    else 
        self.didWin = false
    end

    self.i = 1
end

function LevelUpState:update(dt)
    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        if self.didWin then
            gStateMachine:change('won-game', {player = self.player})
        else
            self.player.stateMachine:change('idle')
            self.player:LevelUp()
            gStateMachine:change('play', {player = self.player})
        end
    end
end

function LevelUpState:render()
    -- Level up Big letters
    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(0, 170/255, 255/255, 1)
    love.graphics.printf('Level ' .. tostring(self.player.level) .. ' Clear!', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, 255)

    -- Player level stats, small letters
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 170/255, 255/255, 1)
    
    for k, item in pairs(self.player.scoreDetails[self.player.level]) do 
        love.graphics.printf(tostring(k) .. ':  ' .. tostring(item), 0, VIRTUAL_HEIGHT / 4 + self.i * 15, VIRTUAL_WIDTH, 'center')
        self.i = self.i + 1
    end
        love.graphics.setColor(255, 255, 255, 255)

    -- love.graphics.print('didwin: ' .. tostring(self.didWin) .. '\n' .. tostring(self.player.level), VIRTUAL_HEIGHT - 10, 0 )
end

