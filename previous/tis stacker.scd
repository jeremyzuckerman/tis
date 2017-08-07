
/* 09.01.05 	- changed to osc style for better timing accuracy
- fixed click at end of sample (was looping around and playing a tiny portion of the beginning.  forgot to subtract the atk and rel from the sustain)
*/
// assign server
s.boot;
s = Server.local;

/*(
CocoaDialog.getPaths({ arg paths;
paths.do({ arg p;
f = SoundFile.new;
f.openRead(p);
~numChan = f.numChannels;
b = Buffer.read(s, p);
});
});
)*/

Server.default.makeGui;

(
~wavesMonophonic = [
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 01.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 02.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 03.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 04.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 05.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 06.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 07.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 08.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 09.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 11.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 12.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 13.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 14.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 15.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 16.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 17.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x_Marker 18.aiff"
];

~wavesPolyphonic = [
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 01.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 02.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 03.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 04.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 05.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 06.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 07.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 08.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 09.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 10.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 11.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 12.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 13.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 14.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 15.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 16.aiff",
	"/Volumes/Projects/The Impermanent Sky/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x_Marker 17.aiff"
];

~wavesMPBuffers = ~wavesMonophonic.collect{|i|
	Buffer.read(s, i)
};

~wavesPPBuffers = ~wavesPolyphonic.collect{|i|
	Buffer.read(s, i)
};

/*f = SoundFile.new;
f.openRead(p);
~numChan = f.numChannels;
b = Buffer.read(s, p);*/
)

//load synthdef
(
/*var buffer;
~fileNum = 0;
buffer = ~buffers[~fileNum];*/

SynthDef("stacker", { |numChan=2, duration=1, out=0, bufnum=0, rate=1, gate=1.0, lev=1, pos=0, loop=0|
	var amp, in, pbuf;
	var atk=0.001, rel=0.001;
	amp = lev;
	//pbuf = PlayBuf.ar(numChan, bufnum, BufRateScale.kr(bufnum)*rate, loop:1);
	//if (numChan==1, {in = Pan2.ar(pbuf, pos)}, {in = pbuf*lev});
	if (numChan==1)
	{
		in = Pan2.ar(
			PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, loop:1)
			, pos)}
	{
		in = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum)*rate, loop:loop)
	};
	Out.ar(0, in*EnvGen.kr(Env.linen(atk, (duration*(rate.reciprocal))-(atk+rel+0.1), rel), levelScale:lev, doneAction:2)
	);
}).send(s);

SynthDef(\wavesStacker, {|out=0, bufnum1=0, bufnum2=1, rate=1, lev1=1, lev2=1, send=16, sendLev=0, gate=1, startPos1=0, startPos2=0, duration=14.5, masterLev=1|

	var in1, in2, xfade, env1, pan1, pan2, pos;
	var duration2, output;
	var lpc;
	var in1Env, in2Env, outEnv;
	var scaledDur;

	scaledDur = duration*(rate.reciprocal);

	outEnv = EnvGen.kr(Env.new(#[0, 1, 1, 0], [0.01, scaledDur-0.02, 0.01]), doneAction:2);
	//outEnv = EnvGen.kr(Env.linen(atk, scaleDur-(atk+rel+0.1), rel), levelScale:lev, doneAction:2);

	in1Env = EnvGen.kr(Env.new(#[0, 1, 1, 0], #[0.4, 0.2, 0.4], #[-2, 1, 2]), gate, timeScale: scaledDur);
	in2Env = EnvGen.kr(Env.new(#[0, 1, 1, 0], #[0.4, 0.2, 0.4], #[2, 1, 2]), gate, timeScale: scaledDur);

	in1 = PlayBuf.ar(2, bufnum1, BufRateScale.kr(bufnum1)*rate, startPos: startPos1)
	*in1Env;

	in2 = PlayBuf.ar(2, bufnum2, BufRateScale.kr(bufnum2)*rate, startPos: startPos2)
	*
	in2Env;

	pos = EnvGen.kr(Env.new(#[0, 0.25, 0.25, 0.5], #[0.4, 0.2, 0.4], #[-1.5, 1, -4]), gate, timeScale:scaledDur); //pan line

	pan1 = PanAz.ar(4, in1[0]+in2[0], -0.25-pos, lev1);
	pan2 = PanAz.ar(4, in1[1]+in2[1], 0.25+pos, lev2);

	lpc = EnvGen.kr(Env.new(#[8000, 20000, 20000, 8000], #[0.4, 0.2, 0.4], #[1, 1, 1]), gate, timeScale:scaledDur);

	output = LPF.ar(pan1+pan2, lpc)*outEnv*masterLev;

	Out.ar(out, output);
	Out.ar(send, output*sendLev);
}).send(s);
)

//execute
(
var lev, panpos, grpID, arr;
var buffer1, buffer2, fileNum=0;
var duration;

buffer1 = ~wavesMPBuffers[fileNum];
buffer2 = ~wavesPPBuffers[fileNum];
duration = buffer1.duration;

//make group at head
s.sendMsg("/g_new", grpID=s.nextNodeID, 0, 0);
//g = Group.new; /* create the group before recording */
//~peak = 6.942; //SmallBells
//~peak = 13.088; //SmallCym2

~peak = 5.0; //SergeWaves1_Brassage_...



//~trans = #[0.05, 0.05001, 0.055, 0.06, 0.076, 0.086, 0.091, 0.1, 0.15, 0.2, 0.25, 0.35, 0.46, 0.5, 0.75, 0.8, 1, 1.2, 1.28, 1.5]; //Vc_bodyHit3_Stk3

//~trans = #[0.25, 0.28, 0.285, 0.35, 0.40, 0.45, 0.49, 0.5, 0.75, 0.87, 1.0, 1.12, 1.25, 1.5, 1.8, 2.0]; // the transposition values
//~trans = #[0.8, 0.804, 0.81, 0.823, 0.8256, 0.84, 0.845, 0.8578, 0.877, 0.89, 0.909, 0.912, 0.914, 0.934, 0.945, 0.956, 1.0];

//~trans = #[0.25, 0.5, 0.68, 1.0, 2.0]; //Vc_bodyHit3_Stk2

//~trans = #[0.25, 0.45, 0.5];
//~trans = #[0.5, 0.75, 1.0, 1.5, 2.0, 2.5];
//~trans = #[1.0, 2.0, 2.5, 3.0];
//~trans = #[0.5, 0.75, 1.0];
//~trans = #[0.46, 0.5, 0.75, 0.8, 1, 1.2, 1.28, 1.5]; //transpostion value
//~trans = #[0.20, 0.26, 0.265, 0.29, 0.35, 0.41, 0.45, 0.485, 0.5, 0.75, 0.87, 1.05, 1.12, 1.3, 1.55, 1.82, 2.0]
//*
//Array.fill(17, {rrand(0.9, 1.1)}); // Vc_bodyHit3_Stk1, celestaImp8va

//~trans = Array.fill(5, {rrand(0.8, 1.4)})++Array.fill(4, {rrand(0.5, 0.8)}); //pnostakhit

//~trans = #[0.6, 0.75, 0.9, 0.95, 0.97, 1.0, 1.35, 2.0]; //cymStackerSmall


//~trans = Array.fill(10, {rrand(0.6, 2)});	//(HUGE!!!!!!!!) Vc_bodyHit3_Stk4,5,6


//~trans = Array.fill(100, {rrand(1, 1.2)});
//~pan = Pseq(#[0, -0.7, 0.7, -1, 1], inf).asStream;
//~pan = Array.fill(100, {rrand( -1.0, 1.00)} );
////~trans = #[0.7, 0.874, 1];

//~trans = Array.fill(10, {rrand(0.49, 5.1)})++Array.fill(10, {rrand(0.9, 1.1)});
//arr = #[1, 1.07143, 1.11111, 1.2, 1.25, 1.33333, 1.42857, 1.5, 1.66667, 1.57895, 1.71429, 1.875];
//~trans = Array.fill(18, {|i| Array.fill(5, {arr[rrand(0, 11)]*rrand(0.99, 1.01)}) }).flatten*3;
//~trans = ~trans*(0.8);
//tibetBellwETVERB_STAKD
//~trans = Array.fill(10, {rrand(0.49, 0.5)})++Array.fill(10, {rrand(0.95, 1.0)});
//~trans = #[0.8, 1, 1.2, 1.28, 1.5, 1.9, 2.78, 3.15]; //transpostion value
//~trans = Array.fill(5, {rrand(0.4, 0.6)});
//~trans = #[0.3, 0.38, 0.43, 0.55, 0.62, 0.75, 0.89, 1.0];
//~trans = Array.fill(5, {|i| ((i+1)*0.5)}); //SmallBells_Stacker1
//~trans = #[0.20, 0.26, 0.265, 0.29, 0.35, 0.41, 0.45, 0.485, 0.5, 0.75, 0.87, 1.05, 1.12, 1.3, 1.55, 1.82, 2.0]; //SmallBells_Stacker2, SmallCym2_Stacker1
//~trans = Array.fill(50, {rrand(0.2, 2)});	//(HUGE!!!!!!!!)SmallBells_Stacker3

//~trans = #[0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];
~trans = Array.fill(10, {rrand(0.2, 1.0)});
~trans.postcs;

~out = ~trans.size.do({ arg i;
	Routine({
		var os;
		var file=0;
		var lev1=0.8;
		var lev2=0.8;

		panpos = rrand(-1.0, 1.0); // spatial postion
		os = ~trans.minItem.reciprocal-(~trans[i].reciprocal)*~peak; //calculates offsets
		os.wait;
		//os.postln; /* view offset times */
		s.sendBundle(0.1
			, ["/s_new", \wavesStacker, -1, 0, grpID, \bufnum, buffer1.bufnum, \numChan, 2, \duration, duration, \rate, ~trans[i], \lev1, lev1 ]
			, ["/s_new", \wavesStacker, -1, 0, grpID, \bufnum, buffer2.bufnum, \numChan, 2, \duration, duration, \rate, ~trans[i], \lev2, lev2 ]
		);
	}).play;
});
)

//stop recording
s.stopRecording;
s.freeAll;

s.makeGui