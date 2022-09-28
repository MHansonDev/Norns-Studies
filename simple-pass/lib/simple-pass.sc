Engine_Simp : CroneEngine {

	var amp=0;
	var <synth;

// this is your constructor. the 'context' arg is a CroneAudioContext.
// it provides input and output busses and groups.
// see its implementation for details.
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

// this is called when the engine is actually loaded by a script.
// you can assume it will be called in a Routine,
//  and you can use .sync and .wait methods.

	alloc {
		//Add SynthDefs
		SynthDef(\passThru, {|inL, inR, out, amp=0.5, windowSize=0.5, pitchRatio=30, pitchDispertion=0.0, timeDispertion=0.02 |
			  // read stereo
			  var sound = [In.ar(inL), In.ar(inR)];
			
				var source = SinOsc.ar(550, 0, 0.1);
			  //var shifted = Ringz.ar(sound, windowSize, pitchRatio, pitchDispertion, timeDispertion);
			  var shifted = PitchShift.ar(sound, 1, pitchRatio, 0, amp);
			  var decimated = Decimator.ar(sound, 44100, pitchRatio, 1, 0);
			  //LocalOut.ar(shifted * 9);
				//LocalOut.ar(sound * 2.5);
			
			Out.ar(out, shifted * amp);
		}).add;

		context.server.sync;

		synth = Synth.new(\passThru, [
			\inL, context.in_b[0].index,			
			\inR, context.in_b[1].index,
			\out, context.out_b.index,
			\amp, 0.5,
			\pitchRatio, 30],
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
		
		this.addCommand("pitchRatio", "f", {|msg|
		  synth.set(\pitchRatio, msg[1]);
		});

		
	}

	free {
             // here you should free resources (e.g. Synths, Buffers &c)
// and stop processes (e.g. Routines, Tasks &c)
            synth.free;
	}

} 