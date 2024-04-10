import std/[algorithm, tables]
import vmath
import nico

type
  AnimatedSprite* = ref object
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

  SpriteAnimation* = ref object
    name*: string
    x*: int
    y*: int
    current*: AnimatedSprite
    animations*: TableRef[string, AnimatedSprite]

  AnimationRenderer* = ref object
    sprite*: TableRef[string, SpriteAnimation]

proc pos*(sprite: SpriteAnimation): IVec2 =
  ivec2(sprite.x, sprite.y)

proc `[]`*(renderer: var AnimationRenderer, name: string): var SpriteAnimation =
  renderer.sprite[name]

proc `[]=`*(renderer: var AnimationRenderer, name: string, value: var SpriteAnimation) =
  renderer.sprite[name] = value

proc cmpSprite(a, b: SpriteAnimation): int =
  cmp(a.y + a.current.height, b.y + b.current.height)

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

proc newSpriteAnimation*(name: string, pos: IVec2, sprites: var TableRef[string, AnimatedSprite]): SpriteAnimation =  
  result = SpriteAnimation(
    name: name, 
    x: pos.x, y: pos.y,
    animations: sprites
  )
  for k, v in result.animations.pairs():
    result.current = v
    break

proc update*(renderer: var SpriteAnimation, shouldUpdate: bool = true) =
  # Stop oneShots from updating frames.
  if renderer.current.oneShot and renderer.current.frame - renderer.current.start == renderer.current.frames-1:
    echo "not updating"
    return

  renderer.current.frame += 1
  if renderer.current.frame - renderer.current.start > renderer.current.frames-1:
    renderer.current.frame = renderer.current.start

proc play*(sprite: var SpriteAnimation) =
  sprite.current.play(sprite.x, sprite.y)

proc play*(sprite: var SpriteAnimation, name: string) =
  let hflip = sprite.current.hflip
  sprite.current = sprite.animations[name]
  sprite.current.hflip = hflip
  sprite.current.play(sprite.x, sprite.y)

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

proc draw*(renderer: var AnimationRenderer, delta: float32) =
  var sprites = renderer.ysort()
  for sprite in sprites:
    renderer.sprite[sprite.name].current.play(sprite.x, sprite.y)
      
proc newAnimationRenderer*(animations: var TableRef[string, SpriteAnimation]): AnimationRenderer =
  result = AnimationRenderer(
    sprite: animations
  )

