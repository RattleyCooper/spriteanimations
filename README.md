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

# Play animations at 6 frames per second
var animationClock = FrameCounter[Player](fps:6)

# Create each animation.
var idleAnimation = newAnimation("idle", 0, 0, 24, 24, 4)
var runAnimation = newAnimation("run", 0, 3, 24, 24, 13)

# Create our sprite
var playerSprite = newSprite(
  "player", 
  ivec2(5, 5), 
  idleAnimation,
  runAnimation
)
var delta: float32

# Create a renderer, which handles drawing/ysorting/zindex
var renderer = newRenderer(playerSprite)

# The sprite's callback function for updating
# the sprite's current animation frame.
animationClock.run playerSprite.every(1) do(sp: var Sprite):
  sp.update()

proc gameInit() =
  loadSpriteSheet(0, "character0.png", 24, 24)
  playerSprite.play("idle")

proc gameUpdate(dt: float32) =
  # process game input

  delta = dt

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
