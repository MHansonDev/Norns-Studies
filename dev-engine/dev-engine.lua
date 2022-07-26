-- pools
--
-- a pitch shifting reverb
--
--
-- @justmat

engine.name = "Dev"
local FilterGraph = require "filtergraph"

local page = 2
local alt = false

local dry_lvl = {15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0}

local lfo_targets = {
  "none",
  "dry",
  "verb",
  "shimmer",
  "freq",
  "res",
  "time",
  "damp",
  "size",
  "diff",
  "lowx",
  "midx",
  "highx",
  "pitchDisp",
  "timeDisp"
}


local function update_fg()
  -- keeps the filter graph current
  local ftype = params:get("type") == 0 and "lowpass" or "highpass"
  filter:edit(ftype, 12, params:get("freq"), params:get("res"))
end


function init()

  params:add_separator()

  -- filter params
  -- freq
  params:add_control("freq", "freq", controlspec.new(0.01, 20000, "exp", 0, 20000))
  params:set_action("freq", function(v) engine.freq(v) end)
  -- resonance/q
  params:add_control("res", "res", controlspec.UNIPOLAR)
  params:set_action("res", function(v) engine.res(v) end)
  -- input gain
  params:add_control("gain", "gain", controlspec.new(0.00, 5.00, "lin", 0.01, 1.00))
  params:set_action("gain", function(v) engine.gain(v) end)
  -- filter type lp/hp
  params:add_number("type", "type", 0, 1, 0)
  params:set_action("type", function(v) engine.type(v) end)

  params:add_separator()

  -- reverb params
  -- t60: approximate reverberation time in seconds (assuming damp == 0)
  params:add_control("time", "time", controlspec.new(0, 60, "lin", 1, 5))
  params:set_action("time", function(v) engine.t60(v) end)
  -- dampening: controls damping of high-frequencies as the reverb decays
  params:add_control("damp", "damp", controlspec.new(0.00, 1.00, "lin", 0.01, 0.13))
  params:set_action("damp", function(v) engine.damp(v) end)
  -- size: scales size of delay-lines within the reverberator, producing the impression of a larger or smaller space
  params:add_control("size", "size", controlspec.new(0.5, 5.0, "lin", 0.1, 1.5))
  params:set_action("size", function(v) engine.size(v) end)
  -- early diffusion: controls shape of early reflections
  params:add_control("diff", "diff", controlspec.new(0.00, 1.00, "lin", 0.01, 0.70))
  params:set_action("diff", function(v) engine.diff(v) end)
  -- modulation depth
  params:add_control("modDepth", "mod depth", controlspec.new(0, 50, "lin", 0, 1))
  params:set_action("modDepth", function(v) engine.modDepth(v) end)
  -- modulation frequency
  params:add_control("modFreq", "mod freq", controlspec.new(0.0, 10.00, "lin", 0.01, 0.1, "hz"))
  params:set_action("modFreq", function(v) engine.modFreq(v) end)

  params:add_separator()

  -- reverb eq/filtering
  -- low: multiplier (0..1) for the reverberation time within the low band
  params:add_control("lowx", "low x", controlspec.new(0.00, 1.00, "lin", 0.01, 1.00))
  params:set_action("lowx", function(v) engine.low(v) end)
  -- mid: multiplier (0..1) for the reverberation time within the mid band
  params:add_control("midx", "mid x", controlspec.new(0.00, 1.00, "lin", 0.01, 1.00))
  params:set_action("midx", function(v) engine.mid(v) end)
  -- high: multiplier (0..1) for the reverberation time within the high band
  params:add_control("highx", "high x", controlspec.new(0.00, 1.00, "lin", 0.01, 1.00))
  params:set_action("highx", function(v) engine.high(v) end)
  -- lowband: the crossover point between low and mid bands
  params:add_control("lowband", "lowband", controlspec.new(100, 6000, "lin", 0, 6000, "hz"))
  params:set_action("lowband", function(v) engine.lowcut(v) end)
  -- highband: the crossover point between high and mid bands
  params:add_control("highband", "highband", controlspec.new(1000, 10000, "lin", 0, 1000, "hz"))
  params:set_action("highband", function(v) engine.highcut(v) end)

  params:add_separator()

  -- pitch shift controls
  -- pitch dispersion: random variation of pitch
  params:add_control("pitchDisp", "pitchDisp", controlspec.new(0.00, 1.00, "lin", 0.01, 0.13))
  params:set_action("pitchDisp", function(v) engine.pitchDispersion(v * .25) end)
  -- time dispersion: delay between playing a note and hearing the shifted note
  params:add_control("timeDisp", "timeDisp", controlspec.new(0.00, 0.50, "lin", 0.01, 0.12))
  params:set_action("timeDisp", function(v) engine.timeDispersion(v) end)
  -- pitch ratio: amount to pitchshift by
  params:add_control("pitchRatio", "pitchRatio", controlspec.new(0.0, 4.0, "lin", 0, 2.0))
  params:set_action("pitchRatio", function(v) engine.pitchRatio(v) end)


  params:bang()

  filter = FilterGraph.new()
  filter:set_position_and_size(0, 0, 127, 64)

  norns.enc.sens(0, 3)

  -- screen metro
  screen_timer = metro.init()
  screen_timer.time = 1/15
  screen_timer.stage = 1
  screen_timer.event = function() redraw() end
  screen_timer:start()
end


function key(n, z)
  if n == 1 then alt = z == 1 and true or false end

  if z == 1 then
    if n == 2 then
      page = util.clamp(page - 1, 1, 3)
    elseif n == 3 then
      page = util.clamp(page + 1, 1, 3)
    end
  end
end


function enc(n, d)
  if n == 3 then
    params:delta('pitchRatio', d)
  elseif n == 2 then
    params:delta('shimmer', d)
  elseif page == 1 then
    if n == 1 then
      params:delta("type", d)
    elseif n == 2 then
      params:delta("freq", d)
    elseif n == 3 then
      params:delta("res", d)
    end
  elseif page == 2 then
    if n == 1 then
      params:delta("dry", d)
    elseif n == 2 then
      params:delta("verb", d)
    elseif n == 3 then
      params:delta("shimmer", d)
    end
  else
    if alt then
      if n == 1 then
        params:delta("lowx", d)
      elseif n == 2 then
        params:delta("midx", d)
      elseif n == 3 then
        params:delta("highx", d)
      end
    else
      if n == 1 then
        params:delta("time", d)
      elseif n == 2 then
        params:delta("damp", d)
      elseif n == 3 then
        params:delta("diff", d)
      end
    end
  end
end


local function draw_mix()

  screen.clear()
  screen.aa(1)
  screen.font_face(13)
  -- dry
  screen.font_size(24)
  screen.level(15)
  screen.rect(4, 4, 42, 27)
  screen.fill()
  screen.move(8, 24)
  screen.text("dry")
  -- verb!
  screen.font_size(24)


  screen.move(64, 58)
  screen.font_face(23)
  screen.font_size(24)
  screen.update()
end


local function draw_filter()
  update_fg()
  screen.clear()
  filter:redraw()
  screen.update()
end


local function draw_edit()
  screen.clear()
  screen.font_face(7)
  screen.font_size(16)
  screen.level(alt and 2 or 8)

  screen.fill()
  screen.stroke()
  screen.level(alt and 8 or 2)

  screen.update()
end


function redraw()
  if page == 1 then
    draw_filter()
  elseif page == 2 then
    draw_mix()
  else
    draw_edit()
  end
end
