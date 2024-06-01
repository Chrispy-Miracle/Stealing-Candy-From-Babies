PlayerBoardShipState = Class{__includes = BaseState}

function PlayerBoardShipState:init(playState)
    self.player = playState.player
    self.player.levelEnded = true
    self.player.gravity = 0

    self.startBeam = false
    self.beamOpacity = 100

    self.ufo = GameObject {
        object_def = OBJECT_DEFS['ufo'],
        x = -OBJECT_DEFS['ufo'].width,
        y = -OBJECT_DEFS['ufo'].height,
        isCarried = false,
        level = self.player.level
    }

    gSounds['space-ship']:play()

    -- bring player and ufo to center
    Timer.tween(2, {
        [self.ufo] = {x = VIRTUAL_WIDTH / 2 - self.ufo.width / 2, y = 0},
        [self.player] = {x = VIRTUAL_WIDTH / 2 - self.player.width / 2, y = VIRTUAL_HEIGHT - self.player.height}
    })
    :finish(function () 
        self.startBeam = true
        gSounds['beam-up3']:play()
    end)
end


function PlayerBoardShipState:update(dt)
    self.player:update(dt)
    self.ufo:update(dt)

    if self.startBeam then 
        

        -- flash ufo's beam 
        if self.beamOpacity < 215 then
            self.beamOpacity = self.beamOpacity + 5
        else
            self.beamOpacity = 0
        end

        Timer.after(2, function ()
            -- "beam up" players items 
            for k, item in pairs(self.player.items['balloons']) do
                if item.y > 0 then
                    Timer.tween(.5, { 
                        [item] = {y = -item.height}
                    })
                end
            end

            for k, item in pairs(self.player.items['lollipops']) do
                if item.y > 0 then
                    Timer.tween(.5, { 
                        [item] = {y = -item.height}
                    })
                end
            end

            -- "beam up" player
            Timer.tween(1.5, {
                [self.player] = {y = -self.player.height - 16}
            })        
            :finish(function()
                self.startBeam = false
                gSounds['ufo']:play()

                -- after that, zip ufo off screen
                Timer.tween(1.5, {
                    [self.ufo] = { x = VIRTUAL_WIDTH, y = -self.ufo.height}
                })

                -- swtich to player level up screen
                :finish(function() 
                    self.player.stateMachine:change('idle')
                    gStateMachine:change("level-up", {player = self.player}) 
                end)
            end)
        end)
    end
end


function PlayerBoardShipState:render()
    self.player:render() 
    
    if self.startBeam then
        love.graphics.setColor(168/255, 50/255, 158/255, self.beamOpacity /255)
        love.graphics.polygon('fill', VIRTUAL_WIDTH / 2, 0, VIRTUAL_WIDTH / 2 - self.player.width * 2, VIRTUAL_HEIGHT, VIRTUAL_WIDTH / 2 + self.player.width * 2, VIRTUAL_HEIGHT)
        love.graphics.setColor(255/255,255/255,255/255, 255/255)
    end
    
    self.ufo:render()
end

