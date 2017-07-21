(
SynthDef(\additive1RM2, { |out=0, masterLev=0.6, mLag=0.1, direct=1, directLag=0.1, centerPitch=70, pitchLag=0.1, atk=0.01, rel=1, amp=0.3, gate=1, freqModRate=0.001, fmIndexStart=0, fmIndexEnd=0.025, fmIndexDur=30, rmRate=10, rmRateLag=0.1, rmLag=0.05, pos=0, send=16, sendLev=0.5, transpose=0, xpLag=20, spreadOffset=0, sLag=20, initSpread=5|
	var in, env;
	var fmIndex;
	var dry, wet;
	var noiseMod, output;
	var spreadMult, noiseShape;

	spreadMult = Line.kr(0, initSpread, sLag) + Lag.kr(spreadOffset, sLag); //starts w/5 (initSpread)
	noiseShape = Line.kr(0.01, 0.1, 20);

	fmIndex = Line.kr(fmIndexStart, fmIndexEnd, fmIndexDur);
	//fmIndex = Lag.kr(fmIndexStart, fmIndexDur);
	in = LFTri.ar(
	((
			Lag2.kr( (centerPitch+Lag.kr(transpose, xpLag)).midicps*Rand(0.99, 1.01), pitchLag)
		)
		*
		SinOsc.kr(
			LFNoise0.kr(
				freqModRate
			)
			, 0
			, fmIndex+Lag.kr(
				LFNoise0.kr(
				Rand(4, 21.0)
				, Rand(-0.2, 0.2)*spreadMult)
			, noiseShape
			)
			, 1
		))+Lag.kr(transpose, xpLag)
		, 0
		, 0.1
	);
	env = EnvGen.kr(
		Env.adsr(atk, 2, amp, rel, curve:[4, -1.5, -4])
		, gate, doneAction:2
	);
	noiseMod =	Lag2.ar(
		LFNoise0.ar(
			Lag2.kr(
				rmRate
				, rmRateLag
			)
			, 1
		)
		, rmLag
	);
	dry = in*Lag2.kr(direct, directLag);
	wet = (in*noiseMod)*(1-Lag2.kr(direct, directLag));

	output = PanAz.ar(4, Mix.ar([dry, wet]), pos)*env*Lag2.kr(masterLev, mLag);

	Out.ar(out, output);
	Out.ar(send, output*sendLev);

}).send(s);
)

/*
lPos = Array.fill(numBass/4, {rrand(-0.5, 0)});
rPos = Array.fill(numBass/4, {rrand(0, 0.5)});
rSPos = Array.fill(numBass/4, {rrand(0.5, 1)});
lSPos = Array.fill(numBass/4, {rrand(-0.5, 1)});
*/

//var lPos, rPos, lSPos, rSPos, density;

~messDens=30;

~lPos = Array.fill(~messDens, {rrand(-0.5, 0)});
~rPos = Array.fill(~messDens, {rrand(0, 0.5)});
~rSPos = Array.fill(~messDens, {rrand(0.5, 1)});
~lSPos = Array.fill(~messDens, {rrand(-0.5, 1)});

 y = Synth.tail(s, \reorder1);
 z = Synth.before(y, \jpverb);

s.sendMsg(\g_new, ~spreadGrp=s.nextNodeID, 0, 0);
s.sendMsg(\g_new, ~spreadGrp1=s.nextNodeID, 0, ~spreadGrp);
s.sendMsg(\g_new, ~spreadGrp2=s.nextNodeID, 0, ~spreadGrp);
s.sendMsg(\g_new, ~spreadGrp3=s.nextNodeID, 0, ~spreadGrp);
s.sendMsg(\g_new, ~spreadGrp4=s.nextNodeID, 0, ~spreadGrp);

~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp1, \centerPitch, 70, \pos, ~lPos[i]]) };
~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp2, \centerPitch, 69.75, \pos, ~rSPos[i]]); };
~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp3, \centerPitch, 72, \pos, ~rPos[i]]); };
~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp4, \centerPitch, 71.75, \pos, ~lSPos[i]]); };

//interrupt with this;
~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp1, \centerPitch, 70+3, \pos, ~lPos[i]]); };
~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp2, \centerPitch, 69.75+3, \pos, ~rSPos[i]]); };
~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp3, \centerPitch, 72+3, \pos, ~rPos[i]]); };
~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp4, \centerPitch, 71.75+3, \pos, ~lSPos[i]]); };

s.sendMsg(\n_set, ~spreadGrp, \transpose, -24, \xpLag, 20, \spreadOffset, 0, \sLag, 20, \masterLev, 1, \mLag, 20)
s.sendMsg(\n_set, ~spreadGrp, \transpose, 0, \xpLag, 0.1)



