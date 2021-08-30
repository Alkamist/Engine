{.experimental: "codeReordering".}

import std/math
import functions

export math
export functions

type
  Vector3 = concept v
    v.x
    v.y
    v.z
    v.x = 0
    v.y = 0
    v.z = 0

template dot*(aCode, bCode: Vector3): untyped =
  let a = aCode
  let b = bCode
  a.x * b.x + a.y * b.y + a.z * b.z

template length*(aCode: Vector3): untyped =
  let a = aCode
  (a.x * a.x + a.y * a.y + a.z * a.z).sqrt

template lengthSquared*(aCode: Vector3): untyped =
  let a = aCode
  a.x * a.x + a.y * a.y + a.z * a.z

template isNormalized*(a: Vector3): bool =
  a.lengthSquared ~= 1.0

template distanceTo*(at, to: Vector3): untyped =
  (at - to).length

template distanceSquaredTo*(at, to: Vector3): untyped =
  (at - to).lengthSquared

template setAll*(a: var Vector3, valueCode): untyped =
  let value = valueCode
  a.x = value
  a.y = value
  a.z = value

template setZero*(a: var Vector3) =
  a.setAll(0.0)

template cross*(aCode, bCode: Vector3): untyped =
  let a = aCode
  let b = bCode
  var output = typeof(a)()
  output.x = a.y * b.z - a.z * b.y
  output.y = a.z * b.x - a.x * b.z
  output.z = a.x * b.y - a.y * b.x
  output

# template normalize*(a: var Vector3) =
#   let lengthSquared = a.lengthSquared
#   if lengthSquared == 0:
#     a.setZero
#   else:
#     let length = lengthSquared.sqrt
#     a /= length

# template normalized*(a: Vector3): Vector3 =
#   result = a
#   result.normalize

# template lerp*[T: SomeFloat](a, b: Vector3, v: T): Vector3 =
#   a * (1.0 - v) + b * v

# template slide*(a, normal: Vector3): Vector3 =
#   assert(normal.isNormalized, "The other vector must be normalized.")
#   a - normal * a.dot(normal)

# template reflect*(a, normal: Vector3): Vector3 =
#   assert(normal.isNormalized, "The other vector must be normalized.")
#   normal * a.dot(normal) * 2.0 - a

# template bounce*(a, normal: Vector3): Vector3 =
#   assert(normal.isNormalized, "The other vector must be normalized.")
#   -a.reflect(normal)

# template project*(a, b: Vector3): Vector3 =
#   b * (a.dot(b) / b.lengthSquared)

# template angleTo*(a, b: Vector3): T =
#   arctan2(a.cross(b).length, a.dot(b))

# template directionTo*(a, b: Vector3): Vector3 =
#   (b - a).normalize

# template limitLength*(a: Vector3, limit: T): Vector3 =
#   result = a
#   let length = result.length
#   if length > 0.0 and limit < length:
#     result /= length
#     result *= limit

template mapIt*(aCode: Vector3, itCode): untyped =
  block:
    let a = aCode
    var output = typeof(a)()
    var it {.inject.} = a.x
    output.x = itCode
    it = a.y
    output.y = itCode
    it = a.z
    output.z = itCode
    output

template applyIt*(a: var Vector3, itCode): untyped =
  block:
    var it {.inject.} = a.x
    a.x = itCode
    it = a.y
    a.y = itCode
    it = a.z
    a.z = itCode

template defineUnaryOperator(op): untyped =
  template op*(aCode: Vector3): untyped =
    let a = aCode
    var output = typeof(a)()
    output.x = op(a.x)
    output.y = op(a.y)
    output.z = op(a.z)
    output

template defineBinaryOperator(op): untyped =
  template op*(aCode, bCode: Vector3): untyped =
    let a = aCode
    let b = bCode
    var output = typeof(a)()
    output.x = op(a.x, b.x)
    output.y = op(a.y, b.y)
    output.z = op(a.z, b.z)
    output

  template op*(aCode: Vector3, bCode: SomeNumber): untyped =
    let a = aCode
    let b: typeof(bCode) = bCode
    var output = typeof(a)()
    output.x = op(a.x, b)
    output.y = op(a.y, b)
    output.z = op(a.z, b)
    output

  template op*(aCode: SomeNumber, bCode: Vector3): untyped =
    let a: typeof(aCode) = aCode
    let b = bCode
    var output = typeof(b)()
    output.x = op(a, b.x)
    output.y = op(a, b.y)
    output.z = op(a, b.z)
    output

template defineBinaryEqualOperator(op): untyped =
  template op*(a: var Vector3, bCode: Vector3): untyped =
    let b = bCode
    op(a.x, b.x)
    op(a.y, b.y)
    op(a.z, b.z)

  template op*(a: var Vector3, bCode: SomeNumber): untyped =
    let b = bCode
    op(a.x, b)
    op(a.y, b)
    op(a.z, b)

template defineComparativeOperator(op): untyped =
  template op*(aCode, bCode: Vector3): bool =
    let a = aCode
    let b = bCode
    op(a.x, b.x) and
    op(a.y, b.y) and
    op(a.z, b.z)

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