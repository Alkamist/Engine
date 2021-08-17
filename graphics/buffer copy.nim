import
  std/macros,
  opengl

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

proc numFields[T](x: T): int =
  for _ in x.fields:
    result.inc

type
  GfxDataType* = enum
    I8, U8,
    I16, U16,
    I32, U32,
    F32, F64,

  Attribute* = object
    count*: int
    typ*: GfxDataType

  Buffer* = object
    attributes*: seq[Attribute]
    openGlId*: GLuint

proc toGlEnum(dataType: GfxDataType): GLenum =
  case dataType:
  of I8: cGL_BYTE
  of U8: cGL_UNSIGNED_BYTE
  of I16: cGL_SHORT
  of U16: cGL_UNSIGNED_SHORT
  of I32: cGL_INT
  of U32: GL_UNSIGNED_INT
  of F32: cGL_FLOAT
  of F64: cGL_DOUBLE

proc toGfxDataType*(typ: typedesc): GfxDataType =
  if typ is int8: I8
  elif typ is uint8: U8
  elif typ is int16: I16
  elif typ is uint16: U16
  elif typ is int32: I32
  elif typ is uint32: U32
  elif typ is int: I32
  elif typ is uint: U32
  elif typ is float32: F32
  elif typ is float64: F64
  elif typ is float: F64
  else: raise newException(IOError, "Improper type for toGfxDataType.")

proc numBytes*(typ: GfxDataType): int =
  case typ:
  of I8: 1
  of U8: 1
  of I16: 2
  of U16: 2
  of I32: 4
  of U32: 4
  of F32: 4
  of F64: 8

proc numBytes*(attribute: Attribute): int =
  attribute.count * attribute.typ.numBytes

proc vertexNumBytes*(buffer: Buffer): int =
  for attribute in buffer.attributes:
    result += attribute.numBytes

proc toAttribute*[T](arr: openArray[T]): Attribute =
  result.count = arr.len
  result.typ = arr[0].typeof.toGfxDataType

proc getAttributes*[T](vertex: T): seq[Attribute] =
  let vertexAsArray = vertex.toArray
  for value in vertexAsArray:
    result.add fieldAsArray.toAttribute

proc select*(buffer: Buffer) =
  glBindBuffer(GL_ARRAY_BUFFER, buffer.openGlId)

proc `data=`*[T](buffer: var Buffer, data: openArray[T]) =
  if data.len > 0:
    buffer.attributes = data[0].getAttributes
    buffer.select()
    var dataSeq = newSeq[T](data.len)
    for i, v in data:
      dataSeq[i] = v
    glBufferData(
      target = GL_ARRAY_BUFFER,
      size = dataSeq.len * dataSeq[0].sizeof,
      data = dataSeq[0].addr,
      usage = GL_STATIC_DRAW,
    )

proc useLayout*(buffer: var Buffer) =
  let vertexNumBytes = buffer.vertexNumBytes
  var byteOffset = 0
  for i, attribute in buffer.attributes:
    glEnableVertexAttribArray(i.GLuint)
    glVertexAttribPointer(
      index = i.GLuint,
        # the 0 based index of the attribute
      size = attribute.count.GLint,
        # the number of values in the attribute
      `type` = attribute.typ.toGlEnum,
        # the type of value present in the attribute
      normalized = GL_FALSE,
        # normalize the values from 0 to 1 on the gpu
      stride = vertexNumBytes.GLsizei,
        # byte offset of each vertex
      `pointer` = cast[pointer](byteOffset),
        # byte offset of the start of the attribute, cast as a pointer
    )
    byteOffset += attribute.numBytes

proc `=destroy`*(buffer: var Buffer) =
  glDeleteBuffers(1, buffer.openGlId.addr)

proc initBuffer*(): Buffer =
  glGenBuffers(1, result.openGlId.addr)

when isMainModule:
  let vertex1 = (-0.5, -0.5, 0.0)
  echo vertex1.getAttributes

  # let vertex2 = (-0.5, -0.5, 0.0, (5, 1))