-- libraries
push = require 'lib/push'
Class = require 'lib/class'
Timer = require 'lib/knife.timer'

-- global
require 'src/entities/entity_defs'
require 'src/gameObjects/game_object_defs'
require 'src/constants'
require 'src/Util'

-- state machine
require 'src/StateMachine'

require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/PlayState'
require 'src/states/GameOverState'
require 'src/states/LevelUpState'
require 'src/states/WonGameState'

-- player states
require 'src/states/playerStates/PlayerIdleState'
require 'src/states/playerStates/PlayerWalkState'
require 'src/states/playerStates/PlayerFloatingState'
require 'src/states/playerStates/PlayerFallState'
require 'src/states/playerStates/PlayerBoardShipState'

-- entities
require 'src/entities/Entity'
require 'src/entities/Player'
require 'src/entities/Baby'
require 'src/entities/Mom'

-- objects
require 'src/gameObjects/GameObject'
require 'src/gameObjects/Purse'
require 'src/gameObjects/Balloon'
require 'src/gameObjects/Lollipop'

-- helper classes
require 'src/Animation'
require 'src/Hitbox'

gFonts = {
    ['xsmall'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['small'] = love.graphics.newFont('fonts/ArcadeAlternate.ttf', 10),
    ['small-title'] = love.graphics.newFont('fonts/ArcadeAlternate.ttf', 16),
    ['title'] = love.graphics.newFont('fonts/ArcadeAlternate.ttf', 32)
}

gTextures = {
    -- game objects (not level specific currently)
    ['balloons'] = love.graphics.newImage('graphics/balloons.png'),
    ['lollipops'] = love.graphics.newImage('graphics/lollipops.png'),
    ['bad-bag'] = love.graphics.newImage('graphics/bad-bag.png'),
    ['ufo'] = love.graphics.newImage('graphics/ufo.png'),
    -- LEVEL 1
    {
        -- backgrounds
        ['background'] = love.graphics.newImage('graphics/background-tall.png'),
        -- entities
        ['bad-baby'] = love.graphics.newImage('graphics/Bad-Baby2.png'),
        ['bad-man'] = love.graphics.newImage('graphics/bad-man-8.png'),
        ['bad-mom'] = love.graphics.newImage('graphics/Bad-Mom.png'),
        ['bad-stork'] = love.graphics.newImage('graphics/bad-stork.png'),
        ['bad-plane-mom'] = love.graphics.newImage('graphics/bad-plane-mom.png'),
        -- particle system
        ['particle'] = love.graphics.newImage('graphics/particle.png'),
    },
    -- LEVEL 2
    {
        -- space-background
        ['background'] = love.graphics.newImage('graphics/space-background.png'),
        -- entities
        ['space-baby'] = love.graphics.newImage('graphics/space-baby.png'),
        ['space-man'] = love.graphics.newImage('graphics/space-man-8.png'),
        ['space-mom'] = love.graphics.newImage('graphics/space-mom.png'),
        ['space-stork'] = love.graphics.newImage('graphics/space-stork.png'),
        ['space-plane-mom'] = love.graphics.newImage('graphics/space-plane-mom.png'),
    }
}

gFrames = {
    -- game objects (non level specific currently)
    ['balloons'] = GenerateQuads(gTextures['balloons'], 16, 32),
    ['lollipops'] = GenerateQuads(gTextures['lollipops'], 16, 32),
    ['bad-bag'] = GenerateQuads(gTextures['bad-bag'], 32, 32),
    ['ufo'] = GenerateQuads(gTextures['ufo'], 200, 64),
    -- LEVEL 1
    {    
        -- background
        ['background'] = GenerateQuads(gTextures[1]['background'], 272, 288),    
        -- entities
        ['bad-man'] = GenerateQuads(gTextures[1]['bad-man'], 32, 64),
        ['bad-baby'] = GenerateQuads(gTextures[1]['bad-baby'], 32, 32),
        ['bad-mom'] = GenerateQuads(gTextures[1]['bad-mom'], 32, 64),
        ['bad-stork'] = GenerateQuads(gTextures[1]['bad-stork'], 64, 32),
        ['bad-plane-mom'] = GenerateQuads(gTextures[1]['bad-plane-mom'], 64, 32)
    },
    -- LEVEL 2
    {
        -- space-background
        ['background'] = GenerateQuads(gTextures[2]['background'], 272, 288), 
        -- entities
        ['space-man'] = GenerateQuads(gTextures[2]['space-man'], 32, 64),
        ['space-baby'] = GenerateQuads(gTextures[2]['space-baby'], 32, 32),
        ['space-mom'] = GenerateQuads(gTextures[2]['space-mom'], 32, 64),
        ['space-stork'] = GenerateQuads(gTextures[2]['space-stork'], 64, 32),
        ['space-plane-mom'] = GenerateQuads(gTextures[2]['space-plane-mom'], 64, 32),
    }
}

-- wavs were made with bfxr, mp3s are from pixabay.com
gSounds = {
    -- main game music
    ['game-music-1'] = love.audio.newSource('sounds/game-music-1.mp3', 'static'),
    ['game-music-2'] = love.audio.newSource('sounds/game-music-2.mp3', 'static'),
    -- game event sounds
    ['walking'] = love.audio.newSource('sounds/walking.mp3', 'static'),
    ['steal'] = love.audio.newSource('sounds/steal.wav', 'static'),
    ['lollipop'] = love.audio.newSource('sounds/lollipop.wav', 'static'),    
    ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
    ['fly-away'] = love.audio.newSource('sounds/fly-away.wav', 'static'),
    ['falling'] = love.audio.newSource('sounds/falling.wav', 'static'),
    ['hit-ground'] = love.audio.newSource('sounds/hit-ground.wav', 'static'),
    ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
    ['hit-wall'] = love.audio.newSource('sounds/hit-wall.wav', 'static'),
    -- plane mom sounds
    ['plane'] = love.audio.newSource('sounds/plane.wav', 'static'),
    ['zap'] = love.audio.newSource('sounds/zap.wav', 'static'),
    -- ufo sounds
    ['space-ship'] = love.audio.newSource('sounds/space-ship.wav', 'static'),
    ['ufo'] = love.audio.newSource('sounds/ufo.wav', 'static'),
    ['beam-up'] = love.audio.newSource('sounds/beam-up3.wav', 'static'),
    -- baby sounds
    ['baby-cry-1'] = love.audio.newSource('sounds/baby-cry-1.mp3', 'static'),
    ['baby-cry-2'] = love.audio.newSource('sounds/baby-cry-2.mp3', 'static'),
    ['baby-cry-3'] = love.audio.newSource('sounds/baby-cry-3.mp3', 'static'),
    -- mom sounds
    ['mad-mom-1'] = love.audio.newSource('sounds/mad-mom-1.mp3', 'static'),
    ['mad-mom-2'] = love.audio.newSource('sounds/mad-mom-2.mp3', 'static'),
    ['mad-mom-3'] = love.audio.newSource('sounds/mad-mom-3.mp3', 'static'),
    ['mad-mom-4'] = love.audio.newSource('sounds/mad-mom-4.mp3', 'static'),
    ['mad-mom-5'] = love.audio.newSource('sounds/mad-mom-5.mp3', 'static'),
    ['mad-mom-6'] = love.audio.newSource('sounds/mad-mom-6.mp3', 'static'),
}
