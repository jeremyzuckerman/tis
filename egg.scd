/*
- add amp env mod to exaggerate the rotation
gradually add detail
- individual amplitude mod
- individual FM
- growing density / pch devitation
- flutters in spatial areas (not always all 4 speakers)
- gradually double with more complex waveform (can open up filter on these waveforms)
*/

(
SynthDef(\eggAdditive, { |outBus=0, masterLev=1, mlLag=1, centerPitch=67, cpLag=0.1, atk=0.1, release=30, amp=1, gate=1, freqModRate=0.00001, fmModRateLag=30, fmIndex=0, fmNoiseIndex=0, fmIndexLag=30, fmNoiseIndexLag=30, amRate=0.0333333, amDepth=0, amLag=0.1, panPos=0.25, ppOffset=0, ppoLag=0.1|
	var in, env, triLev=0.1;
	var fmIndexMod;
	var ampMod;
	var outSig, phase, panner, posOffset;

	posOffset = Lag2.kr(ppOffset, ppoLag);

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
	panner = PanAz.ar(4, outSig, (panPos+posOffset), level:1, width:2);
	Out.ar(outBus, panner*Lag2.kr(masterLev, mlLag))
}).send(s);
)
//first low density, then long slow fade in high density

(
var outs, fadesIn;
var timeScale = 0.1, lPos, rPos, rsPos, lsPos, posArray;

~eggNumVoices = 32;
~ppo=0; //pan position offset

lPos = Array.fill(~eggNumVoices/4, {rrand(-0.5, 0)});
rPos = Array.fill(~eggNumVoices/4, {rrand(0, 0.5)});
rsPos = Array.fill(~eggNumVoices/4, {rrand(0.5, 1)});
lsPos = Array.fill(~eggNumVoices/4, {rrand(-0.5, 1)});

posArray = lPos++rPos++rsPos++lsPos;
//posArray.postcs;

//fadesIn = #[30, 45, 60, 75]*timeScale;
//outs = #[-0.25, 0.75, -0.75, 0.25]; //L, RS, LS, R
//outs = #[-0.25, 0.25, 0.75, -0.75]; //L, R, RS, LS

~eggAddSynths = Array.fill(~eggNumVoices, {s.nextNodeID}); //make node for each synth

s.sendMsg(\g_new, ~eggAdditivesGrp=s.nextNodeID, 0, 0);

~eggNumVoices.do{|i|
	var cp, atk;

	cp = ([66, 67, 68, 70, 71, 72, 74, 81, 81]+0.4).wchoose([5, 10, 5, 5, 1, 2, 10, 10, 10].normalizeSum);
	atk = rrand(60, 60*6)*timeScale;

/*	s.sendMsg(\s_new, \eggAdditive, ~eggAddSynths[i], 0, ~eggAdditivesGrp, \centerPitch, cp*rrand(0.99, 1.01), \masterLev, 0.2, \panPos, outs.wrapAt(i), \atk, atk);*/
	s.sendMsg(\s_new, \eggAdditive, ~eggAddSynths[i], 0, ~eggAdditivesGrp, \centerPitch, cp*rrand(0.99, 1.01), \masterLev, 0.2, \panPos, posArray[i], \atk, atk);
}
)

/*(
var outs, fadesIn;

fadesIn = #[30, 45, 60, 75]*timeScale;
outs = #[0, 2, 3, 1]; //L, RS, LS, R

~sAddSynthsLow = Array.fill(~eggNumVoices, {s.nextNodeID}); //make node for each synth

/*s.sendMsg(\g_new, ~sAdditivesGrp=s.nextNodeID, 0, 0);*/

~eggNumVoices.do{|i|
	var cp, atk;
	cp = ([ 54, 55, 56, 58, 59, 60, 62, 69, 69 ])+0.4.wchoose([5, 10, 5, 5, 1, 2, 10, 10, 10].normalizeSum);
	atk = rrand(60, 60*6);
/*	s.sendMsg(\s_new, \simpleAdditive, ~sAddSynths[i], 0, ~sAdditivesGrp, \centerPitch, cp*rrand(0.99, 1.01), \masterLev, 0.2, \outBus, outs.wrapAt(i), \atk, fadesIn.wrapAt(i));*/
	s.sendMsg(\s_new, \eggAdditive, ~eggAddSynths[i], 0, ~eggAdditivesGrp, \centerPitch, cp*rrand(0.99, 1.01), \masterLev, 0.2, \panPos, outs.wrapAt(i), \atk, atk);
}
)*/

//2:
//MOD
~eggNumVoices.do{|i|
	s.sendMsg(\n_set, ~eggAddSynths[i], \fmIndex, 0.025, \fmIndexLag, rrand(60, 60*4), \fmNoiseIndex, 0.025, \fmNoiseIndexLag, rrand(60, 60*4))
}

//SLOW ROTATION (how to make channels more distinct from each other?)
(
var panO, rotationDur=20;
panO= 1; //also serves as rate. rotations per rotationDur
~ppo=~ppo+panO; //to increment

~eggNumVoices.do{|i|
	s.sendMsg(\n_set, ~eggAddSynths[i], \ppOffset, ~ppo, \ppoLag, rotationDur)
};

fork{
	"rotating 180 degrees...".postln;
	rotationDur.wait;
	"rotation complete".postln;
};
)

(
~eggNumVoices.do{|i|
	s.sendMsg(\n_set, ~eggAddSynths[i], \masterLev, 0.4)
}
)

/*
PanAz discrete outs (with width of 2!!):
-0.25 = L (0)
0.25 = R (1)
0.75 = RS (2)
1.25 = LS (3)
*/