import
  opengl

proc compileShader*(kind: Glenum, source: string): GLuint =
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

proc createShader*(vertex, fragment: string): GLuint =
  result = glCreateProgram()

  let vs = compileShader(GL_VERTEX_SHADER, vertex)
  let fs = compileShader(GL_FRAGMENT_SHADER, fragment)

  glAttachShader(result, vs)
  glAttachShader(result, fs)

  glLinkProgram(result)
  glValidateProgram(result)

  glDeleteShader(vs)
  glDeleteShader(fs)