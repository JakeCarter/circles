-- oO ( circles ) Oo
-- v1.0 @jakecarter
-- llllllll.co/t/xxxxx
-- 
-- ENC 2 & 3 move cursor
-- ENC 1: engine.release
-- 
-- KEY 3: Place circle
-- KEY 2: Remove last circle
-- KEY 1: Hold to remove all
-- 
-- Notes divided along screen x
-- Timbre divided along screen y
-- Bigger circles are louder
--
-- Enjoy
--


engine.name = 'PolyPerc'

music = require 'musicutil'
beatclock = require 'beatclock'
UI = require "ui"
libc = include('lib/libCircles')
libc.handleCircleBurst = function(circle)
  engine.amp(_scale(circle.r, 1, 64, 0.01, 1))
  
  engine.pw(_scale(circle.y, 0, 64, 0.01, 1))
  
  -- maybe try this too; you might like?
  -- engine.cutoff(_scale(circle.y, 0, 64, 200, 2500))
  
  local noteIndex = math.floor(_scale(circle.x, 0, 128, 1, #scale))
  engine.hz(scale[noteIndex])
  
  
end

steps = {}
position = 1
release = 0.5

mode = math.random(#music.SCALES)
scale = music.generate_scale_of_length(60,music.SCALES[mode].name,16)

clk = beatclock.new()
clk_midi = midi.connect()
clk_midi.event = clk.process_midi

message = nil

function init()
  screen.aa(1)
  
  clk.on_step = count
  clk:add_clock_params()
  
  params:add_separator()
  
  params:add_option("keep_on_screen", "keep on screen", { "no", "yes" })
  params:set_action("keep_on_screen", function(x)
    if x == 1 then
      -- no
      libc.shouldBurstOnScreenEdge = false
    else
      -- yes
      libc.shouldBurstOnScreenEdge = true
    end
  end)
  
  clk:start()
end

function count()
  libc.updateCircles()
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
    libc.forEachCircle(function(c)
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
  if n == 1 then
    release = release + (d * 0.05)
    if release < 0 then
      release = 0
    elseif release > 1 then
      release = 1
    end
    engine.release(release)
  elseif n == 2 then
    libc.updateCursor(d,0)
  elseif n == 3 then
    libc.updateCursor(0,d)
  end
  redraw()
end

function _scale(i, imin, imax, omin, omax)
  return ((i - imin) / (imax - imin)) * (omax - omin) + omin;
end
