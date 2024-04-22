StartState = Class{__includes = BaseState}

function StartState:init()
    self.babyPosition = {x = VIRTUAL_WIDTH - 10 }

    self.balloonPosition = {x = self.babyPosition.x, y = 0}
    self.manPosition = {x = -32, y = 0}

    self.babyFrame = {frame = 1 }
    self.manFrame = {frame = 1 }
 
    self.titleOpacity = {valA = 0, valB = 0}
    
    Timer.tween(2, {
        [self.titleOpacity] = {valA = 1, valB = 1}
    }):finish(function ()
        Timer.tween(5, {
            [self.titleOpacity] = {valA = 0}
        })
        Timer.after(5,function ()
            Timer.tween(3, {
                [self.titleOpacity] = {valB = 0}
            })
        end)
    end)

    
    Timer.every(.4, function() 
        if self.babyPosition.x > VIRTUAL_WIDTH / 3 then
            if self.babyFrame.frame == 1 then 
                self.babyFrame.frame = 2 
            else 
                self.babyFrame.frame = 1 
            end
        end
        if self.manPosition.x < VIRTUAL_WIDTH / 3 - 30 then
            if self.manFrame.frame == 1 then 
                self.manFrame.frame = 2 
            else 
                self.manFrame.frame = 1 
            end
        end
    end)

    Timer.tween(4, {
        [self.babyPosition] = {x = VIRTUAL_WIDTH / 3}
    })



    Timer.tween(6, {
        [self.manPosition] = { x = VIRTUAL_WIDTH / 3 - 30}
    })

end

function StartState:update(dt)
    -- if self.babyPosition.x == VIRTUAL_WIDTH / 3 then
    --     Timer.clear(self.babyTimers)
    -- end
              

end

function StartState:render()
    -- draw Title
    love.graphics.setFont(gFonts['small-title'])
    love.graphics.setColor(184/255, 149/255, 208/255, self.titleOpacity.valA)
    love.graphics.printf('It\'s Just Like', 0, 4, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(0, 170/255, 255/255, self.titleOpacity.valA)
    love.graphics.printf('Stealing Candy from Babies!', 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.setFont(gFonts['small-title'])
    love.graphics.setColor(184/255, 149/255, 208/255, self.titleOpacity.valB)
    love.graphics.printf('(Balloons Too!!)', 48, VIRTUAL_HEIGHT / 2 + 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, 255)

    -- draw balloon
    love.graphics.draw(gTextures['bad-balloon'], gFrames['bad-balloon'][1], self.babyPosition.x - BABY_BALLOON_OFFSET_X, VIRTUAL_HEIGHT  - BABY_BALLOON_OFFSET_Y)
    --draw baby
    love.graphics.draw(gTextures['bad-baby'], gFrames['bad-baby'][self.babyFrame.frame], self.babyPosition.x, VIRTUAL_HEIGHT - 32)
    
    -- draw man
    love.graphics.draw(gTextures['bad-man'], gFrames['bad-man'][self.manFrame.frame], self.manPosition.x, VIRTUAL_HEIGHT - 64)
    

end