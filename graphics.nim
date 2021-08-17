import
  opengl,
  ezwin/window,
  graphics/[renderer, buffer, shader]

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
  var wndw = newWindow(
    title = "Test Window",
    x = 2.0,
    y = 2.0,
    width = 4.0,
    height = 4.0,
  )

  var rndr = initRenderer(wndw.handle)
  rndr.backgroundColor = rgb(16, 16, 16)

  let shdr = createShader(vertexShader, fragmentShader)
  glUseProgram(shdr)

  let colorLocation = glGetUniformLocation(shdr, "u_Color")
  glUniform4f(colorLocation, 0.2, 0.3, 0.8, 1.0)

  var vertexBuffer = initBuffer()
  vertexBuffer.data = [
    [-0.5, -0.5, 0.0],
    [0.5, -0.5, 0.0],
    [0.5, 0.5, 0.0],
    # (-0.5, 0.5, 0.0),
  ]
  vertexBuffer.useLayout()

  # var indexBuffer = initBuffer()
  # indexBuffer.data = [
  #   (0, 1, 2),
  #   (2, 3, 0),
  # ]
  # var indexCount = 0
  # for attribute in indexBuffer.attributes:
  #   indexCount += attribute.count

  while not wndw.shouldClose:
    wndw.pollEvents()
    rndr.clear()
    glDrawArrays(GL_TRIANGLES, 0, 3)
    # glDrawElements(GL_TRIANGLES, indexCount.GLsizei, cGL_INT, nil)
    rndr.swapBuffers()

  glDeleteProgram(shdr)