-- oO ( circles ) Oo
-- v1.3 @jakecarter
-- llllllll.co/t/22951
-- 
-- ENC 2 & 3 move cursor
-- ENC 1: engine.cutoff
-- 
-- KEY 3: Place circle
-- KEY 2: Remove circle at cursor
-- KEY 1: Hold removes all circles
-- 
-- Notes divided along screen x
-- Timbre divided along screen y
-- Bigger circles, longer release
--
-- Enjoy
--
-- Release Notes
-- v1.3
-- System param saving/loading
-- now supported.
--
-- v1.2
-- Added param for determinsitc
-- burst type.
--
-- v1.1 - Crow
-- input 2 - Clock
-- output 1 - Trigger
-- output 2 - Pitch
-- output 3 - Y Pos  (0 - 10V)
-- output 4 - Radius (0 - 10V)
--


engine.name = 'PolyPerc'

crow.output[1].action = "pulse(0.1, 5, 1)"

music = require 'musicutil'
beatclock = require 'beatclock'
UI = require "ui"
libc = include('lib/libCircles')
libc.handleCircleBurst = function(circle)
  local noteIndex = math.floor(_scale(circle.x, 0, 128, 1, #scale))
  local note = scale[noteIndex]

  if params:get("output") == outputs.audio then
    if params:get("radius_affects") == radius_affects.release then
      engine.release(_scale(circle.r, 1, 64, 0.03, 1))
      engine.amp(0.3)
    else
      engine.amp(_scale(circle.r, 1, 64, 0.01, 1))
      engine.release(0.5)
    end
  
    engine.pw(_scale(circle.y, 0, 64, 0.01, 1))
    engine.hz(note)
  elseif params:get("output") == outputs.crow then
    crow.output[2].volts = (note - 60) / 12
    crow.output[3].volts = _scale(circle.y, 1, 64, 0.01, 10)
    crow.output[4].volts = _scale(circle.r, 0, 64, 0.01, 10)
    crow.output[1].execute()
  end
end

steps = {}
position = 1

mode = math.random(#music.SCALES)
scale = music.generate_scale_of_length(60,music.SCALES[mode].name,16)

clk = beatclock.new()
clk_midi = midi.connect()
clk_midi.event = clk.process_midi

outputs = { audio = 1, crow = 2 }
clock_sources = { midi = 1, crow = 2 }
radius_affects = { release = 1, amp = 2 }

message = nil

function setupParams()
  -- output
  params:add_option("output", "output", { "audio", "crow" }, outputs.audio)
  
  -- output: audio
  params:add_option("radius_affects", "radius affects", { "release", "amp" })
  params:add_control("cutoff", "cutoff", controlspec.new(50,20000,'exp',0,1000,'hz'))
  params:set_action("cutoff", function(x)
    engine.cutoff(x)
  end)
  params:add_separator()
  
  -- clock_sources
  params:add({type = "option", id = "clock_source", name = "clock source", default = clock_sources.midi,
    options = { "midi", "crow" },
    action = function(value)
      if value == clock_sources.midi then
        clk.on_step = step
        clk:start()
      elseif value == clock_sources.crow then
        clk:stop()
        
        crow.input[2].mode("change",1,0.1,"rising")
        crow.input[2].change = function(s)
          step()
        end
      end
    end
  })
  -- clock_sources: midi
  clk:add_clock_params()
  params:add_separator()
  
  -- libCircles
  params:add_option("keep_on_screen", "keep on screen", { "no", "yes" })
  params:set_action("keep_on_screen", function(value)
    if value == 1 then
      -- no
      libc.shouldBurstOnScreenEdge = false
    else
      -- yes
      libc.shouldBurstOnScreenEdge = true
    end
  end)
  
  params:add_option("burst type", "burst type", { "random", "deterministic"})
  params:set_action("burst type", function(value)
    libc.burst_type = value
  end)
  
  params:default()
  params:bang()
end

function init()
  screen.aa(1)

  setupParams()
end

function step()
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
      libc.removeCircleAt()
    end
  elseif n == 1 and z == 1 then
    message = UI.Message.new({"Remove all circles?.", "", "KEY2 to cancel", "KEY3 to confirm"})
  end
end

function enc(n,d)
  if n == 1 then
    params:delta("cutoff", d)
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
