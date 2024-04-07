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
    oneShot: bool

  SpriteAnimation* = object
    name*: string
    pos*: IVec2
    current*: AnimatedSprite
    animations*: Table[string, AnimatedSprite]
    clock*: FrameCounter

  AnimationRenderer* = object
    sprite*: Table[string, SpriteAnimation]

proc `[]`(renderer: var AnimationRenderer, name: string): var SpriteAnimation =
  renderer.sprite[name]

proc cmpSprite(a, b: SpriteAnimation): int =
  cmp(a.pos.y + a.current.height, b.pos.y + b.current.height)

proc newAnimatedSprite*(name: string, index: int, start: int, w, h: int, frames: int, oneShot: bool = false): AnimatedSprite =
  AnimatedSprite(
    name: name,
    index: index, start: start, 
    width: w, height: h,
    hflip: false, vflip: false,
    frame: start,
    frames: frames,
    oneShot: oneShot
  )

proc reset*(a: var AnimatedSprite) =
  a.frame = a.start

proc play*(sprite: var AnimatedSprite, x: int, y: int) =
  setSpritesheet(sprite.index)
  # Lock last frame of oneShots
  if sprite.oneShot and sprite.frame - sprite.start == sprite.frames-1:
    sprite.frame = sprite.start + sprite.frames - 1

  spr(sprite.frame, x, y, 1, 1, sprite.hflip, sprite.vflip)

proc newSpriteAnimation*(clock: var FrameCounter, name: string, pos: IVec2, sprites: varargs[AnimatedSprite]): SpriteAnimation =
  result = SpriteAnimation(
    name: name, clock: clock, pos: pos
  )
  for sprite in sprites:
    result.animations[sprite.name] = sprite

  if result.animations.len > 0:
    result.current = sprites[0]

proc update*(renderer: var SpriteAnimation, shouldUpdate: bool = true) =
  # Stop oneShots from updating frames.
  if renderer.current.oneShot and renderer.current.frame - renderer.current.start == renderer.current.frames-1:
    echo "not updating"
    return

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

proc ysort*(r: var AnimationRenderer): seq[SpriteAnimation] =
  for k, v in r.sprite.pairs():
    result.add v
  result.sort(cmpSprite, Ascending)

proc process*(renderer: var AnimationRenderer, delta: float32, pauseAnimations: bool = true) =
  for i, sprite in renderer.sprite.pairs():
    renderer.sprite[i].current.play(sprite.pos.x, sprite.pos.y)
    if pauseAnimations: continue
    renderer.sprite[i].clock.ControlFlow(delta)
    renderer.sprite[i].clock.tick()

template finalize*(renderer: var AnimationRenderer) =
  for i, anim in renderer.sprite:
    renderer.sprite[i].clock.run every(1) do():
      renderer.sprite[i].update()

proc newAnimationRenderer*(animations: varargs[SpriteAnimation]): AnimationRenderer =
  result = AnimationRenderer()
  for anim in animations:
    result.sprite[anim.name] = anim

