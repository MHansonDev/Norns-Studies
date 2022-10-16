Engine_PitchShift : CroneEngine {

	var amp=0;
	var <synth;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		//Add SynthDefs
		SynthDef(\passThru, {|inL, inR, out, amp=0.5, windowSize=0.5, pitchRatio=30, pitchDispertion=0.0, timeDispertion=0.02 |
			  // read stereo
			  var sound = [In.ar(inL), In.ar(inR)];
			  var shifted = PitchShift.ar(sound, 1, pitchRatio, 0, amp);
			
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
    synth.free;
	}

} 
