import ../engine/gmath

type
  Vec3* = object
    coord: array[3, float32]

template x*(a: Vec3): untyped = a.coord[0]
template y*(a: Vec3): untyped = a.coord[1]
template z*(a: Vec3): untyped = a.coord[2]

template `x=`*(a: Vec3, v: float32): untyped = a.coord[0] = v
template `y=`*(a: Vec3, v: float32): untyped = a.coord[1] = v
template `z=`*(a: Vec3, v: float32): untyped = a.coord[2] = v

var a = Vec3(coord: [1.0'f32, 0.0, 0.0])

echo a + a
echo a + 1
echo 1 + a
a += a
echo a
echo a ~= a
echo -a
echo a.mapIt(it * 5.0)
a.applyIt(it * 5.0)
echo a.dot(a)
echo a.length
echo a.lengthSquared
echo a.isNormalized
echo a.distanceTo(a)
echo a.distanceSquaredTo(a)
a.setAll(0.0)
a.setZero()
echo a.cross(a)
# a.normalize

# var a = vector3(1.0, 2.0, 3.0)
# var b = vector3(0.0, 1.0, 0.0)

# echo a.lerp(b, 0.5)
# echo a.reflect(b)
# echo a.bounce(b)
# echo a.slide(b)
# echo a.mapIt(it.sin)
# echo a + a
# echo -a

# echo a.isNormalized
# echo a.length

# var basis = basis(b, 0.5)

# echo basis.rotated(b, 0.5)