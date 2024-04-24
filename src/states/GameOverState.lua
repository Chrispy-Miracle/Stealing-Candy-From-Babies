GameOverState = Class{__includes = BaseState}

function GameOverState:init()
end

function GameOverState:update()
end

function GameOverState:render()
    love.graphics.setFont(gFonts['title'])
    love.graphics.print("GAME OVER\n You Lose!", 32, VIRTUAL_HEIGHT / 3)
end