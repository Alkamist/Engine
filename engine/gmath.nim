import std/math
export math

type
  Vector3* = concept x
    x.x
    x.y
    x.z

template x*(a): untyped = a[0]
template y*(a): untyped = a[1]
template z*(a): untyped = a[2]

template `x=`*(a, value): untyped = a[0] = value
template `y=`*(a, value): untyped = a[1] = value
template `z=`*(a, value): untyped = a[2] = value

template vector3AsResult(v, code): untyped =
  block:
    when v is array:
      var result {.inject.}: array[3, v.x.typeof]
    elif v is object:
      var result {.inject.} = typeof(v)()
    code
    result

template defineBinaryOperator(op): untyped =
  template op*(a, b: Vector3): untyped =
    vector3AsResult(a):
      result.x = op(a.x, b.x)
      result.y = op(a.y, b.y)
      result.z = op(a.z, b.z)

defineBinaryOperator(`+`)
defineBinaryOperator(`-`)
defineBinaryOperator(`*`)
defineBinaryOperator(`/`)
defineBinaryOperator(`mod`)
defineBinaryOperator(`div`)
defineBinaryOperator(`zmod`)

template mapIt*(v: Vector3, code): untyped =
  vector3AsResult(v):
    var it {.inject.} = v.x
    result.x = code
    it = v.y
    result.y = code
    it = v.z
    result.z = code

template length*(v: Vector3): untyped =
  (v.x * v.x + v.y * v.y + v.z * v.z).sqrt