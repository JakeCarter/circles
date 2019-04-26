-- circles

engine.name = 'PolyPerc'

local music = require 'musicutil'
local beatclock = require 'beatclock'
local UI = require "ui"
local libc = include('lib/libCircles')
libc.handleCircleBurst = function(x, y, r)
  local noteIndex = r % #scale
  local note = scale[noteIndex]
  engine.hz(note)
end

local steps = {}
local position = 1

local mode = math.random(#music.SCALES)
local scale = music.generate_scale_of_length(60,music.SCALES[mode].name,8)

local clk = beatclock.new()
local clk_midi = midi.connect()
clk_midi.event = clk.process_midi

local message

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
