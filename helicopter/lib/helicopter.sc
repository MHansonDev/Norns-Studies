Engine_Helicopter : CroneEngine {

	var <synth;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	
	alloc {

		SynthDef(\helicopter, { | inL, inR, out, sawAmp=0.1, sinAmp=1, freq=4, release=1 |
			var env, temp, sum;
			
			env = EnvGen.kr(
			  Env.perc(0.01, release, 1, -2),
			  doneAction:2
			);
			
			sum = 0;
			10.do{
			  temp = VarSaw.ar(
			    freq * {Rand(0.98, 1, 1.02)}!2,
			    {Rand(0.0, 1.0)}!2,
			    {ExpRand(0.005, 0.05)}!2
			  );
			  sum = sum + temp;
			};
			sum = sum * sawAmp * env;
			Out.ar(0, sum);
			Out.ar(0, SinOsc.ar(freq) * sinAmp * env);
		}).add;

		context.server.sync;

		
		this.addCommand(\hz, "ffff", { arg msg;
		  var freq = msg[1];
		  var release = msg[2];
		  var sawAmp = msg[3];
		  var sinAmp = msg[4];
		  
		  Synth.new(\helicopter, [\inL, context.in_b[0].index, \inR, context.in_b[1].index, \out, context.out_b.index,
			\amp, 0.5, \freq, freq, \release, release, \sawAmp, sawAmp, \sinAmp, sinAmp], context.xg);
			
		});

	}

	free {
    synth.free;
	}
}