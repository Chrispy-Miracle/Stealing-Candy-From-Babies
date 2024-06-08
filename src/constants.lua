WINDOW_WIDTH = 1280
WINDOW_HEGHT = 720

VIRTUAL_WIDTH = 256
VIRTUAL_HEIGHT = 144

-- these are resolutions a friend suggested to try out
--SEGA (kerf pick)
-- VIRTUAL_WIDTH = 320
-- VIRTUAL_HEIGHT = 224

--SNES
-- VIRTUAL_WIDTH = 256
-- VIRTUAL_HEIGHT = 224

NUMBER_OF_LEVELS = 2

BABY_BALLOON_OFFSET_X = -7
BABY_BALLOON_OFFSET_Y = -12

BABY_LOLLIPOP_OFFSET_X = -7
BABY_LOLLIPOP_OFFSET_Y = -6

PLAYER_BALLOON_OFFSET_X = 12  
PLAYER_BALLOON_OFFSET_Y = -6 

ROTATED_BALLOON_OFFSET_X = 16 
ROTATED_BALLOON_OFFSET_Y = 34 

PLAYER_LOLLIPOP_OFFSET_X = 5 
PLAYER_LOLLIPOP_OFFSET_Y = 16

BACKGROUND_X_SCROLL_SPEED = 30
BACKGROUND_X_LOOP_POINT = 272

BACKGROUND_Y_LOOP_POINT = 288

MOM_BAG_OFFSET_X = -6
MOM_BAG_OFFSET_Y = 26

-- SNES Controller (a generic controller I have)
if #love.joystick.getJoysticks() > 0 then
    is_joystick = true
    joystick = love.joystick.getJoysticks()[1]

    SNES_MAP = {
        -- This is a mapping of controller buttons to their indexes (accessed with love.joystick.isDown())
        a = 1, 
        b = 2, 
        x = 3, 
        y = 4, 
        sel = 5, 
        start = 7, 
        leftTrig = 10, 
        rightTrig = 11,
        -- This is x and y axes on controller(accessed with love.joystick.getAxis())
        xDir = 1, 
        yDir = 2        
    }
    
else 
    is_joystick = false
end