-- oO ( circles ) Oo
-- v1.5.1 @jakecarter
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

engine.name = 'PolyPerc'

-- inclues
local music_util = require("musicutil")
local UI = require("ui")
local math_helpers = include("lib/math_helpers")
local libc = include("lib/libCircles")

-- state
local scale_notes
local midi_out_device = midi.connect()
local midi_out_channel
local message = nil
local active_note_age_map = {}
local scale_names = {}

local running = true

-- enums
local outputs = { audio = 1, crow = 2, crow_jf = 3, midi = 4 }
local clock_sources = { midi = 1, crow = 2 }
local radius_affects = { release = 1, amp = 2 }

function setupParams()
  -- output
  params:add_option("output", "output", { "audio", "crow", "crow + jf", "midi" }, outputs.audio)
  params:set_action("output", function(value)
    if value == outputs.crow then
      crow.output[1].action = "pulse(0.1, 5, 1)"
    elseif value == outputs.crow_jf then
      crow.ii.pullup(true)
      crow.ii.jf.mode(1)
    else
      crow.ii.jf.mode(0)
      crow.ii.pullup(false)
    end
  end)
  
  -- output: audio
  params:add_option("radius_affects", "radius affects", { "release", "amp" })
  params:add_control("cutoff", "cutoff", controlspec.new(50,20000,'exp',0,1000,'hz'))
  params:set_action("cutoff", function(x)
    engine.cutoff(x)
  end)
  params:add_separator()
  
  -- JCTODO: Get this working again; I don't think I'm going to need this with the new `clock` api, but I guess we'll see.
  -- clock_sources 
  -- params:add({type = "option", id = "clock_source", name = "clock source", default = clock_sources.midi,
  --   options = { "midi", "crow" },
  --   action = function(value)
  --     if value == clock_sources.midi then
  --       
  --       -- JCTODO: Switch to `clock`
  --       clk.on_step = step
  --       clk:start()
  --       
  --       
  --     elseif value == clock_sources.crow then
  --       
  --       -- JCTODO: Switch to `clock`
  --       clk:stop()
  --       
  --       crow.input[2].mode("change",1,0.1,"rising")
  --       crow.input[2].change = function(s)
  --         step()
  --       end
  --     end
  --   end
  -- })
  
  -- clock_sources: midi
  -- clk:add_clock_params() -- JCTODO: Switch to `clock`
  
  params:add({type = "number", id = "midi_out_device", name = "midi out device",
    min = 1, max = 4, default = 1,
    action = function(value) midi_out_device = midi.connect(value) end})
  
  params:add{type = "number", id = "midi_out_channel", name = "midi out channel",
    min = 1, max = 16, default = 1,
    action = function(value)
      -- TODO: Turn all notes off
      midi_out_channel = value
    end}
  params:add_separator()
  
  -- scale
  -- scale: root note
  params:add{type = "number", id = "root_note", name = "root note",
    min = 0, max = 127, default = 60, formatter = function(param) return music_util.note_num_to_name(param:get(), true) end,
    action = function() build_scale_notes() end}
  -- scale: mode
  params:add{type = "option", id = "scale_mode", name = "scale mode",
    options = scale_names, default = 5,
    action = function() build_scale_notes() end}
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
  
  for i = 1, #music_util.SCALES do
    table.insert(scale_names, string.lower(music_util.SCALES[i].name))
  end

  
  libc.handleCircleBurst = handleCircleBurst
  -- midi_out_device.event = clk.process_midi -- JCTODO: Switch to `clock`
  
  setupParams()
  
  clock.run(step)
end

function step()
  while true do
    clock.sync(1/4) -- JCTODO: Provide step divider param? `clock.sync(1/params:get("step_div"))`
    if running then
      -- kill old notes
      for active_note, active_note_age in pairs(active_note_age_map) do
        if active_note_age >= 1 then
          midi_out_device:send({type='note_off', note=active_note, ch=midi_out_channel})
          active_note_age_map[active_note] = nil
        else
          active_note_age_map[active_note] = active_note_age + 1
        end
      end
      
      libc.updateCircles()
      redraw()
    end
  end
end

function clock.transport.start()
  running = true
end

function clock.transport.stop()
  running = false
end

function noteForCircle(circle)
  local noteIndex = math.floor(math_helpers.scale(circle.x, 0, 128, 1, #scale_notes))
  local note = scale_notes[noteIndex]
  return note
end

function handleCircleBurst(circle)
  local note = noteForCircle(circle)

  if params:get("output") == outputs.audio then
    if params:get("radius_affects") == radius_affects.release then
      engine.release(math_helpers.scale(circle.r, 1, 64, 0.03, 1))
      engine.amp(0.3)
    else
      engine.amp(math_helpers.scale(circle.r, 1, 64, 0.01, 1))
      engine.release(0.5)
    end
    
    engine.pw(math_helpers.scale(circle.y, 0, 64, 0.01, 1))
    engine.hz(note)
  elseif params:get("output") == outputs.crow then
    crow.output[2].volts = (note - 60) / 12
    crow.output[3].volts = math_helpers.scale(circle.y, 1, 64, 0.01, 10)
    crow.output[4].volts = math_helpers.scale(circle.r, 0, 64, 0.01, 10)
    crow.output[1].execute()
  elseif params:get("output") == outputs.crow_jf then
    crow.ii.jf.play_note((note - 60) / 12, math_helpers.scale(circle.r, 1, 64, 1, 10))
  elseif params:get("output") == outputs.midi then
    play_note(note)
  end
end

function play_note(note)
  midi_out_device:send({type='note_off', note=note, ch=midi_out_channel})
  midi_out_device:send({type='note_on', note=note, ch=midi_out_channel})
  
  active_note_age_map[note] = 1
end

function build_scale_notes()
  scale_notes = music_util.generate_scale(params:get("root_note") - 1, params:get("scale_mode"), 1)
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
      libc.forEachCircle(function(c)
        local note = noteForCircle(c)
        midi_out_device:send({type="note_off", note=note, ch=midi_out_channel})
        active_note_age_map[note] = nil
      end)
      libc.removeAllCircles()
    else
      libc.addCircle()
    end
  elseif n == 2 and z == 1 then
    if message then
      message = nil
    else
      local removedCircle = libc.removeCircleAt()
      local note = noteForCircle(removedCircle)
      midi_out_device:send({type="note_off", note=note, ch=midi_out_channel})
      active_note_age_map[note] = nil
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
