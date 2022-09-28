engine.name = 'PulseSquash'
local UI = require "ui"

amp = 0.5
ticks = 0
sweep = 0.5
release = 1.65
resonance = 2
division = 2

function init()
  
  ampDial = UI.Dial.new(9, 1, 22, 0.5, 0.1, 10)
  releaseDial = UI.Dial.new(40, 1, 22, 1.65, 0.1, 4)
  divisionDial = UI.Dial.new(70, 1, 22, 2, 0.1, 10)
  
  counter = metro.init()
  counter.time = 1 / division
  counter.event = count
  counter:start()
  
  params:add_control("amp", "amp", controlspec.new(0.00, 3, "lin", 0.01, 0.5, 'amp'))
  params:set_action("amp", function(v) engine.amp(v) end)
  
  params:add_control("ampHz", "ampHz", controlspec.new(0.00, 6, "lin", 0.1, 4, 'ampHz'))
  params:set_action("ampHz", function(v) engine.ampHz(v) end)
  
  params:add_control("resonance", "resonance", controlspec.new(0.00, 10, "lin", 0.1, 2, 'resonance'))
  params:set_action("resonance", function(v) engine.resonance(v); resonance = v; end)
  
  params:add_control("maxPartial", "maxPartial", controlspec.new(0.00, 8, "lin", 0.1, 4, 'maxPartial'))
  params:set_action("maxPartial", function(v) engine.maxPartial(v) end)
  
  params:add_control("sweep", "sweep", controlspec.new(0.00, 4, "lin", 0.1, 0.5, 'sweep'))
  params:set_action("sweep", function(v) engine.sweep(v); sweep = v; end)
  
  params:add_control("division", "division", controlspec.new(-100, 100, "lin", 1, 2, 'division'))
  params:set_action("division", function(v) division = v; counter.time = 1 / division; end)
  
  audio.level_cut(1.0)
  audio.level_adc_cut(0)
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

function count(stage)
  engine.hz(sweep, amp, release, resonance)
  --redraw()
end

function key(n,z)
  print(n .. ' ' .. z)
  if n == 2 then
    engine.hz(25, 1.5, release)
  elseif n == 3 then
    engine.hz(23, 1.5, release)
  end
end

function enc(n, delta)
  if n == 1 then
    divisionDial:set_value_delta(delta * 0.05)
    division = divisionDial.value
    counter.time = 1 / division
  elseif n == 2 then
    ampDial:set_value_delta(delta * 0.05)
    amp = ampDial.value
  elseif n == 3 then
    releaseDial:set_value_delta(delta * 0.05)
    release = releaseDial.value
  end
  redraw()
end

function redraw()
  screen.clear()
  screen.fill()
  
  divisionDial:redraw()
  ampDial:redraw()
  releaseDial:redraw()
  screen.pixel(10, 50);
  screen.text('Press Either Button')
  screen.update();
end

function cleanup ()
end