(
SynthDef(\additive1RM2, { |out=0, masterLev=0.6, mLag=0.1, direct=1, directLag=0.1, centerPitch=70, pitchLag=0.1, atk=10, rel=0.1, amp=0.3, gate=1, peak=0.9, freqModRate=0.001, fmIndexStart=0, fmIndexEnd=0.025, fmIndexDur=30, rmRate=10, rmRateLag=0.1, rmLag=0.05, pos=0, send=16, sendLev=0.5, transpose=0, xpLag=20, spreadOffset=0, sLag=20, initSpread=5, firstSpread=3|
	var in, env;
	var fmIndex;
	var dry, wet;
	var noiseMod, output;
	var spreadMult, noiseShape;
	var freqMod;

	spreadMult = XLine.kr(firstSpread, initSpread, sLag) + Lag.kr(spreadOffset, sLag); //starts w/5 (initSpread)
	noiseShape = Line.kr(0.01, 0.1, 20);

	fmIndex = Line.kr(fmIndexStart, fmIndexEnd, fmIndexDur);
	//fmIndex = Lag.kr(fmIndexStart, fmIndexDur);

	freqMod = 	(
		(
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
		)
	)+Lag.kr(transpose, xpLag);

	in = LFTri.ar(
		freqMod
		, 0
		, 0.1
	);
	env = EnvGen.kr(
		Env.adsr(atk, 2, amp, rel, peakLevel:peak, curve:[4, -1.5, -4])
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

	output = PanAz.ar(4, Mix.ar([dry, wet]), pos, 1, 2)*env*Lag2.kr(masterLev, mLag);

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

(
~messDens=20;

~lPos = Array.fill(~messDens, {rrand(-0.5, 0)});
~rPos = Array.fill(~messDens, {rrand(0, 0.5)});
~rSPos = Array.fill(~messDens, {rrand(0.5, 1)});
~lSPos = Array.fill(~messDens, {rrand(-0.5, 1)});

 /*y = Synth.tail(s, \reorder1);
z = Synth.before(y, \jpverb);*/

s.sendMsg(\g_new, ~spreadGrp=s.nextNodeID, 0, 0);
s.sendMsg(\g_new, ~spreadGrp1=s.nextNodeID, 0, ~spreadGrp);
s.sendMsg(\g_new, ~spreadGrp2=s.nextNodeID, 0, ~spreadGrp);
s.sendMsg(\g_new, ~spreadGrp3=s.nextNodeID, 0, ~spreadGrp);
s.sendMsg(\g_new, ~spreadGrp4=s.nextNodeID, 0, ~spreadGrp);
)

//figure out panning. is it working right?
fork{
	s.sendMsg(\n_set, ~spreadGrp, \gate, 0, \rel, 0.01); //end all
	0.05.wait;
	~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp1, \centerPitch, 70, \pos, ~lPos[i]]) };
};

~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp2, \centerPitch, 69.75, \pos, ~rSPos[i]]); };
~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp3, \centerPitch, 72, \pos, ~rPos[i]]); };
~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp4, \centerPitch, 71.75, \pos, ~lSPos[i]]); };

//interrupt with this;
fork{
	var waits;
	//waits = Array.fill(3, {rrand(0.07, 0.8)});
	waits = Array.fill(3, 0);
	s.sendBundle(s.latency, [\n_set, ~spreadGrp, \gate, 0, \rel, 0.01]); //end all
	0.05.wait;
	~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp1, \peak, 0.9, \centerPitch, 70+3, \pos, ~lPos[i]]); };
	waits[0].wait;
	~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp2, \peak, 0.7, \centerPitch, 69.75+3, \pos, ~rSPos[i]]); };
	waits[1].wait;
	~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp3, \peak, 0.7, \centerPitch, 70.5+3, \pos, ~rPos[i]]); };
	waits[2].wait;
	~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp4, \peak, 0.7, \centerPitch, 70.25+3, \pos, ~lSPos[i]]); };
};

fork{
	var waits, ps;
	//waits = Array.fill(3, {rrand(0.07, 0.3)});
   waits = Array.fill(3, 0);
	ps = 5.25;

	s.sendMsg(\n_set, ~spreadGrp, \gate, 0, \rel, 0.01); //end all
	0.05.wait;
	~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp1, \peak, 0.6, \centerPitch, 70+ps, \pos, ~lPos[i]]); };
	waits[0].wait;
	~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp2, \peak, 0.6, \centerPitch, 69.75+ps, \pos, ~rSPos[i]]); };
	waits[1].wait;
	~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp3, \peak, 0.6, \centerPitch, 72+ps, \pos, ~rPos[i]]); };
	waits[2].wait;
	~messDens.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp4, \peak, 0.6, \centerPitch, 71.25+ps, \pos, ~lSPos[i]]); };
};

fork{
	var waits, ps, peakOffset, density;
	waits = Array.fill(3, {rrand(0.07, 0.1)});
	ps = -7.35;
	peakOffset = -0.2;
	density = 10;

/*	s.sendMsg(\n_set, ~spreadGrp, \gate, 0, \rel, 0.01); //end all
	0.05.wait;*/
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp1, \peak, 0.6+peakOffset, \centerPitch, 70+ps, \pos, ~lPos[i]]); };
	waits[0].wait;
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp2, \peak, 0.6+peakOffset, \centerPitch, 69.75+ps, \pos, ~rSPos[i]]); };
	waits[1].wait;
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp3, \peak, 0.6+peakOffset, \centerPitch, 72+ps, \pos, ~rPos[i]]); };
	waits[2].wait;
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp4, \peak, 0.6+peakOffset, \centerPitch, 71.25+ps, \pos, ~lSPos[i]]); };
};

fork{
	var waits, ps, peakOffset, density;
	waits = Array.fill(3, {rrand(0.07, 0.1)*2});
	ps = -11.5;
	peakOffset = -0.3;
	density = 10;

/*	s.sendMsg(\n_set, ~spreadGrp, \gate, 0, \rel, 0.01); //end all
	0.05.wait;*/
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp1, \peak, 0.6+peakOffset, \centerPitch, 70+ps, \pos, ~lPos[i]]); };
	waits[0].wait;
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp2, \peak, 0.6+peakOffset, \centerPitch, 69.75+ps, \pos, ~rSPos[i]]); };
	waits[1].wait;
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp3, \peak, 0.6+peakOffset, \centerPitch, 72+ps, \pos, ~rPos[i]]); };
	waits[2].wait;
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp4, \peak, 0.6+peakOffset, \centerPitch, 71.25+ps, \pos, ~lSPos[i]]); };
};

fork{
	var waits, ps, peakOffset, density;
	waits = Array.fill(3, {rrand(0.07, 0.1)*3});
	ps = -14.5;
	peakOffset = -0.3;
	density = 10;

/*	s.sendMsg(\n_set, ~spreadGrp, \gate, 0, \rel, 0.01); //end all
	0.05.wait;*/
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp1, \peak, 0.6+peakOffset, \centerPitch, 70+ps, \pos, ~lPos[i]]); };
	waits[0].wait;
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp2, \peak, 0.6+peakOffset, \centerPitch, 69.75+ps, \pos, ~rSPos[i]]); };
	waits[1].wait;
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp3, \peak, 0.6+peakOffset, \centerPitch, 72+ps, \pos, ~rPos[i]]); };
	waits[2].wait;
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp4, \peak, 0.6+peakOffset, \centerPitch, 71.25+ps, \pos, ~lSPos[i]]); };
};

fork{
	var waits, ps, peakOffset, density;
	waits = Array.fill(3, {rrand(0.07, 0.1)*5});
	ps = -17;
	peakOffset = -0.3;
	density = 10;

/*	s.sendMsg(\n_set, ~spreadGrp, \gate, 0, \rel, 0.01); //end all
	0.05.wait;*/
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp1, \peak, 0.6+peakOffset, \centerPitch, 70+ps, \pos, ~lPos[i]]); };
	waits[0].wait;
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp2, \peak, 0.6+peakOffset, \centerPitch, 69.75+ps, \pos, ~rSPos[i]]); };
	waits[1].wait;
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp3, \peak, 0.6+peakOffset, \centerPitch, 72+ps, \pos, ~rPos[i]]); };
	waits[2].wait;
	density.do{|i| s.sendBundle(s.latency, [\s_new, \additive1RM2, s.nextNodeID, 0, ~spreadGrp4, \peak, 0.6+peakOffset, \centerPitch, 71.25+ps, \pos, ~lSPos[i]]); };
};



s.sendMsg(\n_set, ~spreadGrp, \transpose, 2, \xpLag, 20, \spreadOffset, 0, \sLag, 20, \masterLev, 1.2, \mLag, 20); //xpose and build

s.sendMsg(\n_set, ~spreadGrp, \gate, 0, \rel, 0.1); //sudden end all
//////////////////////////
//FADE OUT ALL ADDITIVES:
~additivesGrp.set(\rel, 0.1, \gate, 0);
//FADE OUT
s.sendMsg(\n_set, ~sAdditivesGrp, \gate, 0, \release, 0.1); //fade out and free


s.sendMsg(\n_set, ~spreadGrp, \gate, 0, \rel, 0.1); //slow fade



