-- circles

beatclock = require 'beatclock'
local libc = include('lib/libCircles')
libc.debug = false

steps = {}
position = 1

clk = beatclock.new()
clk_midi = midi.connect()
clk_midi.event = clk.process_midi

function init()
  screen.aa(1)
  
  clk.on_step = count
  clk:add_clock_params()
  
  params:add_separator()
  
  clk:start()
end

function count()
  libc.update()
  redraw()
end

function redraw()
  screen.clear()
  
  -- draw cursor
  libc.redrawCursor(function(x, y)
    screen.pixel(x, y)
    screen.fill()
  end)
  
  -- draw circles
  libc.redrawCircles(function(c)
    screen.line_width(1)
    screen.circle(c.x,c.y,c.r)
    screen.close()
    screen.stroke()
  end)
  
  screen.update()
end

function key(n,z)
  if n == 3 and z == 1 then
    libc.addCircle()
  end
end

function enc(n,d)
  if n == 2 then
    libc.updateCursor(d,0)
  elseif n == 3 then
    libc.updateCursor(0,d)
  end
  redraw()
end
