//testing GITHUB 2

(
//var outBus = 0;

//2 voices. fixed pan pos w FM for each channel
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
}).add;

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

//monophonic. LFNoise2 for FM and uses a panner
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
}).add;

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

/*SynthDef(\flutter, {|inBus=100, gate=0, atk=0.1, rel=0.1, tremRate=8, tremRateLag=0.1, tremDepth=1, deviation=0.5, tremRateScale=1, trsLag=0.1|
	var in, trem;
	trem = EnvGen.ar(Env.asr(atk, 1, rel), gate, tremDepth)
	*
	LFTri.ar(
		Array.fill(4, {Lag2.kr(
			Rand(tremRate-(tremRate*deviation), tremRate+(tremRate*deviation))
			, tremRateLag)
		})*Lag2.kr(tremRateScale, trsLag)
		, 0
		, 0.5
		, 0.5
	);
	in = In.ar(inBus, 4);
	Out.ar(0, in-(in*trem));
}).send(s);*/
)

(
~addAmp = 0.4;
~timeScale = 20; //scales the attack time

~instances1=20;
~instances2 = 8;
~instances3 = 6;
~instances4 = 20;
~instances5 = 8;
~instances6 = 20;
)

//(


//4:
(
var cp;
cp = [63];
//cp = [62,63,65,67,70].midicps;
//cp = [66, 68, 70, 71, 72, 74, 81, 81].midicps;

~additivesGrp=Group.new; //master Additives group
~addInternalGrps = Array.fill(8, {Group.new(~additivesGrp, \addToHead)}); //groups for each voice

//MAKE A SEQUENCE USING FORK TO ADD EACH ARRAY  GRADUALLY (or perform manually)
~s1 = Array.fill(~instances1, {|i| Synth.head(~addInternalGrps[0], \additive1RM, [\out, 100, \masterLev, ~addAmp, \amp, 0.5, \cp, cp.choose, \atk, rrand(3.0, 7.0)*~timeScale]) });
~flutter = Synth.tail(~additivesGrp, \flutter, [\direct, 1, \deviation, 0.001]);//deviation can only be set at init. deviation 0<=x<1
)

(
var cp;
//cp = 63;
/*cp = [62,63,65,67,70].midicps;*/
/*cp = [63,67,70].midicps;*/
cp = Array.fill(4, 63).midicps;
~addInternalGrps[0].set(\cp, cp.choose, \pitchLag, 30);
)

//HOW TO INITIATE PANNING MOVEMENT???

~s1.size.do{|i| ~s1[i].set(\direct, 0, \directLag, 120)}; //AM wet/dry
~additivesGrp.set(\gate, 0, \rel, 0.1)

~flutter.set(\direct, 0, \directLag, 120);
~flutter.set(\tremRate, 0.2, \tremRateLag, 30);
~flutter.set(\pulseShape, 0.01, \psLag, 60);
~flutter.set(\pphase, Array.fill(4, {rrand(0, 2pi)}))
~flutter.set(\pulseWidth, 0.5, \pwLag, 120, \tremRateScale, 0.1, \trs, 60);
~flutter.set(\pulseWidth, 0.5, \pwLag, 30, \pulseShape, 0.1, \psLag, 30);


~flutter.set(\gate, 1, \atk, 5);
~flutter.set(\tremRateScale, 10, \trsLag, 60);
~flutter.set(\tremRateScale, 0.1, \trsLag, 0.9);
~flutter.set(\trsLag, 30, \tremRateScale, 0.5);
~flutter.set(\gate, 0, \rel, 1);
~flutter.set(\gate, 1);

~s1.size.do{|i| ~s1[i].set(\rmLag, 0.01)};
~s1.size.do{|i| ~s1[i].set(\rmRateLag, 60, \rmRate, 100)}

~s1.size.do{|i| ~s1[i].set(\masterLev, 0)};
~s2.size.do{|i| ~s2[i].set(\masterLev, 0)};
~s3.size.do{|i| ~s3[i].set(\masterLev, 0)};
~s4.size.do{|i| ~s4[i].set(\masterLev, 0)};
~s5.size.do{|i| ~s5[i].set(\masterLev, 0)};
~s6.size.do{|i| ~s6[i].set(\masterLev, 0)};
~s7.size.do{|i| ~s7[i].set(\masterLev, 0)};
~s8.size.do{|i| ~s8[i].set(\masterLev, 0)};

~additivesGrp.set(\masterLev, 0);
~additivesGrp.set(\gate, 0);

//fade out all but 1st group (~s1)
7.do{|i|
~addInternalGrps[i+1].set(\rel, 60, \gate, 0);
}


//TRY USING PITCH SETS!!
~s2 = Array.fill(~instances2, {|i| Synth.head(~addInternalGrps[1], \additive2, [\masterLev, ~addAmp, \centerPitch, 63, \atk, rrand(3.0, 7.0)*~timeScale]) });

~s3 = Array.fill(~instances3, {|i| Synth.head(~addInternalGrps[2], \additive3, [\masterLev, ~addAmp, \centerPitch, 64, \atk, rrand(3.0, 7.0)*~timeScale]) });

~s4 = Array.fill(~instances4, {|i| Synth.head(~addInternalGrps[3], \additive4, [\masterLev, ~addAmp, \centerPitch, 68, \atk, rrand(6.0, 7.0)*~timeScale, \panRate, rrand(1/6,1/3), \panStartPos, rrand(-8pi, 8pi)]) });

~s5 = Array.fill(~instances5, {|i| Synth.head(~addInternalGrps[4], \additive3, [\masterLev, ~addAmp, \centerPitch, 69, \atk, rrand(3.0, 7.0)*~timeScale, \modDepth, 0.035]) });

~s6 = Array.fill(~instances6, {|i| Synth.head(~addInternalGrps[5], \additive3, [\masterLev, ~addAmp, \centerPitch, rrand(68, 60), \atk, rrand(6.0, 7.0)*~timeScale, \modDepth, 0.035]) });

~s7 = Array.fill(50, {|i| Synth.head(~addInternalGrps[6], \additive3, [\masterLev, 0.5, \centerPitch, rrand(36, 69), \atk, rrand(2.0, 5.0)*~timeScale, \modDepth, 0.035]) });

~s8 = Array.fill(5, {|i| Synth.head(~addInternalGrps[7], \additive3, [\masterLev, 0.5, \centerPitch, [62,63,65,67,70].choose, \atk, rrand(1.0, 4.0)*~timeScale, \modDepth, 0.035]) });

/*~s7 = Synth.tail(~additivesGrp, \amplitudeMod, [\masterLev, 1]);*/
//)

~s7.set(\baseModRate, 0.1, \lag, 30); //musical parameters
~s7.set(\floor, 0, \floorLag, 0.1); //" (depth of the AM, lag)
~s7.set(\modNoiseRate, 0.2); //testing the rate of the LFDNoise3 that modulates the LFPulse freq for the AM
~s7.set(\baseModRate, 1)
~s7.set(\modCurve, -50)
~s7.set(\direct, 0, \directLag, 1)
~s7.set(\direct, 0.2, \directLag, 1)
~s7.set(\masterLev, 2)

~additivesGrp.set(\masterLev, 1)
(
g=Group.new;

//more instances of \additive4 (line)
~s1 = Array.fill(~instances1, {|i| Synth.head(g, \additive1, [\centerPitch, 63, \atk, rrand(0.1, 5)]) }); //array of 5 instances
~s2 = Array.fill(~instances2, {|i| Synth.head(g, \additive2, [\centerPitch, 63, \atk, rrand(0.1, 5)]) });
~s3 = Array.fill(~instances3, {|i| Synth.head(g, \additive3, [\centerPitch, 64, \atk, rrand(0.1, 5)]) });
~s4 = Array.fill(~instances4, {|i| Synth.head(g, \additive4, [\centerPitch, 68, \atk, rrand(0.1, 5), \panRate, rrand(1/6,1/3), \panStartPos, rrand(-8pi, 8pi)]) });
~s5 = Array.fill(~instances5, {|i| Synth.head(g, \additive4, [\centerPitch, 69, \atk, rrand(0.1, 5), \modDepth, 0.035, \panRate, rrand(1/6,1/3), \panStartPos, rrand(-8pi, 8pi)]) });
~s6 = Array.fill(~instances6, {|i| Synth.head(g, \additive4, [\centerPitch, rrand(68, 70), \atk, rrand(0.1, 5), \modDepth, 0.035, \panRate, rrand(1/6,1/3), \panStartPos, rrand(-8pi, 8pi)]) });

/*~s7 = Synth.tail(g, \amplitudeMod);*/

)
~s7.set(\baseModRate, 5, \lag, 5); //musical parameters


~instances1.do{|i|~s1[i].release}; //release each instance
~instances2.do{|i|~s2[i].release}; //release each instance
~instances3.do{|i|~s3[i].release}; //release each instance
~instances4.do{|i|~s4[i].release}; //release each instance
~instances5.do{|i|~s5[i].release}; //release each instance
~instances6.do{|i|~s6[i].release}; //release each instance

/*
experiment with imposing enveloping on 'additives' (gestural and textural)
experiment with tonal chords (with some microtonality)
write down all time varying parameters and plan a long, complex gesture (length of entire piece?)

build tool to process vocals
start simple: triggering
*/
