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
  FragColor = texColor;
}
"""

type
  SpriteVertex = (array[3, float32], array[2, float32])
  SpriteIndex = uint8

  Sprite* = ref object
    position*: Vec2
    dimensions*: Vec2
    backgroundColor*: Color
    shader*: Shader
    texture*: Texture
    vertices: VertexBuffer[SpriteVertex]
    indices: IndexBuffer[SpriteIndex]

proc draw*(sprite: Sprite) =
  drawTriangles(
    sprite.shader,
    sprite.vertices,
    sprite.indices,
    sprite.texture,
  )

proc newSprite*(width, height: int): Sprite =
  result = Sprite()
  result.shader = initShader(vertexShader, fragmentShader)
  result.texture = newTexture(width, height)
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