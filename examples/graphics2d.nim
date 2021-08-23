import pixie
import ezwin
import ../engine

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

uniform sampler2D texture1;

void main()
{
  vec4 texColor = texture(texture1, TexCoord);
  if(texColor.a < 0.01)
    discard;
  FragColor = texColor;
}
"""

var window = newWindow("Test Window")

var renderer = initRenderer(initContext(window.handle))
renderer.backgroundColor = color(0.03, 0.03, 0.03, 1.0)

var shader = initShader(vertexShader, fragmentShader)
var texture = newTexture(window.clientWidth, window.clientHeight)

var vertices = genVertexBuffer[(array[3, float32], array[2, float32])]()
vertices.writeData [
  ([-1.0f, -1.0, 0.0], [0.0f, 1.0]),
  ([-1.0f, 1.0, 0.0], [0.0f, 0.0]),
  ([1.0f, 1.0, 0.0], [1.0f, 0.0]),
  ([1.0f, -1.0, 0.0], [1.0f, 1.0]),
]

var indices = genIndexBuffer[uint8]()
indices.writeData [
  0'u8, 1, 2,
  2, 3, 0
]

proc draw =
  texture.image.fill(color(0.0, 0.0, 0.0, 0.0))
  texture.image.fillPath(
    """
      M 20 60
      A 40 40 90 0 1 100 60
      A 40 40 90 0 1 180 60
      Q 180 120 100 180
      Q 20 120 20 60
      z
    """,
    rgbx(240, 16, 16, 255)
  )
  texture.writeImage()
  shader.select()
  renderer.clear()
  renderer.drawBuffer(vertices, indices)
  renderer.swapFrames()

window.onResize = proc =
  setViewport(0, 0, window.clientWidth, window.clientHeight)
  texture.image.width = window.clientWidth
  texture.image.height = window.clientHeight
  texture.image.data.setLen(window.clientWidth * window.clientHeight)
  draw()

window.onDraw = proc =
  draw()

while not window.shouldClose:
  window.pollEvents()