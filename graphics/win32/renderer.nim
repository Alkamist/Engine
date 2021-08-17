import
  opengl, winim/lean,
  ../color

var openGlIsLoaded = false

type
  Renderer* = object
    hWnd*: HWND
    hdc*: HDC
    openGlContext*: HGLRC

proc makeContextCurrent(renderer: var Renderer) =
  var pfd = PIXELFORMATDESCRIPTOR(
    nSize: PIXELFORMATDESCRIPTOR.sizeof.WORD,
    nVersion: 1,
  )
  pfd.dwFlags = PFD_DRAW_TO_WINDOW or
                PFD_SUPPORT_OPENGL or
                PFD_SUPPORT_COMPOSITION or
                PFD_DOUBLEBUFFER
  pfd.iPixelType = PFD_TYPE_RGBA
  pfd.cColorBits = 32
  pfd.cAlphaBits = 8
  pfd.iLayerType = PFD_MAIN_PLANE

  renderer.hdc = GetDC(renderer.hWnd)
  let format = ChoosePixelFormat(renderer.hdc, pfd.addr)
  if format == 0:
    raise newException(OSError, "ChoosePixelFormat failed.")

  if SetPixelFormat(renderer.hdc, format, pfd.addr) == 0:
    raise newException(OSError, "SetPixelFormat failed.")

  var activeFormat = GetPixelFormat(renderer.hdc)
  if activeFormat == 0:
    raise newException(OSError, "GetPixelFormat failed.")

  if DescribePixelFormat(renderer.hdc, format, pfd.sizeof.UINT, pfd.addr) == 0:
    raise newException(OSError, "DescribePixelFormat failed.")

  if (pfd.dwFlags and PFD_SUPPORT_OPENGL) != PFD_SUPPORT_OPENGL:
    raise newException(OSError, "PFD_SUPPORT_OPENGL check failed.")

  renderer.openGlContext = wglCreateContext(renderer.hdc)
  if renderer.openGlContext == 0:
    raise newException(OSError, "wglCreateContext failed.")

  wglMakeCurrent(renderer.hdc, renderer.openGlContext)

proc `backgroundColor=`*(renderer: Renderer, color: Color) =
  glClearColor(color.r / 255.0,
               color.g / 255.0,
               color.b / 255.0,
               color.a)

proc clear*(renderer: Renderer) =
  glClear(GL_COLOR_BUFFER_BIT)

proc swapBuffers*(renderer: Renderer) =
  SwapBuffers(renderer.hdc)

proc initRenderer*(handle: HWND): Renderer =
  result.hWnd = handle
  result.makeContextCurrent()
  if not openGlIsLoaded:
    opengl.loadExtensions()
    openGlIsLoaded = true