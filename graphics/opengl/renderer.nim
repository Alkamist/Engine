import opengl
import chroma
import context, gpubuffer, indexbuffer

type
  Renderer* = object
    context*: Context

proc toGlEnum*(t: typedesc): GLenum =
  if t is float32: cGL_FLOAT
  elif t is float64: cGL_DOUBLE
  elif t is int8: cGL_BYTE
  elif t is uint8: cGL_UNSIGNED_BYTE
  elif t is int16: cGL_SHORT
  elif t is uint16: cGL_UNSIGNED_SHORT
  elif t is int32: cGL_INT
  elif t is uint32: GL_UNSIGNED_INT
  else:
    raise newException(IOError, "Could not convert data type to GLenum.")

proc `backgroundColor=`*(renderer: Renderer, color: Color) =
  glClearColor(color.r, color.g, color.b, color.a)

proc clear*(renderer: Renderer) =
  glClear(GL_COLOR_BUFFER_BIT)

proc drawBuffer*[I](renderer: Renderer,
                    vertices: var GpuBuffer,
                    indices: IndexBuffer[I]) =
  vertices.useLayout()
  indices.select()
  glDrawElements(
    GL_TRIANGLES,
    indices.len.GLsizei,
    I.toGlEnum,
    nil
  )

proc drawBuffer*(renderer: Renderer, vertices: var GpuBuffer) =
  vertices.useLayout()
  glDrawArrays(
    GL_TRIANGLES,
    0,
    vertices.numValues.GLsizei,
  )

proc swapFrames*(renderer: Renderer) =
  renderer.context.swapFrames()

proc initRenderer*(context: Context): Renderer =
  result.context = context