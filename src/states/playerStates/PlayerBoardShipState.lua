PlayerBoardShipState = Class{__includes = BaseState}

function PlayerBoardShipState:init(playState)
    self.player = playState.player

    self.player.gravity = 0

    self.startBeam = false
    self.beamOpacity = 100

    self.ufo = GameObject {
        object_def = OBJECT_DEFS['ufo'],
        x = -OBJECT_DEFS['ufo'].width,
        y = -OBJECT_DEFS['ufo'].height,
        isCarried = false
    }

    Timer.tween(2, {
        [self.ufo] = {x = VIRTUAL_WIDTH / 2 - self.ufo.width / 2, y = 0},
        [self.player] = {x = VIRTUAL_WIDTH / 2 - self.player.width / 2, y = VIRTUAL_HEIGHT - self.player.height}
    })
    :finish(function () 
        self.startBeam = true
    end)
end


function PlayerBoardShipState:update(dt)
    self.player:update(dt)
    self.ufo:update(dt)

    if self.startBeam then 
        Timer.after(2, function ()
            for k, balloon in pairs(self.player.items) do
                if balloon.y > 0 then
                    Timer.tween(3, { 
                        [balloon] = {y = 0}
                    })
                end
            end
            Timer.tween(3, {
                [self.player] = {y = 0}
            })
        end)
    end

    if self.beamOpacity < 215 then
        self.beamOpacity = self.beamOpacity + 5
    else
        self.beamOpacity = 0
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

