import std/strutils

type
  RealNumber* = float32

proc prettyFloat*(f: float): string =
  result = f.formatFloat(ffDecimal, 4)
  if result[0] != '-':
    result.insert(" ", 0)