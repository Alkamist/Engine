import indexbuffer, vertexbuffer, texture, gmath

type
  MeshIndex* = uint32
  MeshVertex* = (array[3, float32], array[2, float32])

  Mesh* = object
    indices*: IndexBuffer[MeshIndex]
    vertices*: VertexBuffer[MeshVertex]
    texture*: Texture
    transform*: Mat4

# proc parseObj(data: string): tuple[vertices: seq[MeshVertex], indices: seq[MeshIndex]] =
#   var vertexCount = 0
#   var indexCount = 0

#   for line in data.splitLines:
#     if line.len > 0:
#       case line[0]:
#       of 'v': inc vertexCount
#       of 'f': inc indexCount
#       else: discard

#   var vertexId = 0
#   result.vertices = newSeq[MeshVertex](vertexCount)

#   var indexId = 0
#   result.indices = newSeq[MeshIndex](3 * indexCount)

#   for line in data.splitLines:
#     if line.len > 0:
#       case line[0]:
#       of 'v':
#         var i = 0
#         for value in line[1 .. ^1].splitWhitespace:
#           result.vertices[vertexId][0][i] = value.parseFloat.float32
#           inc i
#         inc vertexId
#       of 'f':
#         var i = 0
#         for value in line[1 .. ^1].splitWhitespace:
#           result.indices[indexId + i] = value.parseUInt.uint32
#           inc i
#         inc indexId
#       else:
#         discard

# proc loadFile*(mesh: var Mesh, file: string) =
#   let data = readFile(file)
#   var parsedData = data.parseObj()
#   mesh.vertices.writeData parsedData.vertices
#   mesh.indices.writeData parsedData.indices

proc initMesh*(): Mesh =
  result.indices = genIndexBuffer[MeshIndex]()
  result.vertices = genVertexBuffer[MeshVertex]()

  result.texture = genTexture()
  result.texture.minifyFilter = TextureMinifyFilter.Nearest
  result.texture.magnifyFilter = TextureMagnifyFilter.Nearest
  result.texture.wrapS = TextureWrapMode.Repeat
  result.texture.wrapT = TextureWrapMode.Repeat

  result.transform = identity()