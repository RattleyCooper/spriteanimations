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
var idleAnimation = newAnimatedSprite("idle", 0, 0, ivec2(0, 0), 24, 24, 4)
var runAnimation = newAnimatedSprite("run", 0, 3, ivec2(0, 0), 24, 24, 13)

var renderer = animationClock.newSpriteRenderer(idleAnimation, runAnimation)
var delta: float32

# Hook our frame counter and update
# renderer every counter frame to 
# set next frame
renderer.clock.run every(1) do():
  renderer.update()

proc gameInit() =
  loadSpriteSheet(0, "character0.png", 24, 24)
  renderer.play("idle")

proc gameUpdate(dt: float32) =
  # process game input

  delta = dt

proc gameDraw() =
  cls()
  renderer.render()
  renderer.clock.ControlFlow(delta)
  renderer.clock.tick()

nico.init(orgName, appName)
nico.createWindow(appName, 200, 180, 3, false)
nico.run(gameInit, gameUpdate, gameDraw)
```
