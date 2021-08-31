import ../engine/gmath

var a = vector3(1.0, 2.0, 3.0)

echo a + a
echo a + 1
echo 1 + a
a += a
a += 1
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
a.normalize

a = vector3(0.0, 1.0, 0.0)

var basis = basis(a, 0.5)

echo basis.rotated(a, 0.5)