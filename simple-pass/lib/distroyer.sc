Engine_Distroyer : CroneEngine {

	var amp=0;
	var <synth;
	
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		//Add SynthDefs
		SynthDef(\passThru, {|inL, inR, out, amp=0.5, rate=751, smooth=0.24, mult=1, add=0 |
			  var sound = [In.ar(inL), In.ar(inR)];
			  var destroyed = SmoothDecimator.ar(sound, rate, smooth, mult, add);
			
			Out.ar(out, destroyed * amp);
		}).add;

		context.server.sync;

		synth = Synth.new(\passThru, [
			\inL, context.in_b[0].index,			
			\inR, context.in_b[1].index,
			\out, context.out_b.index,
			\amp, 0.5,
			\rate, 751,
			\smooth, 0.24,
			\mult, 1,
			\add, 0],
		context.xg);

		this.addCommand("test", "ifs", {|msg|
			msg.postln;
		});
		
		this.addCommand("amp", "f", {|msg|
			synth.set(\amp, msg[1]);
		});
		
		this.addCommand("rate", "f", {|msg|
			synth.set(\rate, msg[1]);
		});
		
		this.addCommand("smooth", "f", {|msg|
		  synth.set(\smooth, msg[1]);
		});
		
		this.addCommand("mult", "f", {|msg|
		  synth.set(\mult, msg[1]);
		});
		
		this.addCommand("add", "f", {|msg|
		  synth.set(\add, msg[1]);
		});

	}

	free {
    synth.free;
	}

}