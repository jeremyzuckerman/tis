/*
- add bass √
- add filter modulation on individual voices
- trigger the opening of the filter?
- add amp env mod to exaggerate the rotation
gradually add detail
- individual amplitude mod
- individual FM
- growing density / pch devitation
- flutters in spatial areas (not always all 4 speakers)
- gradually double with more complex waveform (can open up filter on these waveforms)
- add reverb
*/

(
SynthDef(\eggAdditive, { |outBus=0, masterLev=1, mlLag=1, centerPitch=67, cpLag=0.1, atk=0.1, release=30, amp=1, gate=1, freqModRate=0.00001, fmModRateLag=30, fmIndex=0, fmNoiseIndex=0, fmIndexLag=30, fmNoiseIndexLag=30, amRate=0.0333333, amDepth=0, amLag=0.1, panPos=0.25, ppOffset=0, ppoLag=0.1, lpC=8000, lpRise=0.1, lpFall=0.1, timeScale=1, lpEGate=0|
	var in, env, triLev=0.1;
	var fmIndexMod;
	var ampMod;
	var outSig, phase, panner, posOffset;
	var tri, saw, fm, cfMod;

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

	fm = Lag.kr(centerPitch.midicps, cpLag)
	*
	SinOsc.kr(
		LFNoise2.kr(
			Lag.kr(freqModRate, fmModRateLag)
			, Lag.kr(fmNoiseIndex, fmNoiseIndexLag)
		)
		, 0
		, fmIndexMod
		, 1
	);
	////////////////////////////
	cfMod = LFTri.kr(LFNoise0.kr(
	tri = LFTri.ar(
		fm
		, 0
		, triLev+ampMod
	);

	saw = RLPF.ar(
		LFSaw.ar(
			fm
			, 0
			, triLev+ampMod
		)
		, 20+EnvGen.kr(Env.asr(lpRise, lpC, lpFall, [4, -4]), lpEGate, timeScale:timeScale)
	);
	in = tri+saw;
	env = EnvGen.kr(Env.asr(atk, amp, release, curve:[4, -4]), gate, doneAction:2);
	outSig = (in-triLev)*env;
	panner = PanAz.ar(4, outSig, (panPos+posOffset), level:1, width:2);
	Out.ar(outBus, panner*Lag2.kr(masterLev, mlLag))
}).send(s);
)

//first low density, then long slow fade in high density, then bass. overlapped entrances
(
var outs, fadesIn;
var lPos, rPos, rsPos, lsPos, posArray;
var ldPos, wait = 90, bassWait=240;
var bassLPos, bassRPos, bassRSPos, bassLSPos, bassPosArray, numBass=16;

~eggNumVoices = 60;
~ppo=0; //pan position offset
~eggTimeScale=0.1;

ldPos = #[0, 1, 2, 3];

lPos = Array.fill(~eggNumVoices/4, {rrand(-0.5, 0)});
rPos = Array.fill(~eggNumVoices/4, {rrand(0, 0.5)});
rsPos = Array.fill(~eggNumVoices/4, {rrand(0.5, 1)});
lsPos = Array.fill(~eggNumVoices/4, {rrand(-0.5, 1)});

posArray = lPos++rPos++rsPos++lsPos;
//posArray.postcs;

//fadesIn = #[30, 45, 60, 75]*~eggTimeScale;
//outs = #[-0.25, 0.75, -0.75, 0.25]; //L, RS, LS, R
//outs = #[-0.25, 0.25, 0.75, -0.75]; //L, R, RS, LS

~eggLDNodes = Array.fill(8, {s.nextNodeID}); //first spatially discrete, low density voices
~eggAddSynths = Array.fill(~eggNumVoices, {s.nextNodeID}); //spatially disbursed, high density voices

s.sendMsg(\g_new, ~eggAdditivesGrp=s.nextNodeID, 0, 0);

fork{
	//LOW DENSITY
	"low density".postln;
	~eggLDNodes.size.do{|i|
		var pchs, atk;
		var lag;
		lag = rrand(60*4, 60*7)*~eggTimeScale;

		pchs = ([73, 71, 69, 67, 66, 64, 59]-0.3).wchoose([1, 3, 1, 1, 1, 1, 3].normalizeSum);
		atk = rrand(60, 60*2)*~eggTimeScale;

		s.sendMsg(\s_new, \eggAdditive, ~eggLDNodes[i], 0, ~eggAdditivesGrp, \centerPitch, pchs+rrand(-0.2, 0.2), \masterLev, 0.2, \panPos, ldPos.wrapAt(i), \atk, atk);
		//, \lpC, 12000, \lpRise, lag, \lpEGate, 1 //opens filter
	};

	(wait*~eggTimeScale).wait; //WAIT

	//HIGH DENSITY
	"high density".postln;
	~eggNumVoices.do{|i|
		var cp, atk, pchs;
		var lag;
		lag = (rrand(60*4, 60*8)*~eggTimeScale)-wait;

		//pchs = ([66, 67, 68, 70, 71, 72, 74, 81, 81]+0.4).wchoose([5, 10, 5, 5, 1, 2, 10, 10, 10].normalizeSum);
		pchs = ([73, 71, 69, 67, 66, 64, 59]-0.3).wchoose([1, 3, 1, 1, 1, 1, 3].normalizeSum);
		atk = rrand(60*3, 60*6)*~eggTimeScale;

		s.sendMsg(\s_new, \eggAdditive, ~eggAddSynths[i], 0, ~eggAdditivesGrp, \centerPitch, pchs+rrand(-0.2, 0.2), \masterLev, 0.2, \panPos, posArray[i], \atk, atk);
		//, \lpC, 12000, \lpRise, lag, \lpEGate, 1 //opens filter
	};

	(bassWait*~eggTimeScale).wait;

	//BASS
	~eggBassNodes = Array.fill(numBass, {s.nextNodeID}); //bass nodes

	bassLPos = Array.fill(numBass/4, {rrand(-0.5, 0)});
	bassRPos = Array.fill(numBass/4, {rrand(0, 0.5)});
	bassRSPos = Array.fill(numBass/4, {rrand(0.5, 1)});
	bassLSPos = Array.fill(numBass/4, {rrand(-0.5, 1)});

	bassPosArray = bassLPos++bassRPos++bassRSPos++bassLSPos;

	"bass".postln;
	numBass.do{|i|
		var pch, atk;

		pch = (59-24)+rrand(-0.2, 0.2);
		atk = rrand(60*2, 60*3)*~eggTimeScale;

		s.sendMsg(\s_new, \eggAdditive, ~eggBassNodes[i], 0, ~eggAdditivesGrp, \centerPitch, pch, \masterLev, 0.2, \panPos, bassPosArray[i], \atk, atk);
	}
}
)

(
//filter functions. sequenced. make manual control over LD, HD and bass?
//open the filter
~eggOpen = {
	var wait, bassWait;

	wait = 90*~eggTimeScale;
	bassWait = 240*~eggTimeScale;

	fork{
		//open filter on HD Saws
		~eggNumVoices.do{|i|
			var lag;
			lag = (rrand(60*4, 60*8)*~eggTimeScale)-wait;

			s.sendMsg(\n_set, ~eggAddSynths[i], \lpC, 8000, \lpEGate, 1, \lpRise, lag);
		};

		wait.wait;

		//open filter on LD Saws
		~eggLDNodes.size.do{|i|
			var lag;
			lag = rrand(60*4, 60*8)*~eggTimeScale;

			s.sendMsg(\n_set, ~eggLDNodes[i], \lpC, 8000, \lpEGate, 1, \lpRise, lag);
		};

		bassWait.wait;

		//open filter on Bass Saws
		~eggBassNodes.size.do{|i|
			var lag;
			lag = rrand(60*2.5, 60*4)*~eggTimeScale;

			s.sendMsg(\n_set, ~eggBassNodes[i], \lpC, 8000, \lpEGate, 1, \lpRise, lag);
		};
	}
};

//close the filter (mirror open)
~eggClose = {
	var wait, bassWait;

	fork{
		//close filter on basses
		~eggBassNodes.size.do{|i|
			var lag;
			lag = rrand(60*2.5, 60*4)*~eggTimeScale;

			s.sendMsg(\n_set, ~eggBassNodes[i], \lpEGate, 0, \lpFall, lag);
		};

		(60*~eggTimeScale).wait;

		//fade out basses amp
		~eggBassNodes.size.do{|i|
			var rel;
			rel = rrand(60*2, 60*3)*~eggTimeScale;

			s.sendMsg(\n_set, ~eggBassNodes[i], \gate, 0, \release, rel);
		};

		(30*~eggTimeScale).wait;

		//close filter on HD Saws
		~eggNumVoices.do{|i|
			var lag;
			lag = (rrand(60*2.5, 60*6.5)*~eggTimeScale);

			s.sendMsg(\n_set, ~eggAddSynths[i], \lpEGate, 0, \lpFall, lag);
		};

		(30*~eggTimeScale).wait;

		//fade out HDs
		~eggNumVoices.do{|i|
			var rel;
			rel = rrand(60*3, 60*6)*~eggTimeScale;

			s.sendMsg(\n_set, ~eggAddSynths[i], \gate, 0, \release, rel);
		};

		(30*~eggTimeScale).wait;

		//close filter on LD Saws
		~eggLDNodes.size.do{|i|
			var lag;
			lag = rrand(60*4, 60*7)*~eggTimeScale;

			s.sendMsg(\n_set, ~eggLDNodes[i], \lpEGate, 0, \lpFall, lag);
		};

		(300*~eggTimeScale).wait;

		//fade out LDs
		~eggLDNodes.size.do{|i|
			var rel;
			rel = rrand(60, 60*2)*~eggTimeScale;

			s.sendMsg(\n_set, ~eggLDNodes[i], \gate, 0, \release, rel);
		};
	}
}
)

~eggOpen.value; //execute
~eggClose.value; //execute

/*(
var outs, fadesIn;

fadesIn = #[30, 45, 60, 75]*~eggTimeScale;
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

s.sendMsg(\n_set, ~eggAdditivesGrp, \gate, 0, \rel, 30)

//SLOW ROTATION (how to make channels more distinct from each other?)
(
var panO, rotationDur=30;
panO= 1; //also serves as rate. rotations per rotationDur
~ppo=~ppo+panO; //to increment

~eggLDNodes.size.do{|i|
	s.sendMsg(\n_set, ~eggLDNodes[i], \ppOffset, ~ppo, \ppoLag, rotationDur);
};

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
	s.sendMsg(\n_set, ~eggAddSynths[i], \masterLev, 0, \mlLag, 120)
}
)

/*
PanAz discrete outs (with width of 2!!):
-0.25 = L (0)
0.25 = R (1)
0.75 = RS (2)
1.25 = LS (3)
*/