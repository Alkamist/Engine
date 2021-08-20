import ezwin
import ../engine

const vertexShader = """
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

uniform mat4 transform;
uniform mat4 projection;

void main()
{
  gl_Position = projection * transform * vec4(aPos, 1.0f);
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

var step = initTimestep(60.0)

var renderer = initRenderer(initContext(window.handle))
renderer.backgroundColor = (0.03, 0.03, 0.03, 1.0)

var meshVelocity = vec3(10.0, 0.0, 0.0)
var mesh = initMesh(
  indices = [
    0'u32, 1, 2,
    2, 3, 0,
  ],
  vertices = [
    ([0.5f,  0.5, 0.0], [1.0f, 1.0]),
    ([0.5f, -0.5, 0.0], [1.0f, 0.0]),
    ([-0.5f, -0.5, 0.0], [0.0f, 0.0]),
    ([-0.5f,  0.5, 0.0], [0.0f, 1.0]),
  ]
)
mesh.texture.loadImage("examples/concrete.png")
mesh.texture.writeImage()
mesh.texture.generateMipmap()

mesh.transform.translate vec3(0.0, 0.0, -1.0)

var shader = initShader(vertexShader, fragmentShader)

var projection: Mat4 = perspective[float32](90.0, window.clientAspectRatio, 0.01, 1000.0)
shader.setUniform("projection", projection)

window.onResize = proc =
  setViewport(0, 0, window.clientWidth, window.clientHeight)
  projection = perspective[float32](90.0, window.clientAspectRatio, 0.01, 1000.0)
  shader.setUniform("projection", projection)

window.onDraw = proc =
  renderer.clear()
  shader.select()
  renderer.drawMesh(mesh)
  renderer.swapFrames()

while not window.shouldClose:
  window.pollEvents()

  step.update:
    mesh.transform.translate(meshVelocity * step.physicsDelta)
    if mesh.transform.x > 1.0: meshVelocity = vec3(-10.0, 0.0, 0.0)
    if mesh.transform.x < -1.0: meshVelocity = vec3(10.0, 0.0, 0.0)
    shader.setUniform("transform", mesh.transform)

  window.redraw()