import
  opengl,
  tupletoarray

type
  GfxDataType {.pure.} = enum
    Float,
    Int,
    UInt,

  Attribute = object
    count*: int
    dataTypeNumBytes*: int
    dataType*: GfxDataType

  GfxBuffer* = object
    attributes*: seq[Attribute]
    openGlId*: GLuint

proc toGlEnum(attribute: Attribute): GLenum =
  case attribute.dataTypeNumBytes:
  of 1:
    case attribute.dataType:
    of Int: return cGL_BYTE
    of UInt: return cGL_UNSIGNED_BYTE
    of Float: discard
  of 2:
    case attribute.dataType:
    of Int: return cGL_SHORT
    of UInt: return cGL_UNSIGNED_SHORT
    of Float: discard
  of 4:
    case attribute.dataType:
    of Int: return cGL_INT
    of UInt: return GL_UNSIGNED_INT
    of Float: return cGL_FLOAT
  of 8:
    case attribute.dataType:
    of Int: discard
    of UInt: discard
    of Float: return cGL_DOUBLE
  else:
    discard

  raise newException(IOError, "Could not convert Attribute to GLEnum.")

proc toGfxDataType*(t: typedesc): GfxDataType =
  if t is SomeFloat: Float
  elif t is SomeSignedInt: Int
  elif t is SomeUnsignedInt: UInt
  else: raise newException(IOError, "Improper type for toGfxDataType.")

proc toAttribute*[T](arr: openArray[T]): Attribute =
  result.count = arr.len
  result.dataTypeNumBytes = arr[0].sizeof
  result.dataType = arr[0].typeof.toGfxDataType

proc numBytes*(attribute: Attribute): int =
  attribute.count * attribute.dataTypeNumBytes

proc vertexNumBytes*(buffer: GfxBuffer): int =
  for attribute in buffer.attributes:
    result += attribute.numBytes

proc getAttributes*[T: tuple|array](vertex: T): seq[Attribute] =
  when vertex is array:
    for attribute in vertex:
      when attribute is array: result.add attribute.toAttribute
      elif attribute is tuple: result.add attribute.toArray.toAttribute
      elif attribute is SomeNumber:
        result.add vertex.toAttribute
        return
      else:
        raise newException(IOError, "Unsupported type for vertex attribute.")

  elif vertex is tuple:
    for attribute in vertex.fields:
      when attribute is array: result.add attribute.toAttribute
      elif attribute is tuple: result.add attribute.toArray.toAttribute
      else: raise newException(IOError, "When using a tuple vertex, ensure that all attributes are either tuples or arrays.")

proc select*(buffer: GfxBuffer) =
  glBindBuffer(GL_ARRAY_BUFFER, buffer.openGlId)

proc `data=`*[T](buffer: var GfxBuffer, data: openArray[T]) =
  if data.len > 0:
    var dataSeq = newSeq[T](data.len)
    for i, v in data:
      dataSeq[i] = v

    buffer.attributes = data[0].getAttributes
    buffer.select()

    glBufferData(
      target = GL_ARRAY_BUFFER,
      size = dataSeq.len * dataSeq[0].sizeof,
      data = dataSeq[0].addr,
      usage = GL_STATIC_DRAW,
    )

proc useLayout*(buffer: var GfxBuffer) =
  let vertexNumBytes = buffer.vertexNumBytes
  var byteOffset = 0
  for i, attribute in buffer.attributes:
    glEnableVertexAttribArray(i.GLuint)
    glVertexAttribPointer(
      index = i.GLuint,
        # the 0 based index of the attribute
      size = attribute.count.GLint,
        # the number of values in the attribute
      `type` = attribute.toGlEnum,
        # the type of value present in the attribute
      normalized = GL_FALSE,
        # normalize the values from 0 to 1 on the gpu
      stride = vertexNumBytes.GLsizei,
        # byte offset of each vertex
      `pointer` = cast[pointer](byteOffset),
        # byte offset of the start of the attribute, cast as a pointer
    )
    byteOffset += attribute.numBytes

proc `=destroy`*(buffer: var GfxBuffer) =
  glDeleteBuffers(1, buffer.openGlId.addr)

proc initBuffer*(): GfxBuffer =
  glGenBuffers(1, result.openGlId.addr)

proc initAttribute*(count: int,
                    dataTypeNumBytes: int,
                    dataType: GfxDataType): Attribute =
  result.count = count
  result.dataTypeNumBytes = dataTypeNumBytes
  result.dataType = dataType

when isMainModule:
  assert ((0.0, 1.0, 2.0),).getAttributes == @[initAttribute(3, 8, Float)]
  assert ([0.0, 0.5, 1.0], (1, 2)).getAttributes == @[initAttribute(3, 8, Float), initAttribute(2, 8, Int)]
  assert [0.0, 1.0, 1.0].getAttributes == @[initAttribute(3, 8, Float)]
  assert [(0.0, 1.0), (1.0, 2.0)].getAttributes == @[initAttribute(2, 8, Float), initAttribute(2, 8, Float)]
  doAssertRaises(IOError):
    discard (0.0, (1.0, 2.0)).getAttributes