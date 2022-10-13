engine.name = 'MidiSaw'
local UI = require "ui"
local tab = require "tabutil"

release = 1
m = midi.connect()
lastFreq = ''
sawAmp = 1
sinAmp = 1

function init()
  
  releaseDial = UI.Dial.new(9, 20, 22, 0.5, 0, 4)
  sawAmpDial = UI.Dial.new(44, 20, 22, 0.5, 0, 2)
  sinAmpDial = UI.Dial.new(79, 20, 22, 0.5, 0, 2)
  
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
  softcut.enable(1, 1)
  
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
  softcut.enable(2, 1)
  
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
  if n == 1 then
    releaseDial:set_value_delta(delta * 0.05)
    release = releaseDial.value
  elseif n == 2 then
    sawAmpDial:set_value_delta(delta * 0.05)
    sawAmp = sawAmpDial.value
  elseif n == 3 then
    sinAmpDial:set_value_delta(delta * 0.05)
    sinAmp = sinAmpDial.value
    print(sinAmp)
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
    engine.hz(midi_to_hz(d.note), release, sawAmp * 0.1, sinAmp)
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
  sawAmpDial:redraw()
  sinAmpDial:redraw()
  
  screen.move(5, 10);
  screen.text('Release')
  screen.move(50, 10);
  screen.text('Saw')
  screen.move(85, 10);
  screen.text('Sin')
  
  screen.move(20, 60)
  screen.text(lastFreq);
  
  screen.update();
end

function cleanup ()
end