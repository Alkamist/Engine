import std/times

type
  Timestep* = object
    interpolation*: float
    displayDelta*: float
    physicsDelta*: float
    accumulator: float
    currentTime: float
    previousTime: float

proc initTimestep*(physicsFps: float): Timestep =
  result.interpolation = 0.0
  result.displayDelta = 0.0
  result.physicsDelta = 1.0 / physicsFps
  result.accumulator = 0.0
  result.currentTime = cpuTime()
  result.previousTime = cpuTime()

template update*(step: var Timestep, code: untyped): untyped =
  step.currentTime = cpuTime()
  step.displayDelta = step.currentTime - step.previousTime
  step.accumulator += step.displayDelta

  while step.accumulator >= step.physicsDelta:
    code
    step.accumulator -= step.physicsDelta

  step.interpolation = step.accumulator / step.physicsDelta
  step.previousTime = step.currentTime