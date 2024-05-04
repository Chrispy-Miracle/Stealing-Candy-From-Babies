WonGameState = Class{__includes = BaseState}

function WonGameState:enter(params)
    self.player = params.player
end

function WonGameState:update()
    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        love.event.quit()
    end
end

function WonGameState:render()
    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(0, 170/255, 255/255, 1)
    love.graphics.print("You Win!!!", 32, VIRTUAL_HEIGHT / 3)
    love.graphics.setColor(255, 255, 255, 1)

        -- Player level stats, small letters
        -- love.graphics.setFont(gFonts['small'])
        -- love.graphics.setColor(0, 170/255, 255/255, 1)
        -- local i = 1
        -- for k, item in pairs(self.player.scoreDetails[self.player.level]) do 
        --     love.graphics.printf(tostring(k) .. ':  ' .. tostring(item), 0, VIRTUAL_HEIGHT / 4 + i * 15, VIRTUAL_WIDTH, 'center')
        --     i = i + 1
        -- end
        --     love.graphics.setColor(255, 255, 255, 255)
end