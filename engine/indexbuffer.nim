import std/macros
import opengl

type
  IndexBuffer*[T: uint8|uint16|uint32] = object
    len*: int
    openGlId*: GLuint

proc typeToGlEnum*[T](buffer: IndexBuffer[T]): GLenum =
  when T is uint8: result = cGL_UNSIGNED_BYTE
  elif T is uint16: result = cGL_UNSIGNED_SHORT
  elif T is uint32: result = GL_UNSIGNED_INT
  else: error "Unsupported index buffer type for typeToGlEnum."

proc select*(buffer: IndexBuffer) =
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer.openGlId)

proc writeData*[T](buffer: var IndexBuffer, data: openArray[T]) =
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

proc genIndexBuffer*[T](): IndexBuffer[T] =
  glGenBuffers(1, result.openGlId.addr)