import std/[algorithm, tables]
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
    frame*: int
    frames*: int

  SpriteAnimation* = object
    pos*: IVec2
    current*: AnimatedSprite
    animations*: Table[string, AnimatedSprite]
    clock*: FrameCounter

  AnimationRenderer* = object
    spriteAnimations*: seq[SpriteAnimation]

proc cmpSprite(a, b: SpriteAnimation): int =
  cmp(a.pos.y + a.current.height, b.pos.y + b.current.height)

proc newAnimatedSprite*(name: string, index: int, start: int, w, h: int, frames: int): AnimatedSprite =
  AnimatedSprite(
    name: name,
    index: index, start: start, 
    width: w, height: h,
    hflip: false, vflip: false,
    frame: start,
    frames: frames
  )

proc play*(sprite: var AnimatedSprite, x: int, y: int) =
  setSpritesheet(sprite.index)
  spr(sprite.frame, x, y, 1, 1, sprite.hflip, sprite.vflip)

proc newSpriteAnimation*(clock: var FrameCounter, pos: IVec2, sprites: varargs[AnimatedSprite]): SpriteAnimation =
  result = SpriteAnimation(
    clock: clock, pos: pos
  )
  for sprite in sprites:
    result.animations[sprite.name] = sprite

  if result.animations.len > 0:
    result.current = sprites[0]

proc update*(renderer: var SpriteAnimation) =
  renderer.current.frame += 1
  if renderer.current.frame - renderer.current.start > renderer.current.frames-1:
    renderer.current.frame = renderer.current.start

proc play*(sprite: var SpriteAnimation) =
  sprite.current.play(sprite.pos.x, sprite.pos.y)

proc play*(sprite: var SpriteAnimation, name: string) =
  sprite.current = sprite.animations[name]
  sprite.current.play(sprite.pos.x, sprite.pos.y)

proc tick*(sprite: var SpriteAnimation) =
  sprite.clock.tick()

proc ysort*(r: var AnimationRenderer) =
  r.spriteAnimations.sort(cmpSprite, Ascending)

proc process*(renderer: var AnimationRenderer, delta: float32) =
  for i, sprite in renderer.spriteAnimations:
    renderer.spriteAnimations[i].current.play(sprite.pos.x, sprite.pos.y)
    renderer.spriteAnimations[i].clock.ControlFlow(delta)
    renderer.spriteAnimations[i].clock.tick()

template finalize*(renderer: var AnimationRenderer) =
  for i, anim in renderer.spriteAnimations:
    renderer.spriteAnimations[i].clock.run every(1) do():
      renderer.spriteAnimations[i].update()

proc newAnimationRenderer*(animations: varargs[SpriteAnimation]): AnimationRenderer =
  result = AnimationRenderer()
  for anim in animations:
    result.spriteAnimations.add anim

