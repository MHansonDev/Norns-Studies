rate = 1.0
rec = 1.0
pre = 0.0

function init()

  audio.rev_on()
  audio.level_monitor_rev(0.3)

  -- configure the delay
  audio.level_cut(1.0)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  
  
  -- Voice 1
  softcut.level(1,1.0)
  softcut.level_input_cut(1, 1, 1)

  softcut.play(1, 1)
  softcut.pan(1, 0)
  softcut.rate(1, 44)
  softcut.loop_start(1, 0)
  softcut.loop_end(1, 1)
  softcut.loop(1, 1)
  softcut.fade_time(1, 32)
  softcut.rec(1, 1)
  softcut.rec_level(1, 0.3)
  softcut.pre_level(1, 0.4) --[[ 0_0 ]]--
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
  softcut.pan(2, 0)
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



  params:add_separator()
  params:add{id="delay", name="delay", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,0.5,""),
    action=function(x) softcut.level(1,x) end}
  params:add{id="delay_rate", name="delay rate", type="control", 
    controlspec=controlspec.new(0.5,2.0,'lin',0,1,""),
    action=function(x) softcut.rate(1,x) end}
  params:add{id="delay_feedback", name="delay feedback", type="control", 
    controlspec=controlspec.new(0,1.0,'lin',0,0.75,""),
    action=function(x) softcut.pre_level(1,x) end}
  params:add{id="delay_pan", name="delay pan", type="control", 
    controlspec=controlspec.new(-1,1.0,'lin',0,0,""),
    action=function(x) softcut.pan(1,x) end}
end

function enc(n,d)
  if n==1 then
    rate = util.clamp(rate+d/100,-4,4)
    softcut.rate(1,rate)
  elseif n==2 then
    rec = util.clamp(rec+d/100,0,1)
    softcut.rec_level(1,rec)
  elseif n==3 then
    pre = util.clamp(pre+d/100,0,1)
    softcut.pre_level(1,pre)
  end
  redraw()
end

function key(n,z)
  if n==2 and z==1 then
    if rec==0 then rec = 1 else rec = 0 end
    softcut.rec_level(1,rec)
  elseif n==3 and z==1 then
    if pre==1 then pre = 0 else pre = 1 end
    softcut.pre_level(1,pre)
  end
  redraw()
end

function redraw()
  screen.clear()
  screen.move(10,30)
  screen.text("rate: ")
  screen.move(118,30)
  screen.text_right(string.format("%.2f",rate))
  screen.move(10,40)
  screen.text("rec: ")
  screen.move(118,40)
  screen.text_right(string.format("%.2f",rec))
  screen.move(10,50)
  screen.text("pre: ")
  screen.move(118,50)
  screen.text_right(string.format("%.2f",pre))
  screen.update()
end