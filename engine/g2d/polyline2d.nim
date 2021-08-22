import ../gmath

type
  PolyLine2d* = object
    vertices*: seq[Vec3]

proc segment2d(a, b: Vec3, thickness: float32): array[6, Vec3] =
  let diff = b - a
  let normal = vec3(-diff.y, diff.x, 0.0).normalize

  result[0] = a + normal * thickness
  result[1] = b + normal * thickness
  result[2] = b - normal * thickness

  result[3] = b - normal * thickness
  result[4] = a - normal * thickness
  result[5] = a + normal * thickness