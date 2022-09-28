engine.name = "Simp"

function init()
  audio.comp_on()
  params:add_control("amp", "amp", controlspec.new(0.00, 10, "lin", 0.1, 1, 'amp'))
  params:set_action("amp", function(v) engine.amp(v) end)
  
    params:add_control("pitchRatio", "pitchRatio", controlspec.new(1, 30, 'lin', 0.1, 30, 'bits'))
    params:set_action("pitchRatio", function(v)
    print(v)
    engine.pitchRatio(v)
  end)
end

function redraw()
  screen.text('Dev Engine')
  screen.update()
end