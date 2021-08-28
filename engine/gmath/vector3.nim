import std/math
import functions

# AXIS_X = 0 --- Enumerated value for the X axis. Returned by max_axis and min_axis.
# AXIS_Y = 1 --- Enumerated value for the Y axis. Returned by max_axis and min_axis.
# AXIS_Z = 2 --- Enumerated value for the Z axis. Returned by max_axis and min_axis.
# ZERO = Vector3( 0, 0, 0 ) --- Zero vector, a vector with all components set to 0.
# ONE = Vector3( 1, 1, 1 ) --- One vector, a vector with all components set to 1.
# INF = Vector3( inf, inf, inf ) --- Infinity vector, a vector with all components set to @GDScript.INF.
# LEFT = Vector3( -1, 0, 0 ) --- Left unit vector. Represents the local direction of left, and the global direction of west.
# RIGHT = Vector3( 1, 0, 0 ) --- Right unit vector. Represents the local direction of right, and the global direction of east.
# UP = Vector3( 0, 1, 0 ) --- Up unit vector.
# DOWN = Vector3( 0, -1, 0 ) --- Down unit vector.
# FORWARD = Vector3( 0, 0, -1 ) --- Forward unit vector. Represents the local direction of forward, and the global direction of north.
# BACK = Vector3( 0, 0, 1 ) --- Back unit vector. Represents the local direction of back, and the global direction of south.

type
  GVector3*[T] = object
    x*, y*, z*: T

  Vector3* = GVector3[float32]

proc gvector3*[T](x, y, z: T): GVector3[T] =
  GVector3[T](x: x, y: y, z: z)

proc vector3*(x, y, z: float): Vector3 =
  gvector3[float32](x, y, z)

proc asType*[T](v: GVector3[T], to: typedesc): GVector3[to] =
  gvector3[to](v.x.to, v.y.to, v.z.to)

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

proc normalize*[T](a: GVector3[T]): GVector3[T] =
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

proc linearInterpolate*[T: SomeFloat](a, b: GVector3[T], v: T): GVector3[T] =
  a * (1.0 - v) + b * v

proc slide*[T](a, normal: GVector3[T]): GVector3[T] =
  ## Must be normalized.
  a - normal * a.dot(normal)

proc reflect*[T](a, normal: GVector3[T]): GVector3[T] =
  ## Must be normalized.
  normal * a.dot(normal) * 2.0 - a

proc bounce*[T](a, normal: GVector3[T]): GVector3[T] =
  ## Must be normalized.
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