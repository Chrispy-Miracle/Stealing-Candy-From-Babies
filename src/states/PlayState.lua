PlayState = Class{__includes = BaseState}

function PlayState:init()
    -- player
    self.player = Entity {
        type = 'player',
        animations = ENTITY_DEFS['player'].animations,
        width = ENTITY_DEFS['player'].width,
        height = ENTITY_DEFS['player'].height,
        x = - 16,
        y = VIRTUAL_HEIGHT - 70
    }
    self.player.direction = 'right'
    
    -- player's state machine
    self.player.stateMachine = StateMachine{
        ['idle'] = function () return PlayerIdleState(self.player) end,
        ['walk-state'] = function () return PlayerWalkState(self.player) end
    }
    self.player.stateMachine:change('idle')

    -- walk player onto scene
    self.player:changeAnimation('walk-' .. self.player.direction)
    gSounds['walking']:play()
    Timer.tween(2, {
        [self.player] = {x = 16}
    })
    -- stop player
    :finish(function() 
        self.player.stateMachine:change('idle')
    end)

    self.babies = {}
    -- baby spawner
    Timer.every(1, function ()
        if math.random(3) == 1 then
            local baby = Entity {
                type = 'baby',
                animations = ENTITY_DEFS['baby'].animations,
                width = ENTITY_DEFS['baby'].width,
                height = ENTITY_DEFS['baby'].height,
                x = VIRTUAL_WIDTH - 10,
                y = math.random(VIRTUAL_HEIGHT - 32, VIRTUAL_HEIGHT / 2),
                walkSpeed = ENTITY_DEFS['baby'].walkSpeed
            }
            baby.items = {}
            baby:changeAnimation('crawl-left')
            if math.random(3) == 1 then
                baby.hasBalloon = true
                local balloon = GameObject {
                    type = 'balloon',
                    texture = OBJECT_DEFS['balloon'].texture,
                    frame = math.random(#OBJECT_DEFS['balloon'].frames),
                    height = OBJECT_DEFS['balloon'].height,
                    width = OBJECT_DEFS['balloon'].width,
                    x = baby.x - BABY_BALLOON_OFFSET_X,
                    y = baby.y - BABY_BALLOON_OFFSET_Y,
                    isCarried = true,
                    carrier = baby,
                    carrier_offset_x = BABY_BALLOON_OFFSET_X,
                    carrier_offset_y = BABY_BALLOON_OFFSET_Y
                }
                table.insert(baby.items, balloon)
            end 

            table.insert(self.babies, baby)
        end
    end)
end


function PlayState:update(dt)

    self.player.stateMachine:update(dt)

    for k, baby in pairs(self.babies) do
        if baby.x > -baby.width then
            baby.x = baby.x - baby.walkSpeed * dt
            baby:update(dt)

            for k, item in pairs(baby.items) do
                item:update(dt)
            end
        else
            table.remove(self.babies, k)
        end
            

    end

end

function PlayState:render()
    love.graphics.draw(gTextures['background'], gFrames['background'][1], 0, 0)
    
    

    for k, baby in pairs(self.babies) do
        
        if baby.y + baby.height < self.player.y + self.player.height then 
            for k, item in pairs(baby.items) do
                item:render()
            end

            baby:render()
        end
    end
    
    self.player.stateMachine:render()

    for k, baby in pairs(self.babies) do
        
        if baby.y + baby.height > self.player.y + self.player.height then 
            for k, item in pairs(baby.items) do
                item:render()
            end

            baby:render()
        end
    end
end
