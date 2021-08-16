# import opengl
import std/macros

type
  GfxDataType* = enum
    I8, U8,
    I16, U16,
    I32, U32,
    F32, F64,

  Attribute* = object
    count*: int
    typ*: GfxDataType

  Vertex* = object
    attributes*: seq[Attribute]
    data*: pointer

  # Buffer* = object
  #   vertices*: seq[Vertex]
  #   openGlId: GLuint

# proc toGlEnum(dataType: GfxDataType): GLenum =
#   case dataType:
#   of I8: cGL_BYTE
#   of U8: cGL_UNSIGNED_BYTE
#   of I16: cGL_SHORT
#   of U16: cGL_UNSIGNED_SHORT
#   of I32: cGL_INT
#   of U32: GL_UNSIGNED_INT
#   of F32: cGL_FLOAT
#   of F64: cGL_DOUBLE

proc toGfxDataType*(typ: typedesc): GfxDataType =
  if typ is int8: I8
  elif typ is uint8: U8
  elif typ is int16: I16
  elif typ is uint16: U16
  elif typ is int32: I32
  elif typ is uint32: U32
  elif typ is int: I32
  elif typ is uint: U32
  elif typ is float32: F32
  elif typ is float64: F64
  elif typ is float: F64
  else: raise newException(IOError, "Improper type for toGfxDataType.")

# proc toNimType(typ: GfxDataType): typedesc =
#   case typ:
#   of I8: int8
#   of U8: uint8
#   of I16: int16
#   of U16: uint16
#   of I32: int32
#   of U32: uint32
#   of F32: float32
#   of F64: float64

proc numBytes*(typ: GfxDataType): int =
  case typ:
  of I8: 1
  of U8: 1
  of I16: 2
  of U16: 2
  of I32: 4
  of U32: 4
  of F32: 4
  of F64: 8

proc numBytes*(attribute: Attribute): int =
  attribute.count * attribute.typ.numBytes

proc numBytes*(vertex: Vertex): int =
  for attribute in vertex.attributes:
    result += attribute.numBytes



# proc numBytes*(buffer: Buffer): int =
#   for vertex in buffer.vertices:
#     result += vertex.numBytes

# proc select*(buffer: var Buffer) =
#   glBindBuffer(
#     target = GL_ARRAY_BUFFER,
#     buffer = buffer.openGlId,
#   )
#   glBufferData(
#     target = GL_ARRAY_BUFFER,
#     size = buffer.numBytes,
#     data = buffer.vertices.addr,
#     usage = GL_STATIC_DRAW,
#   )

# proc defineAttributes*(buffer: Buffer) =
#   if buffer.vertices.len > 0:
#     for vertex in buffer.vertices:
#       let vertexNumBytes = vertex.numBytes
#       var byteOffset = 0
#       for i, attribute in vertex.attributes:
#         glEnableVertexAttribArray(i.GLuint)
#         glVertexAttribPointer(
#           index = i.GLuint,
#             # the 0 based index of the attribute
#           size = attribute.count.GLuint,
#             # the number of values in the attribute
#           `type` = attribute.typ.toGlEnum,
#             # the type of value present in the attribute
#           normalized = GL_FALSE,
#             # normalize the values from 0 to 1 on the gpu
#           stride = vertexNumBytes,
#             # byte offset of each vertex
#           `pointer` = cast[pointer](byteOffset),
#             # byte offset of the start of the attribute, cast as a pointer
#         )
#         byteOffset += attribute.numBytes

# proc `=destroy`*(buffer: var Buffer) =
#   glDeleteBuffers(1, buffer.openGlId.addr)

# proc initBuffer*(): Buffer =
#   glGenBuffers(1, result.openGlId.addr)



# proc `=destroy`*(vertex: var Vertex) =
#   dealloc(vertex.data)

macro initVertex*(args: varargs[untyped]): untyped =
  var
    stmts = nnkStmtListExpr.newTree()
    vertexSym = genSym(nskVar, "vertex")
    # byteOffsetSym = genSym(nskVar, "byteOffset")
    numArgs = args.len
    attributeSyms = newSeq[NimNode](numArgs)

  for i, arg in args:
    let attributeSym = genSym(nskLet, "attribute")
    attributeSyms[i] = attributeSym
    stmts.add quote do:
      let `attributeSym` = `arg`

  stmts.add quote do:
    var `vertexSym` = Vertex(
      attributes: newSeq[Attribute](`numArgs`)
    )

  for i, arg in args:
    let attributeSym = attributeSyms[i]
    stmts.add quote do:
      `vertexSym`.attributes[`i`] = Attribute(
        count: `attributeSym`.len,
        typ: `attributeSym`[0].typeof.toGfxDataType,
      )

  stmts.add quote do:
    `vertexSym`.data = alloc(`vertexSym`.numBytes)
    # var `byteOffsetSym` = 0

  for i, arg in args:
    let attributeSym = attributeSyms[i]
    stmts.add quote do:
      var dataPtr = cast[ptr `attributeSym`.typeof](`vertexSym`.data)
      dataPtr[] = `attributeSym`


  # for i, arg in args:
  #   let attributeSym = attributeSyms[i]
  #   stmts.add quote do:
  #     var dataPtr = cast[ptr `attributeSym`.typeof](cast[int](`vertexSym`.data) + `byteOffsetSym`)
  #     dataPtr[] = `attributeSym`
  #   if i < args.len - 1:
  #     stmts.add quote do:
  #       `byteOffsetSym` += `attributeSym`.sizeof

  stmts.add quote do:
    `vertexSym`

  nnkBlockExpr.newTree(newEmptyNode(), stmts)

when isMainModule:
  let vertex = initVertex(
    [0.5'f32, -0.5, 0.0],
    # [0.0],
    # [5, 10],
  )

  let vertexData = cast[ptr [0.5'f32, -0.5, 0.0].typeof](vertex.data)
  echo vertexData[]

  # echo vertex.numBytes
  # for attribute in vertex.attributes:
  #   echo $attribute.typ & ": " & $attribute.count