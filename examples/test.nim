import ../engine/gmath

var a = vector3(1.0, 2.0, 3.0)
var b = vector3(0.0, 1.0, 0.0)

echo a.lerp(b, 0.5)
echo a.reflect(b)
echo a.bounce(b)
echo a.slide(b)
echo a.isNormalized
echo a.mapIt(it.sin)
echo a.length
echo a + a
echo -a

var basis = basis(b, 0.5)

echo basis.rotated(b, 0.5)