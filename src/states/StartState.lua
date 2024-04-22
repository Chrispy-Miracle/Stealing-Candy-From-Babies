StartState = Class{__includes = BaseState}

function StartState:init()
    --baby
    self.babyPosition = {x = VIRTUAL_WIDTH - 10 }
    self.babyFrame = {frame = 1 }

    --man
    self.manPosition = {x = -32, y = VIRTUAL_HEIGHT - 64}
    self.manFrame = {frame = 1 }

    --balloon
    self.balloonPosition = {
        x = self.babyPosition.x - BABY_BALLOON_OFFSET_X, 
        y = VIRTUAL_HEIGHT  - BABY_BALLOON_OFFSET_Y
    }

    -- for fading in and out titles
    self.titleOpacity = {valA = 0, valB = 0, valC = 0}
    self.animationComplete = false

    -- baby crawls into scene with balloon
    Timer.every(.4, function() 
        -- animate baby and balloon until they reach destination 
        if self.babyPosition.x > VIRTUAL_WIDTH / 3 then
            if self.babyFrame.frame == 1 then 
                self.babyFrame.frame = 2 
                self.balloonPosition.y = self.balloonPosition.y + 3
            else 
                self.babyFrame.frame = 1 
                self.balloonPosition.y = self.balloonPosition.y - 3
            end
        end

        -- Animate man until destination is reached
        if self.manPosition.x < VIRTUAL_WIDTH / 3 - 30 then
            if self.manFrame.frame == 1 then 
                self.manFrame.frame = 2 
            else 
                self.manFrame.frame = 1 
            end
        end
    end)

    -- Move baby and balloon to left (towards man)
    Timer.tween(4, {
        [self.babyPosition] = {x = VIRTUAL_WIDTH / 3},
        [self.balloonPosition] = {x = VIRTUAL_WIDTH / 3 - BABY_BALLOON_OFFSET_X}
    })

    -- move man to right (towards baby)
    Timer.tween(6, {
        [self.manPosition] = { x = VIRTUAL_WIDTH / 3 - 30}
    })
    
    -- Fade in titles (begin stage 2 of animation)
    Timer.tween(2, {
        [self.titleOpacity] = {valA = 1, valB = 1}
    })
    -- fade out all but "(balloons too!)" title
    :finish(function ()
        Timer.tween(5, {
            [self.titleOpacity] = {valA = 0}
        })
        -- fade "balloons too" title slowly
        Timer.after(6,function ()
            Timer.tween(5, {
                [self.titleOpacity] = {valB = 0}
            })

            -- man steals balloon from baby
            self.manFrame.frame = 2
            Timer.tween(.5, {
                [self.balloonPosition] = {y = self.balloonPosition.y - 20}
            })
            -- man jumps over baby with balloon
            :finish(function ()
                Timer.tween(1, {
                    [self.manPosition] = {x = VIRTUAL_WIDTH / 2 - 32, y = 16},
                    [self.balloonPosition] = {x = VIRTUAL_WIDTH / 2 + BABY_BALLOON_OFFSET_X - 4 - 32, y = 16}
                })
                -- man walks aways on fading title with balloon
                :finish(function ()
                    -- animate man walking with balloon
                    Timer.every(.4, function ()
                        if self.manFrame.frame == 1 then
                            self.manFrame.frame = 2
                            self.balloonPosition.y = self.balloonPosition.y - 4
                        else 
                            self.manFrame.frame = 1
                            self.balloonPosition.y = self.balloonPosition.y + 4
                        end
                    end)
                    -- tween man and balloon position to right of screen
                    Timer.tween(3, {
                        [self.manPosition] = {x = VIRTUAL_WIDTH},
                        [self.balloonPosition] = {x = VIRTUAL_WIDTH + BABY_BALLOON_OFFSET_X - 2}
                    })
                    -- fade in "Press Enter to Play" title
                    :finish(function ()
                        self.animationComplete = true
                        Timer.tween(2, {
                            [self.titleOpacity] = {valC = 1}
                        })
                    end)

                end)
            end)
            
        end)
    end)
end


function StartState:update(dt) 
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

    if self.animationComplete then
        love.graphics.setFont(gFonts['title'])
        love.graphics.setColor(0, 170/255, 255/255, self.titleOpacity.valC)
        love.graphics.printf('Press Enter\nto Play!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(255, 255, 255, 255)
    end

    -- draw balloon
    love.graphics.draw(gTextures['bad-balloon'], gFrames['bad-balloon'][1], 
        self.balloonPosition.x, 
        self.balloonPosition.y)
    --draw baby
    love.graphics.draw(gTextures['bad-baby'], gFrames['bad-baby'][self.babyFrame.frame], self.babyPosition.x, VIRTUAL_HEIGHT - 32)
    
    -- draw man
    love.graphics.draw(gTextures['bad-man'], gFrames['bad-man'][self.manFrame.frame], self.manPosition.x, self.manPosition.y)
    

end