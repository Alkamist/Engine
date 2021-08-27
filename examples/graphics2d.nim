import ezwin
import ../engine as gfx

var window = newWindow("Test Window")
var gfxContext = gfx.initContext(window.handle)

gfx.enableAlphaBlend()
gfx.enableDepthTesting()

var sprite = newSprite()
sprite.loadFile("examples/barrel_side.png")
sprite.viewAtPixelScale(window.clientWidth, window.clientHeight)

proc draw =
  gfx.clearBackground()
  gfx.clearDepthBuffer()
  sprite.draw()
  gfxContext.swapBuffers()

window.onResize = proc =
  gfx.setViewport(0, 0, window.clientWidth, window.clientHeight)
  sprite.viewAtPixelScale(window.clientWidth, window.clientHeight)
  draw()

window.onDraw = proc =
  draw()

while not window.shouldClose:
  window.pollEvents()