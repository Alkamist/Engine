import std/math
import functions

type
  GVector3*[T] = object
    elements: array[3, T]

  Vector3* = GVector3[float32]
  DVector3* = GVector3[float64]
  IVector3* = GVector3[int]

{.push inline.}

template x*[T](a: GVector3[T]): untyped = a.elements[0]
template y*[T](a: GVector3[T]): untyped = a.elements[1]
template z*[T](a: GVector3[T]): untyped = a.elements[2]

template `x=`*[T](a: GVector3[T], v: T): untyped = a.elements[0] = v
template `y=`*[T](a: GVector3[T], v: T): untyped = a.elements[1] = v
template `z=`*[T](a: GVector3[T], v: T): untyped = a.elements[2] = v

template `[]`*[T](a: GVector3[T], i: int): untyped = a.elements[i]
template `[]=`*[T](a: GVector3[T], i: int, v: T): untyped = a.elements[i] = v

proc gvector3*[T](x, y, z: T): GVector3[T] =
  result.x = x
  result.y = y
  result.z = z

proc vector3*(x, y, z: float32): Vector3 =
  result.x = x
  result.y = y
  result.z = z

proc dvector3*(x, y, z: float64): DVector3 =
  result.x = x
  result.y = y
  result.z = z

proc ivector3*(x, y, z: int): IVector3 =
  result.x = x
  result.y = y
  result.z = z

proc asType*[T](v: GVector3[T], to: typedesc): GVector3[to] =
  result.x = v.x.to
  result.y = v.y.to
  result.z = v.z.to

const vector3Zero* = vector3(0.0, 0.0, 0.0)
const vector3One* = vector3(1.0, 1.0, 1.0)
const vector3Inf* = vector3(Inf, Inf, Inf)
const vector3Left* = vector3(-1.0, 0.0, 0.0)
const vector3Right* = vector3(1.0, 0.0, 0.0)
const vector3Up* = vector3(0.0, 1.0, 0.0)
const vector3Down* = vector3(0.0, -1.0, 0.0)
const vector3Forward* = vector3(0.0, 0.0, -1.0)
const vector3Back* = vector3(0.0, 0.0, 1.0)

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
    let x = op(a.x)
    let y = op(a.y)
    let z = op(a.z)
    gvector3[T](x, y, z)

template defineBinaryOperator(op): untyped =
  proc op*[T](a, b: GVector3[T]): GVector3[T] =
    let x = op(a.x, b.x)
    let y = op(a.y, b.y)
    let z = op(a.z, b.z)
    gvector3[T](x, y, z)

  proc op*[T](a: GVector3[T], b: T): GVector3[T] =
    let x = op(a.x, b)
    let y = op(a.y, b)
    let z = op(a.z, b)
    gvector3[T](x, y, z)

  proc op*[T](a: T, b: GVector3[T]): GVector3[T] =
    let x = op(a, b.x)
    let y = op(a, b.y)
    let z = op(a, b.z)
    gvector3[T](x, y, z)

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
    let x = op(a.x, b.x)
    let y = op(a.y, b.y)
    let z = op(a.z, b.z)
    x and y and z

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

proc dot*[T](a, b: GVector3[T]): T =
  a.x * b.x + a.y * b.y + a.z * b.z

proc cross*[T](a, b: GVector3[T]): GVector3[T] =
  gvector3(
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x,
  )

proc length*[T](a: GVector3[T]): T =
  (a.x * a.x + a.y * a.y + a.z * a.z).sqrt

proc lengthSquared*[T](a: GVector3[T]): T =
  a.x * a.x + a.y * a.y + a.z * a.z

proc isNormalized*[T](a: GVector3[T]): bool =
  a.lengthSquared ~= 1.0

proc normalize*[T](a: GVector3[T]) =
  let lengthSquared = a.lengthSquared
  if lengthSquared == 0:
    vector3Zero.asType(T)
  else:
    let length = lengthSquared.sqrt
    a / length

proc distanceTo*[T](at, to: GVector3[T]): T =
  (at - to).length

proc distanceSquaredTo*[T](at, to: GVector3[T]): T =
  (at - to).lengthSquared

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
  let length = a.length
  if length > 0.0 and limit < length:
    result /= length
    result *= limit

{.pop.}