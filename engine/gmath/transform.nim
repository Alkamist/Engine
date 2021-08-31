import defs, basis, vector3

type
  Transform* = object
    basis*: Basis
    origin*: Vector3

{.push inline.}

proc inverseXform*(a, b: Transform): Transform =
  let v = b.origin - a.origin
  result.basis = a.basis.transposeXform(b.basis)
  result.origin = a.basis.xform(v)

proc set*(a: var Transform,
          xx, xy, xz: RealNumber,
          yx, yy, yz: RealNumber,
          zx, zy, zz: RealNumber,
          tx, ty, tz: RealNumber) =
  a.basis.set(xx, xy, xz, yx, yy, yz, zx, zy, zz)
  a.origin.x = tx
  a.origin.y = ty
  a.origin.z = tz

proc xform*(a: Transform, b: Vector3): Vector3 =
  result.x = a.basis[0].dot(b) + a.origin.x
  result.y = a.basis[1].dot(b) + a.origin.y
  result.z = a.basis[2].dot(b) + a.origin.z

proc xformInv*(a: Transform, b: Vector3): Vector3 =
  let v = b - a.origin
  result.x = (a.basis[0][0] * v.x) + (a.basis[1][0] * v.y) + (a.basis[2][0] * v.z)
  result.y = (a.basis[0][1] * v.x) + (a.basis[1][1] * v.y) + (a.basis[2][1] * v.z)
  result.z = (a.basis[0][2] * v.x) + (a.basis[1][2] * v.y) + (a.basis[2][2] * v.z)

proc `*=`*(a: var Transform, b: Transform) =
  a.origin = a.xform(b.origin)
  a.basis *= b.basis

proc `*`*(a, b: Transform): Transform =
  result = a
  result *= b

proc `*=`*(a: var Transform, b: float) =
  a.origin *= b
  a.basis *= b

proc `*`*(a: Transform, b: float): Transform =
  result = a
  result *= b

proc `~=`*(a, b: Transform): bool =
  (a.basis ~= b.basis) and (a.origin ~= b.origin)

proc `==`*(a, b: Transform): bool =
  (a.basis == b.basis) and (a.origin == b.origin)

proc affineInvert*(a: var Transform) =
  a.basis.invert()
  a.origin = a.basis.xform(-a.origin)

proc affineInverse*(a: Transform): Transform =
  result = a
  result.affineInvert()

proc invert*(a: var Transform) =
  a.basis.transpose()
  a.origin = a.basis.xform(-a.origin)

proc inverse*(a: Transform): Transform =
  ## This function assumes the basis is a rotation matrix, with no scaling.
  result = a
  result.invert()

proc rotated*(a: Transform, axis: Vector3, angle: float): Transform =
  result.basis = basis(axis, angle)
  result.origin = vector3()
  result *= a

proc rotate*(a: var Transform, axis: Vector3, angle: float) =
  a = a.rotated(axis, angle)

proc rotateBasis*(a: var Transform, axis: Vector3, angle: float) =
  a.basis.rotate(axis, angle)

proc lookingAt*(a: Transform, target, up: Vector3): Transform =
  result = a
  result.basis = a.basis.lookingAt(target - a.origin, up)

proc setLookAt*(a: var Transform, eye, target, up: Vector3) =
  a.basis = a.basis.lookingAt(target - eye, up)
  a.origin = eye

proc scale*(a: var Transform, scale: Vector3) =
  a.basis.scale(scale)
  a.origin *= scale

proc scaled*(a: Transform, scale: Vector3): Transform =
  result = a
  result.scale(scale)

proc scaleBasis*(a: var Transform, scale: Vector3) =
  a.basis.scale(scale)

proc translate*(a: var Transform, v: Vector3) =
  for i in 0 ..< 3:
    a.origin[i] += a.basis[i].dot(v)

proc translate*(a: var Transform, x, y, z: float) =
  a.translate(vector3(x, y, z))

proc translated*(a: Transform, v: Vector3): Transform =
  result = a
  result.translate(v)

proc orthonormalize*(a: var Transform) =
  a.basis.orthonormalize()

proc orthonormalized*(a: Transform): Transform =
  result = a
  result.orthonormalize()

proc transform*(basis: Basis, origin: Vector3): Transform =
  result.basis = basis
  result.origin = origin

proc transform*(x, y, z, origin: Vector3): Transform =
  result.origin = origin
  result.basis.x = x
  result.basis.y = y
  result.basis.z = z

proc transform*(xx, xy, xz: RealNumber,
                yx, yy, yz: RealNumber,
                zx, zy, zz: RealNumber,
                tx, ty, tz: RealNumber): Transform =
  result.set(xx, xy, xz, yx, yy, yz, zx, zy, zz, tx, ty, tz)

{.pop.}