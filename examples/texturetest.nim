import opengl
import ezwin
import ../graphics
import thing

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

var window = newWindow(
  title = "Test Window",
  x = 2.0,
  y = 2.0,
  width = 4.0,
  height = 4.0,
)

var projection: Mat4 = perspective[float32](90.0, window.clientWidth / window.clientHeight, 0.01, 1000.0)

window.onResize = proc =
  glViewport(
    0.GLsizei, 0.GLsizei,
    window.clientWidthPixels.GLsizei, window.clientHeightPixels.GLsizei
  )
  projection = perspective[float32](90.0, window.clientWidth / window.clientHeight, 0.01, 1000.0)

var renderer = initRenderer(initContext(window.handle))
renderer.backgroundColor = (0.03, 0.03, 0.03, 1.0)

let shader = createShader(vertexShader, fragmentShader)
glUseProgram(shader)

var aThing = newThing()
aThing.transform = aThing.transform * vec3(0.0, 0.0, -1.0).translate
var velocity = vec3(0.01, 0.0, 0.0)

while not window.shouldClose:
  window.pollEvents()

  aThing.transform = aThing.transform * velocity.translate
  if aThing.transform[3, 0] > 1.0: velocity = vec3(-0.01, 0.0, 0.0)
  if aThing.transform[3, 0] < -1.0: velocity = vec3(0.01, 0.0, 0.0)

  glUniformMatrix4fv(glGetUniformLocation(shader, "transform"), 1, GL_FALSE, cast[ptr GLfloat](aThing.transform.addr))
  glUniformMatrix4fv(glGetUniformLocation(shader, "projection"), 1, GL_FALSE, cast[ptr GLfloat](projection.addr))

  renderer.clear()
  renderer.drawBuffer(aThing.vertexBuffer, aThing.indexBuffer)
  renderer.swapFrames()

glDeleteProgram(shader)