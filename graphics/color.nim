type
  Color* = object
    r*, g*, b*, a*: float

proc rgb*(r, g, b: float, a = 1.0): Color =
  Color(r: r, g: g, b: b, a: a)

proc redistribute*(color: Color): Color =
  let
    threshold = 255.999
    r = color.r
    b = color.b
    g = color.g
    a = color.a
    m = r.max(g).max(b)

  if m <= threshold:
    return Color(r: r, g: g, b: b, a: a)

  let total = r + g + b
  if total >= 3.0 * threshold:
    return Color(r: threshold, g: threshold, b: threshold, a: a)

  let
    x = (3.0 * threshold - total) / (3.0 * m - total)
    gray = threshold - x * m

  Color(
    r: gray + x * r,
    g: gray + x * g,
    b: gray + x * b,
    a: a,
  )

proc `*`*(color: Color, value: SomeNumber): Color =
  result.r = color.r * value
  result.g = color.g * value
  result.b = color.b * value
  result.a = color.a

proc `/`*(color: Color, value: SomeNumber): Color =
  result.r = color.r / value
  result.g = color.g / value
  result.b = color.b / value
  result.a = color.a