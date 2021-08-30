{.experimental: "codeReordering".}

import std/[math, strutils]
import functions

type
  GVector3*[T] = object
    coord: array[3, T]

  Vector3Type* = float32
  Vector3* = GVector3[Vector3Type]

{.push inline.}

proc gvector3*[T](x, y, z: T = 0): GVector3[T] =
  result.x = x
  result.y = y
  result.z = z

proc asType*[T](v: GVector3[T], to: typedesc): GVector3[to] =
  result.x = v.x.to
  result.y = v.y.to
  result.z = v.z.to

proc dot*[T](a, b: GVector3[T]): T =
  a.x * b.x + a.y * b.y + a.z * b.z

proc length*[T](a: GVector3[T]): T =
  (a.x * a.x + a.y * a.y + a.z * a.z).sqrt

proc lengthSquared*[T](a: GVector3[T]): T =
  a.x * a.x + a.y * a.y + a.z * a.z

proc isNormalized*[T](a: GVector3[T]): bool =
  a.lengthSquared ~= 1.0

proc distanceTo*[T](at, to: GVector3[T]): T =
  (at - to).length

proc distanceSquaredTo*[T](at, to: GVector3[T]): T =
  (at - to).lengthSquared

proc setAll*[T](a: var GVector3[T], value: T) =
  a.x = value
  a.y = value
  a.z = value

proc setZero*[T](a: var GVector3[T]) =
  a.setAll(0)

proc cross*[T](a, b: GVector3[T]): GVector3[T] =
  result.x = a.y * b.z - a.z * b.y
  result.y = a.z * b.x - a.x * b.z
  result.z = a.x * b.y - a.y * b.x

proc normalize*[T](a: var GVector3[T]) =
  let lengthSquared = a.lengthSquared
  if lengthSquared == 0:
    a.setZero
  else:
    let length = lengthSquared.sqrt
    a /= length

proc normalized*[T](a: GVector3[T]): GVector3[T] =
  result = a
  result.normalize

proc lerp*[T: SomeFloat](a, b: GVector3[T], v: T): GVector3[T] =
  a * (1.0 - v) + b * v

proc slide*[T](a, normal: GVector3[T]): GVector3[T] =
  assert(normal.isNormalized, "The other vector must be normalized.")
  a - normal * a.dot(normal)

proc reflect*[T](a, normal: GVector3[T]): GVector3[T] =
  assert(normal.isNormalized, "The other vector must be normalized.")
  normal * a.dot(normal) * 2.0 - a

proc bounce*[T](a, normal: GVector3[T]): GVector3[T] =
  assert(normal.isNormalized, "The other vector must be normalized.")
  -a.reflect(normal)

proc project*[T](a, b: GVector3[T]): GVector3[T] =
  b * (a.dot(b) / b.lengthSquared)

proc angleTo*[T](a, b: GVector3[T]): T =
  arctan2(a.cross(b).length, a.dot(b))

proc directionTo*[T](a, b: GVector3[T]): GVector3[T] =
  (b - a).normalize

proc limitLength*[T](a: GVector3[T], limit: T): GVector3[T] =
  result = a
  let length = result.length
  if length > 0.0 and limit < length:
    result /= length
    result *= limit

template x*[T](a: GVector3[T]): untyped = a.coord[0]
template y*[T](a: GVector3[T]): untyped = a.coord[1]
template z*[T](a: GVector3[T]): untyped = a.coord[2]

template `x=`*[T](a: GVector3[T], v: T): untyped = a.coord[0] = v
template `y=`*[T](a: GVector3[T], v: T): untyped = a.coord[1] = v
template `z=`*[T](a: GVector3[T], v: T): untyped = a.coord[2] = v

template `[]`*[T](a: GVector3[T], i: int): untyped = a.coord[i]
template `[]=`*[T](a: GVector3[T], i: int, v: T): untyped = a.coord[i] = v

proc prettyFloat*(f: float): string =
  result = f.formatFloat(ffDecimal, 4)
  if result[0] != '-':
    result.insert(" ", 0)

proc `$`*[T](a: GVector3[T]): string =
  "GVector3" & "[" & $T & "]: " &
  "  " & $a.x.prettyFloat & ", " & $a.y.prettyFloat & ", " & $a.z.prettyFloat

proc `$`*(a: Vector3): string =
  "Vector3: " & $a.x.prettyFloat & ", " & $a.y.prettyFloat & ", " & $a.z.prettyFloat

proc vector3*(x, y, z = 0.0): Vector3 =
  result.x = x
  result.y = y
  result.z = z

template mapIt*[T](v: GVector3[T], code): untyped =
  block:
    var it {.inject.} = v.x
    let x = code
    it = v.y
    let y = code
    it = v.z
    let z = code
    gvector3[T](x, y, z)

template applyIt*[T](v: var GVector3[T], code): untyped =
  block:
    var it {.inject.} = v.x
    v.x = code
    it = v.y
    v.y = code
    it = v.z
    v.z = code

template defineUnaryOperator(op): untyped =
  proc op*[T](a: GVector3[T]): GVector3[T] =
    result.x = op(a.x)
    result.y = op(a.y)
    result.z = op(a.z)

template defineBinaryOperator(op): untyped =
  proc op*[T](a, b: GVector3[T]): GVector3[T] =
    result.x = op(a.x, b.x)
    result.y = op(a.y, b.y)
    result.z = op(a.z, b.z)

  proc op*[T](a: GVector3[T], b: T): GVector3[T] =
    result.x = op(a.x, b)
    result.y = op(a.y, b)
    result.z = op(a.z, b)

  proc op*[T](a: T, b: GVector3[T]): GVector3[T] =
    result.x = op(a, b.x)
    result.y = op(a, b.y)
    result.z = op(a, b.z)

template defineBinaryEqualOperator(op): untyped =
  proc op*[T](a: var GVector3[T], b: GVector3[T]) =
    op(a.x, b.x)
    op(a.y, b.y)
    op(a.z, b.z)

  proc op*[T](a: var GVector3[T], b: T) =
    op(a.x, b)
    op(a.y, b)
    op(a.z, b)

template defineComparativeOperator(op): untyped =
  proc op*[T](a, b: GVector3[T]): bool =
    op(a.x, b.x) and op(a.y, b.y) and op(a.z, b.z)

defineUnaryOperator(`+`)
defineUnaryOperator(`-`)

defineBinaryOperator(`+`)
defineBinaryOperator(`-`)
defineBinaryOperator(`*`)
defineBinaryOperator(`/`)
defineBinaryOperator(`mod`)
defineBinaryOperator(`div`)
defineBinaryOperator(`zmod`)

defineBinaryEqualOperator(`+=`)
defineBinaryEqualOperator(`-=`)
defineBinaryEqualOperator(`*=`)
defineBinaryEqualOperator(`/=`)

defineComparativeOperator(`~=`)
defineComparativeOperator(`==`)

{.pop.}