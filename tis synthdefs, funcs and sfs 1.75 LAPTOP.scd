//SynthDefs, functions and soundfiles:
//ADD SUB TO EVERYTHING!!!!!!
(
var sfs;
var numFiles=0;
var polyphony=3, timeScale = 2;
var wavesSFs;
var wavesMarker, wavesNextMarker, wavesLastMarker;
var waveFileDurSamps;

///////////////////////////////////
//GLOBALS:
///////////////////////////////////

//////////////////
//SIMPLE ADDITIVE
~saXpose = 0;
~saFadeTimeScale=1;

~saVoices = Array.fill(polyphony, {|i| 4*i}); //offsets the nodes to group as follows: nodes 1-4: low voice; nodes 5-8 middle voice; nodes 9-12:high voice

~fadesIn = #[ 45, 67.5, 90, 112.5 ]*~saFadeTimeScale;
~outs = #[0, 2, 3, 1]; //L, RS, LS, R

~sAddSynths = Array.fill(4*polyphony, {s.nextNodeID}); //make node for each synth

////////////
//ADDITIVES
~addAmp = 0.4;
~timeScale = 10; //scales the attack time to 20 for the performance

~instances1 = 1;
~instances2 = 8;
~instances3 = 6;
~instances4 = 20;
~instances5 = 8;
~instances6 = 20;

~addXPose = ~saXpose;

~cp = Array.fill(4, 63);

//////////
//SAMPLER
~samplerNodes = Array.fill(~samplerFiles.size, {s.nextNodeID});

//////
//EGG
~eggNumVoices = 60;
~ppo=0; //pan position offset
~samplerPPO = 0; // "
~eggTimeScale = 1; //FOR PERFORMANCE THIS MUST BE ONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
~eggLDNodes = Array.fill(8, {s.nextNodeID}); //first spatially discrete, low density voices
~eggAddSynths = Array.fill(~eggNumVoices, {s.nextNodeID}); //spatially disbursed, high density voices
~eggRotationsLemur = 4;
~intAMLDPhases = #[0, pi];
~intAMLDRateRand = Array.fill(2, {rrand(0.9, 1.1)});
//~intAMLDRateRand = #[1, 1]; //no randomness
~eggIntStreams = 3;
~eggAddSynthsPhases = #[0, 0.5pi, pi];
~eggAddSynthsRateRand = Array.fill(~eggIntStreams, {rrand(0.9, 1.1)});
//~eggAddSynthsRateRand = #[1,1,1]; //no randomness
~eggLVfadeTime = 3;

////////
//WAVES
~wavesMarkerLemur = 0;
~wavesRate = 1;
~wavesML = 1;
~waves = [
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x.aiff" //more intense/dense. fade in more slowly and out more quickly
];

~wavesBuffers = Array.fill(~waves.size, {|i| Buffer.read(s, ~waves[i])});

~wavesInfo = {
	wavesSFs  = Array.fill(~waves.size, {SoundFile.new});
	~waves.size.do{|i| wavesSFs[i].openRead(~waves[i]) };//must openRead the files

	~wavesMarkers = Array.fill(~waves.size, {|i| wavesSFs[i].extractMarkersAiff2(0)}); //0=samples (default), 1=seconds)
	~wavesSR=Array.fill(~waves.size, {|file| ~wavesBuffers[file].sampleRate});

	wavesLastMarker = Array.fill(~waves.size, {|file| ~wavesMarkers[file].last});
	waveFileDurSamps = Array.fill(~waves.size, {|file| ~wavesBuffers[file].duration*~wavesSR[file]});

	~wavesMarkerDurArray=Array.fill(
		~waves.size
		, {|file| Array.fill(
			~wavesMarkers[file].size-1
			, {
				|i| wavesNextMarker=~wavesMarkers[file][i+1]; wavesMarker=~wavesMarkers[file][i]; wavesNextMarker-wavesMarker
			}
		)++(waveFileDurSamps[file]-wavesLastMarker[file])
		}
	);
	//print waves marker durations:
	~waves.size.do{|i|
		"file: ".post; ~waves[i].basename.postln;
		"marker dur(s): ".post; (~wavesMarkerDurArray[i]/~wavesSR[i]).postcs; //in seconds
	};
};

~grps = {
	//////////////
	//GROUPS
	fork{
		var wait=0.1;
		s.sendBundle(s.latency
			, [\g_new, ~amplitudesGrp=s.nextNodeID, 0, 0] //1st group. amplitude spatial gestures (env sources)
			, [\g_new, ~sergeGrp=s.nextNodeID, 3, ~amplitudesGrp] //ending serge sample uses this grp
			, [\g_new, ~group=s.nextNodeID, 3, ~sergeGrp] // (voiceMass)
			, [\g_new, ~xpGroup=s.nextNodeID, 3, ~group]//2 (voiceMass)
			, [\g_new, ~sAdditivesGrp=s.nextNodeID, 3, ~xpGroup]//3 simple additive
			, [\g_new, ~additivesGrp=s.nextNodeID, 3, ~sAdditivesGrp] //4 master additives
			, [\g_new, ~samplerGroup=s.nextNodeID, 3, ~additivesGrp] //sampler
			, [\g_new, ~eggAdditivesGrp=s.nextNodeID, 3, ~amplitudesGrp]//egg
			, [\g_new, ~gvGroup1 = s.nextNodeID, 3, ~eggAdditivesGrp] //glissing Voices
			, [\g_new, ~wavesGrp = s.nextNodeID, 3, ~gvGroup1] //waves
			, [\g_new, ~bleepsGrp = s.nextNodeID, 3, ~wavesGrp] //bleeps
		);
		0.2.wait;

		~addInternalGrps = Array.fill(8, {Group.new(~additivesGrp, \addToHead)}); //groups for each voice. Follower in last grp (nested grps)

		~flutter = Synth.tail(~additivesGrp, \flutter, [\direct, 1, \deviation, 0.001, \afAtk, 0.04, \afRel, 0.04]);//deviation can only be set at init. deviation 0<=x<1
		"groups created".postln;
	}
};

///////////////////////////////////////////////////////////////////////////////////
//SYNTH DEFS:
///////////////////////////////////////////////////////////////////////////////////

///////////
//REORDER
//change the channel order from L,R,C,LFE,LS,RS to L,R,RS,LS (,C,LFE). must be at the tail.
SynthDef(\reorder1, {|inBus=0, subLev=1, lpc=80|
	var in, chans, sub;
	var back;

	in = In.ar(inBus, 6);

	if (~dlyComp==1)
	{back = DelayN.ar([ in[3], in[2] ], 0.05, 0.019, -3.dbamp);} //back 19 ft closer and 3 db louder than front
	{back = [ in[3], in[2] ];};

	//send L, R, LS, RS to sub:
	sub = BLowPass4.ar(
		Mix.ar([ in[0], in[1], in[2], in[3] ])*subLev
		, lpc)*subLev;

	//hardware outs: L, R, C, LFE, LS, RS
	chans = [ in[0], in[1], in[4], sub, back[0], back[1] ]; //the order of the array represents the hardware. the contents, the software

	ReplaceOut.ar(0, chans);
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

/////////////////////////////////
//AMPLITUDES (SPATIAL GESTURES)
SynthDef(\ampCircles, {|out=90, panrate=0.1, lev=1, gate=1, fmDepth=0, fmRateMult=1, fmRange=0.4|
	var in;
	var fm, fmMult, fmAdd;

	fmMult = fmDepth;
	//fmAdd = 1-fmMult;
	fm = LFNoise2.kr(panrate*fmRateMult, (fmRange*0.5)*fmMult, 1);
	in = PanAz.ar(
		4
		, Normalizer.ar(ClipNoise.ar(lev))
		, LFSaw.kr(panrate*fm)
	);
	Out.ar(out
		, in
		*
		EnvGen.kr(Env.asr(0.01, 1, 0.01), gate, doneAction:2)
	)
}).send(s);

SynthDef(\ampFrontBack, {|out=94, modSource=0, position=0, rate=0.05, lev=1, gate=1|
	//NEED TO REFINE THIS TO FADES IN FRONT AND FADES OUT BACK
	//add LFNoise2 to rate
	var one, two;
	var pos, amp, trig, mod;
	var in;

	//trig = Impulse.ar(rate);
	mod = Select.kr(
		modSource
		, [ LFSaw.kr(rate, 1)
			, position ]
	);
	/*	pos = EnvGen.kr(Env(#[-1, 1, 1], [1/rate, (1/rate)*3], #[1, -2]), trig);
	amp = EnvGen.kr(Env(#[1, 1.3, 0], [1/rate, (1/rate)*3], #[2, -2]), trig);*/
	one = PanAz.ar(4, ClipNoise.ar(lev), 0);
	two = PanAz.ar(4, ClipNoise.ar(lev), 1);

	in = XFade2.ar(one, two, Lag.kr(mod, 0.3), level:mod.range(1, 1.3));

	Out.ar(out
		, in
		*
		EnvGen.kr(Env.asr(0.01, 1, 0.01), gate, doneAction:2)
	)
}).send(s);

///////////////////
//SIMPLE ADDITIVES
SynthDef(\simpleAdditive, { |outBus=0, masterLev=1, mlLag=1, centerPitch=67, cpLag=0.1, atk=0.1, release=30, amp=1, gate=1, freqModRate=0.00001, fmModRateLag=30, fmIndex=0, fmNoiseIndex=0, fmIndexLag=30, fmNoiseIndexLag=30, amRate=0.0333333, amDepth=0, amLag=0.1, afBus=130, afAmount=0, afAtk=0.01, afRel=0.01, masterLev2=1|
	var in, env, triLev=0.1;
	var fmIndexMod;
	var ampMod;
	var outSig, phase;
	var ampFoll;

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
	ampFoll = Amplitude.ar(In.ar(afBus, 4), afAtk, afRel, mul:afAmount, add:1-afAmount);
	Out.ar(outBus, outSig*Lag2.kr(masterLev, mlLag)*ampFoll*masterLev2); //mono
}).send(s);

////////////
//ADDITIVES
//2 voices. fixed pan pos w FM for each channel
SynthDef(\additive1RM, { |out=100, masterLev=1, lev=1, direct=1, directLag=0.1, centerPitch=67, pitchLag=0.1, atk=0.1, rel=1, amp=1, gate=1, freqModRate=0.001, fmIndexStart=0, fmIndexEnd=0.025, fmIndexDur=30, rmRate=10, rmRateLag=0.1, rmLag=0.05, send=16, sendLev=0.5|
	var in, env;
	var fmIndex;
	var dry, wet;
	var noiseMod;
	var output;

	fmIndex = Line.kr(fmIndexStart, fmIndexEnd, fmIndexDur);
	in = LFTri.ar(
		Lag2.kr(centerPitch.midicps, pitchLag)
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
	output = Mix.ar([dry, wet])*env*masterLev*lev;
	Out.ar(out, output);
	//Out.ar(5, output); //sub out
	//Out.ar(send, output*sendLev);
}).add;

//monophonic. SinOsc for FM and uses a panner
SynthDef(\additive3, {|out=100, masterLev=1, lev=1, centerPitch=68, atk=0.1, rel=1, amp=1 gate=1, modDepth=0.025, panRateScale=1, send=16, sendLev=0.5|
	var in, env, output;
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
	output = in*env*masterLev*lev;
	Out.ar(out, output);
	//Out.ar(5, output); //sub out
	//Out.ar(send, output*sendLev);
}).add;

//monophonic. SinOsc for FM with a Line on the depth (index of modulation)
SynthDef(\additive4, {|out=100, masterLev=1, lev=1, centerPitch=72, atk=0.1, rel=1, amp=1, gate=1, panRate=1, panStartPos=0, lineStart=10, lineEnd=1, lineDur=70, send=16, sendLev=0.5|
	var in, env, output;
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
	output = in*env*masterLev*lev;
	Out.ar(out, output);
	//Out.ar(5, output); //sub out
	//Out.ar(send, output*sendLev);
}).add;

//FLUTTER (output of additives)
SynthDef(\flutter, {|inBus=100, direct=1, directLag=0.1, gate=1, atk=0.1, rel=0.1, tremRate=20, tremRateLag=0.1, tremDepth=1, deviation=0.5, pulseShape=0.01, psLag=0.1, pulseWidth=0.5, pwLag=0.1, afBus=130, afAmount=0, afAtk=0.01, afRel=0.01, send=16, sendLev=0.5|
	var in, trem;
	var wet, dry;
	var width, shape, phase, pulsePhase=0;
	var wetDry;
	var ampFoll, output;

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
	ampFoll = Amplitude.ar(In.ar(afBus, 4), afAtk, afRel, mul:afAmount, add:1-afAmount); //send from VoiceMass bus 130
	output = Mix.ar([dry, wet])*(ampFoll*6);
	Out.ar(0, output);
	Out.ar(send, output*sendLev);
}).send(s);

////////////
//FOLLOWER
SynthDef(\follower, {|outBus=0, inBus=130, atk=0.1, rel=0.1, lev=1, gate=1, band1Lev=4, band2Lev=1, band3Lev=0.05, band4Lev=0.01, lag=0.01, send=16, sendLev=0.5|

	var out, pitches, amp, source;
	var low, mid, midHigh, high, oscs;

	//source = PlayBuf.ar(1, c.bufnum, loop:1);
	source = In.ar(130, 4);
	amp = Amplitude.ar(source, 0.2, 0.2)*lev;
	low = Lag.kr(
		Pitch.kr(
			LPF.ar(
				LPF.ar(source, 250)
				, 250
			)
		)
		, lag);
	mid = Lag.kr(
		Pitch.kr(
			LPF.ar(
				LPF.ar(
					HPF.ar(
						HPF.ar(source, 250)
						, 250
					)
					, 500
				)
				, 500)
			, minFreq:250)
		, lag);
	midHigh = Lag.kr(
		Pitch.kr(
			LPF.ar(
				LPF.ar(
					HPF.ar(
						HPF.ar(source, 500)
						, 500)
					, 1000
				)
				, 1000)
			, minFreq:500)
		, lag);
	high = Lag.kr(
		Pitch.kr(
			LPF.ar(
				LPF.ar(
					HPF.ar(
						HPF.ar(source, 1000)
						, 1000)
					, 2000)
				, 2000)
			, minFreq:1000)
		, lag);
	/*
	oscs = SinOsc.ar([low, low*Rand(0.99, 1.01)])+SinOsc.ar([mid, mid*Rand(0.99, 1.01)])+SinOsc.ar([midHigh, midHigh*Rand(0.99, 1.01)])+(SinOsc.ar([high*Rand(0.99, 1.01)])*0);*/
	oscs =
	LPF.ar((SinOsc.ar(low) * band1Lev ), 100)
	+ LPF.ar(HPF.ar((SinOsc.ar(mid) * band2Lev ), 400), 500)
	+ LPF.ar(HPF.ar((SinOsc.ar(midHigh) * band3Lev), 600), 1000)
	+ LPF.ar(HPF.ar((SinOsc.ar(high) * band4Lev), 1000), 2000)
	;

	out = (oscs*amp)
	*
	EnvGen.kr(Env.asr(atk, 1, rel, [4,-4]), gate, levelScale:lev, doneAction:2);

	Out.ar(outBus, out);
	Out.ar(send, out*sendLev);

}).send(s);

///////////
//SAMPLER
SynthDef(\sampler, {|outBus=0, bufnum=0, lev=1, lpc=20000, atk=0.01, sus=1, rel=0.01, curve=4, gate=1, posOffset=0, poLag=0.1, rotationRate=0.1, rotationsOn=0, inBus=90, afAmount=0, send=16, sendLev=0, masterLev=1|

	var in, filt, out, quad;
	var mult, add, panner;
	var pan1, pan2, pan3, pan4;
	var positions;
	var afMult, afAdd;

	afMult = afAmount;
	afAdd = 1-afAmount;

	positions = #[-0.25, 0.25, 0.75, -0.75];

	mult = Lag.kr(rotationsOn.round(1), 0.5);
	add = (1-mult);

	in = PlayBuf.ar(6, bufnum, 1, startPos:0, loop:0, doneAction:2);
	quad = [in[0], in[1], in[5], in[4]]; //convert from cubase 5.1 layout to SC quad (L,R,Rs,Ls)
	filt = LPF.ar(quad, [lpc+0.1, lpc+0.1, 20000, 20000], lev); //only filters the front channels
	panner = LFSaw.kr(rotationRate, 0, mult, add);
	out = Array.fill(4, {|i|
		PanAz.ar(4, filt[i], panner+positions[i])
	})
	*
	EnvGen.kr(Env.asr(atk, sus, rel, curve), gate, doneAction:2)
	*
	Amplitude.ar(In.ar(inBus, 4), mul:afMult, add:afAdd)
	*
	masterLev;

	Out.ar(
		0
		, out
		//, filt
	);
	//verb send:
	Out.ar(
		send
		, out*sendLev
	);
}).send(s);

/////////////
//VOICEMASS
~vmFiles = [
	"/Projects/Eliza/TiS Eliza Extended Vox 04-29-17/EDITED/12 E_inhale exhale vow high pch_CLN.aif",
	"/Projects/Eliza/TiS Eliza Extended Vox 04-29-17/EDITED/117 E_singing text montone more air.aif"
];

~voiceMassBuffer = Array.fill(~vmFiles.size, {|i| Buffer.read(s, ~vmFiles[i])}); //a buffer for each soundfile. solves the occasional reciprocal error by preloading buffers
sfs  = Array.fill(~vmFiles.size, {SoundFile.new});
/*sfs.postln;*/
~vmFiles.size.do{|i| sfs[i].openRead(~vmFiles[i]) };//must openRead the files
~voiceMassMarkers = Array.fill(~vmFiles.size, {|i| sfs[i].extractMarkersAiff2(0)}); //0=samples (default), 1=seconds)

//SynthDefs
SynthDef(\pb_voiceMass, {|out=0, bufnum=0, rate=1, startPos=0, panPos=0, gestureLev=1, masterLev =0, atk=0.01, dur=1, rel=0.01, curve= -4, send=16, dryLev=1, sendLev=1, gate=1, loop=0, mlLag=0.01, afBus=130|
	var in, env, output;
	env = Env.asr(atk, 1, rel, curve);
	in = HPF.ar(PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, startPos:startPos, loop:loop, doneAction:2), 20);
	env = EnvGen.kr(env, gate:gate, levelScale:gestureLev, doneAction:2);
	output = PanAz.ar(4, in, panPos)*env;
	//dry:
	Out.ar(out,
		output*dryLev*Lag2UD.kr(masterLev, mlLag)
	);
	//wet:
	Out.ar(send,
		output*sendLev*Lag2UD.kr(masterLev, mlLag)
	);
	Out.ar(afBus, output*5); //sends amplitude to additives
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
SynthDef(\eggAdditive, { |outBus=110, masterLev=1, mlLag=1, centerPitch=67, cpLag=0.1, atk=0.1, release=30, amp=1, gate=1, freqModRate=0.00001, fmModRateLag=30, fmIndex=0, fmNoiseIndex=0, fmIndexLag=30, fmNoiseIndexLag=30, amRate=0.0333333, amDepth=0, amLag=0.1, panPos=0.25, ppOffset=0, ppoLag=0.1, lpC=8000, lpRise=0.1, lpFall=0.1, timeScale=1, lpEGate=0, modDepth=0, mdLag=0.1, intAMdepth=0, iamdLag=0.1, intAMrate=0.2, intAMphase=0, send=16, sendLev=0|

	var in, env, triLev=0.1;
	var fmIndexMod;
	var ampMod;
	var outSig, phase, panner, posOffset;
	var tri, saw, fm, cfMod;
	var mod, filtEnv, modMult, modAdd;
	var internalAM, outwAM, out, iAM,intAMmul, intAMadd;
	var min=0.1;

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
	//intAMadd = 1-intAMmul;
	intAMadd = (1-intAMmul)+(min*2*intAMmul); //go from 0.1 (min) to 1.1 at max
	internalAM = SinOsc.kr(intAMrate, intAMphase, intAMmul, intAMadd);
	filtEnv = EnvGen.kr(Env.asr(lpRise, lpC, lpFall, #[6, -6]), lpEGate, timeScale:timeScale); //curves were #[6, -6]

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
	out = panner*internalAM*Lag2.kr(masterLev, mlLag);

	Out.ar(outBus, out);
	Out.ar(send, HPF.ar(out, 100)*sendLev);
}).send(s);

//AMP MOD
/*
PanAz discrete outs (with width of 2!!):
-0.25 = L (0)
0.25 = R (1)
0.75 = RS (2)
1.25 = LS (3)
*/

//EGG am
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

/////////
//BLEEPS
SynthDef(\bleeps, {|out=0, car=1000, modulator=1100, pmIndex=0.1, modPhase=0, lev=0.1, send=16, sendLev=0, hpc=20, pimRate=6, atk=0.1, rel=0.1, gate=1, pos=0, ppOffset=0, ppoLag=0, amAmount=1|
	var pmIndexMod;
	var maxPI=1.75, minPI=1.25;
	var posOffset, in;
	var modulatorMod;
	var mult, add, min=0.3;

	//equation for wet dry within a range (w/1 the max)
	mult = (amAmount-min)*0.5;
	add = (1-mult);

	posOffset = Lag2.kr(ppOffset, ppoLag);
	pmIndexMod = LFPulse.kr(pimRate, 0, LFNoise2.kr(0.1).range(0.01, 1), maxPI, minPI);

	modulatorMod = LFNoise2.kr(0.1).range(0, 100);

	in = 	HPF.ar(
		PMOsc.ar(Lag.kr(car, 0.1), Lag.kr(modulator+modulatorMod, 0.1), (pmIndex+pmIndexMod)*pi, modPhase, Lag.kr(lev, 0.2))/*!2*/
		, hpc)
	*
	LFTri.kr(0.05*LFNoise2.kr(0.2).range(0.3, 1.2), 0, mult, add);

	Out.ar(0
		, PanAz.ar(4, in, pos+posOffset)
		*
		EnvGen.kr(Env.asr(atk, 1, rel, [4, -4]), gate, doneAction:2)
	)
	//slow AM mod on sendLev?
}).send(s);

/////////////////
//SPINNING SERGE
//edit file so it loops perfectly!!
//lemur: start/stop, lev, hpCut
SynthDef(\spinningSerge, {|out=0, bufnum=0, atk=0.1, rel=0.1, masterLev=1, gate=0, hpCut=5000|
	var pb, file, in;

	file = ~bufArr[3];
	pb = PlayBuf.ar(1, file.bufnum, BufRateScale.kr(file.bufnum), loop:1);
	in = 	DelayN.ar(
		PitchShift.ar(pb, 0.2, 0.5, mul:1.5)+(pb*1)
		, 0.2
		, [0.2,0.3,0,0.1]
		, 1
	);

	Out.ar(0, HPF.ar(in, hpCut)
		*
		EnvGen.kr(Env.asr(atk, 1, rel, [4, -4]), gate, doneAction:0)
		*masterLev
	)
}).send(s);

////////
//WAVES
SynthDef(\waves, {|out=0, bufnum1=0, bufnum2=1, rate=1, lev1=1, lev2=1, send=16, sendLev=0, gate=0, startPos1=0, startPos2=0, duration1=14.5, masterLev=1|

	var in1, in2, xfade, env1, pan1, pan2, pos;
	var duration2, output;
	var lpc;
	var in1Env, in2Env, outEnv;

	outEnv = EnvGen.kr(Env.new(#[0, 1, 1, 0], [0.01, duration1-0.02, 0.01]), doneAction:2);

	in1Env = EnvGen.kr(Env.new(#[0, 1, 1, 0], #[0.4, 0.2, 0.4], #[-2, 1, 2]), gate, timeScale: duration1);
	in2Env = EnvGen.kr(Env.new(#[0, 1, 1, 0], #[0.4, 0.2, 0.4], #[2, 1, 2]), gate, timeScale: duration1);

	in1 = PlayBuf.ar(2, bufnum1, BufRateScale.kr(bufnum1)*rate, startPos: startPos1)
	*in1Env;

	in2 = PlayBuf.ar(2, bufnum2, BufRateScale.kr(bufnum2)*rate, startPos: startPos2)
	*
	in2Env;

	pos = EnvGen.kr(Env.new(#[0, 0.25, 0.25, 0.5], #[0.4, 0.2, 0.4], #[-1.5, 1, -4]), gate, timeScale:duration1); //pan line

	pan1 = PanAz.ar(4, in1[0]+in2[0], -0.25-pos, lev1);
	pan2 = PanAz.ar(4, in1[1]+in2[1], 0.25+pos, lev2);

	lpc = EnvGen.kr(Env.new(#[8000, 20000, 20000, 8000], #[0.4, 0.2, 0.4], #[1, 1, 1]), gate, timeScale:duration1);

	output = LPF.ar(pan1+pan2, lpc)*outEnv*masterLev;

	Out.ar(out, output);
	Out.ar(send, output*sendLev);
}).send(s);



////////////////////////////////////
//FILES AND FUNCTION EVALS:
///////////////////////////////////
~samplerFiles =
[
	"/Projects/SC GITHUB/tis SOUNDFILES/TIS 061317 3 Rnd Hi Freq Sparse F GV 1 ed.wav",
	"/Projects/SC GITHUB/tis SOUNDFILES/TIS 061317 1 Rnd FM 1-R,L GV 1 ed.wav",
	"/Projects/SC GITHUB/tis SOUNDFILES/061417 1 Mod Waves-R GV 1 F h.d. ed.wav",
	"/Projects/SC GITHUB/tis SOUNDFILES/descending_masses_serge quad.wav" //sergeMass
];

// ~sergeMass = "/Projects/SC GITHUB/tis SOUNDFILES/descending_masses_serge quad.wav";

~samplerNodes = Array.fill(~samplerFiles.size, {s.nextNodeID});

~samplerDurs = Array.newClear(~samplerFiles.size+1);

/*(
f = ["sounds/a11wlk01.wav", "sounds/a11wlk01.wav", "sounds/a11wlk01.wav"];
fork{
a = f.collect{|path| Buffer.read(s, Platform.resourceDir +/+ path)};
s.sync;
"done".postln; a.postln;  //run your action function here action.value
};
)*/
~count = ~samplerFiles.size;
~samplerBufs = Array.fill(~samplerFiles.size, {|i| var buf; buf = Buffer.read(
	s
	, ~samplerFiles[i]
	//on loading completion (add all other buffers):
	, action: {
		fork{
			~count=~count-1; //counts down

			~samplerDurs.put(i, buf.duration);
			~samplerDurs[i].postln;

			//only does this once:
			if (~count==0){
				"initializing".postln;
				~grps.value;
				0.2.wait;
				MIDIClient.init; //initialize
				MIDIIn.connectAll; //connects to all available devices
				0.2.wait;
				~wavesInfo.value;
				0.1.wait;
				~reorder = Synth.tail(s, \reorder1); "reorder".postln;
				0.2.wait;
				{~reorderWindow.value}.defer;
				0.1.wait;
				~verb = Synth.before(~reorder, \jpverb);
				0.1.wait;
				~openFiles.value; //loads files
				0.2.wait;
				~additivesMIDI.value;
				~eggMIDI.value;
				~bleepMIDI.value;
				~samplerMIDI.value;
				~spinningSergeMIDI.value;
				~wavesMIDI.value;

			}{nil};
		}
	}
)
});
/*++[ Buffer.read(s, ~sergeMass, action: {|buf|
~samplerDurs.put(~samplerDurs.size-1, buf.duration);
~samplerDurs.last.postln;
})
];*/


///////////////////////////////////////////////////////////////////////////////////
//FUNCTIONS:
///////////////////////////////////////////////////////////////////////////////////

////////////////////////////
//filter and rotation functions:
~eggOpen = {
	//first low density, then long slow fade in high density, then bass. overlapped entrances
	var outs, fadesIn;
	var lPos, rPos, rsPos, lsPos, posArray;
	var ldPos, wait = 90, bassWait=240;
	var bassLPos, bassRPos, bassRSPos, bassLSPos, bassPosArray, numBass=16;

	"egg".postln;

	ldPos = #[-0.25, 0.25];

	lPos = Array.fill(~eggNumVoices/4, {rrand(-0.5, 0)});
	rPos = Array.fill(~eggNumVoices/4, {rrand(0, 0.5)});
	rsPos = Array.fill(~eggNumVoices/4, {rrand(0.5, 1)});
	lsPos = Array.fill(~eggNumVoices/4, {rrand(-0.5, 1)});

	posArray = lPos++rPos++rsPos++lsPos;

	/*~eggLDNodes = Array.fill(8, {s.nextNodeID}); //first spatially discrete, low density voices
	~eggAddSynths = Array.fill(~eggNumVoices, {s.nextNodeID}); //spatially disbursed, high density voices*/

	s.sendMsg(\s_new, \eggAM, ~eggAM=s.nextNodeID, 1, ~eggAdditivesGrp); //EGG AM (tail of egg grp)

	~eggOpenTask = Task{
		~eggCounter.play; //start the egg counter

		//LOW DENSITY
		"low density".postln;
		~eggLDNodes.size.do{|i|
			var pchs, atk;
			var lag;
			lag = rrand(60*4, 60*7)*~eggTimeScale;

			pchs = ([73, 71, 69, 67, 66, 64, 59]-0.3).wchoose([1, 3, 1, 1, 1, 1, 3].normalizeSum);
			atk = rrand(60, 60*2)*~eggTimeScale;

			s.sendMsg(\s_new, \eggAdditive, ~eggLDNodes[i], 0, ~eggAdditivesGrp, \centerPitch, pchs+rrand(-0.2, 0.2), \masterLev, 0.2, \panPos, ldPos.wrapAt(i), \atk, atk, \lpC, 12000, \lpRise, lag, \lpEGate, 1); //opens filter
		};

		(wait*~eggTimeScale).wait; //WAIT

		//HIGH DENSITY
		"high density".postln;
		~eggNumVoices.do{|i|
			var cp, atk, pchs;
			var lag;
			lag = (rrand(60*4, 60*8)*~eggTimeScale)-wait;

			pchs = ([73, 71, 69, 67, 66, 64, 59]-0.3).wchoose([1, 3, 1, 1, 1, 1, 3].normalizeSum);
			atk = rrand(60*3, 60*6)*~eggTimeScale;

			s.sendMsg(\s_new, \eggAdditive, ~eggAddSynths[i], 0, ~eggAdditivesGrp, \centerPitch, pchs+rrand(-0.2, 0.2), \masterLev, 0.2, \panPos, posArray[i], \atk, atk, \lpC, 12000, \lpRise, lag, \lpEGate, 1) //opens filter
		};

		(bassWait*~eggTimeScale).wait;
		/*	s.sendMsg(\n_set, ~eggAdditivesGrp, \wetDry, 0.7, \wdLag, (60*5)*~eggTimeScale); //fade in AM*/

		//BASS
		~eggBassNodes = Array.fill(numBass, {s.nextNodeID}); //bass nodes

		bassLPos = Array.fill(numBass/4, {rrand(-0.5, 0)});
		bassRPos = Array.fill(numBass/4, {rrand(0, 0.5)});
		bassRSPos = Array.fill(numBass/4, {rrand(0.5, 1)});
		bassLSPos = Array.fill(numBass/4, {rrand(-0.5, 1)});

		bassPosArray = bassLPos++bassRPos++bassRSPos++bassLSPos;

		"bass".postln;
		numBass.do{|i|
			var pch, atk, lag;

			pch = (59-24)+rrand(-0.2, 0.2);
			atk = rrand(60*2, 60*3)*~eggTimeScale;
			lag = rrand(60*2.5, 60*4)*~eggTimeScale;

			s.sendMsg(\s_new, \eggAdditive, ~eggBassNodes[i], 0, ~eggAdditivesGrp, \centerPitch, pch, \masterLev, 0.2, \panPos, bassPosArray[i], \atk, atk, \lpC, 8000, \lpEGate, 1, \lpRise, lag);
		};
		(60*4).wait;
		"fully open".postln;
	}.play;
};

//close the filter (mirror open) and fade all except the last group of oscillators
~eggClose = {
	var wait, bassWait;

	~eggCloseTask = Task{
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
	}.play;
};

//rotation:
~eggRotation = {|panO=1/*also serves as rotations/rotationDur*/, rotationDur=60|

	~ppo=~ppo+panO; //to increment

	~eggLDNodes.size.do{|i|
		s.sendBundle(s.latency, [\n_set, ~eggLDNodes[i], \ppOffset, ~ppo, \ppoLag, rotationDur]);
	};
	~eggNumVoices.do{|i|
		s.sendBundle(s.latency
			, [\n_set, ~eggAddSynths[i], \ppOffset, ~ppo, \ppoLag, rotationDur]
			, [\n_set, ~bleepsGrp, \ppOffset, ~ppo, \ppoLag, rotationDur]
		);
	};

	//s.sendBundle(s.latency, [\n_set, ~eggAM, \posOffset, ~ppo, \ppoLag, rotationDur]);

	~erInfo = Task{
		"rotating 180 degrees...".postln;
		rotationDur.wait;
		"rotation complete.".postln;
	}.play;
};

//rotation for descending serge:
~samplerRotation = {|numRotations=10, duration=2|
	//numRotations per duration
	~samplerPPO = ~samplerPPO+numRotations;

	s.sendMsg(\n_set, ~sergeNode, \posOffset, ~samplerPPO, \poLag, duration);

	fork{
		"rotating serge...".postln;
		duration.wait;
		"serge rotations complete.".postln;
	}
};

//nodes: ~eggLDNodes, ~eggAddSynths, ~eggBassNodes
~intAMfade = {|amDepth=1, amFadeIn=240|

	~eggLDNodes.size.do{|i|
		var rates, phases;

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

~counter = Routine{
	var occurence=15;
	inf.do{|i|
		"counter: ".post; (occurence*i).asTimeString2.postln;
		occurence.wait;
	}
};

//open and eval files:
~openFiles = {
	var rout;
	rout = Routine{
		Object.readArchive("/Projects/SC GITHUB/tis/midiAssignments 1.1 LAPTOP.scd");
		0.2.wait;
		Object.readArchive("/Projects/SC GITHUB/tis/voiceMass lemur GUI.1.4 LAPTOP.scd");
		0.1.wait;
		Object.readArchive("/Projects/SC GITHUB/tis/glissing voices gui 1.55 LAPTOP.scd");
		0.1.wait;
		/*		Object.readArchive("/Projects/SC GITHUB/tis/sampler LAPTOP.scd");
		0.1.wait;*/
		//Object.readArchive("/Projects/SC GITHUB/tis/egg.1.31 LAPTOP.scd");
	};
	AppClock.play(rout);
};
)