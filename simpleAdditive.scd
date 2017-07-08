(
SynthDef(\simpleAdditive, { |outBus=0, masterLev=1, mlLag=1, centerPitch=67, cpLag=0.1, atk=0.1, release=30, amp=1, gate=1, freqModRate=0.00001, fmModRateLag=30, fmIndex=0, fmNoiseIndex=0, fmIndexLag=30, fmNoiseIndexLag=30, amRate=0.0333333, amDepth=0, amLag=0.1|
	var in, env, triLev=0.1;
	var fmIndexMod;
	var ampMod;
	var outSig, phase;

	phase = Rand(0, 2pi);

	ampMod = SinOsc.ar(
		amRate*rrand(0.99, 1.01)
		, phase
		, triLev*0.5
		, triLev
	)
	*
	Lag.kr(amDepth, amLag);
	fmIndexMod = Lag.kr(fmIndex, fmIndexLag);
	in = LFTri.ar(
		Lag.kr(centerPitch.midicps, cpLag)
		*
		SinOsc.kr(
			LFNoise2.kr(
				Lag.kr(freqModRate, fmModRateLag)
				, Lag.kr(fmNoiseIndex, fmNoiseIndexLag)
			)
			, 0
			, fmIndexMod
			, 1
		)
		, 0
		, triLev+ampMod
	);
	env = EnvGen.kr(Env.asr(atk, amp, release, curve:[4, -4]), gate, doneAction:2);
	outSig = (in-triLev)*env;
	Out.ar(outBus, outSig*Lag2.kr(masterLev, mlLag))
}).send(s);
)

//COUNTER:
(
fork{
	var occurence=15;
	inf.do{|i|
		"counter: ".post; (occurence*i).asTimeString2.postln;
		occurence.wait;
	}
};
)

//1:
(
var outs, fadesIn;
var timeScale = 2;

fadesIn = #[30, 45, 60, 75]*timeScale;
outs = #[0, 2, 3, 1]; //L, RS, LS, R

~sAddSynths = Array.fill(4, {s.nextNodeID}); //make node for each synth

s.sendMsg(\g_new, ~sAdditivesGrp=s.nextNodeID, 0, 0);

4.do{|i|
	/*var atk;
	atk = rrand(30,60);
	*/
	s.sendMsg(\s_new, \simpleAdditive, ~sAddSynths[i], 0, ~sAdditivesGrp, \centerPitch, 63, \masterLev, 0.2, \atk,  fadesIn[i], \outBus, outs[i], \atk, fadesIn[i]);
}
)

//5:
s.sendMsg(\n_set, ~sAdditivesGrp, \mlLag, 60, \masterLev, 1) //change master level

s.sendMsg(\n_set, ~sAdditivesGrp, \gate, 0, \release, 1) //fade out and free

//suddenly quiet
s.sendMsg(\n_set, ~sAdditivesGrp, \mlLag, 0.1, \masterLev, 0.1) //change master level

//6?:
//AM (not sure if it's effective. rate too slow?)
s.sendMsg(\n_set, ~sAddSynths[0], \amLag, 20, \amRate, 0.05, \amDepth, 0.8);//'
s.sendMsg(\n_set, ~sAddSynths[1], \amLag, 20, \amRate, 0.05, \amDepth, 0.8);//'
s.sendMsg(\n_set, ~sAddSynths[2], \amLag, 20, \amRate, 0.05, \amDepth, 0.8);//'
s.sendMsg(\n_set, ~sAddSynths[3], \amLag, 20, \amRate, 0.05, \amDepth, 0.8);//'

//2:
//FM
s.sendMsg(\n_set, ~sAddSynths[0], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20);//'
s.sendMsg(\n_set, ~sAddSynths[1], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20);//'
s.sendMsg(\n_set, ~sAddSynths[2], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20);//'
s.sendMsg(\n_set, ~sAddSynths[3], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20);//'

/*s.sendMsg(\n_set, ~sAdditivesGrp, \freqModRate, 500, \fmNoiseIndex, 50);
s.sendMsg(\n_set, ~sAdditivesGrp, \fmIndex, 100);
s.sendMsg(\n_set, ~sAdditivesGrp, \fmModRateLag, 0.01);*/


4.do{|i|
	s.sendBundle(s.latency, [\n_set, ~sAddSynth[i], \centerPitch, pch])
}
