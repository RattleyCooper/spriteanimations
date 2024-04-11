# spriteanimations
 Frame Locked Sprite Animations for Nico

## Install

`nimble install https://github.com/RattleyCooper/spriteanimations`

## Example

```nim
import nico
import vmath
import tables
import framecounter

type
  Player = ref object
    sprite: Sprite
    x: int
    y: int


# Play animations at 6 frames per second
var animationClock = FrameCounter[Sprite](fps:6)

# Run things on Player's at 60fps
var playerClock = FrameCounter[Player](fps: 60)

# Create each animation.
var idleAnimation = newAnimation("idle", 0, 0, 24, 24, 4)
var runAnimation = newAnimation("run", 0, 3, 24, 24, 13)

# If we are creating Animation's for something
# that shares a spritesheet we can re-use the
# same Animation object, as it's only used to
# store information about the animation frames
# on the spritesheet. The Sprite will handle
# tracking which frame should be displayed.

# Create our sprite
var playerSprite = newSprite(
  "player", 
  ivec2(5, 5), 
  idleAnimation,
  runAnimation
)

var player = Player(x: 50, y: 50, sprite: playerSprite)

var delta: float32

# Create a renderer, which handles drawing/ysorting/zindex
var renderer = newRenderer(playerSprite)

# The sprite's callback function for updating
# the sprite's current animation frame.
animationClock.run playerSprite.every(1) do(sp: var Sprite):
  sp.update()

# Lock sprite to player position on every frame.
playerClock.run player.every(1) do(p: var Player):
  p.sprite.x = p.x
  p.sprite.y = p.y


proc gameInit() =
  loadSpriteSheet(0, "character0.png", 24, 24)
  player.sprite.play("idle")

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
  delta = dt

  # Call player callbacks.
  playerClock.tick(dt)

proc gameDraw() =
  cls()

  # Draw current animation frame for each sprite
  renderer.draw(delta)

  # The FrameCounter will call each callback
  # 6 times per second, animating our sprite.
  animationClock.tick(delta)

nico.init(orgName, appName)
nico.createWindow(appName, 200, 180, 3, false)
nico.run(gameInit, gameUpdate, gameDraw)
```
