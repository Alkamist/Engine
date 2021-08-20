import indexbuffer, vertexbuffer, texture, gmath

type
  MeshIndex* = uint32
  MeshVertex* = (array[3, float32], array[2, float32])

  Mesh* = object
    indices*: IndexBuffer[MeshIndex]
    vertices*: VertexBuffer[MeshVertex]
    texture*: Texture
    transform*: Mat4

proc initMesh*(indices: openArray[MeshIndex],
               vertices: openArray[MeshVertex]): Mesh =
  result.indices = genIndexBuffer[MeshIndex]()
  result.indices.writeData indices

  result.vertices = genVertexBuffer[MeshVertex]()
  result.vertices.writeData vertices

  result.texture = genTexture()
  result.texture.minifyFilter = TextureMinifyFilter.Nearest
  result.texture.magnifyFilter = TextureMagnifyFilter.Nearest
  result.texture.wrapS = TextureWrapMode.Repeat
  result.texture.wrapT = TextureWrapMode.Repeat

  result.transform = identity()