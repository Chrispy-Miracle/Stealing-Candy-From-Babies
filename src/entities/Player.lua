Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
    self.level = def.level

    -- health (or sugar buzz)
    self.health = def.entity_def.startingHealth
    self.maxHealth = def.entity_def.maxHealth

    self.balloonsCarried = 0
    self.gravity = 0
    self.isFloating = false
    self.isFalling = false

    self.screensFloatedUp = 0
    self.levelEnded =  false

    self.items = {
        ['balloons'] = {},
        ['lollipops'] = {}
    }

    self.scoreDetails = {
        {
            ['Candies Stolen'] = 0,
            ['Balloons Stolen'] = 0,
            ['Damage Taken'] =  0,
            ['Time'] =  0
        }
    }

    -- constantly crashing from sugar buzz!
    if self.type == 'player' then
        Timer.every(1, function () 
            if not self.levelEnded then
                -- one damage per second
                self.health = self.health - 1 
                self.scoreDetails[self.level]['Damage Taken'] = self.scoreDetails[self.level]['Damage Taken'] + 1
                self.scoreDetails[self.level]['Time'] = self.scoreDetails[self.level]['Time'] + 1
            end
        end)
    end

    --particle system
    self.pSystem = love.graphics.newParticleSystem(gTextures[1]['particle'], 32)
    self.pSystem:setParticleLifetime(.3, 1.5) -- Particles live at least 2s and at most 5s.
	self.pSystem:setSpin(math.rad(-360), math.rad(360))
	self.pSystem:setLinearAcceleration(-200, -150, 200, 200) -- Random movement in all directions.
	self.pSystem:setColors(0, 1, 0, 1, 0, 1, 0, .5) -- Fade to transparency.
end

function Player:update(dt)
    Entity.update(self, dt)
    self.pSystem:update(dt)

    -- update player's balloons
    if #self.items['balloons'] > 1 then
        -- angle the balloons nicely
        for k, item in pairs(self.items['balloons']) do
            if k % 2 == 0 then
                item.balloonAngle =  math.rad(k * -10)
            else 
                item.balloonAngle = math.rad(k * 10)
            end
        end
    elseif #self.items['balloons'] == 1 then
        self.items['balloons'][1].balloonAngle = 0
    end
end

function Player:render()
    Entity.render(self)
    love.graphics.draw(self.pSystem, self.x + self.width, self.y)

    -- for debugging collisions
    love.graphics.setColor(0,1,0,1)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    if self.direction == 'right' then
        love.graphics.rectangle('line', self.x + self.width / 2, self.y + self.height / 2, 5, 5)
    elseif self.direction == 'left' then
        love.graphics.rectangle('line', self.x, self.y + self.height / 2, 5, 5)
    end
    love.graphics.setColor(1,1,1,1)
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

-- check for storks colliding with balloons, pop em if so--math.random(4, 16)
function Player:tryBalloonPop(popper, balloon, itemKey)
    local r, g, b = math.random(255) / 255, math.random(255) / 255, math.random(255) / 255

    -- 2 balloons 
    if popper.x < balloon.x + math.deg(balloon.balloonAngle) and popper.x > balloon.x - math.deg(balloon.balloonAngle) and
        popper.y + 8 < balloon.y + 20 and popper.y + 16 > balloon.y then

        table.remove(self.items['balloons'], itemKey)
        gSounds['hit']:play()
        self.pSystem:setColors(r, g, b, 1, r, g, b, 0)
        self.pSystem:emit(32)
        -- this will affect gravity
        self.balloonsCarried = self.balloonsCarried - 1
    end 
end


function Player:stealItem(prevOwner, item, itemKey)
                    
    gSounds['steal']:play()

    if item.type == 'balloon' then
        item.carrier_offset_x = PLAYER_BALLOON_OFFSET_X
        item.carrier_offset_y = PLAYER_BALLOON_OFFSET_Y
        self.balloonsCarried = self.balloonsCarried + 1

        -- take out of previous carrier's items
        table.remove(prevOwner.items, itemKey)
        -- put into player's items
        item.carrier = self
        table.insert(self.items['balloons'], item) 
        self.scoreDetails[self.level]['Balloons Stolen'] = self.scoreDetails[self.level]['Balloons Stolen'] + 1
        
    elseif item.type == 'lollipop' then
        Timer.after(.4, function () gSounds['lollipop']:play() end )
        self.hasLollipop = true
        item.carrier_offset_x = PLAYER_LOLLIPOP_OFFSET_X
        item.carrier_offset_y = PLAYER_LOLLIPOP_OFFSET_Y

        -- take out of previous carrier's items
        table.remove(prevOwner.items, itemKey)
        -- put into player's items
        item.carrier = self
        table.insert(self.items['lollipops'], item)  
        self.scoreDetails[self.level]['Candies Stolen'] = self.scoreDetails[self.level]['Candies Stolen'] + 1
        

        -- this animates health bar going up 1 point every .2 seconds
        Timer.every(.2, function () 
            if self.health < self.maxHealth then
                self.health = self.health + 1
            end
        end)
        :limit(15)
        :finish(function () 
            self.hasLollipop = false
            -- remove lollipop from items
            table.remove(self.items['lollipops']) 
        end)
    end 
end