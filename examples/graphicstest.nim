import opengl
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
renderer.backgroundColor = (0.05, 0.05, 0.05, 1.0)

var vertexBuffer = genVertexBuffer[(array[3, float32], array[2, float32])]()
vertexBuffer.writeData [
  ([0.5f,  0.5, 0.0], [1.0f, 1.0]),
  ([0.5f, -0.5, 0.0], [1.0f, 0.0]),
  ([-0.5f, -0.5, 0.0], [0.0f, 0.0]),
  ([-0.5f,  0.5, 0.0], [0.0f, 1.0]),
]

var indexBuffer = genIndexBuffer[uint32]()
indexBuffer.writeData [
  0'u32, 1, 2,
  2, 3, 0,
]

var texture = genTexture()
texture.loadImage("examples/concrete.png")
texture.minifyFilter = TextureMinifyFilter.Nearest
texture.magnifyFilter = TextureMagnifyFilter.Nearest
texture.wrapS = TextureWrapMode.Repeat
texture.wrapT = TextureWrapMode.Repeat
texture.writeImage()
texture.generateMipmap()

let shader = createShader(vertexShader, fragmentShader)
glUseProgram(shader)

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