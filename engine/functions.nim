import opengl
import chroma
import indexbuffer, vertexbuffer, shader, texture

proc setBackgroundColor*(color: Color) =
  glClearColor(color.r, color.g, color.b, color.a)

proc clearBackground* =
  glClear(GL_COLOR_BUFFER_BIT)

proc clearDepthBuffer* =
  glClear(GL_DEPTH_BUFFER_BIT)

proc enableAlphaBlend* =
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

proc setViewport*(x, y, width, height: int) =
  glViewport(
    x.GLsizei, y.GLsizei,
    width.GLsizei, height.GLsizei,
  )

proc drawTriangles*[V, I](shader: Shader,
                          vertices: VertexBuffer[V],
                          indices: IndexBuffer[I]) =
  shader.select()
  vertices.selectLayout()
  indices.select()
  glDrawElements(
    GL_TRIANGLES,
    indices.len.GLsizei,
    indices.typeToGlEnum,
    nil
  )

proc drawTriangles*[V, I](shader: Shader,
                          vertices: VertexBuffer[V],
                          indices: IndexBuffer[I],
                          texture: Texture) =
  texture.select()
  drawTriangles(shader, vertices, indices)