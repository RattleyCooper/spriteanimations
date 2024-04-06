# spriteanimations
 Frame Locked Sprite Animations for Nico

## Install

`nimble install https://github.com/RattleyCooper/spriteanimations`

## Example

```nim
import nico
import vmath
import framecounter

var animationClock = FrameCounter(fps:6)
var idleAnimation = newAnimatedSprite("idle", 0, 0, 24, 24, 4)
var runAnimation = newAnimatedSprite("run", 0, 3, 24, 24, 13)

var playerAnimation = animationClock.newSpriteAnimation(ivec2(5, 5), idleAnimation, runAnimation)
var delta: float32

# Create a renderer, which can be used to do
# ysorting.
var renderer = newAnimationRenderer(
  playerAnimation
)
# finalize the renderer; creates callbacks to
# update animations.
renderer.finalize()

proc gameInit() =
  loadSpriteSheet(0, "character0.png", 24, 24)
  playerAnimation.play("idle")

proc gameUpdate(dt: float32) =
  # process game input

  delta = dt

proc gameDraw() =
  cls()

  # Ysort based on SpriteAnimation.pos.y + SpriteAnimation.current.height
  renderer.ysort()
  renderer.process(delta) # Process animations

nico.init(orgName, appName)
nico.createWindow(appName, 200, 180, 3, false)
nico.run(gameInit, gameUpdate, gameDraw)
```
