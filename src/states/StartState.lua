StartState = Class{__includes = BaseState}

function StartState:init()
    --baby
    self.baby = Entity {
        type = 'baby',
        animations = ENTITY_DEFS['baby'].animations,
        width = ENTITY_DEFS['baby'].width,
        height = ENTITY_DEFS['baby'].height,
        x = VIRTUAL_WIDTH - 10,
        y = VIRTUAL_HEIGHT - 32
    }

    self.baby:changeAnimation('crawl-left')

    --man
    self.man = Entity {
        type = 'player',
        animations = ENTITY_DEFS['player'].animations,
        width = ENTITY_DEFS['player'].width,
        height = ENTITY_DEFS['player'].height,
        x = -32,
        y = VIRTUAL_HEIGHT - 64
    }

    self.man:changeAnimation('walk-right')

    --balloon
    self.balloonPosition = {
        x = self.baby.x - BABY_BALLOON_OFFSET_X, 
        y = VIRTUAL_HEIGHT  - BABY_BALLOON_OFFSET_Y
    }

    -- for fading in and out titles
    self.titleOpacity = {valA = 0, valB = 0, valC = 0}
    self.animationComplete = false

    -- baby crawls into scene with balloon
    Timer.every(.4, function() 
        -- animate balloon to go with baby until they reach destination 
        if self.baby.x > VIRTUAL_WIDTH / 3 then
            if self.baby.currentAnimation:getCurrentFrame() == 1 then
                self.balloonPosition.y = self.balloonPosition.y + 4
            else
                self.balloonPosition.y = self.balloonPosition.y - 4
            end
        end
    end)

    -- Move baby and balloon to left (towards man)
    Timer.tween(4, {
        [self.baby] = {x = VIRTUAL_WIDTH / 3},
        [self.balloonPosition] = {x = VIRTUAL_WIDTH / 3 - BABY_BALLOON_OFFSET_X}        
    })

    -- move man to right (towards baby)
    Timer.tween(6, {
        [self.man] = {x = VIRTUAL_WIDTH / 3 - 30}
    }):finish(function ()
        self.man:changeAnimation('idle')
    end)
    
    -- Fade in titles
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
            Timer.tween(.5, {
                [self.balloonPosition] = {y = self.balloonPosition.y - 16}
            })

            -- man jumps over baby with balloon
            :finish(function ()
                Timer.tween(1, {
                    [self.man] = {x = VIRTUAL_WIDTH / 2 - 32, y = 16},
                    [self.balloonPosition] = {x = VIRTUAL_WIDTH / 2 + BABY_BALLOON_OFFSET_X - 34, y = 18}
                })
                -- man walks aways on fading title with balloon
                :finish(function ()
                    -- animate man walking with balloon
                    self.man:changeAnimation('walk-right')
                    Timer.every(.4, function ()
                        if self.man.currentAnimation:getCurrentFrame() == 1 then
                            self.balloonPosition.y = self.balloonPosition.y + 4
                        else
                            self.balloonPosition.y = self.balloonPosition.y - 4
                        end
                    end)
                    -- tween man and balloon position to right of screen
                    Timer.tween(3, {
                        [self.man] = {x = VIRTUAL_WIDTH},
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
    if self.baby.x == VIRTUAL_WIDTH / 3 then
        self.baby:changeAnimation('idle')
    end

    self.baby:update(dt)

    -- if self.man.x < VIRTUAL_WIDTH / 3 - 30 then
        self.man:update(dt)
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
    self.baby:render()
    
    -- draw man
    self.man:render()

end