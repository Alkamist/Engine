{.experimental: "codeReordering".}

import std/[math, strutils]
import vector3

type
  GBasis*[T] = object
    elements: array[3, GVector3[T]]

  Basis* = GBasis[Vector3Type]

{.push inline.}

proc gbasis*[T](): GBasis[T] =
  result[0] = gvector3[T](1, 0, 0)
  result[1] = gvector3[T](0, 1, 0)
  result[2] = gvector3[T](0, 0, 1)

proc gbasis*[T](row0, row1, row2: GVector3[T]): GBasis[T] =
  result[0] = row0
  result[1] = row1
  result[2] = row2

proc gbasis*[T](xx, xy, xz: T,
                yx, yy, yz: T,
                zx, zy, zz: T): GBasis[T] =
  result.set(xx, xy, xz, yx, yy, yz, zx, zy, zz)

proc gbasis*[T](axis: GVector3[T], angle: float): GBasis[T] =
  result.setAxisAngle(axis, angle)

proc set*[T](a: var GBasis[T],
             xx, xy, xz: T,
             yx, yy, yz: T,
             zx, zy, zz: T) =
  a[0][0] = xx
  a[0][1] = xy
  a[0][2] = xz
  a[1][0] = yx
  a[1][1] = yy
  a[1][2] = yz
  a[2][0] = zx
  a[2][1] = zy
  a[2][2] = zz

proc set*[T](a: var GBasis[T], x, y, z: GVector3[T]) =
  a.x = x
  a.y = y
  a.z = z

proc getAxis*[T](a: GBasis[T], i: int): GVector3[T] =
  result.x = a[0][i]
  result.y = a[1][i]
  result.z = a[2][i]

proc setAxis*[T](a: var GBasis[T], i: int, v: GVector3[T]) =
  a[0][i] = v.x
  a[1][i] = v.y
  a[2][i] = v.z

proc getColumn*[T](a: GBasis[T], i: int): GVector3[T] =
  result.getAxis(i)

proc getRow*[T](a: GBasis[T], i: int): GVector3[T] =
  result.x = a[i][0]
  result.y = a[i][1]
  result.z = a[i][2]

proc setRow*[T](a: var GBasis[T], i: int, v: GVector3[T]) =
  a[i][0] = v.x
  a[i][1] = v.y
  a[i][2] = v.z

proc getMainDiagonal*[T](a: GBasis[T]): GVector3[T] =
  result.x = a[0][0]
  result.y = a[1][1]
  result.z = a[2][2]

proc setZero*[T](a: var GBasis[T]): GVector3[T] =
  a[0].setZero()
  a[1].setZero()
  a[2].setZero()

proc tDotX*[T](a: GBasis[T], v: GVector3[T]): T =
  a[0][0] * v[0] + a[1][0] * v[1] + a[2][0] * v[2]

proc tDotY*[T](a: GBasis[T], v: GVector3[T]): T =
  a[0][1] * v[0] + a[1][1] * v[1] + a[2][1] * v[2]

proc tDotZ*[T](a: GBasis[T], v: GVector3[T]): T =
  a[0][2] * v[0] + a[1][2] * v[1] + a[2][2] * v[2]

proc xform*[T](a: GBasis[T], v: GVector3[T]): GVector3[T] =
  result.x = a[0].dot(v)
  result.y = a[1].dot(v)
  result.z = a[2].dot(v)

proc xformInv*[T](a: GBasis[T], v: GVector3[T]): GVector3[T] =
  result.x = (a[0][0] * v.x) + (a[1][0] * v.y) + (a[2][0] * v.z)
  result.y = (a[0][1] * v.x) + (a[1][1] * v.y) + (a[2][1] * v.z)
  result.z = (a[0][2] * v.x) + (a[1][2] * v.y) + (a[2][2] * v.z)

proc determinant*[T](a: GBasis[T]): T =
  a[0][0] * (a[1][1] * a[2][2] - a[2][1] * a[1][2]) -
  a[1][0] * (a[0][1] * a[2][2] - a[2][1] * a[0][2]) +
  a[2][0] * (a[0][1] * a[1][2] - a[1][1] * a[0][2])

proc transposeXform*[T](a, b: GBasis[T]): GBasis[T] =
  result.set(
    a[0].x * b[0].x + a[1].x * b[1].x + a[2].x * b[2].x,
    a[0].x * b[0].y + a[1].x * b[1].y + a[2].x * b[2].y,
    a[0].x * b[0].z + a[1].x * b[1].z + a[2].x * b[2].z,
    a[0].y * b[0].x + a[1].y * b[1].x + a[2].y * b[2].x,
    a[0].y * b[0].y + a[1].y * b[1].y + a[2].y * b[2].y,
    a[0].y * b[0].z + a[1].y * b[1].z + a[2].y * b[2].z,
    a[0].z * b[0].x + a[1].z * b[1].x + a[2].z * b[2].x,
    a[0].z * b[0].y + a[1].z * b[1].y + a[2].z * b[2].y,
    a[0].z * b[0].z + a[1].z * b[1].z + a[2].z * b[2].z,
  )

proc invert*[T](a: var GBasis[T]) =
  template cofac(row1, col1, row2, col2): untyped =
    (a[row1][col1] * a[row2][col2] - a[row1][col2] * a[row2][col1])

  let co = [
    cofac(1, 1, 2, 2), cofac(1, 2, 2, 0), cofac(1, 0, 2, 1)
  ]
  let det = a[0][0] * co[0] +
            a[0][1] * co[1] +
            a[0][2] * co[2]

  assert det != 0.0

  let s = 1.0 / det
  a.set(
    co[0] * s, cofac(0, 2, 2, 1) * s, cofac(0, 1, 1, 2) * s,
    co[1] * s, cofac(0, 0, 2, 2) * s, cofac(0, 2, 1, 0) * s,
    co[2] * s, cofac(0, 1, 2, 0) * s, cofac(0, 0, 1, 1) * s,
  )

proc inverse*[T](a: GBasis[T]): GBasis[T] =
  result = a
  result.invert()

proc orthonormalize*[T](a: var GBasis[T]) =
  var x = a.x
  var y = a.y
  var z = a.z
  x = x.normalize
  y = y - x * x.dot(y)
  y = y.normalize
  z = z - x * x.dot(z) - y * y.dot(z)
  z = z.normalize
  a.x = x
  a.y = y
  a.z = z

proc orthonormalized*[T](a: GBasis[T]): GBasis[T] =
  result = a
  result.orthonormalize()

proc transpose*[T](a: var GBasis[T]) =
  template swap(x, y): untyped =
    let temp = x
    x = y
    y = temp
  swap(a[0][1], a[1][0])
  swap(a[0][2], a[2][0])
  swap(a[1][2], a[2][1])

proc transposed*[T](a: GBasis[T]): GBasis[T] =
  result = a
  result.transpose()

proc isOrthogonal*[T](a: GBasis[T]): bool =
  let identity = gbasis[T]()
  let m = a * a.transpose
  m ~= identity

proc isDiagonal*[T](a: GBasis[T]): bool =
  elements[0][1] ~= 0.0 and elements[0][2] ~= 0.0 and
  elements[1][0] ~= 0.0 and elements[1][2] ~= 0.0 and
  elements[2][0] ~= 0.0 and elements[2][1] ~= 0.0

proc isRotation*[T](a: GBasis[T]): bool =
  a.determinant ~= 1.0 and a.isOrthogonal

proc isSymmetric*[T](a: GBasis[T]): bool =
  if not a[0][1] ~= a[1][0]:
    return false
  if not a[0][2] ~= a[2][0]:
    return false
  if not a[1][2] ~= a[2][1]:
    return false
  true

proc scale*[T](a: var GBasis[T], scale: GVector3[T]) =
  a[0][0] *= scale.x
  a[0][1] *= scale.x
  a[0][2] *= scale.x
  a[1][0] *= scale.y
  a[1][1] *= scale.y
  a[1][2] *= scale.y
  a[2][0] *= scale.z
  a[2][1] *= scale.z
  a[2][2] *= scale.z

proc scaled*[T](a: GBasis[T], scale: GVector3[T]): GBasis[T] =
  result = a
  result.scale(scale)

proc setAxisAngle*[T](a: var GBasis[T], axis: GVector3[T], angle: float) =
  assert(axis.isNormalized, "The rotation axis must be normalized.")

  let axisSquared = gvector3[T](axis.x * axis.x, axis.y * axis.y, axis.z * axis.z)
  let cosine = angle.cos
  a[0][0] = axisSquared.x + cosine * (1.0 - axisSquared.x)
  a[1][1] = axisSquared.y + cosine * (1.0 - axisSquared.y)
  a[2][2] = axisSquared.z + cosine * (1.0 - axisSquared.z)

  let sine = angle.sin
  let t = 1.0 - cosine

  var xyzt = axis.x * axis.y * t
  var zyxs = axis.z * sine
  a[0][1] = xyzt - zyxs
  a[1][0] = xyzt + zyxs

  xyzt = axis.x * axis.z * t
  zyxs = axis.y * sine
  a[0][2] = xyzt + zyxs
  a[2][0] = xyzt - zyxs

  xyzt = axis.y * axis.z * t
  zyxs = axis.x * sine
  a[1][2] = xyzt - zyxs
  a[2][1] = xyzt + zyxs

proc rotated*[T](a: GBasis[T], axis: GVector3[T], angle: float): GBasis[T] =
  gbasis[T](axis, angle) * a

proc rotate*[T](a: var GBasis[T], axis: GVector3[T], angle: float) =
  a = a.rotated(axis, angle)

proc rotatedLocal*[T](a: GBasis[T], axis: GVector3[T], angle: float): GBasis[T] =
  a * gbasis[T](axis, angle)

proc rotateLocal*[T](a: var GBasis[T], axis: GVector3[T], angle: float) =
  a = a.rotatedLocal(axis, angle)

proc lookingAt*[T](a: GBasis[T], target, up: GVector3[T]): GBasis[T] =
  let zero = gvector3[T]()
  assert(not target ~= zero, "The target vector can't be zero.")
  assert(not up ~= zero, "The up vector can't be zero.")
  let vz = -target.normalize
  var vx = up.cross(vz)
  assert(not vx ~= zero, "The target vector and up vector can't be parallel to each other.")
  vx = vx.normalize
  let vy = vz.cross(vx)
  result.set(vx, vy, vz)

template x*[T](a: GBasis[T]): untyped = a.getAxis(0)
template y*[T](a: GBasis[T]): untyped = a.getAxis(1)
template z*[T](a: GBasis[T]): untyped = a.getAxis(2)

template `x=`*[T](a: GBasis[T], v: GVector3[T]): untyped = a.setAxis(0, v)
template `y=`*[T](a: GBasis[T], v: GVector3[T]): untyped = a.setAxis(1, v)
template `z=`*[T](a: GBasis[T], v: GVector3[T]): untyped = a.setAxis(2, v)

template `[]`*[T](a: GBasis[T], i: int): untyped = a.elements[i]
template `[]=`*[T](a: GBasis[T], i: int, v: GVector3[T]): untyped = a.elements[i] = v

proc `*=`*[T](a: var GBasis[T], b: GBasis[T]) =
  a.set(
    b.tdotx(a[0]), b.tdoty(a[0]), b.tdotz(a[0]),
    b.tdotx(a[1]), b.tdoty(a[1]), b.tdotz(a[1]),
    b.tdotx(a[2]), b.tdoty(a[2]), b.tdotz(a[2]),
  )

proc `*`*[T](a, b: GBasis[T]): GBasis[T] =
  result = a
  result *= b

proc `+=`*[T](a: var GBasis[T], b: GBasis[T]) =
  a[0] += b[0]
  a[1] += b[1]
  a[2] += b[2]

proc `+`*[T](a, b: GBasis[T]): GBasis[T] =
  result = a
  result += b

proc `-=`*[T](a: var GBasis[T], b: GBasis[T]) =
  a[0] -= b[0]
  a[1] -= b[1]
  a[2] -= b[2]

proc `-`*[T](a, b: GBasis[T]): GBasis[T] =
  result = a
  result -= b

proc `*=`*[T](a: var GBasis[T], value: float) =
  a[0] *= value
  a[1] *= value
  a[2] *= value

proc `*`*[T](a: GBasis[T], value: float): GBasis[T] =
  result = a
  result *= value

proc `~=`*[T](a, b: GBasis[T]): bool =
  a[0] ~= b[0] and a[1] ~= b[1] and a[2] ~= b[2]

proc `$`*[T](a: GBasis[T]): string =
  "GBasis" & "[" & $T & "]:\n" &
  "  " & $a.x.x.prettyFloat & ", " & $a.x.y.prettyFloat & ", " & $a.x.z.prettyFloat & "\n" &
  "  " & $a.y.x.prettyFloat & ", " & $a.y.y.prettyFloat & ", " & $a.y.z.prettyFloat & "\n" &
  "  " & $a.z.x.prettyFloat & ", " & $a.z.y.prettyFloat & ", " & $a.z.z.prettyFloat & "\n"

proc `$`*(a: Basis): string =
  "Basis:\n" &
  "  " & $a.x.x.prettyFloat & ", " & $a.x.y.prettyFloat & ", " & $a.x.z.prettyFloat & "\n" &
  "  " & $a.y.x.prettyFloat & ", " & $a.y.y.prettyFloat & ", " & $a.y.z.prettyFloat & "\n" &
  "  " & $a.z.x.prettyFloat & ", " & $a.z.y.prettyFloat & ", " & $a.z.z.prettyFloat & "\n"

proc basis*(): Basis =
  gbasis[Vector3Type]()

proc basis*(row0, row1, row2: Vector3): Basis =
  gbasis[Vector3Type](row0, row1, row2)

proc basis*(xx, xy, xz: Vector3Type,
            yx, yy, yz: Vector3Type,
            zx, zy, zz: Vector3Type): Basis =
  gbasis[Vector3Type](xx, xy, xz, yx, yy, yz, zx, zy, zz)

proc basis*(axis: Vector3, angle: Vector3Type): Basis =
  gbasis[Vector3Type](axis, angle)

{.pop.}