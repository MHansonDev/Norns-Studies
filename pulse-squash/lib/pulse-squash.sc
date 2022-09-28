Engine_PulseSquash : CroneEngine {

  var amp=1.65;
	var <synth;

  // this is your constructor. the 'context' arg is a CroneAudioContext.
  // it provides input and output busses and groups.
  // see its implementation for details.
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	
	alloc {

		SynthDef(\pulseSquash, { | inL, inR, out, amp=0.5, ampHz=4, resonance=2, maxPartial=4, release=1.65, sweep=0.5 |
			var amp1, amp2, freq1, freq2, sig1, sig2, env, scale, pitch1, pitch2, index;
			
      var sound = [In.ar(inL), In.ar(inR)];
			env = Env.perc(level: amp, releaseTime: release).kr(2);
			
			Out.ar(out, (MoogFF.ar(sound, XLine.kr(0.1, 16000, sweep), XLine.kr(0.1, resonance, sweep)) * env) * amp);
		}).add;

		context.server.sync;

		
		this.addCommand(\hz, "ffff", { arg msg;
		  var sweep = msg[1];
		  var amp = msg[2];
		  var release = msg[3];
		  var resonance = msg[4];
		  msg.postln;
		  
		  Synth.new(\pulseSquash, [\inL, context.in_b[0].index, \inR, context.in_b[1].index, \out, context.out_b.index,
			  \amp, amp, \resonance, resonance, \maxParticle, 4, \release, release, \sweep, sweep], context.xg);
			
		});

		this.addCommand("test", "ifs", {|msg|
			msg.postln;
		});

		this.addCommand("amp", "f", {|msg|
			synth.set(\amp, msg[1]);
		});
		
		this.addCommand("ampHz", "f", {|msg|
		  msg.postln;
		  synth.set(\ampHz, msg[1]);
		});
		
		this.addCommand("resonance", "f", {|msg|
		  synth.set(\resonance, msg[1]);
		});
		
		this.addCommand("maxPartial", "f", {|msg|
		  synth.set(\maxPartial, msg[1]);
		});
		
		this.addCommand("sweep", "f", {|msg|
		  synth.set(\sweep, msg[1]);
		});

	}

	free {
    synth.free;
	}
}