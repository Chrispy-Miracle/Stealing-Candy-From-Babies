# Stealing Candy from Babies!
## A Final Project for Harvard University's CS50G-Intro to Game Development
### Created by Chris Patchett 2024

## Overview
Stealing Candy from Babies is a retro styled video game built with the Lua programming language with the Love2d game framework.  In what appears at first to be a simple side scroller, the player must
continue stealing candy from babies in order to maintain their sugar rush.
If the player's sugar rush, like health in many games, reaches zero, the game is over.

Complicating a task that should be "as easy as stealing candy from a baby", 
whenever the player messes with a baby, be it through stealing candy, balloons (more on this later) 
or simply bumping the baby with their feet, the baby's mom will rush out and 
attempt to attack the offending player with her purse.

The player is also able to steal balloons from the babies which results in a strange twist of game mechanics.
Suddenly, upon collecting enough balloons, gravity is overcome and the player begins to float away.
As the ground disappears, what once appeared as a side scrolling game is now revealed to have an upward scrolling gamestate. As the player floats away, they must still steal candy in order to survive, but now when they steal from the babies, the offended moms are now piloting planes and zoom in to kamikaze attack the player.
Further complicating the matter, the babies are now carried through the sky by storks whose beaks can pop the player's balloons. 

If enough of the player's balloons pop, another new game mechanic is introduced: Falling!
However high the player has floated, without enough balloons to keep them afloat, they begin
a descent back to the ground, in which they must try to steal enough balloons to rise up again 
as well as enough candy to keep that sugar rush going.
Without enough balloons to float and a diminishing sugar rush, falling all the way to the ground may well 
be the player's demise, damage being relative to the number of balloons held, or lack thereof.

However, if the player can keep up their sugar rush whilst dodging plane moms and avoiding the stork's beaks popping their balloons, after floating up enough screens, the player is taken away.... TO THE MOON! 
In the game's current state, if the player can navigate to the end of the second level successfully, 
the game is won.  Good Luck! 
***

***
## Fonts, Graphics, Sounds, Libraries
### Fonts: 
    * Arcade Alternate, which was borrowed from CS50G's Mario project
    * Font, which was borrowed from CS50G's Pokemon project

### Graphics:
    I personally made all the graphics/spritesheets for this game using GIMP (Hooray for open source!)

### Sounds:
    The game sounds were all created using BFXR or downloaded for free from <pixabay.com>

### Libraries:
    Knife library was used exclusively for it's Timer class.  Class and Push libraries also utilized.

***
## Entities:
### Entity Base Class:
    All game entities have level dependent data pulled from the entity_defs, keeps track of basic entity info, including animations
### Baby:  
    Upon being spawned, babies have a random chance of having a lollipop or a balloon, if the player is floating the baby is spawned as a stork carrying a baby. Messing with any baby causes a Mom to spawn
### Mom:
    When a baby is stepped on or stolen from, a mom rushes over to the player and attacks 
### Player:  
    The most complex of the entity classes, the player class includes functions for leveling up, checking balloon pops, stealing items and crashing down to the ground.

***
## Game Objects:
### Game Object Base Class:
    Allows creation of game objects using the data contained in game_object_defs. Offset is adjusted here for when objects are carried by different entities, potentially in different orientations.  Updates a few object specific scenarios, namely calculating and updating the objects hitboxes 

***
## Game States:
### Base State/State Machine:
    These are both borrowed directly from class. Base State is used as a base for all other states, whether game or player states.  State Machine allows transfer from one state to another, whether game states or player states
### Start State: 
    This is the title screen, which includes an animation of a man stealing a balloon from a baby, mostly accomplished by leveraging the knife.timer library
### Play State:
    This is the main gamestate, wherein the player state machine is held and updated. This class sets up main game functions including the player and the game level.  Included is a SpawnBabies function which sets a timer to procedurally generate babies. Tables for both babies and moms are held, updated and rendered from here.
### Game Over State:
    This is a simple screen to display game stats once the player's sugar rush has reached 0
    Time, damage, candies stolen and balloons stolen are totalled from each level and rendered here.
    Pressing enter here will restart the game
### Level Up State
    Almost identical to the Game Over State, except only game stats from the cleared level are compiled.
    Pressing enter in this state will take you to either the next level or the Won Game State
### Won Game State
    This state is almost identical to the Game Over state in that stats from the entire game are totalled from all levels.
    Pressing enter here will exit the game.

***
## Player States:
### Player Idle State:
    The simplest of the player states.  Changes to walk state if any directional buttons are pushed
### Player Walk State:
    Allows for player movement in four directions. Returns player to idle if no directional buttons are currently pressed.
    Restricts movement and causes damage if player tries to walk off screen to left, scrolls back to left if player goes too far to the right. Changes to float state if 4 or more balloons are held by player.
### Player Floating State:
    Stops scrolling on X axis and begins scrolling on Y axis, with player's gravity dependent on number of ballons carried. 
    Checks for balloon pops and can change to falling state if if player has less than 4 balloons.  Checks for player reaching top screen of level and can also change to board ship state if player has floated up a sufficient number of screens.  Also allows for movement in all directions, although 1/2 speed of walking on Y axis.  If player floats off screen right or left, they appear on the opposite side of scree. Same is true of floating past the top of the screen; player appears at bottom.
### Player Falling State:
    If player was floating and has balloons popped (and has 3 or less), they begin to fall.  Fall speed is relative to the number of balloons player carries.  Player can no longer use direction pad to influence Y axis movement.  They can, however, still float off screen to the left or right.  If player has 4 balloons, they transfer back to float state. If the player is more than one screen above the ground, they appear at the top of screen if they go past the bottom.  If the player is less than one screen above the ground, crash to ground is initiated, damaging player more the fewer balloons they carry. 
### Player Board Ship State:
    This is the end of level state.  If the player successfully floats up required number of screens for the current level, directional input is no longer allowed and an animation plays wherein the player will be beamed up by a ufo and taken to level up state, after which they will either go to the playstate and start the next level or, to the Won game state if the game is completed.

***
## Animation and HitBoxes

***
## Constants and Dependencies

***
## Util and Main


***
***
### Thanks So Much for Looking!