engine.name = 'Helicopter'
local UI = require "ui"
local tab = require "tabutil"

release = 0
m = midi.connect()
lastFreq = ''
sawAmp = 0.85
sinAmp = 0.35

lift = false
xdir=50
altitude=50

gameOver = false

function init()
  
  counter = metro.init()
  counter.time = 1/13
  counter.count = -1
  counter.event = count
  counter:start()
  
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

function count(stage)
  if (altitude < 0) then
    gameOver = true
  end
  
  
  if lift == true then
    if gameOver == false then
      engine.hz(midi_to_hz(43), release, sawAmp * 0.1, sinAmp)
    else
      engine.hz(midi_to_hz(13), 5, 3, 3)
      gameOver = true
      redraw()
      counter:stop()
    end
    altitude = util.clamp(altitude - 0.4, -10, 50)
  else
    altitude = util.clamp(altitude + 0.4, -10, 50)
  end
  redraw()
end

function key(n,z)
  print(n .. ' ' .. z)
  if n == 1 and z == 1 then
    lift = true
  elseif n == 1 then
    lift = false
  end
  if n == 2 then

  end
end

function enc(n, delta)
  if n == 1 then
    
  elseif n == 2 then
    xdir = xdir + delta * 0.4
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
  tab.print(d)
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
  
  if gameOver == false then
    screen.rect(xdir, altitude, 10, 10)
    screen.arc(xdir + 5, altitude - 15, 10, 90, 170)
  else
    screen.font_size(20)
    screen.move(10, 50)
    screen.text('GAME OVER')
  end
  
  screen.update();
end

function cleanup ()
end