import std/[algorithm, tables]
import vmath
import nico

type
  Animation* = ref object
    name*: string
    index*: int
    start*: int
    width*: int
    height*: int
    frames*: int
    oneShot: bool
    zindex*: int

  Sprite* = ref object
    name*: string
    x*: int
    y*: int
    hflip*: bool
    vflip*: bool
    frame*: int
    current*: Animation
    animations*: TableRef[string, Animation]

  Renderer* = ref object
    ysorted*: bool
    sprite*: TableRef[string, Sprite]

proc pos*(sprite: Sprite): IVec2 =
  ivec2(sprite.x, sprite.y)

proc `[]`*(renderer: var Renderer, name: string): var Sprite =
  renderer.sprite[name]

proc `[]=`*(renderer: var Renderer, name: string, value: var Sprite) =
  renderer.sprite[name] = value

proc cmpSprite(a, b: Sprite): int =
  cmp(a.y + a.current.height, b.y + b.current.height)

proc newAnimation*(name: string, index: int, start: int, w, h: int, frames: int, oneShot: bool = false, zindex: int=0): Animation =
  Animation(
    name: name,
    index: index, start: start, 
    width: w, height: h,
    frames: frames,
    oneShot: oneShot,
    zindex: zindex
  )

proc reset*(a: var Sprite) =
  a.frame = a.current.start

proc play*(sprite: var Sprite, x: int, y: int) =
  setSpritesheet(sprite.current.index)
  # Lock last frame of oneShots
  if sprite.current.oneShot and sprite.frame - sprite.current.start == sprite.current.frames-1:
    sprite.frame = sprite.current.start + sprite.current.frames - 1
  spr(sprite.frame, x, y, 1, 1, sprite.hflip, sprite.vflip)

proc newSprite*(name: string, pos: IVec2, animations: var TableRef[string, Animation]): Sprite =  
  result = Sprite(
    name: name, 
    x: pos.x, y: pos.y,
    animations: animations,
    hflip: false, vflip: false
  )
  for k, v in result.animations.pairs():
    result.current = v
    break

proc newSprite*(name: string, pos: IVec2, animations: varargs[Animation]): Sprite =  
  result = Sprite(
    name: name, 
    x: pos.x, y: pos.y,
    hflip: false, vflip: false,
    animations: newTable[string, Animation]()
  )
  for anim in animations:
    result.animations[anim.name] = anim
  for k, v in result.animations.pairs():
    result.current = v
    break

proc update*(sprite: var Sprite, shouldUpdate: bool = true) =
  # Stop oneShots from updating frames.
  if sprite.current.oneShot and sprite.frame - sprite.current.start == sprite.current.frames-1:
    return

  sprite.frame += 1
  if sprite.frame - sprite.current.start > sprite.current.frames-1:
    sprite.frame = sprite.current.start

proc play*(sprite: var Sprite) =
  sprite.play(sprite.x, sprite.y)

proc play*(sprite: var Sprite, name: string) =
  let hflip = sprite.hflip
  sprite.current = sprite.animations[name]
  sprite.hflip = hflip
  sprite.play(sprite.x, sprite.y)

proc ysort*(r: var Renderer): seq[Sprite] =
  var zsorted: Table[int, seq[Sprite]]
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

proc draw*(renderer: var Renderer, delta: float32) =
  if renderer.ysorted:
    var sprites = renderer.ysort()
    for sprite in sprites:
      renderer.sprite[sprite.name].play(sprite.x, sprite.y)
  else:
    for sprite in renderer.sprite.values():
      renderer.sprite[sprite.name].play(sprite.x, sprite.y)

proc newRenderer*(sprites: varargs[Sprite]): Renderer =
  result = Renderer(
    sprite: newTable[string, Sprite](),
    ysorted: true
  )
  for sprite in sprites:
    result.sprite[sprite.name] = sprite

proc newRenderer*(animations: var TableRef[string, Sprite]): Renderer =
  result = Renderer(
    sprite: animations,
    ysorted: true
  )

