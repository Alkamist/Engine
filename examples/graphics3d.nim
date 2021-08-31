import std/[math, times]
import ezwin
import ../engine as gfx

const vertexShader = """
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 transform;

void main()
{
  gl_Position = projection * view * transform * vec4(aPos, 1.0f);
  TexCoord = aTexCoord;
}
"""

const fragmentShader = """
#version 330 core
out vec4 FragColor;

in vec2 TexCoord;

uniform sampler2D texture1;

void main()
{
  vec4 texColor = texture(texture1, TexCoord);
  FragColor = texColor;
}
"""

var window = newWindow("Test Window")
var gfxContext = gfx.initContext(window.handle)

gfx.enableAlphaBlend()
gfx.enableDepthTesting()

type
  Vertex = (array[3, float32], array[2, float32])
  Index = uint32

var vertices = initVertexBuffer[Vertex]()
vertices.writeToGpu [
  ([-0.5f, -0.5f, -0.5f], [0.0f, 0.0f]),
  ([0.5f, -0.5f, -0.5f], [1.0f, 0.0f]),
  ([0.5f,  0.5f, -0.5f], [1.0f, 1.0f]),
  ([-0.5f,  0.5f, -0.5f], [0.0f, 1.0f]),
  ([-0.5f, -0.5f,  0.5f], [1.0f, 0.0f]),
  ([0.5f, -0.5f,  0.5f], [0.0f, 0.0f]),
  ([0.5f,  0.5f,  0.5f], [0.0f, 1.0f]),
  ([-0.5f,  0.5f,  0.5f], [1.0f, 1.0f]),
]

var indices = initIndexBuffer[Index]()
indices.writeToGpu [
  0'u32, 1, 2,
  2, 3, 0,

  4, 5, 6,
  6, 7, 4,

  7, 3, 0,
  0, 4, 7,

  6, 2, 1,
  1, 5, 6,

  0, 1, 5,
  5, 4, 0,

  3, 2, 6,
  6, 7, 3,
]

var texture = initTexture(1, 1)
texture.loadFile("examples/barrel_side.png")
texture.writeToGpu()

var shader = initShader(vertexShader, fragmentShader)

var projection: Mat4 = perspective[float32](90.0, window.clientAspectRatio, 0.01, 1000.0)
shader.setUniform("projection", projection)

var transform = transform()
shader.setUniform("transform", transform)

proc draw =
  gfx.clearBackground()
  gfx.clearDepthBuffer()
  gfx.drawTriangles(shader, vertices, indices, texture)
  gfxContext.swapBuffers()

window.onResize = proc =
  gfx.setViewport(0, 0, window.clientWidth, window.clientHeight)
  projection = perspective[float32](90.0, window.clientAspectRatio, 0.01, 1000.0)
  shader.setUniform("projection", projection)
  draw()

while not window.shouldClose:
  window.pollEvents()

  # var t = sin(cpuTime() * 5.0) * 0.01
  # transform.rotate(vector3(0.0, 1.0, 0.0), 0.001)
  transform.scale(vector3(1.0, 1.001, 1.0))
  # transform.translate(vector3(0.001, 0.0, 0.0))
  transform.orthonormalize()
  shader.setUniform("transform", transform)

  # var camX = sin(cpuTime()) * 1.5
  # var camZ = cos(cpuTime()) * 1.5
  # var view = lookAt(vec3(camX, 1.0, camZ), vec3(0.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0))
  var view = lookAt(vec3(0.0, 1.0, -2.0), vec3(0.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0))
  shader.setUniform("view", view)

  draw()