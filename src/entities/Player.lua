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
end

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:render()
    Entity.render(self)
end

function Player:LevelUp()
    -- self.stateMachine:change('idle')
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
    self.items = {}
    table.insert(self.scoreDetails, {
        ['Candies Stolen'] = 0,
        ['Balloons Stolen'] = 0,
        ['Damage Taken'] =  0,
        ['Time'] =  0
    })
end

-- check for storks colliding with balloons, pop em if so--math.random(4, 16)
function Player:tryBalloonPop(popper, balloon, itemKey)
    -- 2 balloons 
    if popper.x < balloon.x + math.deg(balloon.balloonAngle) and popper.x > balloon.x - math.deg(balloon.balloonAngle) and
        popper.y + 8 < balloon.y + 20 and popper.y + 16 > balloon.y then

        table.remove(self.items, itemKey)
        gSounds['hit']:play()
        
        -- this will affect gravity
        self.balloonsCarried = self.balloonsCarried - 1
    end 
end