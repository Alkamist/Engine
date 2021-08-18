import
  opengl,
  ezwin/window,
  graphics/[context, renderer, gfxbuffer, shader, color]

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

  wndw.onResize = proc =
    glViewport(0.GLsizei, 0.GLsizei,
               wndw.clientWidthPixels.GLsizei, wndw.clientHeightPixels.GLsizei)

  var
    position = (0.0'f32, 0.0'f32)
    velocity = 0.01

  var rndr = initRenderer(initContext(wndw.handle))
  rndr.backgroundColor = rgb(16, 16, 16)

  let shdr = createShader(vertexShader, fragmentShader)
  glUseProgram(shdr)

  let colorLocation = glGetUniformLocation(shdr, "u_Color")
  glUniform4f(colorLocation, 0.2, 0.3, 0.8, 1.0)

  var vertexBuffer = initGfxBuffer(GfxBufferKind.Vertex)
  var indexBuffer = initGfxBuffer(GfxBufferKind.Index)
  indexBuffer.data = [
    [0'u32, 1, 2],
    [2'u32, 3, 0],
  ]

  while not wndw.shouldClose:
    wndw.pollEvents()

    position[0] += velocity
    if position[0] > 1.0: velocity = -0.01
    elif position[0] < 0.0: velocity = 0.01

    vertexBuffer.data = [
      [position[0] - 0.5'f32, position[1] - 0.5],
      [position[0] + 0.5'f32, position[1] - 0.5],
      [position[0] + 0.5'f32, position[1] + 0.5],
      [position[0] - 0.5'f32, position[1] + 0.5],
    ]

    rndr.clear()
    rndr.drawBuffer(vertexBuffer, indexBuffer)
    rndr.swapFrames()

  glDeleteProgram(shdr)