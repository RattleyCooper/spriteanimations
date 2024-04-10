# spriteanimations
 Frame Locked Sprite Animations for Nico

## Install

`nimble install https://github.com/RattleyCooper/spriteanimations`

## Example

```nim
import nico
import vmath
import framecounter
import tables

type
  Player = ref object

# Play animations at 6 frames per second
var animationClock = FrameCounter[Player](fps:6)

# Create each sprite animation.
var idleAnimation = newAnimatedSprite("idle", 0, 0, 24, 24, 4)
var runAnimation = newAnimatedSprite("run", 0, 3, 24, 24, 13)

# Associate the animations.
var playerSprites = newTable[string, AnimatedSprite]()
playerSprites["idle"] = idleAnimation
playerSprites["run"] = runAnimation

var playerAnimations = newSpriteAnimation("player", ivec2(5, 5), playerSprites)
var delta: float32

var animations = newTable[string, SpriteAnimation]()
animations["player"] = playerAnimations

# Create a renderer, which is used for drawing/ysorting/zindex
var renderer = newAnimationRenderer(animations)

# Create callbacks on the animation clock for every sprite animation
animationClock.run playerAnimations.every(1) do(sp: var SpriteAnimation):
  sp.update()

proc gameInit() =
  loadSpriteSheet(0, "character0.png", 24, 24)
  renderer.sprite["player"].play("idle")

proc gameUpdate(dt: float32) =
  # process game input

  delta = dt

proc gameDraw() =
  cls()

  # Draw sprites
  renderer.draw(delta)

  # Proceed with sprite animation
  animationClock.tick(delta) 

nico.init(orgName, appName)
nico.createWindow(appName, 200, 180, 3, false)
nico.run(gameInit, gameUpdate, gameDraw)
```
