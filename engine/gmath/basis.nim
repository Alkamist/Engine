import vector3

type
  GBasis*[T] = object
    elements: array[3, GVector3[T]]

  Basis* = GBasis[float32]
  DBasis* = GBasis[float64]

{.push inline.}

proc getAxis*[T](a: GBasis[T], i: int): GVector3[T] =
  result.x = a.elements[0][i]
  result.y = a.elements[1][i]
  result.z = a.elements[2][i]

proc setAxis*[T](a: var GBasis[T], i: int, v: GVector3[T]) =
  a.elements[0][i] = v.x
  a.elements[1][i] = v.y
  a.elements[2][i] = v.z

template x*[T](a: GBasis[T]): untyped = a.getAxis(0)
template y*[T](a: GBasis[T]): untyped = a.getAxis(1)
template z*[T](a: GBasis[T]): untyped = a.getAxis(2)

template `x=`*[T](a: GBasis[T], v: GVector3[T]): untyped = a.setAxis(0, v)
template `y=`*[T](a: GBasis[T], v: GVector3[T]): untyped = a.setAxis(1, v)
template `z=`*[T](a: GBasis[T], v: GVector3[T]): untyped = a.setAxis(2, v)

template `[]`*[T](a: GBasis[T], i: int): untyped = a.elements[i]
template `[]=`*[T](a: GBasis[T], i: int, v: GVector3[T]): untyped = a.elements[i] = v

proc setElements*[T](a: var GBasis[T],
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

proc gbasis*[T](xx, xy, xz: T,
                yx, yy, yz: T,
                zx, zy, zz: T): GBasis[T] =
  result.setElements(xx, xy, xz, yx, yy, yz, zx, zy, zz)

proc gbasis*[T](row0: GVector3[T] = gvector3[T](1.0, 0.0, 0.0),
                row1: GVector3[T] = gvector3[T](0.0, 1.0, 0.0),
                row2: GVector3[T] = gvector3[T](0.0, 0.0, 1.0)): GBasis[T] =
  result[0] = row0
  result[1] = row1
  result[2] = row2

proc basis*(xx, xy, xz: float32,
            yx, yy, yz: float32,
            zx, zy, zz: float32): Basis =
  result.setElements(xx, xy, xz, yx, yy, yz, zx, zy, zz)

proc basis*(row0 = vector3(1.0, 0.0, 0.0),
            row1 = vector3(0.0, 1.0, 0.0),
            row2 = vector3(0.0, 0.0, 1.0)): Basis =
  result[0] = row0
  result[1] = row1
  result[2] = row2

proc getColumn*[T](a: GBasis[T], i: int): GVector3[T] =
  result.x = a[0][i]
  result.y = a[1][i]
  result.z = a[2][i]

proc getRow*[T](a: GBasis[T], i: int): GVector3[T] =
  result.x = a[i][0]
  result.y = a[i][1]
  result.z = a[i][2]

proc mainDiagonal*[T](a: GBasis[T]): GVector3[T] =
  result.x = a[0][0]
  result.y = a[1][1]
  result.z = a[2][2]

proc setZero*[T](a: var GBasis[T]): GVector3[T] =
  a[0] = vector3Zero
  a[1] = vector3Zero
  a[2] = vector3Zero

proc tDotX*[T](a: GBasis[T], v: GVector3[T]): T =
  a[0][0] * v[0] + a[1][0] * v[1] + a[2][0] * v[2]

proc tDotY*[T](a: GBasis[T], v: GVector3[T]): T =
  a[0][1] * v[0] + a[1][1] * v[1] + a[2][1] * v[2]

proc tDotZ*[T](a: GBasis[T], v: GVector3[T]): T =
  a[0][2] * v[0] + a[1][2] * v[1] + a[2][2] * v[2]

proc `*`*[T](a, b: GBasis[T]): GBasis[T] =
  gbasis[T](
    b.tdotx(a[0]), b.tdoty(a[0]), b.tdotz(a[0]),
    b.tdotx(a[1]), b.tdoty(a[1]), b.tdotz(a[1]),
    b.tdotx(a[2]), b.tdoty(a[2]), b.tdotz(a[2]),
  )

proc `*=`*[T](a: var GBasis[T], b: GBasis[T]) =
  a.setElements(
    b.tdotx(a[0]), b.tdoty(a[0]), b.tdotz(a[0]),
    b.tdotx(a[1]), b.tdoty(a[1]), b.tdotz(a[1]),
    b.tdotx(a[2]), b.tdoty(a[2]), b.tdotz(a[2]),
  )

proc `+=`*[T](a: var GBasis[T], b: GBasis[T]) =
  a[0] += b.a[0]
  a[1] += b.a[1]
  a[2] += b.a[2]

proc `+`*[T](a, b: GBasis[T]): GBasis[T] =
  result = a
  result += b

proc `-=`*[T](a: var GBasis[T], b: GBasis[T]) =
  a[0] -= b.a[0]
  a[1] -= b.a[1]
  a[2] -= b.a[2]

proc `-`*[T](a, b: GBasis[T]): GBasis[T] =
  result = a
  result -= b

proc `*=`*[T](a: var GBasis[T], value: T) =
  a[0] *= value
  a[1] *= value
  a[2] *= value

proc `*`*[T](a: GBasis[T], value: T): GBasis[T] =
  result = a
  result *= value

proc `~=`*[T](a, b: GBasis[T]): bool =
  a[0] ~= b[0] and a[1] ~= b[1] and a[2] ~= b[2]

proc xform*[T](a: GBasis[T], v: GVector3[T]): GVector3[T] =
  result.x = a[0].dot(v)
  result.y = a[1].dot(v)
  result.z = a[2].dot(v)

proc xformInverse*[T](a: GBasis[T], v: GVector3[T]): GVector3[T] =
  result.x = (a[0][0] * v.x) + (a[1][0] * v.y) + (a[2][0] * v.z)
  result.y = (a[0][1] * v.x) + (a[1][1] * v.y) + (a[2][1] * v.z)
  result.z = (a[0][2] * v.x) + (a[1][2] * v.y) + (a[2][2] * v.z)

proc determinant*[T](a: GBasis[T]): T =
  a[0][0] * (a[1][1] * a[2][2] - a[2][1] * a[1][2]) -
  a[1][0] * (a[0][1] * a[2][2] - a[2][1] * a[0][2]) +
  a[2][0] * (a[0][1] * a[1][2] - a[1][1] * a[0][2])

proc transposeXform*[T](a, b: GBasis[T]): GBasis[T] =
  gbasis[T](
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

proc inverse*[T](a: GBasis[T]): GBasis[T] =
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
  gbasis[T](
    co[0] * s, cofac(0, 2, 2, 1) * s, cofac(0, 1, 1, 2) * s,
    co[1] * s, cofac(0, 0, 2, 2) * s, cofac(0, 2, 1, 0) * s,
    co[2] * s, cofac(0, 1, 2, 0) * s, cofac(0, 0, 1, 1) * s,
  )

proc orthonormalize*[T](a: GBasis[T]): GBasis[T] =
  var x = a.x
  var y = a.y
  var z = a.z
  x = x.normalize
  y = y - x * x.dot(y)
  y = y.normalize
  z = z - x * x.dot(z) - y * y.dot(z)
  z = z.normalize
  result.x = x
  result.y = y
  result.z = z

proc transpose*[T](a: GBasis[T]): GBasis[T] =
  template swap(x, y): untyped =
    let temp = x
    x = y
    y = temp
  result = a
  swap(result[0][1], result[1][0])
  swap(result[0][2], result[2][0])
  swap(result[1][2], result[2][1])

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

proc scale*[T](a: GBasis[T], by: GVector3[T]): GBasis[T] =
  result = a
  result[0][0] *= by.x
  result[0][1] *= by.x
  result[0][2] *= by.x
  result[1][0] *= by.y
  result[1][1] *= by.y
  result[1][2] *= by.y
  result[2][0] *= by.z
  result[2][1] *= by.z
  result[2][2] *= by.z

proc setAxisAngle*[T](a: var GBasis[T], axis: GVector3[T], angle: T) =
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

proc rotate*[T](a: GBasis[T], axis: GVector3[T], angle: T): GBasis[T] =
  var m = gbasis[T]()
  m.setAxisAngle(axis, angle)
  m * a

proc rotateLocal*[T](a: GBasis[T], axis: GVector3[T], angle: T): GBasis[T] =
  var m = gbasis[T]()
  m.setAxisAngle(axis, angle)
  a * m

proc lookAt*[T](a: GBasis[T], target, up: GVector3[T]): GBasis[T] =
  let zero = vector3Zero.asType(T)
  assert(not target ~= zero, "The target vector can't be zero.")
  assert(not up ~= zero, "The up vector can't be zero.")
  let vz = -target.normalize
  var vx = up.cross(vz)
  assert(not vx ~= zero, "The target vector and up vector can't be parallel to each other.")
  vx = vx.normalize
  let vy = vz.cross(vx)
  result.x = vx
  result.y = vy
  result.z = vz

{.pop.}