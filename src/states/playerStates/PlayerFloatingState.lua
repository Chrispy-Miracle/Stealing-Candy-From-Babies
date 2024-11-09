PlayerFloatingState = Class{__includes = BaseState}

function PlayerFloatingState:init(playState)
    self.playState = playState
    self.player = playState.player
    self.player.isFloating = true
    self.playState.backgroundScrollX = 0
    self.player:changeAnimation('idle-' .. self.player.direction)

    -- play/stop sounds
    gSounds['walking']:stop()
    gSounds['fly-away']:play()
    
    -- make onground moms and babies go away with the ground
    self:tweenEntitiesToLowerBound(self.playState.babies)
    self:tweenEntitiesToLowerBound(self.playState.moms)
end

function PlayerFloatingState:update(dt)
    self:checkForLevelComplete()
    -- set player gravity and background scroll according to number of balloons
    self.player.gravity = self.player.balloonsCarried * 10
    self.playState.backgroundScrollY = (self.playState.backgroundScrollY - self.player.gravity * dt) % BACKGROUND_Y_LOOP_POINT

    self:handlePlayerFloat(dt)    
    self:handlePlayerMovement(dt)
    self.player:update(dt)  

    -- change background to sky after you cant see the ground
    if self.player.y < -self.player.height / 2 then
        self.playState.background = 2 
    end
    self.player:checkForBalloonPops()
    -- change to falling state if not enough balloons to float
    if self.player.balloonsCarried <= 3 then
        self.player.stateMachine:change('fall-state')
    end
end

function PlayerFloatingState:render()
    self.player:render()
end


function PlayerFloatingState:tweenEntitiesToLowerBound(entities)
    for k, entity in pairs(entities) do
        Timer.tween(2, {
            [entity] = {y = VIRTUAL_HEIGHT}
        })
    end
end

function PlayerFloatingState:checkForLevelComplete()
    -- check for level ending 
    if self.player.level == 1 and self.player.screensFloatedUp == 10 then
        self.player.stateMachine:change('board-ship')
    elseif self.player.level == 2 and self.player.screensFloatedUp == 15 then
        self.player.stateMachine:change('board-ship')
    end
end

function PlayerFloatingState:handlePlayerFloat(dt)
    -- if player on screen, they float up
    if self.player.y > -self.player.height then
        self.player.y = self.player.y - self.player.gravity * dt
    else 
        -- wrap player to bottom of sceen if floated past top
        self.player.y = VIRTUAL_HEIGHT
        self.player.screensFloatedUp = self.player.screensFloatedUp + 1
    end
end

function PlayerFloatingState:handlePlayerMovement(dt)
    -- float to right
    if wasRightPressed() then
        self.player.direction = 'right'
        self.player:changeAnimation('idle-' .. self.player.direction)
        self.player.x = self.player.x + self.player.walkSpeed * dt

        -- player to left side of screen if they float off right
        if self.player.x > VIRTUAL_WIDTH - 2 then
            self.player.x = -self.player.width - 2
        end
    end
    -- float to left
    if wasLeftPressed() then
        self.player.direction = 'left'
        self.player:changeAnimation('idle-' .. self.player.direction)
        self.player.x = self.player.x - self.player.walkSpeed * dt

        -- player to right side of screen if they float off left
        if self.player.x < -self.player.width - 2 then
            self.player.x = VIRTUAL_WIDTH - 2
        end
    end
    -- float up faster
    if wasUpPressed() then
        self.player.y = self.player.y - (self.player.walkSpeed / 2) * dt
    end
    -- float down (more like slow down)
    if wasDownPressed() then
        self.player.y = self.player.y + (self.player.walkSpeed / 2) * dt
    end
end
