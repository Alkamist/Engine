import
  opengl,
  ezwin/window,
  graphics/[context, buffer, shader]

const vertexShader = """
#version 330 core
layout(location = 0) in vec4 position;
void main() {
  gl_Position = position;
}
"""

const fragmentShader = """
#version 330 core
layout(location = 0) out vec4 color;
uniform vec4 u_Color;
void main() {
  color = u_Color;
}
"""

when isMainModule:
  var wnd = newWindow(
    title = "Test Window",
    x = 2.0,
    y = 2.0,
    width = 4.0,
    height = 4.0,
  )

  var ctx = initContext(wnd.handle)

  let shdr = createShader(vertexShader, fragmentShader)
  glUseProgram(shdr)

  let colorLocation = glGetUniformLocation(shdr, "u_Color")
  glUniform4f(colorLocation, 0.2, 0.3, 0.8, 1.0)

  var vertexBuffer = initBuffer()
  vertexBuffer.data = [
    ((-0.5, -0.5, 0.0), (5'i32, 5'i32)),
    ((0.0, 0.5, 0.0), (5'i32, 5'i32)),
    ((0.5, -0.5, 0.0), (5'i32, 5'i32)),
  ]
  vertexBuffer.useLayout()

  while not wnd.shouldClose:
    wnd.pollEvents()
    glClear(GL_COLOR_BUFFER_BIT)
    glDrawArrays(GL_TRIANGLES, 0, 3)
    # glDrawElements(GL_TRIANGLES, indices.len.GLsizei, GL_UNSIGNED_INT, nil)
    ctx.swapBuffers()

  glDeleteProgram(shdr)