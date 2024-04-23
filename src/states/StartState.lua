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

    --man
    self.man = Entity {
        type = 'player',
        animations = ENTITY_DEFS['player'].animations,
        width = ENTITY_DEFS['player'].width,
        height = ENTITY_DEFS['player'].height,
        x = -32,
        y = VIRTUAL_HEIGHT - 64
    }

    -- start animations
    self.baby:changeAnimation('crawl-left')
    self.man:changeAnimation('walk-right')

    --balloon
    self.balloonPosition = {
        x = self.baby.x - BABY_BALLOON_OFFSET_X, 
        y = VIRTUAL_HEIGHT  - BABY_BALLOON_OFFSET_Y
    }

    -- for fading in and out titles
    self.titleOpacity = {valA = 0, valB = 0, valC = 0}
    self.animationComplete = false


    -- Baby Balloon and Man Animation: --

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
    Timer.tween(5, {
        [self.baby] = {x = VIRTUAL_WIDTH / 3},
        [self.balloonPosition] = {x = VIRTUAL_WIDTH / 3 - BABY_BALLOON_OFFSET_X}        
    })

    gSounds['walking']:setLooping(true)
    gSounds['walking']:play()
    -- move man to right (towards baby)
    Timer.tween(5, {
        [self.man] = {x = VIRTUAL_WIDTH / 3 - 30}
    })
    --once the man and baby meet in middle
    :finish(function ()
        gSounds['walking']:stop()
        -- wait half a sec then man steals balloon from baby
        Timer.after(1, function ()
            -- make it look like he grabbed it
            self.man:changeAnimation('idle')
            gSounds['steal']:play()

            -- slide balloon up to man's hand
            Timer.tween(.6, {
                [self.balloonPosition] = {y = self.balloonPosition.y - 16}
            })

            :finish(function () 
                -- man jumps over baby with balloon
                gSounds['jump']:play()
                Timer.tween(1.5, {
                    [self.man] = {x = VIRTUAL_WIDTH / 2, y = 16},
                    [self.balloonPosition] = {x = VIRTUAL_WIDTH / 2 + 11, y = 24}
                }) 

                -- man walks aways on fading title with balloon
                :finish(function ()
                    -- animate man walking with balloon
                    self.man:changeAnimation('walk-right')
                    gSounds['walking']:play()
                    
                    -- shift balloon to stay with man
                    Timer.every(.4, function ()
                        if self.man.currentAnimation:getCurrentFrame() == 1 then
                            self.balloonPosition.x = self.balloonPosition.x + 3
                        else
                            self.balloonPosition.x = self.balloonPosition.x - 3
                        end
                    end)

                    -- tween man and balloon position to right of screen
                    Timer.tween(3, {
                        [self.man] = {x = VIRTUAL_WIDTH},
                        [self.balloonPosition] = {x = VIRTUAL_WIDTH + 11}
                    })

                    -- fade in "Press Enter to Play" title
                    :finish(function ()
                        self.animationComplete = true
                        Timer.tween(2, {
                            [self.titleOpacity] = {valC = 1}
                        })
                        gSounds['walking']:stop()
                    end)
                end)
            end)
        end)
    end)

    
    -- Fade in titles
    Timer.tween(2, {
        [self.titleOpacity] = {valA = 1, valB = 1}
    })
    -- fade out all but "(balloons too!)" title
    :finish(function ()
        Timer.tween(6, {
            [self.titleOpacity] = {valA = 0}
        })

        -- fade "balloons too" title slowly
        Timer.after(6,function ()
            Timer.tween(5, {
                [self.titleOpacity] = {valB = 0}
            })
        end)
    end)
end


function StartState:update(dt) 
    if self.baby.x == VIRTUAL_WIDTH / 3 then
        self.baby:changeAnimation('idle')
    end

    self.baby:update(dt)

    if self.man.x > VIRTUAL_WIDTH then
        self.man:changeAnimation('idle')
    end

    self.man:update(dt)

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play')
    end
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