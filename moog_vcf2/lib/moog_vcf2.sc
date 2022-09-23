Engine_MoogVCF2 : CroneEngine {

	var amp=0;
	var <synth;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		SynthDef(\passThru, {|inL, inR, out, amp=2, freq=7000, gain=1 |
		
			  var sound = [In.ar(inL), In.ar(inR)];
			
			  var filtered = MoogFF.ar(sound, freq, gain);
			
			Out.ar(out, filtered * amp);
		}).add;

		context.server.sync;

		synth = Synth.new(\passThru, [
			\inL, context.in_b[0].index,			
			\inR, context.in_b[1].index,
			\out, context.out_b.index,
			\amp, 2,
			\freq, 7000,
			\gain, 1,
			\rate, 1],
		context.xg);

		this.addCommand("test", "ifs", {|msg|
			msg.postln;
		});
		
		this.addCommand("amp", "f", {|msg|
			synth.set(\amp, msg[1]);
		});
		
		this.addCommand("freq", "f", {|msg|
		  synth.set(\freq, msg[1]);
		});
		
		this.addCommand("gain", "f", {|msg|
		  synth.set(\gain, msg[1]);
		});

		
	}

	free {
    // here you should free resources (e.g. Synths, Buffers &c)
    // and stop processes (e.g. Routines, Tasks &c)
    synth.free;
	}

} 
