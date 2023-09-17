table = table
math = math
concat = table.concat
local _tostring
_tostring = tostring

moon = assert require "moon"
dump = moon.p
debug = debug

conf = {
  color: true
  outputToFile: true
  logLevel: "print"
  modes: {
    {n: "print", c: "\27[34m"}
    {n: "debug", c: "\27[36m"}
    {n: "info", c: "\27[32m"}
    {n: "warn", c: "\27[33m"}
    {n: "error", c: "\27[31m"}
    {n: "fatal", c: "\27[35m"}
  }
}

local logger
logger = {}
logger.outFile = nil
levels = {}

for key, val in ipairs conf.modes
  levels[val.n] = key

round = (x, inc) ->
  inc = inc or 1
  x = x/inc
  return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * inc

tostring = (...) ->
  t = {}
  for i = 1, select '#', ...
    x = select(i, ...)
    if type(x) == "number"
      x = round x, .01
    t[#t + 1] = _tostring x
  return concat t, " "

with logger
  .logFileName = (name) ->
    logger.outFile = name


for i, mode in ipairs conf.modes
  nameUpper = mode.n\upper!
  logger[mode.n] = (...) ->
    if i < levels[conf.logLevel] then return

    msg = tostring ...
    info = debug.getinfo 2, "Sl"
    line = info.short_src .. ":" .. info.currentline

    print string.format(
      "%s[%-6s%s]%s %s: %s",
      conf.color and mode.c or "",
      nameUpper,
      os.date("%H:%M:%S"),
      conf.color and "\27[0m" or "",
      line, msg
    )

    if conf.outputToFile
      print logger.outFile
      fp = io.open logger.outFile, "a"
      str =  string.format("[%-6s%s] %s: %s\n", nameUpper, os.date(), line, msg)

      fp\write str
      fp\close!



logger
