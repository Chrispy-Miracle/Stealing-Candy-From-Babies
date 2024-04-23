push = require 'lib/push'
Class = require 'lib/class'
Timer = require 'lib/knife.timer'

require 'src/constants'
require 'src/Util'

require 'src/StateMachine'

require 'src/Animation'

require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/PlayState'

require 'src/entity_defs'
require 'src/Entity'


gFonts = {
    ['small-title'] = love.graphics.newFont('fonts/ArcadeAlternate.ttf', 16),
    ['title'] = love.graphics.newFont('fonts/ArcadeAlternate.ttf', 32)
}


gTextures = {
    ['background'] = love.graphics.newImage('graphics/background.png'),
    ['bad-baby'] = love.graphics.newImage('graphics/Bad-Baby2.png'),
    ['bad-balloon'] = love.graphics.newImage('graphics/bad-balloon.png'),
    ['bad-man'] = love.graphics.newImage('graphics/Bad-Man3.png')
}


gFrames = {
    ['background'] = GenerateQuads(gTextures['background'], 256, 144),
    ['bad-baby'] = GenerateQuads(gTextures['bad-baby'], 32, 32),
    ['bad-balloon'] = GenerateQuads(gTextures['bad-balloon'], 32, 32),
    ['bad-man'] = GenerateQuads(gTextures['bad-man'], 32, 64)
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


