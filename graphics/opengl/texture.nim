import opengl
import pixie

# var textureId: GLuint
# glGenTextures(1, textureId.addr)
# glBindTexture(GL_TEXTURE_2D, textureId)


# glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
# glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
# glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
# glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
# var texture = readImage("examples/concrete.png")
# glTexImage2D(
#   GL_TEXTURE_2D,
#   0,
#   GL_RGBA.GLint,
#   texture.width.GLsizei,
#   texture.height.GLsizei,
#   0,
#   GL_RGBA,
#   GL_UNSIGNED_BYTE,
#   texture.data[0].addr,
# )
# glGenerateMipmap(GL_TEXTURE_2D)

type
  Texture* = object
    openGlId*: GLuint

proc select*(texture: Texture) =
  glBindTexture(GL_TEXTURE_2D, texture.openGlId)

proc initTexture*(): Texture =
  glGenTextures(1, result.openGlId.addr)