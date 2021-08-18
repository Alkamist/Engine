import opengl
import winim/lean

var openGlIsLoaded = false

type
  Context* = object
    hwnd: HWND
    hdc: HDC
    hglrc: HGLRC

proc makeCurrent(context: var Context) =
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

  context.hdc = GetDC(context.hwnd)
  let format = ChoosePixelFormat(context.hdc, pfd.addr)
  if format == 0:
    raise newException(OSError, "ChoosePixelFormat failed.")

  if SetPixelFormat(context.hdc, format, pfd.addr) == 0:
    raise newException(OSError, "SetPixelFormat failed.")

  var activeFormat = GetPixelFormat(context.hdc)
  if activeFormat == 0:
    raise newException(OSError, "GetPixelFormat failed.")

  if DescribePixelFormat(context.hdc, format, pfd.sizeof.UINT, pfd.addr) == 0:
    raise newException(OSError, "DescribePixelFormat failed.")

  if (pfd.dwFlags and PFD_SUPPORT_OPENGL) != PFD_SUPPORT_OPENGL:
    raise newException(OSError, "PFD_SUPPORT_OPENGL check failed.")

  context.hglrc = wglCreateContext(context.hdc)
  if context.hglrc == 0:
    raise newException(OSError, "wglCreateContext failed.")

  wglMakeCurrent(context.hdc, context.hglrc)

proc swapFrames*(context: Context) =
  SwapBuffers(context.hdc)

proc initContext*(handle: HWND): Context =
  result.hwnd = handle
  result.makeCurrent()
  if not openGlIsLoaded:
    opengl.loadExtensions()
    openGlIsLoaded = true