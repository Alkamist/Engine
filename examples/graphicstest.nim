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

var window = newWindow(
  title = "Test Window",
  x = 2.0,
  y = 2.0,
  width = 4.0,
  height = 4.0,
)

window.onResize = proc =
  glViewport(
    0.GLsizei, 0.GLsizei,
    window.clientWidthPixels.GLsizei, window.clientHeightPixels.GLsizei
  )

var renderer = initRenderer(initContext(window.handle))
renderer.backgroundColor = color(0.05, 0.05, 0.05, 1.0)

let shader = createShader(vertexShader, fragmentShader)
glUseProgram(shader)

var vertexBuffer = initGpuBuffer(GpuBufferKind.Vertex)
vertexBuffer.data = [
  (vec3(0.5,  0.5, 0.0), vec2(1.0, 1.0)),
  (vec3(0.5, -0.5, 0.0), vec2(1.0, 0.0)),
  (vec3(-0.5, -0.5, 0.0), vec2(0.0, 0.0)),
  (vec3(-0.5,  0.5, 0.0), vec2(0.0, 1.0)),
]

var indexBuffer = initIndexBuffer[uint32]()
indexBuffer.writeData([
  0'u32, 1, 2,
  2, 3, 0,
])

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

while not window.shouldClose:
  window.pollEvents()
  renderer.clear()
  renderer.drawBuffer(vertexBuffer, indexBuffer)
  renderer.swapFrames()

glDeleteProgram(shader)













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
# glUniformMatrix4fv(glGetUniformLocation(shader, "transform"), 1, GL_FALSE, cast[ptr GLfloat](transform[0].addr))
# glUniformMatrix4fv(glGetUniformLocation(shader, "projection"), 1, GL_FALSE, cast[ptr GLfloat](projection[0].addr))