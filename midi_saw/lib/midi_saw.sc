Engine_MidiSaw : CroneEngine {

	var <synth;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	
	alloc {

		SynthDef(\midiSaw, { | inL, inR, out, amp=0.5, freq=4, release=0.65 |
			var env, temp, sum;
			
			env = EnvGen.kr(
			  Env.perc(0.01, release, 1, -2),
			  doneAction:2
			);
			
			sum = 0;
			10.do{
			  temp  = VarSaw.ar(
			    freq * {Rand(0.98, 1, 1.02)}!2,
			    {Rand(0.0, 1.0)}!2,
			    {ExpRand(0.005, 0.05)}!2
			  );
			  sum = sum + temp;
			};
			sum = sum * 0.05 * env;
			Out.ar(0, sum);
		}).add;

		context.server.sync;

		
		this.addCommand(\hz, "ff", { arg msg;
		  var freq = msg[1];
		  var release = msg[2];
		  
		  Synth.new(\midiSaw, [\inL, context.in_b[0].index, \inR, context.in_b[1].index, \out, context.out_b.index,
			\amp, 0.5, \freq, freq, \release, release], context.xg);
			
		});

	}

	free {
    synth.free;
	}
}