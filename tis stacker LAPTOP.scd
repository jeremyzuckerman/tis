(
~wavesMonophonic = [
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 01.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 02.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 03.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 04.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 05.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 06.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 07.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 08.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 09.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 11.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 12.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 13.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 14.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 15.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 16.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 17.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_Poly1_1.5x_Marker 18.aiff"
];

~wavesPolyphonic = [
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 01.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 02.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 03.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 04.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 05.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 06.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 07.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 08.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 09.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 10.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 11.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 12.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 13.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 14.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 15.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 16.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassages/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 17.aiff"
];

~wavesMPBuffers = ~wavesMonophonic.collect{|i|
	Buffer.read(s, i)
};

~wavesPPBuffers = ~wavesPolyphonic.collect{|i|
	Buffer.read(s, i)
};
)

(
SynthDef(\wavesStacker, {|out=0, bufnum1=0, bufnum2=1, rate=1, lev1=1, lev2=1, send=16, sendLev=0, gate=1, startPos1=0, startPos2=0, duration=14.5, masterLev=1|

	var in1, in2, xfade, env1, pan1, pan2, pos;
	var duration2, output;
	var lpc;
	var in1Env, in2Env, outEnv;
	var scaledDur;

	scaledDur = duration*(rate.reciprocal);

	outEnv = EnvGen.kr(Env.new(#[0, 1, 1, 0], [0.01, scaledDur-0.02, 0.01]), doneAction:2);

	in1Env = EnvGen.kr(Env.new(#[0, 1, 1, 0], #[0.35, 0.05, 0.6], #[-2, 1, 2]), gate, timeScale: scaledDur);
	in2Env = EnvGen.kr(Env.new(#[0, 1, 1, 0], #[0.35, 0.05, 0.6], #[2, 1, 2]), gate, timeScale: scaledDur);

	in1 = PlayBuf.ar(2, bufnum1, BufRateScale.kr(bufnum1)*rate, startPos: startPos1)
	*in1Env;

	in2 = PlayBuf.ar(2, bufnum2, BufRateScale.kr(bufnum2)*rate, startPos: startPos2)
	*
	in2Env;

	pos = EnvGen.kr(Env.new(#[0, 0.25, 0.25, 0.5], #[0.35, 0.05, 0.6], #[-1.5, 1, -4]), gate, timeScale:scaledDur); //pan line

	pan1 = PanAz.ar(4, in1[0]+in2[0], -0.25-pos, lev1*0.5);
	pan2 = PanAz.ar(4, in1[1]+in2[1], 0.25+pos, lev2*0.5);

	lpc = EnvGen.kr(Env.new(#[8000, 20000, 20000, 8000], #[0.35, 0.05, 0.6], #[1, 1, 1]), gate, timeScale:scaledDur);

	output = HPF.ar(LPF.ar(pan1+pan2, lpc), 25)*outEnv*masterLev;

	Out.ar(out, output);
	Out.ar(send, output*sendLev);
}).send(s);
)

(
~wavesStackerFunc = {|fileNum=0, masterLev=1, density=10, peak=5|

	var lev, panpos, grpID, arr;
	var buffer1, buffer2;
	var duration;
	var trans;

	buffer1 = ~wavesMPBuffers[fileNum];
	buffer2 = ~wavesPPBuffers[fileNum];
	duration = buffer1.duration;

	//make group at head
	s.sendMsg("/g_new", grpID=s.nextNodeID, 0, 0);

	trans = Array.fill(density, {rrand(0.2, 1.0)});
	//trans.postcs;

	trans.size.do({ arg i;
		Routine({
			var os;
			var lev1=0.8;
			var lev2=0.8;

			os = trans.minItem.reciprocal-(trans[i].reciprocal)*peak; //calculates offsets
			os.wait;
			//os.postln; /* view offset times */

			s.sendBundle(0.1
				, ["/s_new", \wavesStacker, -1, 0, grpID, \bufnum, buffer1.bufnum, \numChan, 2, \duration, duration, \rate, trans[i], \lev1, lev1 ]
				, ["/s_new", \wavesStacker, -1, 0, grpID, \bufnum, buffer2.bufnum, \numChan, 2, \duration, duration, \rate, trans[i], \lev2, lev2 ]
			);
		}).play;
	});
};

~wavesStackerRoutFunc = {|wait=20|
	~waveTask = Task{
		30.do{|i|
			var fileNum;
			fileNum = i.fold(0, 16);

			~wavesStackerFunc.value(fileNum: fileNum, masterLev:masterLev, density:density);
			"serge wave: ".post; fileNum.postln;
			"occurrence ".post; (i+1).postln;
			wait.wait;
		};
	}.start
};
)

~wavesStackerFunc.value //individual event

~wavesStackerRoutFunc.value //task
~waveTask.stop //completes any current waves and then stops

