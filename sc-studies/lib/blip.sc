Engine_Blip : CroneEngine {

  var amp=0;
	var <synth;

  // this is your constructor. the 'context' arg is a CroneAudioContext.
  // it provides input and output busses and groups.
  // see its implementation for details.
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	
	alloc {
		//Add SynthDefs
		SynthDef(\scStudies, {|inL, inR, out, amp=0.03, freqL=440, freqR=440|
			// read stereo
			var sound = [SinOsc.ar(LFNoise0.kr(8, freqL, 5000)), SinOsc.ar(LFNoise0.kr(16, freqR, 5000))];
			Out.ar(out, sound*amp);
		}).add;

		context.server.sync;

		synth = Synth.new(\scStudies, [
			\inL, context.in_b[0].index,			
			\inR, context.in_b[1].index,
			\out, context.out_b.index,
			\amp, 0.03,
			\freqL, 440,
			\freqR, 440],
		context.xg);

    // this is how you add "commands",
    // which is how the lua interpreter controls the engine.
    // the format string is analogous to an OSC message format string,
    // and the 'msg' argument contains data.

		this.addCommand("test", "ifs", {|msg|
			msg.postln;
		});

		this.addCommand("amp", "f", {|msg|
			synth.set(\amp, msg[1]);
		});
		
		this.addCommand("freqL", "f", {|msg|
		  synth.set(\freqL, msg[1]);
		});
		
		this.addCommand("freqR", "f", {|msg|
		  synth.set(\freqR, msg[1]);
		});
	}

	free {
    // here you should free resources (e.g. Synths, Buffers &c)
    // and stop processes (e.g. Routines, Tasks &c)
    synth.free;
	}
}