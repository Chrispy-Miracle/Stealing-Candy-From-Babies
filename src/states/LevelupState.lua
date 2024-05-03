LevelUpState = Class{__includes = BaseState}

function LevelUpState:init(player)

end

function LevelUpState:update(dt)
end

function LevelUpState:render()
    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(0, 170/255, 255/255, 1)
    love.graphics.printf('Level Up!', 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, 255)
end

