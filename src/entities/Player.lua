Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
    self.level = def.level
    self.health = def.entity_def.startingHealth  -- health (or sugar buzz)
    self.maxHealth = def.entity_def.maxHealth
    self.balloonsCarried = 0  -- # of balloons carried affects gravity
    self.gravity = 0
    self.isFloating = false
    self.isFalling = false
    self.screensFloatedUp = 0
    self.levelEnded =  false
    self.hasLollipop = false
    self.items = {
        ['balloons'] = {},
        ['lollipops'] = {}
    }
    -- to display level and game detail end screens
    self.scoreDetails = {
        {
            ['Candies Stolen'] = 0,
            ['Balloons Stolen'] = 0,
            ['Damage Taken'] =  0,
            ['Time'] =  0
        }
    }
    self:initHitboxes()
    self:initParticleSystem()
    self:takeDamageEveryInterval(1, 1)
end

function Player:update(dt)
    Entity.update(self, dt)
    self.pSystem:update(dt)
    self:handleChangeToFloatState()
    self:handleStealAttemptAnimationAndSound()
    self:updateHitboxes(dt)
    self:updatePlayerBalloons(dt)
end

function Player:render()
    Entity.render(self)
    --particle system
    love.graphics.draw(self.pSystem, self.x + self.width, self.y)
    -- for debugging collisions
    self.hitBox:render()
    self.handHitBox:render()
    self.footHitBox:render()
end


function Player:takeDamageEveryInterval(damage, interval)
    -- constantly crashing from sugar buzz!
    if self.type == 'player' then
        Timer.every(interval, function () 
            if not self.levelEnded then
                -- one damage per second
                self.health = self.health - damage 
                self.scoreDetails[self.level]['Damage Taken'] = self.scoreDetails[self.level]['Damage Taken'] + damage
                self.scoreDetails[self.level]['Time'] = self.scoreDetails[self.level]['Time'] + damage
            end
        end)
    end
end

function Player:initParticleSystem()
    --particle system for popping balloons
    self.pSystem = love.graphics.newParticleSystem(gTextures[1]['particle'], 32)
    self.pSystem:setParticleLifetime(.3, 1.5) 
	self.pSystem:setSpin(math.rad(-360), math.rad(360))
	self.pSystem:setLinearAcceleration(-200, -150, 200, 200) -- Random movement in all directions.
	self.pSystem:setColors(0, 1, 0, 1, 0, 1, 0, .5) -- Fade to transparency.
end



function Player:handleChangeToFloatState()
    if self.balloonsCarried > 3 and not self.isFloating then
        if self.playState.isScrollingBack then -- simulate state change if scrolling 
            self.y =  self.y - (self.balloonsCarried * 5) * dt
        else
            self.stateMachine:change('float-state')
        end
    end
end

function Player:handleStealAttemptAnimationAndSound()
    -- momentary change to steal animation, then back 
    if wasSpaceOrBPressed() then
        self:changeAnimation('steal-' .. self.direction)
        gSounds['steal']:play()
        Timer.after(.2, function () self:changeAnimation('idle-' .. self.direction) end)
    end
end

function Player:updatePlayerBalloons()
    -- update player's balloons
    if #self.items['balloons'] > 1 then
        self:updateMultipleBalloons()
    elseif #self.items['balloons'] == 1 then
        self:updateSingleBallooon()
    end
end

function Player:updateMultipleBalloons()
    -- angle the balloons nicely
    for k, item in pairs(self.items['balloons']) do
        if k % 2 == 0 then
            item.balloonAngle =  math.rad(k * -10)
            item.angledXY = {x = -k * 4, y = k * 1.75} -- for adjusting balloon hitboxes
        else 
            item.balloonAngle = math.rad(k * 10)
            item.angledXY = {x = k * 4, y = k * 1.75}
        end
    end
end

function Player:updateSingleBallooon()
    local loneBalloon = self.items['balloons'][1]
    loneBalloon.balloonAngle = 0
    loneBalloon.hitBox.item.x = loneBalloon.x + ROTATED_BALLOON_OFFSET_X + loneBalloon.width / 2 + loneBalloon.angledXY.x 
    loneBalloon.hitBox.item.y = loneBalloon.y + ROTATED_BALLOON_OFFSET_Y - loneBalloon.height / 2 + loneBalloon.angledXY.y
end

function Player:LevelUp()
    self.level = self.level + 1
    self.isFloating = false
    self.isFalling = false
    self.gravity = 0
    self.balloonsCarried = 0
    self.screensFloatedUp = 0
    
    self.health = 60
    self.x = -16
    self.y = VIRTUAL_HEIGHT - 70

    self.direction = 'right'
    self.animations = self:createAnimations(ENTITY_DEFS[self.level]['player'].animations)
    self.items = {
        ['balloons'] = {},
        ['lollipops'] = {}
    }
    table.insert(self.scoreDetails, {
        ['Candies Stolen'] = 0,
        ['Balloons Stolen'] = 0,
        ['Damage Taken'] =  0,
        ['Time'] =  0
    })
end


-- check for storks colliding with balloons, pop them if so
function Player:tryBalloonPop(popper, balloon, itemKey)
    -- random color (for now) for particle system
    local r, g, b = math.random(255) / 255, math.random(255) / 255, math.random(255) / 255

    if balloon:didCollide(popper) then
        table.remove(self.items['balloons'], itemKey)
        gSounds['hit']:play()

        -- particle system
        self.pSystem:setColors(r, g, b, 1, r, g, b, 0)
        self.pSystem:emit(32)

        -- this will affect gravity
        self.balloonsCarried = self.balloonsCarried - 1
    end 
end


function Player:stealItem(prevOwner, item, itemKey)
    -- play sounds             
    gSounds['baby-cry-' .. tostring(math.random(3))]:play()

    if item.type == 'balloon' then
        self:stealBalloon(prevOwner, item, itemKey)
        
    elseif item.type == 'lollipop' then
        self:stealLollipop(prevOwner, item, itemKey)
    end 
end

function Player:stealBalloon(prevOwner, item, itemKey)
    -- align with player position
    item.carrier_offset_x = PLAYER_BALLOON_OFFSET_X
    item.carrier_offset_y = PLAYER_BALLOON_OFFSET_Y

    self.balloonsCarried = self.balloonsCarried + 1

    -- take out of previous carrier's items
    table.remove(prevOwner.items, itemKey)
    -- put into player's items
    item.carrier = self
    table.insert(self.items['balloons'], item) 
    self.scoreDetails[self.level]['Balloons Stolen'] = self.scoreDetails[self.level]['Balloons Stolen'] + 1
end

function Player:stealLollipop(prevOwner, item, itemKey)
    self.hasLollipop = true
    -- lick lollipop sound
    Timer.after(.4, function () 
        gSounds['lollipop']:setVolume(.5) 
        gSounds['lollipop']:play() 
    end)

    item.carrier_offset_x = PLAYER_LOLLIPOP_OFFSET_X
    item.carrier_offset_y = PLAYER_LOLLIPOP_OFFSET_Y

    -- take out of previous carrier's items and put into player's items
    table.remove(prevOwner.items, itemKey)
    item.carrier = self
    table.insert(self.items['lollipops'], item) 
    -- update score
    self.scoreDetails[self.level]['Candies Stolen'] = self.scoreDetails[self.level]['Candies Stolen'] + 1
    
    self:handleHealthIncrease()
end

function Player:handleHealthIncrease()
    -- this animates health bar going up 1 point every .2 seconds
    Timer.every(.2, function () 
        if self.health < self.maxHealth then
            self.health = self.health + 1
        end
    end)
    :limit(15)
    :finish(function () 
        -- remove lollipop from items after "eating" it
        table.remove(self.items['lollipops']) 
        self.hasLollipop = false
    end)
end

-- when player is falling and about to hit the ground
function Player:crashDown()
    self.playState.background = 1
    self.playState.backgroundScrollY = BACKGROUND_Y_LOOP_POINT / 2

    -- scoot player and background such that player is back on the ground
    Timer.tween(1, {
        [self] = {y = VIRTUAL_HEIGHT / 2},
        [self.playState] = {backgroundScrollY = BACKGROUND_Y_LOOP_POINT}

    }):finish(function()
        self.isFloating =  false
        self.isFalling = false
        gSounds['hit-ground']:play()

        --damage player
        self.health = self.health - (30 - (self.balloonsCarried * 10))
        self.scoreDetails[self.level]['Damage Taken'] = self.scoreDetails[self.level]['Damage Taken'] + (30 - (self.balloonsCarried * 10))
        
        -- go back to player idle state
        self.stateMachine:change('idle')            
    end)
end


-- HITBOX FUNCTIONS
function Player:initHitboxes()
    self:initMainHitbox()
    self:initHandHitbox()
    self:initFootHitbox()
end

function Player:initMainHitbox()
    -- entire player (for taking damage)
    self.hitBox = HitBox{
        item = self,
        x = self.x,
        y = self.y,
        width = self.width,
        height = self.height - 3
    }
end

function Player:initHandHitbox()
    -- player's hand position (for stealing)
    self.handHitBox = HitBox{
        item = {
            x = self.x + self.width / 2, 
            y = self.y + self.height / 3           
        },
        x = self.x + self.width / 2, 
        y = self.y + self.height / 3,
        width = self.width / 2,
        height = 10
    }
end

function Player:initFootHitbox()
    --player's foot position (to detect stepping on babies)
    self.footHitBox = HitBox{
        item = {
            x = self.x,
            y = self.y + self.height - 10
        },
        x = self.x,
        y = self.y + self.height - 10,
        width = self.width,
        height = 10
    }
end

function Player:updateHitboxes(dt)
    self.hitBox:update(dt)
    self:updateHandHitbox(dt)
    self:updateFootHitbox(dt)
end

function Player:updateHandHitbox(dt)
    -- update hand position hitbox for player's direction 
    if self.direction == 'right' then
        self.handHitBox.item.x = self.x + self.width / 2
        self.handHitBox.item.y = self.y + self.height / 3
    elseif self.direction == 'left' then 
        self.handHitBox.item.x = self.x
        self.handHitBox.item.y = self.y + self.height / 3
    end
    self.handHitBox:update(dt)
end

function Player:updateFootHitbox(dt)
    -- update foot hitbox
    self.footHitBox.item.x = self.x
    self.footHitBox.item.y = self.y + self.height - 10
    self.footHitBox:update(dt)
end