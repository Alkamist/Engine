import ../engine/gmath

type
  Vec3* = object
    x*, y*, z*: float32

block:
  let a = [1.0, 2.0, 3.0]
  echo a.mapIt(it.sin)
  echo a.length
  echo a + a

block:
  let a = Vec3(x: 1.0, y: 2.0, z: 3.0)
  echo a.mapIt(it.sin)
  echo a.length