import opengl

proc setViewport*(x, y, width, height: int) =
  glViewport(
    x.GLsizei, y.GLsizei,
    width.GLsizei, height.GLsizei,
  )