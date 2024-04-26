GameOverState = Class{__includes = BaseState}

function GameOverState:init()
end

function GameOverState:update()
    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        gStateMachine:change('start')
    end
end

function GameOverState:render()
    love.graphics.setFont(gFonts['title'])
    love.graphics.print("GAME OVER\n You Lose!", 32, VIRTUAL_HEIGHT / 3)
end