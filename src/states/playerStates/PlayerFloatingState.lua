PlayerFloatingState = Class{__includes = BaseState}

function PlayerFloatingState:init(playState)
    self.playState = playState
    self.player = playState.player

    self.player.isFloating = true
    self.player:changeAnimation('idle')
    gSounds['walking']:stop()
    
    self.playState.backgroundScrollX = 0

    -- change background to sky after you cant see the ground
    Timer.after(2.4, function () self.playState.background = 2 end)
end


function PlayerFloatingState:update(dt)
    -- check items for balloon pops 
    for k, item in pairs(self.player.items) do 
        if item.type == 'balloon' then
            -- check playState storks
            for j, stork in pairs(self.playState.babies) do 
                -- baby is a stork in this instance
                if stork.type == 'stork' then
                    self:tryBalloonPop(stork, item, k)
                end
            end
        end
    end

    -- change to falling state if not enough balloons to float
    if self.player.balloonsCarried <= 3 then
        self.player.stateMachine:change('fall-state')
    else
        -- set player gravity and background scoll accorging to number of balloons
        self.player.gravity = self.player.balloonsCarried * 10
        self.playState.backgroundScrollY = (self.playState.backgroundScrollY - self.player.gravity * dt) % BACKGROUND_Y_LOOP_POINT

        -- if player on screen,they float up
        if self.player.y > -self.player.height then
            self.player.y = self.player.y - self.player.gravity * dt
        else 
            -- wrap player back to bottom of sceen if they floated off
            self.player.y = VIRTUAL_HEIGHT
            self.player.gravity = 0
        end
    end

    -- allow for movement
    if love.keyboard.isDown('right') then
        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
    end

    if love.keyboard.isDown('left') then
        self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
    end

    if love.keyboard.isDown('up') then
        self.player.y = self.player.y - (PLAYER_WALK_SPEED / 2) * dt
    end

    if love.keyboard.isDown('down') then
        self.player.y = self.player.y + (PLAYER_WALK_SPEED / 2) * dt
    end

    -- update player
    self.player:update(dt)  
end

-- check for storks colliding with balloons, pop em if so
function PlayerFloatingState:tryBalloonPop(popper, balloon, itemKey)
    if popper.x < balloon.x + balloon.width + 10 and popper.x > balloon.x + balloon.width - 10 and
        popper.y < balloon.y + 30 and popper.y > balloon.y then

        table.remove(self.player.items, itemKey)
        gSounds['hit']:play()
        
        -- this will affect gravity
        self.player.balloonsCarried = self.player.balloonsCarried - 1
    end 
end


function PlayerFloatingState:render()
    self.player:render()
end
