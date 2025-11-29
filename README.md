# spriteanimations
  Sprite Animations and rendering engine for 2.5D games in Nico.

  Handles sprite animations, ysorting/zindexing, with text billboard support.

<p align="center">
  <img src="https://github.com/RattleyCooper/spriteanimations/blob/main/assets/game.gif?raw=true">
</p>

## Install

`nimble install https://github.com/RattleyCooper/spriteanimations`

## Example

```nim
import nico
import vmath
import framecounter
import spriteanimations

const orgName = "RattleyCooper"
const appName = "spriteanimations"

type
  Player = ref object
    sprite: Sprite
    x: int
    y: int

# Play animations at 6 frames per second
var animationClock = FrameCounter(fps:6)

# Run things on Player's at 60fps
var gameClock = FrameCounter(fps: 60)

# Define the bounds/frames of the animations.
# and give them names to use when we want to
# display them.
var playerIdleAnimation = newAnimation(
  "idle", # Animation name
  0,      # Starting frame
  24,     # Frame width
  24,     # Frame height
  4       # Animation frames
)
var playerRunAnimation = newAnimation("run", 3, 24, 24, 13)

# If we are creating Animation's for something
# that shares animation details we can re-use the
# same Animation object, as it's only used to
# store information about the animation frames
# on the spritesheet. The Sprite will handle
# tracking which frame should be displayed, and
# which index that nico will pull the spritesheet
# from. 

# Create our player sprite
var playerSprite = newSprite(
  "player", 
  "assets/character0.png",
  0, # index of spritesheet in nico
  ivec2(50, 50), 
  playerIdleAnimation,
  playerRunAnimation
)

# Create player2 sprite
var player2Sprite = newSprite(
  "player2",
  "assets/character1.png",
  1, # index of spritesheet in nico
  ivec2(100, 50), 
  playerIdleAnimation,
  playerRunAnimation
)

# Create our player
var player = Player(x: 50, y: 50, sprite: playerSprite)
var player2 = Player(x: 100, y: 50, sprite: player2Sprite)

# Add our player sprite to the renderer, 
# which will handle drawing/ysorting/zindex
var renderer = newRenderer(playerSprite, player2Sprite)

proc updatePlayerAnimations(player: Player) =
  # The sprite's callback function for updating
  # the sprite's current animation frame.
  # You can use any method you want, but calling
  # Sprite.update() will move the animation to 
  # the next frame.
  animationClock.run every(1) do():
    player.sprite.update()

proc lockPlayerSprite(player: Player) =
  # Lock sprite to player position on every frame.
  gameClock.run every(1) do():
    player.sprite.x = player.x
    player.sprite.y = player.y

proc gameInit() =
  # Call initSpritesheets to load spritesheets. Deduplication happens
  # automatically, so if something shares a spritesheet the
  # spritesheet will only be loaded once, and the index that
  # nico uses to set/load will be updated automatically.
  renderer.initSpritesheets()
  player.sprite.play("idle")
  player2.sprite.play("idle")

  # Register our callbacks to update animations
  updatePlayerAnimations(player)
  updatePlayerAnimations(player2)

  # Register our callbacks to lock sprites to position
  lockPlayerSprite(player)
  lockPlayerSprite(player2)

proc gameUpdate(dt: float32) =
  if btn(pcLeft):
    player.x -= 1
    player.sprite.play("run")
    player.sprite.hflip = true
  elif btn(pcRight):
    player.x += 1
    player.sprite.play("run")
    player.sprite.hflip = false
  else:
    player.sprite.play("idle")

  # Call player callbacks.
  gameClock.tick()

proc gameDraw() =
  cls()

  # Draw current animation frame for each sprite
  renderer.draw() # renderer.drawYSorted() if ysorted

  # The FrameCounter will call each callback
  # 6 times per second, animating our sprite.
  animationClock.tick()

nico.init(orgName, appName)
nico.createWindow(appName, 200, 180, 3, false)
nico.run(gameInit, gameUpdate, gameDraw)
```
