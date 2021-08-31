import std/math
import defs, functions

type
  Vector3* = object
    coords*: array[3, RealNumber]

{.push inline.}

template x*(a: Vector3): untyped = a.coords[0]
template y*(a: Vector3): untyped = a.coords[1]
template z*(a: Vector3): untyped = a.coords[2]
template `x=`*(a: Vector3, v: RealNumber): untyped = a.coords[0] = v
template `y=`*(a: Vector3, v: RealNumber): untyped = a.coords[1] = v
template `z=`*(a: Vector3, v: RealNumber): untyped = a.coords[2] = v
template `[]`*(a: Vector3, i: int): untyped = a.coords[i]
template `[]=`*(a: Vector3, i: int, v: RealNumber): untyped = a.coords[i] = v

proc `$`*(a: Vector3): string =
  "Vector3: " & $a.x.prettyFloat & ", " & $a.y.prettyFloat & ", " & $a.z.prettyFloat

template defineUnaryOperator(op): untyped =
  proc op*(a: Vector3): Vector3 =
    result.x = op(a.x)
    result.y = op(a.y)
    result.z = op(a.z)

template defineBinaryOperator(op): untyped =
  proc op*(a, b: Vector3): Vector3 =
    result.x = op(a.x, b.x)
    result.y = op(a.y, b.y)
    result.z = op(a.z, b.z)

  proc op*(a: Vector3, b: RealNumber): Vector3 =
    result.x = op(a.x, b)
    result.y = op(a.y, b)
    result.z = op(a.z, b)

  proc op*(a: RealNumber, b: Vector3): Vector3 =
    result.x = op(a, b.x)
    result.y = op(a, b.y)
    result.z = op(a, b.z)

template defineBinaryEqualOperator(op): untyped =
  proc op*(a: var Vector3, b: Vector3) =
    op(a.x, b.x)
    op(a.y, b.y)
    op(a.z, b.z)

  proc op*(a: var Vector3, b: RealNumber) =
    op(a.x, b)
    op(a.y, b)
    op(a.z, b)

template defineComparativeOperator(op): untyped =
  proc op*(a, b: Vector3): bool =
    op(a.x, b.x) and op(a.y, b.y) and op(a.z, b.z)

defineUnaryOperator(`+`)
defineUnaryOperator(`-`)

defineBinaryOperator(`+`)
defineBinaryOperator(`-`)
defineBinaryOperator(`*`)
defineBinaryOperator(`/`)
defineBinaryOperator(`mod`)

defineBinaryEqualOperator(`+=`)
defineBinaryEqualOperator(`-=`)
defineBinaryEqualOperator(`*=`)
defineBinaryEqualOperator(`/=`)

defineComparativeOperator(`~=`)
defineComparativeOperator(`==`)

proc vector3*(x, y, z: RealNumber = 0): Vector3 =
  result.x = x
  result.y = y
  result.z = z

template mapIt*(v: Vector3, code): untyped =
  block:
    var it {.inject.} = v.x
    let x = code
    it = v.y
    let y = code
    it = v.z
    let z = code
    vector3(x, y, z)

template applyIt*(v: var Vector3, code): untyped =
  block:
    var it {.inject.} = v.x
    v.x = code
    it = v.y
    v.y = code
    it = v.z
    v.z = code

proc dot*(a, b: Vector3): RealNumber =
  a.x * b.x + a.y * b.y + a.z * b.z

proc length*(a: Vector3): RealNumber =
  (a.x * a.x + a.y * a.y + a.z * a.z).sqrt

proc lengthSquared*(a: Vector3): RealNumber =
  a.x * a.x + a.y * a.y + a.z * a.z

proc isNormalized*(a: Vector3): bool =
  a.lengthSquared ~= 1.0

proc distanceTo*(at, to: Vector3): RealNumber =
  (at - to).length

proc distanceSquaredTo*(at, to: Vector3): RealNumber =
  (at - to).lengthSquared

proc setAll*(a: var Vector3, value: RealNumber) =
  a.x = value
  a.y = value
  a.z = value

proc setZero*(a: var Vector3) =
  a.setAll(0)

proc cross*(a, b: Vector3): Vector3 =
  result.x = a.y * b.z - a.z * b.y
  result.y = a.z * b.x - a.x * b.z
  result.z = a.x * b.y - a.y * b.x

proc normalize*(a: var Vector3) =
  let lengthSquared = a.lengthSquared
  if lengthSquared == 0:
    a.setZero
  else:
    let length = lengthSquared.sqrt
    a /= length

proc normalized*(a: Vector3): Vector3 =
  result = a
  result.normalize

proc lerp*[RealNumber: SomeFloat](a, b: Vector3, v: RealNumber): Vector3 =
  a * (1.0 - v) + b * v

proc slide*(a, normal: Vector3): Vector3 =
  assert(normal.isNormalized, "The other vector must be normalized.")
  a - normal * a.dot(normal)

proc reflect*(a, normal: Vector3): Vector3 =
  assert(normal.isNormalized, "The other vector must be normalized.")
  normal * a.dot(normal) * 2.0 - a

proc bounce*(a, normal: Vector3): Vector3 =
  assert(normal.isNormalized, "The other vector must be normalized.")
  -a.reflect(normal)

proc project*(a, b: Vector3): Vector3 =
  b * (a.dot(b) / b.lengthSquared)

proc angleTo*(a, b: Vector3): RealNumber =
  arctan2(a.cross(b).length, a.dot(b))

proc directionTo*(a, b: Vector3): Vector3 =
  (b - a).normalized

proc limitLength*(a: Vector3, limit: RealNumber): Vector3 =
  result = a
  let length = result.length
  if length > 0.0 and limit < length:
    result /= length
    result *= limit

{.pop.}