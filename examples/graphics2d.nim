import ezwin
import ../engine as gfx

var window = newWindow("Test Window")
var gfxContext = gfx.initContext(window.handle)

gfx.enableAlphaBlend()
gfx.enableDepthTesting()

var sprite = newSprite()
sprite.loadFile("examples/barrel_side.png")
sprite.transform = vec3(sprite.width.float32, sprite.height.float32, 1.0).scale
sprite.updateMatrix()

proc draw =
  gfx.clearBackground()
  gfx.clearDepthBuffer()
  sprite.draw()
  gfxContext.swapBuffers()

window.onResize = proc =
  gfx.setViewport(0, 0, window.clientWidth, window.clientHeight)
  let xScale = window.clientWidth.float
  let yScale = window.clientHeight.float
  sprite.projection = ortho[float32](-xScale, xScale, -yScale, yScale, 0.1, 1000.0)
  sprite.updateMatrix()
  draw()

window.onDraw = proc =
  draw()

while not window.shouldClose:
  window.pollEvents()