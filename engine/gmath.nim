import vmath
export vmath

import math
export math

template toArray*[T](v: GVec2[T]): array[2, T] = [v.x, v.y]
template toArray*[T](v: GVec3[T]): array[3, T] = [v.x, v.y, v.z]
template toArray*[T](v: GVec4[T]): array[4, T] = [v.x, v.y, v.z, v.w]

template x*[T](m: GMat4[T]): T = m[3, 0]
template y*[T](m: GMat4[T]): T = m[3, 1]
template z*[T](m: GMat4[T]): T = m[3, 2]

proc normal*[T](v: GVec2[T]): GVec2[T] =
  vec2(-v.y, v.x).normalize

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