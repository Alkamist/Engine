import opengl
import pixie
import ezwin
import ../graphics

const vertexShader = """
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

void main()
{
  gl_Position = vec4(aPos, 1.0f);
  TexCoord = aTexCoord;
}
"""

const fragmentShader = """
#version 330 core
out vec4 FragColor;

in vec2 TexCoord;

uniform sampler2D ourTexture;

void main()
{
    FragColor = texture(ourTexture, TexCoord);
}
"""

var wndw = newWindow(
  title = "Test Window",
  x = 2.0,
  y = 2.0,
  width = 4.0,
  height = 4.0,
)

wndw.onResize = proc =
  glViewport(
    0.GLsizei, 0.GLsizei,
    wndw.clientWidthPixels.GLsizei, wndw.clientHeightPixels.GLsizei
  )

var rndr = initRenderer(initContext(wndw.handle))
rndr.backgroundColor = graphics.rgb(16, 16, 16)

let shdr = createShader(vertexShader, fragmentShader)
glUseProgram(shdr)

var vertexBuffer = initGfxBuffer(GfxBufferKind.Vertex)
vertexBuffer.data = [
  ([0.5'f32,  0.5, 0.0], [1.0'f32, 1.0]),
  ([0.5'f32, -0.5, 0.0], [1.0'f32, 0.0]),
  ([-0.5'f32, -0.5, 0.0], [0.0'f32, 0.0]),
  ([-0.5'f32,  0.5, 0.0], [0.0'f32, 1.0]),
]

var indexBuffer = initGfxBuffer(GfxBufferKind.Index)
indexBuffer.data = [
  [0'u32, 1, 2],
  [2'u32, 3, 0],
]

var textureId: GLuint
glGenTextures(1, textureId.addr)
glBindTexture(GL_TEXTURE_2D, textureId)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
var texture = readImage("examples/concrete.png")
glTexImage2D(
  GL_TEXTURE_2D,
  0,
  GL_RGBA.GLint,
  texture.width.GLsizei,
  texture.height.GLsizei,
  0,
  GL_RGBA,
  GL_UNSIGNED_BYTE,
  texture.data[0].addr,
)
glGenerateMipmap(GL_TEXTURE_2D)

while not wndw.shouldClose:
  wndw.pollEvents()
  rndr.clear()
  rndr.drawBuffer(vertexBuffer, indexBuffer)
  rndr.swapFrames()

glDeleteProgram(shdr)













# proc perspective(fov = 90.0,
#                  zNear = 0.1,
#                  zFar = 1000.0,
#                  aspectRatio = 4.0 / 3.0): array[4, array[4, float32]] =
#   let fovRads = fov.radToDeg
#   let denom = tan(0.5 * fovRads)
#   let zDiff = (zFar - zNear)
#   [[(aspectRatio / denom).float32, 0.0, 0.0, 0.0],
#    [0'f32, 1.0 / denom, 0.0, 0.0],
#    [0'f32, 0.0, zFar / zDiff, 1.0],
#    [0'f32, 0.0, (-zFar * zNear) / zDiff, 0.0]]

# const vertexShader = """
# #version 330 core
# layout (location = 0) in vec3 aPos;
# layout (location = 1) in vec3 aTexCoord;

# out vec2 TexCoord;

# uniform mat4 transform;

# void main()
# {
#   gl_Position = transform * vec4(aPos, 1.0f);
#   TexCoord = aTexCoord;
# }
# """

# var projection = perspective()
# var transform = [
#   [1.0'f32, 0.0, 0.0, 0.0],
#   [0.0'f32, 1.0, 0.0, 0.0],
#   [0.0'f32, 0.0, 1.0, 0.0],
#   [0.0'f32, 0.0, 0.0, 1.0],
# ]
# glUniformMatrix4fv(glGetUniformLocation(shdr, "transform"), 1, GL_FALSE, cast[ptr GLfloat](transform[0].addr))
# glUniformMatrix4fv(glGetUniformLocation(shdr, "projection"), 1, GL_FALSE, cast[ptr GLfloat](projection[0].addr))