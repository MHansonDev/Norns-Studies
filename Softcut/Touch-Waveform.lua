-- softcut study 8: copy
--
-- K1 load backing track
-- K2 random copy/paste
-- K3 save clip
-- E1 level

fileselect = require 'fileselect'
tabutil = require 'tabutil'

m = midi.connect()

file1 = _path.dust.."audio/waveform/Fall.wav"
file2 = _path.dust.."audio/waveform/Ambience.wav"

rate = 1
selecting = false

length1 = 1
position1 = 1
pos1 = 1

length2 = 1
position2 = 1
pos2 = 1


function load_file(file, buffer)
    local ch, samples = audio.file_info(file)
    length1 = (buffer == 1) and samples/48000 or length1
    length2 = (buffer == 2) and samples/48000 or length2
    softcut.buffer_read_mono(file,0,1,-1,1, buffer)
    reset(buffer)
    waveform_loaded = true
end

function update_positions(i, pos)
  if (i == 1) then
    position1 = (pos - 1) / length1
  elseif (i == 2) then
    position2 = (pos - 1) / length2
  end
  redraw()
end

function reset(i)
  softcut.enable(i,1)
  softcut.buffer(i,i)
  softcut.level(i,0)
  softcut.loop(i,1)
  softcut.loop_start(i,1)
  softcut.loop_end(i, (i == 1) and 1+length1 or 1 + length2)
  softcut.position(i,1)
  softcut.rate(i,1.0)
  softcut.play(i,1)
  softcut.fade_time(i,0.5)
  update_content(i, 1, (i == 1) and length1 or length2, 128)
end


-- WAVEFORM 1
local interval1 = 0
waveform1_samples = {}
waveform1Loaded = false

-- WAVEFORM 2
local interval2 = 0
waveform2_samples = {}
scale = 30

function on_render(ch, start, i, s)
  print(ch)
  if waveform1Loaded == false then
    waveform1_samples = s
    interval = i
    waveform1Loaded = true
  else
    waveform2_samples = s
    interval2 = i
    --print('waveform2' .. s)
  end
  redraw()
end

function update_content(buffer,winstart,winend,samples)
  softcut.render_buffer(buffer, winstart, winend - winstart, 128)
end
--/ WAVEFORMS

function init()
  softcut.buffer_clear()
  
  audio.level_adc_cut(1)
  softcut.level_input_cut(1,2,1.0)
  softcut.level_input_cut(2,2,1.0)

  softcut.phase_quant(1,0.01)
  softcut.event_phase(update_positions)
  softcut.poll_start_phase()
  softcut.event_render(on_render)

  reset(1)
  reset(2)
end

function key(n,z)
  if n==1 and z==1 then
    
    selecting = true
    print (_path.dust)
    fileselect.enter(_path.dust,load_file)
    
  elseif n==2 and z==1 then
    
    softcut.buffer_clear()
    load_file(file1, 1)
    load_file(file2, 2)
    
  elseif n==3 and z==1 then
    
    softcut.buffer_clear()
    reset(1)
    reset(2)
    
  end
end

function enc(n,d)
  if n==1 then
    --level = util.clamp(level+d/100,0,2)
    --softcut.level(1,level)
  elseif n==2 then
    -- This encoder controls the position of Softcut channel 1.
    -- It seems to work well with files greater than 2 minutes, but otherwise isn't stable.
    pos = util.clamp(position1 + (pos1 + d), 0, 48000)
    softcut.position(1,pos1)
    print(pos)
  elseif n==3 then
    rate = util.clamp(rate + (d * 0.1), -100, 10)
    softcut.rate(1, rate)
  end
  redraw()
end

-- CC Messages
m.event = function(data)
  local d = midi.to_msg(data)
  if d.type == "note_on" then
    --softcut.rec_level(1, d.note * 0.03)
  end
  if d.type == "cc" then
    print("cc " .. d.cc .. " = " .. d.val)
    if (d.cc == 0) then
      pos1 = util.clamp((d.val / 128) * length1, 0, 48000)
      softcut.position(1, pos1)
    elseif (d.cc == 1) then
      pos2 = util.clamp((d.val / 128) * length2, 0, 48000)
      softcut.position(2, pos2)
    elseif (d.cc == 2 or d.cc == 3) then
      -- Volume 1
      softcut.level((d.cc == 2 and 1 or 2), (d.val / 128) * 5)
    elseif (d.cc == 4 or d.cc == 5) then
      -- Rate
      local rate = (d.val * 4)
      rate = (rate / 128) - 1
      softcut.rate((d.cc == 4 and 1 or 2), rate)
      print(rate)
    end
  end
  redraw()
end

function redraw()
  screen.clear()

  screen.level(15)
  screen.move(62,10)

  screen.level(4)
  
  -- Position 1
  local x_pos = 0
  for i,s in ipairs(waveform1_samples) do
    local height = util.round(math.abs(s) * (scale * 1.0))
    screen.move(util.linlin(0,128,10,120,x_pos), 15.5 - (height / 2))
    screen.line_rel(0, 2 * (height / 2))
    screen.stroke()
    x_pos = x_pos + 1
  end
  screen.level(15)
  screen.move(util.linlin(0, 1, 10, 120, position1), 5)
  screen.line_rel(0, 20)
  screen.stroke()
  
  -- Position 2
  local x_pos2 = 0
  for i,s in ipairs(waveform2_samples) do
    local height = util.round(math.abs(s) * (scale * 1.0))
    screen.move(util.linlin(0,128,10,120,x_pos2 * 1.79), 47.5 - (height / 2))
    screen.line_rel(0, 2 * (height / 2))
    screen.stroke()
    x_pos2 = x_pos2 + 1
  end
  screen.level(15)
  screen.move(util.linlin(0, 1, 10, 120,position2),37)
  screen.line_rel(0, 20)
  screen.stroke()
  
  
  
  screen.update()
end