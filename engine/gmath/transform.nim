import basis, vector3

type
  GTransform*[T] = object
    basis*: GBasis[T]
    origin*: GVector3[T]

  Transform* = GTransform[float32]