//SynthDefs, functions and soundfiles:
(
var sfs;

///////////
//REORDER
//change the channel order from L,R,C,LFE,LS,RS to L,R,RS,LS,C,LFE. must be at the tail
SynthDef(\reorder1, {|inBus=0, subLev=1|
	var in, chans, sub;
	var front, back;

	in = In.ar(inBus, 6);
	sub = Mix.ar([in])*subLev; //send all to sub

	chans = [ in[0], in[1], in[4], sub, in[3], in[2] ];
	front = [ in[0], in[1] ];
	back = [ in[3], in[2] ];

	//ReplaceOut.ar(0, chans);
	ReplaceOut.ar(0, [front, back]);
}).send(s);

/////////
//JP VERB
//an SC3 Plugin (in ~/Library/Application Support/SuperCollider/Extensions/SC3plugins/
// stereo. need 2
SynthDef(\jpverb, {|inBus=16, decay=5, damp=0.5, size=1.5, earlyDiff=0.6, modDepth=0.1, modFreq=2, low=1, mid=1, high=0.5, lowcut=250, highcut=3000|
	var front, back, in;

	in = In.ar(inBus, 4);
	front = [in[0], in[1]];
	back = [in[2], in[3]];

	Out.ar(0
		, JPverb.ar(front, decay, damp, size, earlyDiff, modDepth, modFreq, low, mid, high, lowcut, highcut)
	);
	Out.ar(2
		, JPverb.ar(back, decay, damp, size, earlyDiff, modDepth, modFreq, low, mid, high, lowcut, highcut)
	);
}).send(s);

///////////////////
//SIMPLE ADDITIVES:
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

////////////
//ADDITIVES:

/*//2 voices. fixed pan pos w FM for each channel
SynthDef(\additive1, { |out=100, masterLev=1, centerPitch=67, atk=0.1, rel=1, amp=1, gate=1, freqModRate=0.001, fmIndexStart=0, fmIndexEnd=0.025, fmIndexDur=30|
	var in, env;
	var fmIndex;

	fmIndex = Line.kr(fmIndexStart, fmIndexEnd, fmIndexDur);
	in = LFTri.ar(centerPitch.midicps
		*
		SinOsc.kr(
			LFNoise2.kr(
				Array.fill(4, freqModRate)
			)
			, 0
			, fmIndex
			, 1
		)
		, 0
		, 0.1
	);
	env = EnvGen.kr(Env.asr(atk, amp, rel, curve:[4, -4]), gate, doneAction:2);
	Out.ar(out, in*env*masterLev )
}).add;*/

//2 voices. fixed pan pos w FM for each channel
SynthDef(\additive1RM, { |out=100, masterLev=1, direct=1, directLag=0.1, centerPitch=67, pitchLag=0.1, atk=0.1, rel=1, amp=1, gate=1, freqModRate=0.001, fmIndexStart=0, fmIndexEnd=0.025, fmIndexDur=30, rmRate=10, rmRateLag=0.1, rmLag=0.05|
	var in, env;
	var fmIndex;
	var dry, wet;
	var noiseMod;

	fmIndex = Line.kr(fmIndexStart, fmIndexEnd, fmIndexDur);
	in = LFTri.ar(
		Lag2.kr(Control.names(\cp).kr(Array.fill(4, 63).midicps), pitchLag)
		*
		SinOsc.kr(
			LFNoise2.kr(
				Array.fill(4, freqModRate)
			)
			, 0
			, fmIndex
			, 1
		)
		, 0
		, 0.1
	);
	env = EnvGen.kr(
		Env.asr(atk, amp, rel, curve:[4, -4])
		, gate, doneAction:2
	);
	noiseMod =	Lag2.ar(
		LFNoise0.ar(
			Lag2.kr(
				Array.fill(4, rmRate)
				, rmRateLag
			)
			, 1
		)
		, rmLag
	);
	dry = in*Lag2.kr(direct, directLag);
	wet = (in*noiseMod)*(1-Lag2.kr(direct, directLag));
	Out.ar(out, Mix.ar([dry, wet])*env*masterLev);
}).add;

/*//monophonic. LFNoise2 for FM and uses a panner
SynthDef(\additive2, {|out=100, masterLev=1, centerPitch=67, atk=0.1, rel=1, amp=1, gate=1, panRateScale=1|
	var in, env;
	in = PanAz.ar(4,
		LFTri.ar(centerPitch.midicps
			*
			SinOsc.kr(
				LFNoise2.kr(1/10)
				, 0.5pi
				, 0.05
				, 1
			)
			, 0
			, 0.05
		)
		, SinOsc.ar(
			Rand(1/6, 1/3)*panRateScale
			, Rand(-8pi, 8pi) //use Rand, not rrand
			, 2
		)
	);
	env = EnvGen.kr(Env.asr(atk, amp, rel, curve:[4, -4]), gate, doneAction:2);
	Out.ar(out, in*env*masterLev);
}).add;*/

//monophonic. SinOsc for FM and uses a panner
SynthDef(\additive3, {|out=100, masterLev=1, centerPitch=68, atk=0.1, rel=1, amp=1, gate=1, modDepth=0.025, panRateScale=1|
	var in, env;
	in = PanAz.ar(4,
		LFTri.ar(centerPitch.midicps
			*
			SinOsc.kr(
				Rand(1/15,1/10)
				, Rand(-8pi, 8pi)
				, modDepth
				, 1
			)
			, 0
			, 0.05
		)
		, SinOsc.ar(
			Rand(1/6, 1/3)*panRateScale
			, Rand(0, 2pi)
			, 2
		)
	);
	env = EnvGen.kr(Env.asr(atk, amp, rel, curve:[4, -4]), gate, doneAction:2);
	Out.ar(out, in*env*masterLev);
}).add;

//monophonic. SinOsc for FM with a Line on the depth (index of modulation)
SynthDef(\additive4, {|out=100, masterLev=1, centerPitch=72, atk=0.1, rel=1, amp=1, gate=1, panRate=1, panStartPos=0, lineStart=10, lineEnd=1, lineDur=70|
	var in, env;
	in = PanAz.ar(4,
		LFTri.ar(centerPitch.midicps
			*
			SinOsc.kr(
				Rand(1/15,1/0)
				, Rand(-8pi, 8pi)
				, 0.025
				*
				Line.kr(lineStart, lineEnd, lineDur)
				, 1
			)
			, 0
			, 0.05
		)
		, SinOsc.ar(
			panRate
			, panStartPos
			, 2
		)
	);
	env = EnvGen.kr(Env.asr(atk, amp, rel, curve:[4, -4]), gate, doneAction:2);
	Out.ar(out, in*env*masterLev);
}).add;

SynthDef(\flutter, {|inBus=100, direct=1, directLag=0.1, gate=1, atk=0.1, rel=0.1, tremRate=20, tremRateLag=0.1, tremDepth=1, deviation=0.5, pulseShape=0.01, psLag=0.1, pulseWidth=0.5, pwLag=0.1|
	var in, trem;
	var wet, dry;
	var width, shape, phase, pulsePhase=0;
	var wetDry;

	phase = Control.names(\pphase).kr(Array.fill(4, pulsePhase));
	wetDry = Lag2.kr(direct, directLag);
	shape = Lag2.kr(pulseShape, psLag);
	width = Lag2.kr(pulseWidth, pwLag);
	trem = EnvGen.ar(Env.asr(atk, 1, rel), gate, tremDepth)
	*
	LFPulse.ar(
		Array.fill(4, {Lag2.kr(
			tremRate+Rand(deviation*(-1), deviation)
			, tremRateLag)
		})
		, phase
		, width
	);
	in = In.ar(inBus, 4);
	dry = in*wetDry;
	wet = in*Lag2.ar(trem, shape)*(1-wetDry);
	Out.ar(0, Mix.ar([dry, wet]));
}).send(s);

///////////
//SAMPLER
SynthDef(\sampler, {|outBus=0, bufnum=0, lev=1, lpc=20000, atk=0.01, sus=1, rel=0.01, curve=4, gate=1|
	var in, filt, out, quad;
	in = PlayBuf.ar(6, bufnum, 1, startPos:0, loop:0, doneAction:2);
	quad = [in[0], in[1], in[5], in[4]]; //convert from cubase 5.1 layout to SC quad (L,R,Rs,Ls)
	filt = LPF.ar(quad, [lpc+0.1, lpc+0.1, 20000, 20000], lev); //only filters the front channels
	out = filt
	*
	EnvGen.kr(Env.asr(atk, sus, rel, curve), gate, doneAction:2);
	Out.ar(0, out)
}).send(s);

~samplerFiles =
[
	"/Projects/SC GITHUB/tis SOUNDFILES/TIS 061317 3 Rnd Hi Freq Sparse F GV 1 ed.wav",
	"/Projects/SC GITHUB/tis SOUNDFILES/TIS 061317 1 Rnd FM 1-R,L GV 1 ed.wav",
	"/Projects/SC GITHUB/tis SOUNDFILES/061417 1 Mod Waves-R GV 1 F h.d. ed.wav",
];

~sergeMass = "/Projects/SC GITHUB/tis SOUNDFILES/descending_masses_serge quad.wav";

~samplerDurs = Array.newClear(~samplerFiles.size+1);
~samplerBufs = Array.fill(~samplerFiles.size, {|i| var buf; buf = Buffer.read(
	s
	, ~samplerFiles[i]
	//on loading completion (add all other buffers):
	, action: {
		~samplerDurs.put(i, buf.duration);
		~samplerDurs[i].postln;
		//only does this once:
		if (i==0){
			"initializing".postln;
			MIDIClient.init; //initialize
			MIDIIn.connectAll; //connects to all available devices
			//REMEMBER TO UNCOMMENT THIS!!!!!!!!!!!!!!!!!
/*			{~reorderWindow.value}.defer;
			~reorder = Synth.tail(s, \reorder1);
			~verb = Synth.before(~reorder, \jpverb);*/
		}{nil};
	}
)
})++[ Buffer.read(s, ~sergeMass, action: {|buf|
	~samplerDurs.put(~samplerDurs.size-1, buf.duration);
	~samplerDurs.last.postln;
})
];

/////////////
//VOICEMASS
~vmFiles = [
	"/Projects/TIS/Eliza/TiS Eliza Extended Vox 04-29-17/EDITED/12 E_inhale exhale vow high pch_CLN.aif"
	, "/Projects/TIS/Eliza/TiS Eliza Extended Vox 04-29-17/EDITED/117 E_singing text montone more air.aif"
	/*	 , "/Projects/TIS/Eliza/TiS Eliza Extended Vox 04-29-17/EDITED/118 E_singing text monotone lower pch.aif"
	, "/Projects/TIS/Eliza/TiS Eliza Extended Vox 04-29-17/EDITED/119 E_singing text monotone vary pchs more air.aif"
	, "/Projects/TIS/Eliza/TiS Eliza Extended Vox 04-29-17/EDITED/120 E_singing text monotone w vib.aif"*/
];

~voiceMassBuffer = Array.fill(~vmFiles.size, {|i| Buffer.read(s, ~vmFiles[i])}); //a buffer for each soundfile. solves the occasional reciprocal error by preloading buffers
sfs  = Array.fill(~vmFiles.size, {SoundFile.new});
/*sfs.postln;*/
~vmFiles.size.do{|i| sfs[i].openRead(~vmFiles[i]) };//must openRead the files
~voiceMassMarkers = Array.fill(~vmFiles.size, {|i| sfs[i].extractMarkersAiff2(0)}); //0=samples (default), 1=seconds)

//SynthDefs
SynthDef(\pb_voiceMass, {|out=0, bufnum=0, rate=1, startPos=0, panPos=0, gestureLev=1, masterLev =0.5, atk=0.01, dur=1, rel=0.01, curve= -4, send=16, dryLev=1, sendLev=1, gate=1, loop=0, mlLag=0.01|
	var in, env;
	env = Env.asr(atk, 1, rel, curve);
	in = HPF.ar(PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, startPos:startPos, loop:loop, doneAction:2), 20);
	env = EnvGen.kr(env, gate:gate, levelScale:gestureLev, doneAction:2);
	//dry:
	Out.ar(out,
		PanAz.ar(4, in, panPos, dryLev*Lag2UD.kr(masterLev, mlLag))
		*
		env;
	);
	//wet:
	Out.ar(send,
		PanAz.ar(4, in, panPos, sendLev*Lag2UD.kr(masterLev, mlLag))
		*
		env
	);
}).send(s);

//////////////////
//GLISSING VOICES
//serge
~gvFiles = [
	"/Projects/TIS/TIS Serge/Audio/061317 3 Rnd Hi Freq and Sparse Filt 1-R.aif",
	/*	"/Projects/TIS/TIS Serge/Audio/061317 3 Rnd Hi Freq and Sparse Filt 1-L.aif",*/
	"/Projects/TIS/TIS Serge/Audio/Serge 041417_01 copy.wav",
	"/Projects/TIS/TIS Serge/Audio/Serge 050615_mono.wav",
	"/Projects/TIS/TIS Serge/Audio/Serge 032315_mono.wav",
	/*	"/Projects/TIS/TIS Serge/Audio/061317 1 Rnd FM 1-L.aif",
	"/Projects/TIS/TIS Serge/Audio/061317 1 Rnd FM 1-R.aif",*/
	"/Projects/TIS/TIS Serge/Audio/061417 1 Mod Waves-L.aif",
	"/Projects/TIS/TIS Serge/Audio/061417 1 Mod Waves-R.aif"
	//	"/Volumes/Projects/The Impermanent Sky/Audio/test.wav" //short file for testing
];

~bufArr = Array.fill(~gvFiles.size, {|i| Buffer.read(s, ~gvFiles[i])}); //a buffer for each soundfile. solves the occasional reciprocal error by preloading buffers

SynthDef(\pb_quad_wSends, {|out=50, bufnum=0, rate=1, startPos=0, panPos=0, masterLev=1, lpCut=20000, level=0.5, atk=0.01, dur=1, rel=0.01, send=54, sendLev=1, gate=1, loop=0|
	var in, env;
	env = Env.asr(atk, 1, rel, [4,-4]);
	in = HPF.ar(PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, startPos:startPos, loop:loop, doneAction:2), 30);
	env = EnvGen.kr(env, gate:gate, doneAction:2);
	//dry:
	Out.ar(out,
		PanAz.ar(4, in, panPos, level*masterLev)
		*
		env;
	);
	//wet:
	Out.ar(send,
		PanAz.ar(4, in, panPos, level*sendLev*masterLev)
		*
		env
	);
}).send(s);

SynthDef(\filter, {|in=50, out=0, sendIn=54, send=16, lpCut=20000|
	var input, sendInput;
	input = LPF.ar(In.ar(in, 4), Lag.kr(lpCut, 0.4));
	sendInput = LPF.ar(In.ar(sendIn, 4), Lag.kr(lpCut, 0.4));
	Out.ar(out, input);
	Out.ar(send, sendInput);
}).send(s);

//////
//EGG
SynthDef(\eggAdditive, { |outBus=110, masterLev=1, mlLag=1, centerPitch=67, cpLag=0.1, atk=0.1, release=30, amp=1, gate=1, freqModRate=0.00001, fmModRateLag=30, fmIndex=0, fmNoiseIndex=0, fmIndexLag=30, fmNoiseIndexLag=30, amRate=0.0333333, amDepth=0, amLag=0.1, panPos=0.25, ppOffset=0, ppoLag=0.1, lpC=8000, lpRise=0.1, lpFall=0.1, timeScale=1, lpEGate=0, modDepth=0, mdLag=0.1, intAMdepth=0, iamdLag=0.1, intAMrate=0.2, intAMphase=0|

	var in, env, triLev=0.1;
	var fmIndexMod;
	var ampMod;
	var outSig, phase, panner, posOffset;
	var tri, saw, fm, cfMod;
	var mod, filtEnv, modMult, modAdd;
	var internalAM, outwAM, out, iAM,intAMmul, intAMadd;

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

	iAM = Lag.kr(intAMdepth, iamdLag);
	intAMmul = iAM*0.5;
	intAMadd = 1-intAMmul;
	internalAM = SinOsc.kr(intAMrate, intAMphase, intAMmul, intAMadd); //wetdry method?
	filtEnv = EnvGen.kr(Env.asr(lpRise, lpC, lpFall, [6, -6]), lpEGate, timeScale:timeScale);

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
		, 20+filtEnv
	);
	in = tri+saw;
	env = EnvGen.kr(Env.asr(atk, amp, release, curve:[4, -4]), gate, doneAction:2);
	outSig = (in-triLev)*env;
	panner = PanAz.ar(4, outSig, (panPos+posOffset), level:1, width:2);
	/*	out = panner*(1-iAM); //no internal AM (intAM = 0)
	outwAM = panner*internalAM*iAM; //internal AM (intAM = 1)*/
	out = panner*internalAM;

	Out.ar(outBus, out*Lag2.kr(masterLev, mlLag))
}).send(s);

//AMP MOD
/*
PanAz discrete outs (with width of 2!!):
-0.25 = L (0)
0.25 = R (1)
0.75 = RS (2)
1.25 = LS (3)
*/

//egg AM
SynthDef(\eggAM, {|inBus=110, posOffset=0, ppoLag=0.1, wetDry=1, wdLag|
	var in, lt, rt, rs, ls;
	var am, out, pos;
	var dryRs, wetRs, dryLs, wetLs, direct;

	direct = Lag.kr(wetDry, wdLag);

	in = In.ar(inBus, 4);
	pos = Lag2.kr(posOffset, ppoLag);
	am = Lag.kr( LFNoise0.kr(Array.fill(2, {Rand(15, 25)}) ), 0.1);

	dryRs = in[2]*direct;
	wetRs = in[2]*am[0]*(1-direct);
	dryLs = in[3]*direct;
	wetLs = in[3]*am[1]*(1-direct);

	lt = PanAz.ar(4, in[0], -0.25+pos);
	rt = PanAz.ar(4, in[1], 0.25+pos);
	/*	rs = PanAz.ar(4, in[2], 0.75+pos);
	ls = PanAz.ar(4, in[3], -0.75+pos);*/
	rs = PanAz.ar(4, Mix.ar([dryRs, wetRs]), 0.75+pos);
	ls = PanAz.ar(4, Mix.ar([dryLs, wetLs]), -0.75+pos);

	out = lt+rt+rs+ls;
	Out.ar(0, out)
}).send(s);

////////////////////////////
//filter and rotation functions:
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

			s.sendBundle(s.latency, [\n_set, ~eggAddSynths[i], \lpC, 8000, \lpEGate, 1, \lpRise, lag]);
		};

		wait.wait;

		//open filter on LD Saws
		~eggLDNodes.size.do{|i|
			var lag;
			lag = rrand(60*4, 60*8)*~eggTimeScale;

			s.sendBundle(s.latency, [\n_set, ~eggLDNodes[i], \lpC, 8000, \lpEGate, 1, \lpRise, lag]);
		};

		bassWait.wait;

		//open filter on Bass Saws
		~eggBassNodes.size.do{|i|
			var lag;
			lag = rrand(60*2.5, 60*4)*~eggTimeScale;

			s.sendBundle(s.latency, [\n_set, ~eggBassNodes[i], \lpC, 8000, \lpEGate, 1, \lpRise, lag]);
		};
		"done".postln;
	}
};

//close the filter (mirror open) and fade all except the last group of oscillators
~eggClose = {
	var wait, bassWait;

	fork{
		"closing...".postln;
		//close filter on basses
		~eggBassNodes.size.do{|i|
			var lag;
			lag = rrand(60*2.5, 60*4)*~eggTimeScale;

			s.sendBundle(s.latency, [\n_set, ~eggBassNodes[i], \lpEGate, 0, \lpFall, lag]);
		};

		(60*~eggTimeScale).wait;

		//fade out basses amp
		~eggBassNodes.size.do{|i|
			var rel;
			rel = rrand(60*2, 60*3)*~eggTimeScale;

			s.sendBundle(s.latency, [\n_set, ~eggBassNodes[i], \gate, 0, \release, rel]);
		};

		(30*~eggTimeScale).wait;

		//close filter on HD Saws
		~eggNumVoices.do{|i|
			var lag;
			lag = (rrand(60*2.5, 60*6.5)*~eggTimeScale);

			s.sendBundle(s.latency, [\n_set, ~eggAddSynths[i], \lpEGate, 0, \lpFall, lag]);
		};

		(30*~eggTimeScale).wait;

		//fade out HDs
		~eggNumVoices.do{|i|
			var rel;
			rel = rrand(60*3, 60*6)*~eggTimeScale;

			s.sendBundle(s.latency, [\n_set, ~eggAddSynths[i], \gate, 0, \release, rel]);
		};

		(30*~eggTimeScale).wait;

		//close filter on LD Saws
		~eggLDNodes.size.do{|i|
			var lag;
			lag = rrand(60*4, 60*7)*~eggTimeScale;

			s.sendBundle(s.latency, [\n_set, ~eggLDNodes[i], \lpEGate, 0, \lpFall, lag]);
		};

		(300*~eggTimeScale).wait;

		//fade out LDs
		/*		~eggLDNodes.size.do{|i|
		var rel;
		rel = rrand(60, 60*2)*~eggTimeScale;

		s.sendMsg(\n_set, ~eggLDNodes[i], \gate, 0, \release, rel);
		};*/
		//"done".postln;
	}
};

//rotation:
~eggRotation = {|panO=1/*also serves as rotations/rotationDur*/, rotationDur=60|

	~ppo=~ppo+panO; //to increment

	~eggLDNodes.size.do{|i|
		s.sendBundle(s.latency, [\n_set, ~eggLDNodes[i], \ppOffset, ~ppo, \ppoLag, rotationDur]);
	};
	~eggNumVoices.do{|i|
		s.sendBundle(s.latency, [\n_set, ~eggAddSynths[i], \ppOffset, ~ppo, \ppoLag, rotationDur]);
	};

	s.sendBundle(s.latency, [\n_set, ~eggAM, \posOffset, ~ppo, \ppoLag, rotationDur]);

	fork{
		"rotating 180 degrees...".postln;
		rotationDur.wait;
		"rotation complete".postln;
	};
};

//nodes: ~eggLDNodes, ~eggAddSynths, ~eggBassNodes
~intAMfade = {|amDepth=1, amFadeIn=240|

	~eggLDNodes.size.do{|i|
		var rates, phases;
		rates = Array.fill(2, {0.2*rrand(0.9, 1.1)});
		phases = Array.fill(2, {rrand(0.0, pi)});

		if (i.even==true){
			s.sendBundle(s.latency, [\n_set, ~eggLDNodes[i], \intAMdepth, amDepth, \iamdLag, amFadeIn, \intAMrate, rates[0], \iAMphase, phases[0]] );
		}
		{
			s.sendBundle(s.latency, [\n_set, ~eggLDNodes[i], \intAMdepth, amDepth, \iamdLag, amFadeIn, \intAMrate, rates[1], \iAMphase, phases[1]] );
		};
	};

	~eggAddSynths.size.do{|i|
		var rates, phases, streams=3;
		rates = Array.fill(streams, {0.2*rrand(0.9, 1.1)});
		phases = Array.fill(streams, {rrand(0.0, pi)});

		switch (i%streams
			, 0, { s.sendBundle(s.latency, [\n_set, ~eggAddSynths[i], \intAMdepth, amDepth, \iamdLag, amFadeIn, \intAMrate, rates[0], \iAMphase, phases[0]] )}
			, 1, { s.sendBundle(s.latency, [\n_set, ~eggAddSynths[i], \intAMdepth, amDepth, \iamdLag, amFadeIn, \intAMrate, rates[1], \iAMphase, phases[1]] )}
			, 2,  { s.sendBundle(s.latency, [\n_set, ~eggAddSynths[i], \intAMdepth, amDepth, \iamdLag, amFadeIn, \intAMrate, rates[2], \iAMphase, phases[2]] )}
		);
	};
};

//reorder gui
~reorderWindow = {
	var window, text, flow;
	window = Window("Sampler", Rect(0, 500, 320, 150));
	window.view.decorator = flow = FlowLayout(window.view.bounds, 20@20, 40@5);
	text = StaticText(window, 300@100);
	text.string = "CHANNELS REORDERED. MIDI INITIALIZED.";
	window.front;

	CmdPeriod.add({window.close})
};
)
