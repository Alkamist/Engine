import vmath
import ../graphics

export vmath

type
  Thing* = ref object
    indexBuffer*: IndexBuffer[uint32]
    vertexBuffer*: VertexBuffer[(array[3, float32], array[2, float32])]
    texture*: Texture
    transform*: Mat4

proc newThing*(): Thing =
  result = Thing()
  result.indexBuffer = genIndexBuffer[uint32]()
  result.vertexBuffer = genVertexBuffer[(array[3, float32], array[2, float32])]()
  result.texture = genTexture()

  result.vertexBuffer.writeData [
    ([0.5f,  0.5, 0.0], [1.0f, 1.0]),
    ([0.5f, -0.5, 0.0], [1.0f, 0.0]),
    ([-0.5f, -0.5, 0.0], [0.0f, 0.0]),
    ([-0.5f,  0.5, 0.0], [0.0f, 1.0]),
  ]

  result.indexBuffer.writeData [
    0'u32, 1, 2,
    2, 3, 0,
  ]

  result.texture.loadImage("examples/concrete.png")
  result.texture.minifyFilter = TextureMinifyFilter.Nearest
  result.texture.magnifyFilter = TextureMagnifyFilter.Nearest
  result.texture.wrapS = TextureWrapMode.Repeat
  result.texture.wrapT = TextureWrapMode.Repeat
  result.texture.writeImage()
  result.texture.generateMipmap()

  result.transform = mat4(
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0,
  )