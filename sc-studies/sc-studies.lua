engine.name = 'SCStudies'

ticks = 0

function init()
  counter = metro.init()
  counter.time = 1/16
  counter.count = -1
  counter.event = count
  counter:start()
  
  params:add_control("amp", "amp", controlspec.new(0.00, 3, "lin", 0.01, 0, 'amp'))
  params:set_action("amp", function(v) engine.amp(v) end)
  
  params:add_control("freqL", "freqL", controlspec.new(10, 16000, "lin", 10, 440, 'amp'))
  params:set_action("freqL", function(v) engine.freqL(v) end)
  
  params:add_control("freqR", "freqR", controlspec.new(10, 16000, "lin", 10, 440, 'amp'))
  params:set_action("freqR", function(v) engine.freqR(v) end)
  
  params:add_control("phaseMod", "phaseMod", controlspec.new(0, 100, "lin", 0.1, 5, 'phaseMod'))
  params:set_action("phaseMod", function(v) engine.phaseMod(v) end)
end

function count(stage)
  ticks = ticks + 1
  redraw()
end

function redraw()
  if ticks > 100 then
    screen.clear();
  end
  if ticks > 150 then
    ticks = 0
  end
  screen.text('wat')
  screen.pixel(math.random(-10, 100), math.random(-10, 60));
  screen.update();
end