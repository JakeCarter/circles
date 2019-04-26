-- circles

engine.name = 'PolyPerc'

music = require 'musicutil'
beatclock = require 'beatclock'
UI = require "ui"
libc = include('lib/libCircles')
libc.handleCircleBurst = function(x, y, r)
  local pixelsPerNote = 64 / #scale
  local noteIndex = math.floor((y / pixelsPerNote) + 1)
  local note = scale[noteIndex]
  -- print(note)
  engine.amp(r/100)
  engine.hz(note)
end

steps = {}
position = 1

mode = math.random(#music.SCALES)
scale = music.generate_scale_of_length(60,music.SCALES[mode].name,8)

clk = beatclock.new()
clk_midi = midi.connect()
clk_midi.event = clk.process_midi

message = nil

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
  
  if message then
    message:redraw()
  else
    -- draw cursor
    screen.pixel(libc.p.x, libc.p.y)
    screen.fill()
    
    -- draw circles
    libc.redrawCircles(function(c)
      screen.line_width(1)
      screen.circle(c.x,c.y,c.r)
      screen.close()
      screen.stroke()
    end)
  end
  
  screen.update()
end

function key(n,z)
  if n == 3 and z == 1 then
    if message then
      message = nil
      libc.removeAllCircles()
    else
      libc.addCircle()
    end
  elseif n == 2 and z == 1 then
    if message then
      message = nil
    else
      libc.removeCircle()
    end
  elseif n == 1 and z == 1 then
    message = UI.Message.new({"Remove all circles?.", "", "KEY2 to cancel", "KEY3 to confirm"})
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
