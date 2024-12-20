StartState = Class{__includes = BaseState}

function StartState:init()
    -- init baby
    self.baby = Entity {
        type = 'baby',
        entity_def = ENTITY_DEFS[1]['baby'],
        x = VIRTUAL_WIDTH - 10,
        y = VIRTUAL_HEIGHT - 36,
        level = 1
    }

    -- init man
    self.man = Entity {
        type = 'player',
        entity_def = ENTITY_DEFS[1]['player'],
        x = -32,
        y = VIRTUAL_HEIGHT - 68,
        level = 1
    }

    -- init balloon
    self.balloonPosition = {
        x = self.baby.x - BABY_BALLOON_OFFSET_X, 
        y = self.baby.y + BABY_BALLOON_OFFSET_Y
    }

    -- for fading in and out titles
    self.titleOpacity = {valA = 0, valB = 0, valC = 0}
    self.animationComplete = false

    -- play animations
    self:playIntroAnimation()
    self:playTitleAnimation()
end


function StartState:update(dt)
    -- change animation to idle when baby and man get to their destinations
    if self.baby.x == VIRTUAL_WIDTH / 3 then
        self.baby:changeAnimation('idle-left')
    end

    if self.man.x > VIRTUAL_WIDTH then
        self.man:changeAnimation('idle-right')
    end

    -- update entities
    self.baby:update(dt)
    self.man:update(dt)

    -- change to play state
    if wasEnterPressed() then
        Timer.clear()
        gSounds['walking']:stop()
        gStateMachine:change('play', {player = nil})
    end
end


function StartState:render()
    -- draw Titles
    love.graphics.setFont(gFonts['small-title'])
    love.graphics.setColor(184/255, 149/255, 208/255, self.titleOpacity.valA)
    love.graphics.printf('It\'s Just Like', 0, 4, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(0, 170/255, 255/255, self.titleOpacity.valA)
    love.graphics.printf('Stealing Candy from Babies!', 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1,1,1,1)

    love.graphics.setFont(gFonts['small-title'])
    love.graphics.setColor(184/255, 149/255, 208/255, self.titleOpacity.valB)
    love.graphics.printf('(Balloons Too!!)', 48, VIRTUAL_HEIGHT / 2 + 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1,1,1,1)

    if self.animationComplete then
        love.graphics.setFont(gFonts['title'])
        love.graphics.setColor(0, 170/255, 255/255, self.titleOpacity.valC)
        love.graphics.printf('Press Enter\nto Play!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1,1,1,1)
    end

    -- draw balloon
    love.graphics.draw(gTextures['balloons'], gFrames['balloons'][math.random(#OBJECT_DEFS['balloon'].frames)], 
        self.balloonPosition.x, 
        self.balloonPosition.y)
    
    --draw baby
    self.baby:render()
    
    -- draw man
    self.man:render()

    -- print credits
    love.graphics.setFont(gFonts['xsmall'])
    love.graphics.setColor(0, 170/255, 255/255, 1)
    love.graphics.printf('Created by Chris Patchett 2024, All rights reserved', 0, VIRTUAL_HEIGHT - 8, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1, 1, 1, 1)

end


function StartState:playIntroAnimation() 
    -- start animations
    self.baby:changeAnimation('crawl-left')
    self.man:changeAnimation('walk-right')

    self:playBabyAnimation()
    self:playManAnimation()
end


function StartState:playBabyAnimation()
    -- Move baby and balloon to left (towards man)
    Timer.tween(5, {
        [self.baby] = {x = VIRTUAL_WIDTH / 3},
        [self.balloonPosition] = {x = VIRTUAL_WIDTH / 3 - BABY_BALLOON_OFFSET_X}        
    })
    :finish(function () self.baby.walkSpeed = 0 end)
end


function StartState:playManAnimation()
    -- start sound
    gSounds['walking']:setLooping(true)
    gSounds['walking']:play()

    -- move man to right (towards baby)
    Timer.tween(5, {
        [self.man] = {x = VIRTUAL_WIDTH / 3 - 29}
    })
    --once the man and baby meet in middle
    :finish(function () self:playStealBalloonAnimation() end)
end


function StartState:playStealBalloonAnimation() 
    gSounds['walking']:stop()
    -- wait a sec then man steals balloon from baby
    Timer.after(1, function () self:playGrabAnimation() end)
end


function StartState:playGrabAnimation()
    self.man:changeAnimation('idle-right')
    gSounds['steal']:play()
    gSounds['baby-cry-3']:play()

    -- slide balloon up to man's hand
    Timer.tween(.6, {
        [self.balloonPosition] = {y = self.balloonPosition.y - 18}
    })
    :finish(function () self:playJumpAndWalkAnimation() end)
end


function StartState:playJumpAndWalkAnimation()
    -- man jumps over baby with balloon
    gSounds['jump']:play()
    Timer.tween(1.5, {
        [self.man] = {x = VIRTUAL_WIDTH / 2 - 39, y = 16},
        [self.balloonPosition] = {x = VIRTUAL_WIDTH / 2 - 18, y = 18}
    }) 
    -- man walks aways on fading title with balloon
    :finish(function () self:playManWalksAwayAnimation() end)
end


function StartState:playManWalksAwayAnimation()
    -- animate man walking with balloon
    self.man:changeAnimation('walk-right')
    gSounds['walking']:play()

    -- tween man and balloon position to right of screen
    Timer.tween(3, {
        [self.man] = {x = VIRTUAL_WIDTH},
        [self.balloonPosition] = {x = VIRTUAL_WIDTH + 22}
    })
    :finish(function() self:fadeInPressEnterTitle() end)
end


function StartState:fadeInPressEnterTitle()
    self.animationComplete = true
    Timer.tween(2, {
        [self.titleOpacity] = {valC = 1}
    })
    gSounds['walking']:stop()
end


function StartState:playTitleAnimation()
    -- Fade in titles
    Timer.tween(2, {
        [self.titleOpacity] = {valA = 1, valB = 1}
    })
    -- fade out all but "(balloons too!)" title
    :finish(function ()
        Timer.tween(7, {
            [self.titleOpacity] = {valA = 0}
        })

        -- fade "balloons too" title slowly
        Timer.after(6.5,function ()
            Timer.tween(5, {
                [self.titleOpacity] = {valB = 0}
            })
        end)
    end)
end