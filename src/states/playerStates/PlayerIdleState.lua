PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(player)
    self.player = player

    -- stop walk sound and set animation to idle
    gSounds['walking']:stop()
    self.player.isWalking = false
    self.player:changeAnimation('idle-' .. self.player.direction)
end

function PlayerIdleState:update(dt)
    -- change to walk state if arrow buttons pushed
    if love.keyboard.isDown('right') or love.keyboard.isDown('left') 
        or love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.player.isWalking = true
        self.player.stateMachine:change('walk-state')
    end

    --change to floating state
    if self.player.balloonsCarried > 3 then
        self.player.stateMachine:change('float-state')
    end

    self.player:update(dt)
end

function PlayerIdleState:render()
    self.player:render()
end