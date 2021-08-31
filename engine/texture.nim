import opengl
import pixie

type
  TextureMinifyFilter* {.pure.} = enum
    Nearest = GL_NEAREST,
    Linear = GL_LINEAR,
    NearestMipmapNearest = GL_NEAREST_MIPMAP_NEAREST,
    LinearMipmapNearest = GL_LINEAR_MIPMAP_NEAREST,
    NearestMipmapLinear = GL_NEAREST_MIPMAP_LINEAR,
    LinearMipmapLinear = GL_LINEAR_MIPMAP_LINEAR,

  TextureMagnifyFilter* {.pure.} = enum
    Nearest = GL_NEAREST,
    Linear = GL_LINEAR,

  TextureWrapMode* {.pure.} = enum
    Repeat = GL_REPEAT,
    ClampToBorder = GL_CLAMP_TO_BORDER,
    ClampToEdge = GL_CLAMP_TO_EDGE,
    MirroredRepeat = GL_MIRRORED_REPEAT,
    MirrorClampToEdge = GL_MIRROR_CLAMP_TO_EDGE,

  Texture* = object
    openGlId*: GLuint
    backgroundColor*: Color
    image*: Image

proc clear*(texture: Texture) =
  texture.image.fill(texture.backgroundColor)

proc resize*(texture: Texture, width, height: int) =
  texture.image.width = width
  texture.image.height = height
  texture.image.data.setLen(width * height)

proc loadFile*(texture: var Texture, file: string) =
  texture.image = readImage(file)

proc select*(texture: Texture) =
  glBindTexture(GL_TEXTURE_2D, texture.openGlId)

proc `minifyFilter=`*(texture: Texture, filter: TextureMinifyFilter) =
  texture.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter.GLint)

proc `magnifyFilter=`*(texture: Texture, filter: TextureMagnifyFilter) =
  texture.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filter.GLint)

proc `wrapS=`*(texture: Texture, mode: TextureWrapMode) =
  texture.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mode.GLint)

proc `wrapT=`*(texture: Texture, mode: TextureWrapMode) =
  texture.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mode.GLint)

proc `wrapR=`*(texture: Texture, mode: TextureWrapMode) =
  texture.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R, mode.GLint)

proc writeToGpu*(texture: Texture) =
  texture.select()
  glTexImage2D(
    GL_TEXTURE_2D,
    0,
    GL_RGBA.GLint,
    texture.image.width.GLsizei,
    texture.image.height.GLsizei,
    0,
    GL_RGBA,
    GL_UNSIGNED_BYTE,
    texture.image.data[0].addr,
  )

proc generateMipmap*(texture: Texture) =
  texture.select()
  glGenerateMipmap(GL_TEXTURE_2D)

proc generateTexture*(): Texture =
  glGenTextures(1, result.openGlId.addr)

proc initTexture*(width, height: int): Texture =
  result = generateTexture()
  result.backgroundColor = color(0.0, 0.0, 0.0, 0.0)
  result.image = newImage(width, height)
  result.minifyFilter = TextureMinifyFilter.Nearest
  result.magnifyFilter = TextureMagnifyFilter.Nearest
  result.wrapS = TextureWrapMode.Repeat
  result.wrapT = TextureWrapMode.Repeat