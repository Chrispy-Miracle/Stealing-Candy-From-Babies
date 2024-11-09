PlayerWalkState = Class{__includes = BaseState}

function PlayerWalkState:init(playState)
    self.playState = playState
    self.player = playState.player

    -- start walking sound and animation
    gSounds['walking']:play()
    self.player:changeAnimation('walk-' .. self.player.direction)
end

function PlayerWalkState:update(dt)
    self:handlePlayerMovement(dt)
    
    if noDirectionPressed() then  -- return to idle state 
        gSounds['walking']:stop()
        self.player.stateMachine:change('idle')
    end
    self.player:handleBabyCollision()
    self.player:update(dt)
end

function PlayerWalkState:render()
    self.player:render()
end


function PlayerWalkState:handlePlayerMovement(dt)
    if wasRightPressed() then   
        self:movePlayerHorizontal("right", dt)
    elseif wasLeftPressed() then
        self:movePlayerHorizontal("left", dt)
    elseif wasUpPressed() then
        --move player while confining y-axis movement
        if self.player.y > VIRTUAL_HEIGHT / 3 then
            self.player.y = self.player.y - (self.player.walkSpeed / 2) * dt
        end
    elseif wasDownPressed() then
        --move player while confining y-axis movement
        if self.player.y < VIRTUAL_HEIGHT / 2 + 8 then
            self.player.y = self.player.y + (self.player.walkSpeed / 2) * dt
        end
    end
end

function PlayerWalkState:movePlayerHorizontal(direction, dt)
    self.player.direction = direction
    self.player:changeAnimation('walk-' .. self.player.direction)

    if direction == "right" then 
        self.player.x = self.player.x + self.player.walkSpeed * dt
    elseif direction =="left" then
        self.player.x = self.player.x - self.player.walkSpeed * dt
    end
    self:scrollBackground(direction, dt)
    self:handleBoundary(direction, dt)
end

function PlayerWalkState:scrollBackground(direction, dt)
    local scroll
    if direction == "right" then
        scroll = BACKGROUND_X_SCROLL_SPEED
    elseif direction == "left" then
        scroll = -BACKGROUND_X_SCROLL_SPEED
    end
    self.playState.backgroundScrollX = (self.playState.backgroundScrollX + scroll * dt) % BACKGROUND_X_LOOP_POINT
end

function PlayerWalkState:handleBoundary(direction, dt)
    if direction == "right" then
        self:handleRightBoundary()
    elseif direction == "left" then
        self:handleLeftBoundary(dt)
    end
end

function PlayerWalkState:handleRightBoundary()
    -- if player is at right edge of screen scroll all things back to left
    if self.player.x > VIRTUAL_WIDTH - self.player.width then
        self.playState.isScrollingBack = true
        self:scrollPlayerAndBackgroundLeft()
        self:scrollEntitiesLeft(self.playState.babies)
        self:scrollEntitiesLeft(self.playState.moms)
    end
end    


function PlayerWalkState:scrollPlayerAndBackgroundLeft()
    Timer.tween(1.5, {
        [self.player] = {x = 16},
        [self.playState] = {backgroundScrollX = BACKGROUND_X_LOOP_POINT}
    })
    :finish(function () self.playState.isScrollingBack = false end)
end

function PlayerWalkState:scrollEntitiesLeft(entities)
    for k, entity in pairs(entities) do
        local newEntityX = entity.x >= self.player.x and 16 + (entity.x - self.player.x) or 16 - (self.player.x - entity.x)
        Timer.tween(1.5, {
            [entity] = {x = newEntityX} 
        })
    end 
end

function PlayerWalkState:handleLeftBoundary(dt)
    -- if player hits left wall, do a bit of damage
    if self.player.x < -self.player.width / 2 then
        gSounds['hit-wall']:play()
        self.player.health = self.player.health - 2
        self.player.scoreDetails[self.player.level]['Damage Taken'] = self.player.scoreDetails[self.player.level]['Damage Taken'] + 5
        -- move player back
        self.player.x = self.player.x + self.player.width / 2
        self:scrollBackground("right", dt)
    end
end


