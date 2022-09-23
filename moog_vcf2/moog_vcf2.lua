engine.name = 'MoogVCF2'
local UI = require "ui"
local ControlSpec = require "controlspec"

local ampDial, freqDial, gainDial

function init()
  audio.level_monitor(0)
  audio.rev_off()
  
  params:add{type = "control", controlspec = ControlSpec.new(0.0, 5.0, "lin", 0.1, 2, 'amp'), id = "amp"}
  params:set_action('amp', function(v) engine.amp(v) end)
  
  params:add{type = "control", controlspec = ControlSpec.new(10.0, 13000.0, "exp", 10, 7000, 'freq'), id = "freq"}
  params:set_action('freq', function(v) engine.freq(v) end)
  
  params:add{type = "control", controlspec = ControlSpec.new(0.0, 4.0, "lin", 0.1, 1, 'gain'), id = "gain"}
  params:set_action('gain', function(v) engine.gain(v) end)
  
  ampDial = UI.Dial.new(9, 19, 22, 2, 0.1, 5)
  freqDial = UI.Dial.new(45, 19, 22, 7000, 10, 13000)
  gainDial = UI.Dial.new(80, 19, 22, 1, 0, 4)

end

function enc(n, delta)
  if n == 1 then
    ampDial:set_value_delta(delta * 0.05)
    params:set('amp', ampDial.value)
  elseif n == 2 then
    freqDial:set_value_delta(delta * 50)
    params:set('freq', freqDial.value)
  elseif n == 3 then
    gainDial:set_value_delta(delta * 0.04)
    params:set('gain', gainDial.value)
  end
  redraw()
end


function redraw()
  screen.clear()
  screen.fill()
  
  ampDial:redraw()
  freqDial:redraw()
  gainDial:redraw()

  screen.move(11, 10)
  screen.text('amp')

  screen.move(47, 10)
  screen.text('freq')

  screen.move(82, 10)
  screen.text('gain')
  
  screen.update()
end