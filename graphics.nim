import
  opengl,
  ezwin/window,
  graphics/[context, shader]

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
void main() {
  color = vec4(1.0, 0.0, 0.0, 1.0);
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

  var
    vertexBuffer: cuint
    vertices = [
      0.5.float32, 0.5, 0.0, # top right
      0.5, -0.5, 0.0, # bottom right
      -0.5, -0.5, 0.0, # bottom left
      -0.5, 0.5, 0.0, # top left
    ]

  glGenBuffers(
    n = 1,
    buffers = vertexBuffer.addr,
  )
  glBindBuffer(
    target = GL_ARRAY_BUFFER,
    buffer = vertexBuffer,
  )
  glBufferData(
    target = GL_ARRAY_BUFFER,
    size = vertices.len * float32.sizeof,
    data = vertices.addr,
    usage = GL_STATIC_DRAW,
  )
  glEnableVertexAttribArray(
    index = 0
  )
  glVertexAttribPointer(
    index = 0,
    size = 3,
    `type` = cGL_FLOAT,
    normalized = GL_FALSE,
    stride = float32.sizeof * 3,
    `pointer` = cast[pointer](0),
  )

  var
    indexBuffer: cuint
    indices = [
      0.cuint, 1, 3, # first triangle
      1, 2, 3, # second triangle
    ]

  glGenBuffers(
    n = 1,
    buffers = indexBuffer.addr,
  )
  glBindBuffer(
    target = GL_ELEMENT_ARRAY_BUFFER,
    buffer = indexBuffer,
  )
  glBufferData(
    target = GL_ELEMENT_ARRAY_BUFFER,
    size = indices.len * cuint.sizeof,
    data = indices.addr,
    usage = GL_STATIC_DRAW,
  )

  while not wnd.shouldClose:
    wnd.pollEvents()
    glClear(GL_COLOR_BUFFER_BIT)
    glDrawElements(GL_TRIANGLES, indices.len.GLsizei, GL_UNSIGNED_INT, nil)
    ctx.swapBuffers()

  glDeleteProgram(shdr)