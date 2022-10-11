engine.name = 'MidiSaw'
local UI = require "ui"
local tab = require "tabutil"

release = 0.65
m = midi.connect()
lastFreq = '';

function init()
  
  releaseDial = UI.Dial.new(9, 20, 22, 0.5, 0.1, 4)
  
  params:add_control("amp", "amp", controlspec.new(0.00, 3, "lin", 0.01, 0.5, 'amp'))
  params:set_action("amp", function(v) engine.amp(v) end)
  
  params:add_control("ampHz", "ampHz", controlspec.new(0.00, 6, "lin", 0.1, 4, 'ampHz'))
  params:set_action("ampHz", function(v) engine.ampHz(v) end)
  
  params:add_control("fund", "fund", controlspec.new(0.00, 80, "lin", 1, 40, 'fund'))
  params:set_action("fund", function(v) engine.fund(v) end)
  
  params:add_control("maxPartial", "maxPartial", controlspec.new(0.00, 8, "lin", 0.1, 4, 'maxPartial'))
  params:set_action("maxPartial", function(v) engine.maxPartial(v) end)
  
  params:add_control("width", "width", controlspec.new(0.00, 4, "lin", 0.1, 0.5, 'fund'))
  params:set_action("width", function(v) engine.width(v) end)
  
  audio.level_cut(1.0)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  
  
  -- Voice 1
  softcut.level(1,1.0)
  softcut.level_input_cut(1, 1, 1)

  softcut.play(1, 1)
  softcut.pan(1, -1)
  softcut.rate(1, 44)
  softcut.loop_start(1, 0)
  softcut.loop_end(1, 1)
  softcut.loop(1, 1)
  softcut.fade_time(1, 32)
  softcut.rec(1, 1)
  softcut.rec_level(1, 0.3)
  softcut.pre_level(1, 0.3) --[[ 0_0 ]]--
  softcut.position(1, 0)
  softcut.enable(1, 0)
  
  softcut.filter_dry(1, 0);
  softcut.filter_lp(1, 1.0);
  softcut.filter_bp(1, 1.0);
  softcut.filter_hp(1, 1.0);
  softcut.filter_fc(1, 3000);
  softcut.filter_rq(1, 1.0);
  
  -- Voice 2
  softcut.level(2,1.0)
  softcut.level_input_cut(2, 2, 1)
  
  softcut.play(2, 1)
  softcut.pan(2, 1)
  softcut.rate(2, 32)
  softcut.loop_start(2, 0)
  softcut.loop_end(2, 1)
  softcut.loop(2, 1)
  softcut.fade_time(2, 32)
  softcut.rec(2, 1)
  softcut.rec_level(2, 0.3)
  softcut.pre_level(2, 0.4) --[[ 0_0 ]]--
  softcut.position(2, 0)
  softcut.enable(2, 0)
  
  softcut.filter_dry(2, 0);
  softcut.filter_lp(2, 1.0);
  softcut.filter_bp(2, 1.0);
  softcut.filter_hp(2, 1.0);
  softcut.filter_fc(2, 3000);
  softcut.filter_rq(2, 1.0);

  
end

function key(n,z)
  print(n .. ' ' .. z)
  if z == 1 then
    if n == 2 then
    elseif n == 3 then
    end
  end
end

function enc(n, delta)
  if n == 2 then
    releaseDial:set_value_delta(delta * 0.05)
    release = releaseDial.value
  end
  redraw()
end

function midi_to_hz(note)
  local hz = (440 / 32) * (2 ^ ((note - 9) / 12))
  return hz
end

m.event = function(data)
  local d = midi.to_msg(data)
  if d.type == "note_on" then
    engine.hz(midi_to_hz(d.note), release)
    lastFreq = midi_to_hz(d.note)
  end
  if d.type == "cc" then
    print("cc " .. d.cc .. " = " .. d.val)
    if (d.cc == 0) then
      engine.cutoff(d.val * 50)
    end
  end
  redraw()
end

function redraw()
  screen.clear()
  screen.fill()
  
  releaseDial:redraw()
  screen.move(5, 10);
  screen.text('Release')
  screen.move(50, 30)
  screen.text(lastFreq);
  screen.update();
end

function cleanup ()
end