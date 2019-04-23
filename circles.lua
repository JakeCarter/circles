-- circles

beatclock = require 'beatclock'
local libc = dofile('/home/we/dust/code/carter/circles/lib/libCircles.lua')
libc.debug = false

steps = {}
position = 1

clk = beatclock.new()
clk_midi = midi.connect()
clk_midi.event = clk.process_midi

function init()
  p = {}
  p.x = 128/2
  p.y = 64/2
  
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
  screen.aa(0)
  screen.level(1)
  screen.line_width(1)
  screen.pixel(p.x, p.y)
  
  -- draw circles
  libc.redrawCircles(_circle_redraw_handler)
  
  screen.update()
end

function _circle_redraw_handler(c)
    screen.level(15)
    screen.line_width(1)
    screen.stroke()
    screen.circle(c.x,c.y,c.r)
end

function key(n,z)
  if n == 3 and z == 1 then
    libc.addCircle(p.x, p.y)
  end
end

function enc(n,d)
  if n == 1 then
    --libc.update()
  elseif n == 2 then
    p.x = p.x + d
    if p.x > 128 then
      p.x = 128
    elseif p.x < 0 then
      p.x = 0
    end
  elseif n == 3 then
    p.y = p.y + d
    if p.y > 63 then
      p.y = 64
    elseif p.y < 0 then
      p.y = 0
    end
  end
  redraw()
end
