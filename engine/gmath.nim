import vmath
export vmath

template x*[T](m: GMat4[T]): T = m[3, 0]
template y*[T](m: GMat4[T]): T = m[3, 1]
template z*[T](m: GMat4[T]): T = m[3, 2]

{.push inline.}

proc position*[T](m: GMat4[T]): GVec3[T] =
  result.x = m.x
  result.y = m.y
  result.z = m.z

proc translate*[T](m: var GMat4[T], by: GVec3[T]) =
  m = m * by.translate

proc scale*[T](m: var GMat4[T], by: GVec3[T]) =
  m = m * by.scale

proc identity*(): Mat4 =
  mat4(
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0,
  )

{.pop.}