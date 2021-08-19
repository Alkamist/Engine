import opengl
# import vmath
# import ../tupletoarray

# type SomeVec*[T] = GVec2[T] | GVec3[T] | GVec4[T]
# proc toArray*[T](vec: GVec2[T]): array[2, T] = [vec.x, vec.y]
# proc toArray*[T](vec: GVec3[T]): array[3, T] = [vec.x, vec.y, vec.z]
# proc toArray*[T](vec: GVec4[T]): array[4, T] = [vec.x, vec.y, vec.z, vec.w]

type
  IndexBufferDataType* = uint8 | uint16 | uint32

  IndexBuffer*[T: IndexBufferDataType] = object
    len*: int
    openGlId*: GLuint

# template dataType*[T](buffer: IndexBuffer[T]): typedesc = T

proc select*(buffer: IndexBuffer) =
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer.openGlId)

proc writeData*[T: IndexBufferDataType](buffer: var IndexBuffer, data: openArray[T]) =
  var dataSeq = newSeq[T](data.len)
  for i, v in data:
    dataSeq[i] = v

  buffer.len = data.len
  buffer.select()

  glBufferData(
    target = GL_ELEMENT_ARRAY_BUFFER,
    size = dataSeq.len * T.sizeof,
    data = dataSeq[0].addr,
    usage = GL_STATIC_DRAW,
  )

proc `=destroy`*[T](buffer: var IndexBuffer[T]) =
  glDeleteBuffers(1, buffer.openGlId.addr)

proc initIndexBuffer*[T](): IndexBuffer[T] =
  glGenBuffers(1, result.openGlId.addr)