import std/times
import ezwin
import ../engine

proc segment2d(a, b: Vec3, thickness: float32): array[6, Vec3] =
  let diff = b - a
  let normal = vec3(-diff.y, diff.x, 0.0).normalize
  let halfThickness = 0.5 * thickness

  result[0] = a + normal * halfThickness
  result[1] = b + normal * halfThickness
  result[2] = b - normal * halfThickness

  result[3] = b - normal * halfThickness
  result[4] = a - normal * halfThickness
  result[5] = a + normal * halfThickness

const vertexShader = """
#version 330 core
layout (location = 0) in vec3 aPos;

uniform mat4 projection;

void main()
{
  vec4 zOffsetPos = vec4(aPos, 1.0f) - vec4(0.0, 0.0, 100.0, 0.0);
  gl_Position = projection * zOffsetPos;
}
"""

const fragmentShader = """
#version 330 core
out vec4 FragColor;
void main()
{
  FragColor = vec4(1.0, 1.0, 1.0, 1.0);
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

var vertices = genVertexBuffer[(array[3, float32],)]()

template projection: untyped =
  let halfXInches = 0.5 * window.clientWidth.float / window.dpi
  let halfYInches = 0.5 * window.clientHeight.float / window.dpi
  ortho[float32](
    -halfXInches, halfXInches,
    -halfYInches, halfYInches,
    0.01, 1000.0,
  )

shader.setUniform("projection", projection)

window.onResize = proc =
  setViewport(0, 0, window.clientWidth, window.clientHeight)
  shader.setUniform("projection", projection)

while not window.shouldClose:
  window.pollEvents()

  var time = cpuTime()
  var seg = segment2d(
    vec3(0.0, 0.0, 0.0),
    vec3(3.0 * cos(time), 3.0 * sin(time), 0.0),
    0.2,
  )
  vertices.writeData [
    (seg[0].toArray,),
    (seg[1].toArray,),
    (seg[2].toArray,),
    (seg[3].toArray,),
    (seg[4].toArray,),
    (seg[5].toArray,),
  ]

  renderer.clear()
  shader.select()
  renderer.drawBuffer(vertices)
  renderer.swapFrames()