import std/math
import defs, functions, vector3

type
  Basis* = object
    elements*: array[3, Vector3]

{.push inline.}

template `[]`*(a: Basis, i: int): untyped = a.elements[i]
template `[]=`*(a: Basis, i: int, v: Vector3): untyped = a.elements[i] = v

proc getAxis*(a: Basis, i: int): Vector3 =
  result.x = a[0][i]
  result.y = a[1][i]
  result.z = a[2][i]

proc setAxis*(a: var Basis, i: int, v: Vector3) =
  a[0][i] = v.x
  a[1][i] = v.y
  a[2][i] = v.z

template x*(a: Basis): untyped = a.getAxis(0)
template y*(a: Basis): untyped = a.getAxis(1)
template z*(a: Basis): untyped = a.getAxis(2)
template `x=`*(a: Basis, v: Vector3): untyped = a.setAxis(0, v)
template `y=`*(a: Basis, v: Vector3): untyped = a.setAxis(1, v)
template `z=`*(a: Basis, v: Vector3): untyped = a.setAxis(2, v)

proc `$`*(a: Basis): string =
  "Basis:\n" &
  "  " & $a.x.x.prettyFloat & ", " & $a.x.y.prettyFloat & ", " & $a.x.z.prettyFloat & "\n" &
  "  " & $a.y.x.prettyFloat & ", " & $a.y.y.prettyFloat & ", " & $a.y.z.prettyFloat & "\n" &
  "  " & $a.z.x.prettyFloat & ", " & $a.z.y.prettyFloat & ", " & $a.z.z.prettyFloat & "\n"

proc set*(a: var Basis, x, y, z: Vector3) =
  a.x = x
  a.y = y
  a.z = z

proc set*(a: var Basis,
          xx, xy, xz: RealNumber,
          yx, yy, yz: RealNumber,
          zx, zy, zz: RealNumber) =
  a[0][0] = xx
  a[0][1] = xy
  a[0][2] = xz
  a[1][0] = yx
  a[1][1] = yy
  a[1][2] = yz
  a[2][0] = zx
  a[2][1] = zy
  a[2][2] = zz

proc setAxisAngle*(a: var Basis, axis: Vector3, angle: float) =
  assert(axis.isNormalized, "The rotation axis must be normalized.")

  let axisSquared = vector3(axis.x * axis.x, axis.y * axis.y, axis.z * axis.z)
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

proc tDotX*(a: Basis, v: Vector3): RealNumber =
  a[0][0] * v[0] + a[1][0] * v[1] + a[2][0] * v[2]

proc tDotY*(a: Basis, v: Vector3): RealNumber =
  a[0][1] * v[0] + a[1][1] * v[1] + a[2][1] * v[2]

proc tDotZ*(a: Basis, v: Vector3): RealNumber =
  a[0][2] * v[0] + a[1][2] * v[1] + a[2][2] * v[2]

proc `*=`*(a: var Basis, b: Basis) =
  a.set(
    b.tdotx(a[0]), b.tdoty(a[0]), b.tdotz(a[0]),
    b.tdotx(a[1]), b.tdoty(a[1]), b.tdotz(a[1]),
    b.tdotx(a[2]), b.tdoty(a[2]), b.tdotz(a[2]),
  )

proc `*`*(a, b: Basis): Basis =
  result = a
  result *= b

proc `+=`*(a: var Basis, b: Basis) =
  a[0] += b[0]
  a[1] += b[1]
  a[2] += b[2]

proc `+`*(a, b: Basis): Basis =
  result = a
  result += b

proc `-=`*(a: var Basis, b: Basis) =
  a[0] -= b[0]
  a[1] -= b[1]
  a[2] -= b[2]

proc `-`*(a, b: Basis): Basis =
  result = a
  result -= b

proc `*=`*(a: var Basis, value: float) =
  a[0] *= value
  a[1] *= value
  a[2] *= value

proc `*`*(a: Basis, value: float): Basis =
  result = a
  result *= value

proc `~=`*(a, b: Basis): bool =
  a[0] ~= b[0] and a[1] ~= b[1] and a[2] ~= b[2]

proc basis*(): Basis =
  result[0] = vector3(1.0, 0.0, 0.0)
  result[1] = vector3(0.0, 1.0, 0.0)
  result[2] = vector3(0.0, 0.0, 1.0)

proc basis*(row0, row1, row2: Vector3): Basis =
  result[0] = row0
  result[1] = row1
  result[2] = row2

proc basis*(xx, xy, xz: RealNumber,
            yx, yy, yz: RealNumber,
            zx, zy, zz: RealNumber): Basis =
  result.set(xx, xy, xz, yx, yy, yz, zx, zy, zz)

proc basis*(axis: Vector3, angle: float): Basis =
  result.setAxisAngle(axis, angle)

proc getColumn*(a: Basis, i: int): Vector3 =
  a.getAxis(i)

proc getRow*(a: Basis, i: int): Vector3 =
  result.x = a[i][0]
  result.y = a[i][1]
  result.z = a[i][2]

proc setRow*(a: var Basis, i: int, v: Vector3) =
  a[i][0] = v.x
  a[i][1] = v.y
  a[i][2] = v.z

proc getMainDiagonal*(a: Basis): Vector3 =
  result.x = a[0][0]
  result.y = a[1][1]
  result.z = a[2][2]

proc setZero*(a: var Basis): Vector3 =
  a[0].setZero()
  a[1].setZero()
  a[2].setZero()

proc xform*(a: Basis, v: Vector3): Vector3 =
  result.x = a[0].dot(v)
  result.y = a[1].dot(v)
  result.z = a[2].dot(v)

proc xformInv*(a: Basis, v: Vector3): Vector3 =
  result.x = (a[0][0] * v.x) + (a[1][0] * v.y) + (a[2][0] * v.z)
  result.y = (a[0][1] * v.x) + (a[1][1] * v.y) + (a[2][1] * v.z)
  result.z = (a[0][2] * v.x) + (a[1][2] * v.y) + (a[2][2] * v.z)

proc determinant*(a: Basis): RealNumber =
  a[0][0] * (a[1][1] * a[2][2] - a[2][1] * a[1][2]) -
  a[1][0] * (a[0][1] * a[2][2] - a[2][1] * a[0][2]) +
  a[2][0] * (a[0][1] * a[1][2] - a[1][1] * a[0][2])

proc transposeXform*(a, b: Basis): Basis =
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

proc invert*(a: var Basis) =
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

proc inverse*(a: Basis): Basis =
  result = a
  result.invert()

proc orthonormalize*(a: var Basis) =
  var x = a.x
  var y = a.y
  var z = a.z
  x.normalize
  y = y - x * x.dot(y)
  y.normalize
  z = z - x * x.dot(z) - y * y.dot(z)
  z.normalize
  a.x = x
  a.y = y
  a.z = z

proc orthonormalized*(a: Basis): Basis =
  result = a
  result.orthonormalize()

proc transpose*(a: var Basis) =
  template swap(x, y): untyped =
    let temp = x
    x = y
    y = temp
  swap(a[0][1], a[1][0])
  swap(a[0][2], a[2][0])
  swap(a[1][2], a[2][1])

proc transposed*(a: Basis): Basis =
  result = a
  result.transpose()

proc isOrthogonal*(a: Basis): bool =
  let identity = basis()
  let m = a * a.transposed
  m ~= identity

proc isDiagonal*(a: Basis): bool =
  a[0][1] ~= 0.0 and a[0][2] ~= 0.0 and
  a[1][0] ~= 0.0 and a[1][2] ~= 0.0 and
  a[2][0] ~= 0.0 and a[2][1] ~= 0.0

proc isRotation*(a: Basis): bool =
  a.determinant ~= 1.0 and a.isOrthogonal

proc isSymmetric*(a: Basis): bool =
  if not (a[0][1] ~= a[1][0]):
    return false
  if not (a[0][2] ~= a[2][0]):
    return false
  if not (a[1][2] ~= a[2][1]):
    return false
  true

proc scale*(a: var Basis, scale: Vector3) =
  a[0][0] *= scale.x
  a[0][1] *= scale.x
  a[0][2] *= scale.x
  a[1][0] *= scale.y
  a[1][1] *= scale.y
  a[1][2] *= scale.y
  a[2][0] *= scale.z
  a[2][1] *= scale.z
  a[2][2] *= scale.z

proc scaled*(a: Basis, scale: Vector3): Basis =
  result = a
  result.scale(scale)

proc rotated*(a: Basis, axis: Vector3, angle: float): Basis =
  basis(axis, angle) * a

proc rotate*(a: var Basis, axis: Vector3, angle: float) =
  a = a.rotated(axis, angle)

proc rotatedLocal*(a: Basis, axis: Vector3, angle: float): Basis =
  a * basis(axis, angle)

proc rotateLocal*(a: var Basis, axis: Vector3, angle: float) =
  a = a.rotatedLocal(axis, angle)

proc lookingAt*(a: Basis, target, up: Vector3): Basis =
  let zero = vector3()
  assert(not (target ~= zero), "The target vector can't be zero.")
  assert(not (up ~= zero), "The up vector can't be zero.")
  let vz = -target.normalized
  var vx = up.cross(vz)
  assert(not (vx ~= zero), "The target vector and up vector can't be parallel to each other.")
  vx = vx.normalized
  let vy = vz.cross(vx)
  result.set(vx, vy, vz)

{.pop.}