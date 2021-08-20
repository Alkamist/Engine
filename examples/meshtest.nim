import std/times
import ezwin
import ../engine

const vertexShader = """
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

uniform mat4 projection;
uniform mat4 camera;
uniform mat4 transform;

void main()
{
  gl_Position = projection * camera * transform * vec4(aPos, 1.0f);
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

var window = ezwin.newWindow(
  title = "Test Window",
  x = 256,
  y = 256,
  width = 1024,
  height = 768,
)

var renderer = initRenderer(initContext(window.handle))
renderer.backgroundColor = (0.03, 0.03, 0.03, 1.0)

var shader = initShader(vertexShader, fragmentShader)

var mesh = initMesh()
mesh.vertices.writeData [
  ([-0.5f, -0.5f, -0.5f], [0.0f, 0.0f]),
  ([0.5f, -0.5f, -0.5f], [1.0f, 0.0f]),
  ([0.5f,  0.5f, -0.5f], [1.0f, 1.0f]),
  ([-0.5f,  0.5f, -0.5f], [0.0f, 1.0f]),
  ([-0.5f, -0.5f,  0.5f], [1.0f, 0.0f]),
  ([0.5f, -0.5f,  0.5f], [0.0f, 0.0f]),
  ([0.5f,  0.5f,  0.5f], [0.0f, 1.0f]),
  ([-0.5f,  0.5f,  0.5f], [1.0f, 1.0f]),
]
mesh.indices.writeData [
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
mesh.texture.loadImage("barrel_side.png")
mesh.texture.writeImage()
mesh.texture.generateMipmap()
shader.setUniform("transform", mesh.transform)

var projection: Mat4 = perspective[float32](90.0, window.clientAspectRatio, 0.01, 1000.0)
shader.setUniform("projection", projection)

var radius = 1.5

window.onMouseMove = proc =
  if window.input.isPressed(Left):
    let change = -window.input.mouseDelta[1].float
    radius *= 2.0.pow(change * 0.01)

window.onResize = proc =
  setViewport(0, 0, window.clientWidth, window.clientHeight)
  projection = perspective[float32](90.0, window.clientAspectRatio, 0.01, 1000.0)
  shader.setUniform("projection", projection)

while not window.shouldClose:
  window.pollEvents()

  var camX = sin(cpuTime()) * radius
  var camZ = cos(cpuTime()) * radius
  var camera = lookAt(vec3(camX, 1.0, camZ), vec3(0.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0))
  shader.setUniform("camera", camera)

  renderer.clear()
  shader.select()
  renderer.drawMesh(mesh)
  renderer.swapFrames()