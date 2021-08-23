import std/times

type
  Timestep* = object
    interpolation*: float
    delta*: float
    displayDelta*: float
    accumulator: float
    currentTime: float
    previousTime: float

proc initTimestep*(physicsFps: float): Timestep =
  result.interpolation = 0.0
  result.displayDelta = 0.0
  result.delta = 1.0 / physicsFps
  result.accumulator = 0.0
  result.currentTime = cpuTime()
  result.previousTime = cpuTime()

template update*(step: var Timestep, code: untyped): untyped =
  step.currentTime = cpuTime()
  step.displayDelta = step.currentTime - step.previousTime
  step.accumulator += step.displayDelta

  while step.accumulator >= step.delta:
    code
    step.accumulator -= step.delta

  step.interpolation = step.accumulator / step.delta
  step.previousTime = step.currentTime