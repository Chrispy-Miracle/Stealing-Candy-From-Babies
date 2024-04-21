love.graphics.setDefaultFilter('nearest', 'nearest')
require 'src/Dependencies'

function love.load()
    love.window.setTitle('Candy from Babies')

    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
        canvas = false
    })

    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end
    }

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wadPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    -- gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end


function love.draw()
    push:start()
    -- gStateMachine:render()
    push:finish()
end
