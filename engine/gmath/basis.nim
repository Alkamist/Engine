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

proc gbasis*[T](x: GVector3[T] = gvector3(1.0, 0.0, 0.0),
                y: GVector3[T] = gvector3(0.0, 1.0, 0.0),
                z: GVector3[T] = gvector3(0.0, 0.0, 1.0)): GBasis[T] =
  result.x = x
  result.y = y
  result.z = z

proc basis*(xx, xy, xz: float32,
            yx, yy, yz: float32,
            zx, zy, zz: float32): Basis =
  result.setElements(xx, xy, xz, yx, yy, yz, zx, zy, zz)

proc basis*(x = vector3(1.0, 0.0, 0.0),
            y = vector3(0.0, 1.0, 0.0),
            z = vector3(0.0, 0.0, 1.0)): Basis =
  result.x = x
  result.y = y
  result.z = z

proc column*[T](a: GBasis[T], i: int): GVector3[T] =
  result.x = a[0][i]
  result.y = a[1][i]
  result.z = a[2][i]

proc row*[T](a: GBasis[T], i: int): GVector3[T] =
  result.x = a[i][0]
  result.y = a[i][1]
  result.z = a[i][2]

proc mainDiagonal*[T](a: GBasis[T]): GVector3[T] =
  result.x = a[0][0]
  result.y = a[1][1]
  result.z = a[2][2]

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

# proc isOrthogonal*[T](a: GBasis[T]): bool =
#   let identity = gbasis[T]()
#   a * a.transposed




# bool Basis::is_orthogonal() const {
# 	Basis identity;
# 	Basis m = (*this) * transposed();

# 	return m.is_equal_approx(identity);
# }

{.pop.}