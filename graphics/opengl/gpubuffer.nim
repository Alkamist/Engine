import opengl
import vmath
import ../tupletoarray

type SomeVec*[T] = GVec2[T] | GVec3[T] | GVec4[T]
proc toArray*[T](vec: GVec2[T]): array[2, T] = [vec.x, vec.y]
proc toArray*[T](vec: GVec3[T]): array[3, T] = [vec.x, vec.y, vec.z]
proc toArray*[T](vec: GVec4[T]): array[4, T] = [vec.x, vec.y, vec.z, vec.w]

type
  GpuBufferKind* {.pure.} = enum
    Vertex,
    Index,

  GpuDataType* {.pure.} = enum
    Float,
    Int,
    UInt,

  Attribute* = object
    numValues*: int
    dataTypeNumBytes*: int
    dataType*: GpuDataType

  GpuBuffer* = object
    kind*: GpuBufferKind
    numValues*: int
    attributes*: seq[Attribute]
    openGlId*: GLuint

proc toGlEnum*(kind: GpuBufferKind): GLenum =
  case kind:
  of Vertex: GL_ARRAY_BUFFER
  of Index: GL_ELEMENT_ARRAY_BUFFER

proc toGlEnum*(attribute: Attribute): GLenum =
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

proc toGfxDataType*(t: typedesc): GpuDataType =
  if t is SomeFloat: Float
  elif t is SomeSignedInt: Int
  elif t is SomeUnsignedInt: UInt
  else: raise newException(IOError, "Improper type for toGfxDataType.")

proc toAttribute*[T](arr: openArray[T]): Attribute =
  result.numValues = arr.len
  result.dataTypeNumBytes = arr[0].sizeof
  result.dataType = arr[0].typeof.toGfxDataType

proc numBytes*(attribute: Attribute): int =
  attribute.numValues * attribute.dataTypeNumBytes

proc vertexNumBytes*(buffer: GpuBuffer): int =
  for attribute in buffer.attributes:
    result += attribute.numBytes

proc vertexNumValues*(buffer: GpuBuffer): int =
  for attribute in buffer.attributes:
    result += attribute.numValues
  result *= buffer.numValues

proc getAttributes*[T: tuple|array|SomeVec[SomeNumber]](vertex: T): seq[Attribute] =
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
      elif attribute is SomeVec[SomeNumber]: result.add attribute.toArray.toAttribute
      else: raise newException(IOError, "When using a tuple vertex, ensure that all attributes are either tuples or arrays.")

  elif vertex is SomeVec[SomeNumber]:
    result.add vertex.toArray.toAttribute

proc select*(buffer: GpuBuffer) =
  glBindBuffer(buffer.kind.toGlEnum, buffer.openGlId)

proc `data=`*[T](buffer: var GpuBuffer, data: openArray[T]) =
  if data.len > 0:
    buffer.numValues = data.len

    var dataSeq = newSeq[T](data.len)
    for i, v in data:
      dataSeq[i] = v

    buffer.attributes = data[0].getAttributes
    buffer.select()

    glBufferData(
      target = buffer.kind.toGlEnum,
      size = dataSeq.len * dataSeq[0].sizeof,
      data = dataSeq[0].addr,
      usage = GL_STATIC_DRAW,
    )

proc useLayout*(buffer: var GpuBuffer) =
  buffer.select()
  let vertexNumBytes = buffer.vertexNumBytes
  var byteOffset = 0
  for i, attribute in buffer.attributes:
    glEnableVertexAttribArray(i.GLuint)
    glVertexAttribPointer(
      index = i.GLuint,
        # the 0 based index of the attribute
      size = attribute.numValues.GLint,
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

proc `=destroy`*(buffer: var GpuBuffer) =
  glDeleteBuffers(1, buffer.openGlId.addr)

proc initGpuBuffer*(kind: GpuBufferKind): GpuBuffer =
  result.kind = kind
  glGenBuffers(1, result.openGlId.addr)

proc initAttribute*(numValues: int,
                    dataTypeNumBytes: int,
                    dataType: GpuDataType): Attribute =
  result.numValues = numValues
  result.dataTypeNumBytes = dataTypeNumBytes
  result.dataType = dataType

when isMainModule:
  assert ((0.0, 1.0, 2.0),).getAttributes == @[initAttribute(3, 8, Float)]
  assert ([0.0, 0.5, 1.0], (1, 2)).getAttributes == @[initAttribute(3, 8, Float), initAttribute(2, 8, Int)]
  assert [0.0, 1.0, 1.0].getAttributes == @[initAttribute(3, 8, Float)]
  assert [(0.0, 1.0), (1.0, 2.0)].getAttributes == @[initAttribute(2, 8, Float), initAttribute(2, 8, Float)]
  doAssertRaises(IOError):
    discard (0.0, (1.0, 2.0)).getAttributes