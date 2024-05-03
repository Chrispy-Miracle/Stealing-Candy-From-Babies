-- libraries
push = require 'lib/push'
Class = require 'lib/class'
Timer = require 'lib/knife.timer'

-- global
require 'src/entity_defs'
require 'src/game_object_defs'
require 'src/constants'
require 'src/Util'

-- state machine
require 'src/StateMachine'

require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/PlayState'
require 'src/states/GameOverState'
require 'src/states/LevelUpState'

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
require 'src/GameObject'

-- helper classes
require 'src/Animation'


gFonts = {
    ['small'] = love.graphics.newFont('fonts/ArcadeAlternate.ttf', 10),
    ['small-title'] = love.graphics.newFont('fonts/ArcadeAlternate.ttf', 16),
    ['title'] = love.graphics.newFont('fonts/ArcadeAlternate.ttf', 32)
}


gTextures = {
    ['background'] = love.graphics.newImage('graphics/background-tall.png'),
    ['bad-baby'] = love.graphics.newImage('graphics/Bad-Baby2.png'),
    ['balloons'] = love.graphics.newImage('graphics/balloons.png'),
    ['lollipops'] = love.graphics.newImage('graphics/lollipops.png'),
    ['bad-man'] = love.graphics.newImage('graphics/bad-man6.png'),
    ['bad-mom'] = love.graphics.newImage('graphics/Bad-Mom.png'),
    ['bad-stork'] = love.graphics.newImage('graphics/bad-stork.png'),
    ['bad-balloon'] = love.graphics.newImage('graphics/bad-balloon.png'),
    ['bad-bag'] = love.graphics.newImage('graphics/bad-bag.png'),
    ['bad-plane-mom'] = love.graphics.newImage('graphics/bad-plane-mom.png'),
    ['ufo'] = love.graphics.newImage('graphics/ufo.png'),
    ['space-background'] = love.graphics.newImage('graphics/space-background.png'),

}


gFrames = {
    ['background'] = GenerateQuads(gTextures['background'], 272, 288),
    ['bad-baby'] = GenerateQuads(gTextures['bad-baby'], 32, 32),
    ['balloons'] = GenerateQuads(gTextures['balloons'], 32, 32),
    ['lollipops'] = GenerateQuads(gTextures['lollipops'], 16, 32),
    ['bad-man'] = GenerateQuads(gTextures['bad-man'], 32, 64),
    ['bad-mom'] = GenerateQuads(gTextures['bad-mom'], 32, 64),
    ['bad-stork'] = GenerateQuads(gTextures['bad-stork'], 64, 32),
    ['bad-bag'] = GenerateQuads(gTextures['bad-bag'], 32, 32),
    ['bad-plane-mom'] = GenerateQuads(gTextures['bad-plane-mom'], 64, 32),
    ['ufo'] = GenerateQuads(gTextures['ufo'], 200, 64),
    ['space-background'] = GenerateQuads(gTextures['space-background'], 272, 288),
}


gSounds = {
    ['bonus'] = love.audio.newSource('sounds/bonus.wav', 'static'),
    ['falling'] = love.audio.newSource('sounds/falling.wav', 'static'),
    ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
    ['hit-ground'] = love.audio.newSource('sounds/hit-ground.wav', 'static'),
    ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'), 
    ['steal'] = love.audio.newSource('sounds/steal.wav', 'static'), 
    ['walking'] = love.audio.newSource('sounds/walking.wav', 'static')
}


