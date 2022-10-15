engine.name = 'Helicopter'
local UI = require "ui"
local tab = require "tabutil"

release = 0
m = midi.connect()
lastFreq = ''
sawAmp = 0.85
sinAmp = 0.35

lift = false
xpos=50
altitude=50
angle = 1
liftOff = false

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
  if altitude < 0 or altitude > 50 or xpos < 20 or xpos > 115 then
    gameOver = true
  end
  
  if lift == true then
    if gameOver == false then
      engine.hz(midi_to_hz(43), release, sawAmp * 0.1, sinAmp)
    else
      softcut.play(1, 0)
      softcut.play(2, 0)
      engine.hz(midi_to_hz(13), 1, 10, 10)
      softcut.buffer_clear()
      gameOver = true
      redraw()
      counter:stop()
    end
    altitude = util.clamp(altitude - 0.4, -10, 50)
  else
    altitude = util.clamp(altitude + 0.4, -10, 50)
  end
  
  angle = angle + 20
  
  redraw()
end

function reset()
  softcut.play(1, 1)
  softcut.play(2, 1)
  lift = false
  liftOff = false
  xpos=50
  altitude=50
end

function key(n,z)
  if gameOver == true and n == 3 then
    gameOver = false
    counter:start()
    reset()
    redraw()
  end
  if n == 2 and z == 1 then
    liftOff = true
    lift = true
  elseif n == 2 then
    lift = false
  end
end

function enc(n, delta)
  if n == 1 then
    
  elseif n == 2 then
    xpos = xpos + delta * 0.4
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
    
    --Body
    screen.rect(xpos, altitude, 10, 10)
    
    -- Tail
    screen.move_rel(0, 5)
    screen.line_rel(-15, 0)
    screen.stroke()
    
    -- Rear Rotor
    screen.move(xpos - 25, altitude + 5)
    screen.font_size(3)
    screen.text_rotate(xpos - 15, altitude + 5, '``heli``', angle)
    screen.text_rotate(xpos - 15, altitude + 5, '``heli``', angle + 180)
    
    -- Legs
    screen.move(xpos + 3, altitude + 10)
    screen.line_rel(-3, 3)
    
    screen.move(xpos + 7, altitude + 10)
    screen.line_rel(3, 3)
    screen.stroke()
    
    --Directions
    if liftOff == false then
      screen.font_size(10)
      screen.font_face(3)
      screen.move(20, 10)
      screen.text('K2: Liftoff')
      screen.move(20, 30)
      screen.text('Avoid the edge')
    end
  else
    screen.font_size(20)
    screen.move(10, 50)
    screen.text('GAME OVER')
  end
  
  screen.update();
end

function cleanup ()
end