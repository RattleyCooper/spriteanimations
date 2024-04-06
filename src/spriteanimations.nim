import std/[tables]
import vmath
import framecounter
import nico

type
  AnimatedSprite* = object
    name*: string
    index*: int
    start*: int
    width*: int
    height*: int
    hflip*: bool
    vflip*: bool
    pos*: IVec2
    frame*: int
    frames*: int

  SpriteRenderer* = object
    current*: AnimatedSprite
    animations*: Table[string, AnimatedSprite]
    clock*: FrameCounter

proc newAnimatedSprite*(name: string, index: int, start: int, pos: IVec2, w, h: int, frames: int): AnimatedSprite =
  AnimatedSprite(
    name: name,
    index: index, start: start, 
    pos: pos, width: w, height: h,
    hflip: false, vflip: false,
    frame: start,
    frames: frames
  )

proc play*(sprite: var AnimatedSprite) =
  setSpritesheet(sprite.index)
  spr(sprite.frame, sprite.pos.x, sprite.pos.y, 1, 1, sprite.hflip, sprite.vflip)

proc newSpriteRenderer*(clock: var FrameCounter, sprites: varargs[AnimatedSprite]): SpriteRenderer =
  result = SpriteRenderer(
    clock: clock
  )
  for sprite in sprites:
    result.animations[sprite.name] = sprite

  if result.animations.len > 0:
    result.current = sprites[0]

proc update*(renderer: var SpriteRenderer) =
    renderer.current.frame += 1
    if renderer.current.frame - renderer.current.start > renderer.current.frames-1:
      renderer.current.frame = renderer.current.start

proc render*(renderer: var SpriteRenderer) =
  renderer.current.play()

proc play*(renderer: var SpriteRenderer, name: string) =
  renderer.current = renderer.animations[name]
  renderer.current.play()

proc tick*(renderer: var SpriteRenderer) =
  renderer.clock.tick()
