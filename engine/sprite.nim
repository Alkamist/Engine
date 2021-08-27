import opengl
import vmath
import pixie
import functions, vertexbuffer, indexbuffer,
       shader, texture

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

type
  SpriteVertex = (array[3, float32], array[2, float32])
  SpriteIndex = uint8

  Sprite* = ref object
    backgroundColor*: Color
    shader*: Shader
    texture*: Texture
    vertices*: VertexBuffer[SpriteVertex]
    indices*: IndexBuffer[SpriteIndex]
    projection: Mat4
    view: Mat4
    transform: Mat4

proc widthPixels*(sprite: Sprite): int = sprite.texture.image.width
proc heightPixels*(sprite: Sprite): int = sprite.texture.image.height

proc projection*(sprite: Sprite): Mat4 = sprite.projection
proc view*(sprite: Sprite): Mat4 = sprite.view
proc transform*(sprite: Sprite): Mat4 = sprite.transform

proc `projection=`*(sprite: Sprite, value: Mat4) =
  sprite.projection = value
  sprite.shader.setUniform("projection", value)

proc `view=`*(sprite: Sprite, value: Mat4) =
  sprite.view = value
  sprite.shader.setUniform("view", value)

proc `transform=`*(sprite: Sprite, value: Mat4) =
  sprite.transform = value
  sprite.shader.setUniform("transform", value)

proc viewAtPixelScale*(sprite: Sprite, viewportWidth, viewportHeight: int) =
  sprite.`view=` lookAt(
    eye = vec3(0.0, 0.0, 1.0),
    center = vec3(0.0, 0.0, 0.0),
    up = vec3(0.0, 1.0, 0.0),
  ) * vec3(
    sprite.widthPixels.float / viewportWidth.float,
    sprite.heightPixels.float / viewportHeight.float,
    1.0,
  ).scale

proc loadFile*(sprite: Sprite, file: string) =
  sprite.texture.loadFile(file)
  sprite.texture.writeToGpu()

proc useImage*(sprite: Sprite, image: Image) =
  sprite.texture.image = image
  sprite.texture.writeToGpu()

proc draw*(sprite: Sprite) =
  drawTriangles(
    sprite.shader,
    sprite.vertices,
    sprite.indices,
    sprite.texture,
  )

proc newSprite*(): Sprite =
  result = Sprite()
  result.shader = initShader(vertexShader, fragmentShader)
  result.texture = newTexture(1, 1)
  result.vertices = initVertexBuffer[SpriteVertex]()
  result.vertices.writeToGpu [
    ([-1.0f, -1.0, 0.0], [0.0f, 1.0]),
    ([-1.0f, 1.0, 0.0], [0.0f, 0.0]),
    ([1.0f, 1.0, 0.0], [1.0f, 0.0]),
    ([1.0f, -1.0, 0.0], [1.0f, 1.0]),
  ]
  result.indices = initIndexBuffer[SpriteIndex]()
  result.indices.writeToGpu [
    0'u8, 1, 2,
    2, 3, 0
  ]
  result.`projection=` ortho[float32](-1.0, 1.0, -1.0, 1.0, 0.1, 1000.0)
  result.`transform=` vec3(1.0, 1.0, 1.0).scale
  result.`view=` lookAt(vec3(0.0, 0.0, 1.0), vec3(0.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0))