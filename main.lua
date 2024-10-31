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
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end,
        ['level-up'] = function () return LevelUpState() end,
        ['won-game'] = function () return WonGameState() end
    }

    gStateMachine:change('start')

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        Timer.clear()
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    Timer.update(dt)
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end


function love.draw()
    push:start()
    gStateMachine:render()
    push:finish()
end


-- to simplify player controls
function wasEnterPressed()
    return love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') or is_joystick and joystick:isDown({SNES_MAP.start})
end

function wasSpaceOrBPressed()
    return love.keyboard.wasPressed('space') or is_joystick and joystick:isDown({SNES_MAP.b})
end

function wasRightPressed()
    return love.keyboard.isDown('right') or love.keyboard.isDown('d') or is_joystick and joystick:getAxis(SNES_MAP.xDir) == 1
end

function wasLeftPressed()
    return love.keyboard.isDown('left') or love.keyboard.isDown('a') or is_joystick and joystick:getAxis(SNES_MAP.xDir) == -1
end

function wasUpPressed()
    return love.keyboard.isDown('up') or love.keyboard.isDown('w') or is_joystick and joystick:getAxis(SNES_MAP.yDir) == -1
end

function wasDownPressed()
    return love.keyboard.isDown('down') or love.keyboard.isDown('s') or is_joystick and joystick:getAxis(SNES_MAP.yDir) == 1
end
