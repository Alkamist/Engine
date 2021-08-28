import vector3

type
  GBasis*[T] = object
    x*, y*, z*: GVector3[T]

  Basis* = GBasis[float32]

proc gbasis*[T](x: GVector3[T] = gvector3(1.0, 0.0, 0.0),
                y: GVector3[T] = gvector3(0.0, 1.0, 0.0),
                z: GVector3[T] = gvector3(0.0, 0.0, 1.0)): GBasis[T] =
  GBasis[T](x: x, y: y, z: z)

proc basis*(x = vector3(1.0, 0.0, 0.0),
            y = vector3(0.0, 1.0, 0.0),
            z = vector3(0.0, 0.0, 1.0)): Basis =
  gbasis[float32](x, y, z)