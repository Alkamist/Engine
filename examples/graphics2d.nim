import ezwin
import ../engine

var window = newWindow("Test Window")
var glContext = initContext window.handle

engine.enableAlphaBlend()

var sprite = newSprite(256, 256)
sprite.texture.image = readImage("examples/barrel_side.png")
sprite.texture.writeToGpu()

var sprite2 = newSprite(256, 256)
sprite2.texture.clear()
sprite2.texture.image.fillPath(
  """
    M 60 90
    A 40 40 90 0 1 100 60
    A 40 40 90 0 1 180 60
    Q 180 120 100 180
    Q 20 120 20 60
    z
  """,
  color(0.7, 0.7, 0.1, 0.8).rgba
)
sprite2.texture.writeToGpu()

proc draw =
  engine.clearBackground()
  engine.clearDepthBuffer()
  sprite.draw()
  sprite2.draw()
  glContext.swapBuffers()

window.onResize = proc =
  engine.setViewport(0, 0, window.clientWidth, window.clientHeight)
  draw()

window.onDraw = proc =
  draw()

while not window.shouldClose:
  window.pollEvents()