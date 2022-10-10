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

		SynthDef(\twoButton2, { | inL, inR, out, amp=0.5, ampHz=4, fund=40, maxPartial=4, release=0.65 |
			var sig1, sig2, env, scale, pitch1, pitch2, index;
			
			sig1 = SinOsc.ar() * amp;
			sig2 = SinOsc.ar(XLine.kr(500, 0.1, 1), 0.5);
			
			env = Env.perc(level: amp, releaseTime: release).kr(2);
			
			//Out.ar(0, sig1 * env);
			//Out.ar(1, MoogFF.ar(sig2, XLine.kr(0.1, 1600, 0.3), 1) * env);
			//Out.ar(0, [Mix.new(SinOsc.ar([500 * ampHz, 1000 * ampHz, 1500 * ampHz]) * 0.3) * env, Mix.new(SinOsc.ar([300, 600, 900]) * 0.3) * env]);
			Out.ar(0, Splay.ar(SinOsc.ar({(ExpRand(50, 3000) * ampHz)}!3)) * env);
		}).add;

		context.server.sync;

		
		this.addCommand(\hz, "ff", { arg msg;
		  var ampHz = msg[1];
		  var release = msg[2];
		  
		  Synth.new(\twoButton2, [\inL, context.in_b[0].index, \inR, context.in_b[1].index, \out, context.out_b.index,
			\amp, 0.5, \ampHz, ampHz, \fund, 40, \maxParticle, 4, \release, release], context.xg);
			
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

	}

	free {
    synth.free;
	}
}