import tupletoarray

type
  VertexDataType {.pure.} = enum
    Float,
    Int,
    UInt,

  VertexAttribute = object
    count*: int
    dataTypeNumBytes*: int
    dataType*: VertexDataType

  Vertex* = object
    attributes: seq[VertexAttribute]
    dataPtr: pointer
    hasData: bool

proc toVertexDataType*(t: typedesc): VertexDataType =
  if t is SomeFloat: Float
  elif t is SomeSignedInt: Int
  elif t is SomeUnsignedInt: UInt
  else: raise newException(IOError, "Improper type for toVertexDataType.")

proc numBytes*(attribute: VertexAttribute): int =
  attribute.count * attribute.dataTypeNumBytes

proc toVertexAttribute*[T](arr: openArray[T]): VertexAttribute =
  result.count = arr.len
  result.dataTypeNumBytes = arr[0].sizeof
  result.dataType = arr[0].typeof.toVertexDataType

proc `=destroy`*(vertex: var Vertex) =
  if vertex.hasData:
    dealloc(vertex.dataPtr)

proc `data=`*[T: tuple](vertex: var Vertex, tupl: T) =
  vertex.attributes = @[]

  for field in tupl.fields:
    when field is array:
      vertex.attributes.add field.toVertexAttribute
    elif field is tuple:
      vertex.attributes.add field.toArray.toVertexAttribute
    elif field is SomeNumber:
      vertex.attributes.add [field].toVertexAttribute

  if vertex.hasData:
    vertex.dataPtr = realloc(vertex.dataPtr, tupl.sizeof)
  else:
    vertex.dataPtr = alloc(tupl.sizeof)
    vertex.hasData = true

  cast[ptr T](vertex.dataPtr)[] = tupl

proc initVertex*(): Vertex =
  result

when isMainModule:
  var vertex = initVertex()

  vertex.data = ((0.0, 1.0, 2.0), (1, 2))
  echo $vertex.attributes

  vertex.data = ([0.0, 1.0, 2.0], (1, 2), 1)
  echo $vertex.attributes

  # echo cast[ptr array[3, float]](vertex.dataPtr)[]