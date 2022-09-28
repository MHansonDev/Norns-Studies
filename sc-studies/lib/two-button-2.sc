Engine_TwoButton2 : CroneEngine {

  var amp=1.65;
	var <synth;

  // this is your constructor. the 'context' arg is a CroneAudioContext.
  // it provides input and output busses and groups.
  // see its implementation for details.
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	
	alloc {

		SynthDef(\twoButton2, { | inL, inR, out, amp=0.5, ampHz=4, fund=40, maxPartial=4, width=0.5, release=1.65 |
			var amp1, amp2, freq1, freq2, sig1, sig2, env, scale, pitch1, pitch2, index;
			
			scale = Buffer.loadCollection(synth, Scale.majorPentatonic.degrees);
			
			index = LFDNoise0.kr(1).range(0, 1);
			index = index * BufFrames.kr(scale);
			
			pitch1 = Index.kr(scale, index) + 6 * (ampHz / 4);
			pitch2 = Index.kr(scale, index) + 6 * (ampHz / 4);
			index.poll(7);
			
			sig1 = SinOsc.ar(pitch1.midicps + XLine.kr(500, 0.1, 1), 0.5);
			sig2 = SinOsc.ar(pitch2.midicps + XLine.kr(500, 0.1, 1), 0.5);
			//sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.35);
			//sig2 = FreeVerb.ar(sig2, 0.6, 0.6, 0.35);
			
			env = Env.perc(level: amp, releaseTime: release).kr(2);
			
			Out.ar(0, MoogFF.ar(sig1, XLine.kr(0.1, 1600, 0.5), XLine.kr(0.1, 5, 0.5)) * env);
			Out.ar(1, MoogFF.ar(sig2, XLine.kr(0.1, 1600, 0.3), 2) * env);
		}).add;

		context.server.sync;

		
		this.addCommand(\hz, "fff", { arg msg;
		  var ampHz = msg[1];
		  var width = msg[2];
		  var release = msg[3];
		  
		  Synth.new(\twoButton2, [\inL, context.in_b[0].index, \inR, context.in_b[1].index, \out, context.out_b.index,
			\amp, 0.5, \ampHz, ampHz, \fund, 40, \maxParticle, 4, \width, width, \release, release], context.xg);
			
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
		
		this.addCommand("fund", "f", {|msg|
		  synth.set(\fund, msg[1]);
		});
		
		this.addCommand("maxPartial", "f", {|msg|
		  synth.set(\maxPartial, msg[1]);
		});
		
		this.addCommand("width", "f", {|msg|
		  synth.set(\width, msg[1]);
		});

	}

	free {
    synth.free;
	}
}