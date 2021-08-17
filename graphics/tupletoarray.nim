import std/macros

macro typeOfFirstField*(tupl): untyped =
  tupl.getType[1].getType

macro arrayType*(tupl, fieldType): untyped =
  var t = tupl.getType
  let arraySize = t.len - 1
  result = nnkBracketExpr.newTree(
    ident "array",
    newIntLitNode(arraySize),
    fieldType,
  )

template toArray*(tupl, fieldType): untyped =
  var
    arr: tupl.arrayType(fieldType)
    i = 0
  for field in tupl.fields:
    arr[i] = field.fieldType
    i.inc
  arr

template toArray*(tupl): untyped =
  block:
    type fieldType = tupl.typeOfFirstField
    tupl.toArray(fieldType)