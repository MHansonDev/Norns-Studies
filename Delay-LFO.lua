-- Softcut / LFO / Midi Study
local ControlSpec = require "controlspec"
local MollyThePoly = require "molly_the_poly/lib/molly_the_poly_engine"
local Formatters = require "formatters"

engine.name = "PolyPerc"

m = midi.connect()

rate = 1.0
rec = 1.0
pre = 0.00

local SCREEN_FRAMERATE = 15
local screen_dirty = true

local NUM_LFOS = 2
local LFO_MIN_TIME = 1 -- Secs
local LFO_MAX_TIME = 60 * 60 * 24
local LFO_UPDATE_FREQ = 128
local LFO_RESOLUTION = 128 -- MIDI CC resolution

local lfo_freqs = {}
local lfo_progress = {}
local lfo_values = {}

local specs = {}
specs.TIME_L = ControlSpec.new(LFO_MIN_TIME, LFO_MAX_TIME, "exp", 0, 4, "s")
specs.TIME_R = ControlSpec.new(LFO_MIN_TIME, LFO_MAX_TIME, "exp", 0, 8, "s")

local function reset_phase()
    for i = 1, NUM_LFOS do
        lfo_progress[i] = math.pi * 1.5
    end
end

local function update_freqs()
    for i = 1, NUM_LFOS do
        lfo_freqs[i] = 1 / util.linexp(1, NUM_LFOS, params:get("time_l"), params:get("time_r"), i)
    end
end

local function lfo_update()
    local delta = (1 / LFO_UPDATE_FREQ) * 2 * math.pi
    for i = 1, NUM_LFOS do
        lfo_progress[i] = lfo_progress[i] + delta * lfo_freqs[i]
        local value = util.round(util.linlin(-1, 1, 0, LFO_RESOLUTION - 1, math.sin(lfo_progress[i])))
        if value ~= lfo_values[i] then
            lfo_values[i] = value
            screen_dirty = true
        end

        if i == 1 then
            softcut.position(1, lfo_values[1] * 0.01)
            softcut.filter_bp(2, (lfo_values[1] * 0.025));
        end
    end
end

local function screen_update()
    if screen_dirty then
        screen_dirty = false
        redraw()
    end
end

function midi_to_hz(note)
    local hz = (440 / 32) * (2 ^ ((note - 9) / 12))
    return hz
end

m.event = function(data)
    local d = midi.to_msg(data)
    if d.type == "note_on" then
        engine.amp(d.vel / 127)
        engine.hz(midi_to_hz(d.note))
        -- softcut.rec_level(1, d.note * 0.03)
    end
    if d.type == "cc" then
        print("cc " .. d.cc .. " = " .. d.val)
        if (d.cc == 0) then
            engine.cutoff(d.val * 50)
        end

    end
end

function init()
    params:add_separator()

    params:add{
        type = "number",
        id = "midi_out_channel",
        name = "MIDI Out Channel",
        min = 1,
        max = 16,
        default = 1,
        action = function(value)
            midi_out_channel = value
        end
    }

    params:add{
        type = "number",
        id = "midi_cc_start",
        name = "MIDI CC Range",
        min = 0,
        max = 128 - NUM_LFOS,
        default = 1,
        formatter = function(param)
            return param:get() .. "-" .. param:get() + NUM_LFOS - 1
        end
    }

    params:add_separator("LFOs")

    params:add{
        type = "control",
        id = "time_l",
        name = "Left Time",
        controlspec = specs.TIME_L,
        formatter = Formatters.format_secs,
        action = function(value)
            update_freqs()
            screen_dirty = true
        end
    }

    params:add{
        type = "control",
        id = "time_r",
        name = "Right Time",
        controlspec = specs.TIME_R,
        formatter = Formatters.format_secs,
        action = function(value)
            update_freqs()
            screen_dirty = true
        end
    }

    engine.release(1)
    engine.pw(0.5)
    engine.cutoff(7000)
    audio.rev_on()
    audio.level_monitor_rev(0.3)

    audio.level_cut(1.0)
    audio.level_adc_cut(1)
    audio.level_eng_cut(1)

    -- Voice 1
    softcut.level(1, 1.0)
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
    softcut.pre_level(1, 0.4) --[[ 0_0 ]] --
    softcut.position(1, 0)
    softcut.enable(1, 1)

    softcut.filter_dry(1, 0);
    softcut.filter_lp(1, 1.0);
    softcut.filter_bp(1, 1.0);
    softcut.filter_hp(1, 1.0);
    softcut.filter_fc(1, 3000);
    softcut.filter_rq(1, 1.0);

    -- Voice 2
    softcut.level(2, 1.0)
    softcut.level_input_cut(1, 2, 1)

    softcut.play(2, 1)
    softcut.pan(2, 1)
    softcut.rate(2, 32)
    softcut.loop_start(2, 0)
    softcut.loop_end(2, 1)
    softcut.loop(2, 1)
    softcut.fade_time(2, 32)
    softcut.rec(2, 1)
    softcut.rec_level(2, 0.3)
    softcut.pre_level(2, 0.4) --[[ 0_0 ]] --
    softcut.position(2, 0)
    softcut.enable(2, 1)

    softcut.filter_dry(2, 0);
    softcut.filter_lp(2, 1.0);
    softcut.filter_bp(2, 1.0);
    softcut.filter_hp(2, 1.0);
    softcut.filter_fc(2, 3000);
    softcut.filter_rq(2, 1.0);

    reset_phase()
    update_freqs()
    lfo_update()

    metro.init(lfo_update, 1 / LFO_UPDATE_FREQ):start()
    metro.init(screen_update, 1 / SCREEN_FRAMERATE):start()
end

function enc(n, d)
    if n == 1 then
        rate = util.clamp(rate + d / 100, -4, 4)
        softcut.rate(1, (44 * rate));
        softcut.rate(2, (32 * rate));
        print(rate);
    elseif n == 2 then
        rec = util.clamp(rec + d / 100, 0, 1)
        softcut.rec_level(1, rec);
        softcut.rec_level(2, rec);
        print(rec);
    elseif n == 3 then
        pre = util.clamp(pre + d / 100, 0, 1)
        softcut.pre_level(1, pre);
        softcut.pre_level(2, pre);
        print(pre);
    end
    redraw()
end

function key(n, z)
    if n == 2 and z == 1 then
        if rec == 0 then
            rec = 1
        else
            rec = 0
        end
        softcut.rec_level(1, rec)
    elseif n == 3 and z == 1 then
        if pre == 1 then
            pre = 0
        else
            pre = 1
        end
        softcut.pre_level(1, pre)
    end
    redraw()
end

function redraw()
    screen.clear()
    screen.aa(1)

    local BAR_W, BAR_H = 1, 41
    local MARGIN_H, MARGIN_V = 6, 6
    local gutter = (128 - MARGIN_H * 2 - BAR_W * NUM_LFOS) / (NUM_LFOS - 1)

    -- Draw bars
    for i = 1, NUM_LFOS do
        local row_x = util.round(MARGIN_H + (gutter + BAR_W) * (i - 1))

        -- Dotted
        for y = 0, BAR_H - 1, 2 do
            screen.rect(row_x, MARGIN_V + y, BAR_W, 1)
            screen.level(1)
            screen.fill()
        end

        -- Fills
        local filled_height = util.linlin(0, LFO_RESOLUTION - 1, 0, BAR_H, lfo_values[i])
        screen.rect(row_x, MARGIN_V + BAR_H - filled_height, BAR_W, filled_height)
        screen.level(15)
        screen.fill()
    end

    -- Draw text
    screen.level(3)
    screen.move(MARGIN_H, 64 - 5)
    screen.text("\u{25C0} " .. params:string("time_l"))
    screen.move(128 - MARGIN_H, 64 - 5)
    screen.text_right(params:string("time_r") .. " \u{25B6}")
    screen.fill()

    screen.move(20, 20)
    screen.text("rate: ")
    screen.move(100, 20)
    screen.text_right(string.format("%.2f", rate))
    screen.move(20, 30)
    screen.text("rec: ")
    screen.move(100, 30)
    screen.text_right(string.format("%.2f", rec))
    screen.move(20, 40)
    screen.text("pre: ")
    screen.move(100, 40)
    screen.text_right(string.format("%.2f", pre))

    screen.update()

end
