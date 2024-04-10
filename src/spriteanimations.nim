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
    zindex*: int

  SpriteAnimation* = object
    name*: string
    pos*: IVec2
    current*: AnimatedSprite
    animations*: Table[string, AnimatedSprite]
    clock*: FrameCounter[SpriteAnimation]

  AnimationRenderer* = object
    sprite*: Table[string, SpriteAnimation]

proc `[]`(renderer: var AnimationRenderer, name: string): var SpriteAnimation =
  renderer.sprite[name]

proc cmpSprite(a, b: SpriteAnimation): int =
  cmp(a.pos.y + a.current.height, b.pos.y + b.current.height)

proc newAnimatedSprite*(name: string, index: int, start: int, w, h: int, frames: int, oneShot: bool = false, zindex: int=0): AnimatedSprite =
  AnimatedSprite(
    name: name,
    index: index, start: start, 
    width: w, height: h,
    hflip: false, vflip: false,
    frame: start,
    frames: frames,
    oneShot: oneShot,
    zindex: zindex
  )

proc reset*(a: var AnimatedSprite) =
  a.frame = a.start

proc play*(sprite: var AnimatedSprite, x: int, y: int) =
  setSpritesheet(sprite.index)
  # Lock last frame of oneShots
  if sprite.oneShot and sprite.frame - sprite.start == sprite.frames-1:
    sprite.frame = sprite.start + sprite.frames - 1
  spr(sprite.frame, x, y, 1, 1, sprite.hflip, sprite.vflip)

proc newSpriteAnimation*(clock: var FrameCounter[SpriteAnimation], name: string, pos: IVec2, sprites: varargs[AnimatedSprite]): SpriteAnimation =
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
  let hflip = sprite.current.hflip
  sprite.current = sprite.animations[name]
  sprite.current.hflip = hflip
  sprite.current.play(sprite.pos.x, sprite.pos.y)

proc tick*(sprite: var SpriteAnimation, dt: float32) =
  sprite.clock.tick(dt)

proc ysort*(r: var AnimationRenderer): seq[SpriteAnimation] =
  var zsorted: Table[int, seq[SpriteAnimation]]
  var lowz: int
  var highz: int
  for k, v in r.sprite.pairs():
    lowz = min(v.current.zindex, lowz)
    highz = max(v.current.zindex, highz)
    if zsorted.contains(v.current.zindex):
      zsorted[v.current.zindex].add v
    else:
      zsorted[v.current.zindex] = @[v]
  for i in lowz..highz:
    if zsorted.contains(i):
      var l = zsorted[i]
      l.sort(cmpSprite, Ascending)
      result.add l

proc process*(renderer: var AnimationRenderer, delta: float32, pauseAnimations: bool = true) =
  var sprites = renderer.ysort()
  for sprite in sprites:
    renderer.sprite[sprite.name].current.play(sprite.pos.x, sprite.pos.y)
    if pauseAnimations: continue
    renderer.sprite[sprite.name].clock.tick(delta)


proc add*(renderer: var AnimationRenderer, sprite: var SpriteAnimation) =
  renderer.sprite[sprite.name] = sprite
  renderer.sprite[sprite.name].clock.run sprite.every(1) do(sp: var SpriteAnimation):
    renderer.sprite[sprite.name].update()

template finalize*(renderer: var AnimationRenderer) =
  for i, anim in renderer.sprite.pairs():
    renderer.sprite[i].clock.run renderer.sprite[i].every(1) do(sp: var SpriteAnimation):
      renderer.sprite[i].update()
      

proc newAnimationRenderer*(animations: varargs[SpriteAnimation]): AnimationRenderer =
  result = AnimationRenderer()
  for anim in animations:
    result.sprite[anim.name] = anim

