import opengl
import gmath

type
  Shader* = object
    openGlId*: GLuint

proc compileShaderSrc(kind: Glenum, source: string): GLuint =
  result = glCreateShader(kind)
  let src = allocCStringArray([source])
  glShaderSource(result, 1, src, nil)
  glCompileShader(result)
  deallocCStringArray(src)

  var compiledOk: GLint
  glGetShaderiv(result, GL_COMPILE_STATUS, compiledOk.addr)
  if compiledOk.Glboolean == GL_FALSE:
    var length: GLint
    glGetShaderiv(result, GL_INFO_LOG_LENGTH, length.addr)
    var message = newString(length)
    glGetShaderInfoLog(result, length, length.addr, message.cstring)
    glDeleteShader(result)
    raise newException(IOError, "Failed to compile shader: " & $message)

proc select*(shader: Shader) =
  glUseProgram(shader.openGlId)

proc setUniform*(shader: Shader, name: string, value: var Mat4) =
  shader.select()
  glUniformMatrix4fv(
    glGetUniformLocation(shader.openGlId, name),
    1, GL_FALSE,
    cast[ptr GLfloat](value.addr),
  )

proc `=destroy`*(shader: var Shader) =
  glDeleteProgram(shader.openGlId)

proc initShader*(vertexSrc, fragmentSrc: string): Shader =
  result.openGlId = glCreateProgram()

  var vertexId = compileShaderSrc(GL_VERTEX_SHADER, vertexSrc)
  var fragmentId = compileShaderSrc(GL_FRAGMENT_SHADER, fragmentSrc)

  glAttachShader(result.openGlId, vertexId)
  glAttachShader(result.openGlId, fragmentId)

  glLinkProgram(result.openGlId)
  glValidateProgram(result.openGlId)

  glDeleteShader(vertexId)
  glDeleteShader(fragmentId)