proc snapped*[T: SomeFloat](value, step: T): T =
  if step != 0.0:
    (value / step + 0.5).floor * step
  else:
    value

proc `~=`*[T: SomeFloat](a, b: T): bool =
  const epsilon = 0.000001
  (a - b).abs <= epsilon