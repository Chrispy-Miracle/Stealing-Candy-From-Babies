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
    end
    
    self.player.gravity = 40 - self.player.balloonsCarried * 5
    -- self.playState.backgroundScrollY = (self.player.gravity * dt - self.playState.backgroundScrollY) % BACKGROUND_Y_LOOP_POINT
    

    -- allow for movement
    if love.keyboard.isDown('right') then
        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
    end

    if love.keyboard.isDown('left') then
        self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
    end

    self.player:update(dt)
end

function PlayerFallState:render()
    self.player:render()
end

