PlayerFallState = Class{__includes = BaseState}

function PlayerFallState:init(playState)
    self.playState = playState
    self.player = playState.player

    self.player.isFalling = true
    self.player.gravity = 40 - self.player.balloonsCarried * 5
        
    self.playState.backgroundScrollX = 0
end

function PlayerFallState:update(dt)
    if self.player.balloonsCarried >= 3 then
        self.player.stateMachine:change('float-state')
    end

    -- player falls
    self.player.y = self.player.y + self.player.gravity * dt 
    -- player wraps to top of screen if falls below bottom 
    if self.player.y > VIRTUAL_HEIGHT then
        self.player.y = -self.player.height
        self.player.screensFloatedUp = self.player.screensFloatedUp - 1
        if self.player.screensFloatedUp <= 1 then
            self.playState.background = 1
            Timer.after(2.4, function ()
                self.player.isFloating =  false
                Timer.tween(1, {
                    [self.player] = {y = VIRTUAL_HEIGHT / 2},
                    [self.playState] = {backgroundScrollX = 0}
                })
                self.player.stateMachine:change('idle')
            end)
        end
    end
    
    -- if self.playState.background == 1 and self.player.y == VIRTUAL_HEIGHT * .8  then

    -- end

    self.player.gravity = self.player.balloonsCarried * 10
    self.playState.backgroundScrollY = (self.player.gravity * dt + self.playState.backgroundScrollY) % BACKGROUND_Y_LOOP_POINT
    

    -- allow for movement
    if love.keyboard.isDown('right') then
        self.player.direction = 'right'
        self.player:changeAnimation('idle-' .. self.player.direction)
        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
    end

    if love.keyboard.isDown('left') then
        self.player.direction = 'left'
        self.player:changeAnimation('idle-' .. self.player.direction)
        self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
    end

    self.player:update(dt)
end

function PlayerFallState:render()
    self.player:render()
end

