//there is a limit to the number of markers .readHeadsAsString can read (string length seems to max at .readHeaderAsString.size = 2047). split up single files with many markers into multiple files

(
var path;

fork{
	path = [
		"/Volumes/Projects/The Impermanent Sky/TIS Serge/Audio/061317 3 Sparse Filt.aif"
		, "/Volumes/Projects/The Impermanent Sky/TIS Serge/Audio/061317 3 Sparse Filt 2.aif"
	];

	~sfFile = Array.fill(path.size, {SoundFile.new});
	~sfFile.size.do{|i|~sfFile[i].openRead(path[i])};
	~sfBuf = Array.fill(path.size, {|i| Buffer.read(s, path[i])});
	~sfMarkers=Array.fill(path.size, {|i| ~sfFile[i].extractMarkersAiff2(0)});
	path.size.do{|i|~sfMarkers[i].postcs;~sfMarkers[i].size;};

	0.4.wait;

	SynthDef(\sparseFilts, {|out=0, bufnum=0, rate=1, startPos=0, panPos=0, level=0.5, masterLev=1, atk=0.01, sus=0.2, rel=0.01, send=16, sendLev=1, gate=1, loop=0|
		var in, env;
		/*	env = Env.asr(atk, 1, rel, -4);*/
		env = Env.new(#[0, 1, 1, 0], [atk, sus, rel]);
		in = HPF.ar(LPF.ar(PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, startPos:startPos, loop:loop, doneAction:2), 20000), 30);
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
}
)

//MAKE GUI W waitMult, masterLev, and on/off pad (use hold technique?)
(
var waitMult=1, masterLev=0;
var trigger, ml, density, mlMin=0, mlMult=3;

~sfPolyphony = 30;
~sfPolyphonyVars = Array.newClear(~sfPolyphony); //voice++i work?

~sfGroup = s.nextNodeID;
s.sendMsg(\g_new, ~sfGroup, 0, 0);

//press to trigger, release to stop:
trigger = OSCFunc.new({|msg|
	if(msg[1.value]==1)
	{~sfTask.start;}
	{
		//~sfPolyphony.do{|i| ~sfPolyphonyVars[i].stop};
		s.sendBundle(s.latency, [\n_set, ~gvGroup1, \rel, 0.01, \gate, 0]);
		//s.sendBundle(s.latency, [\g_freeAll, ~gvGroup1]);
		~gvList.clear;
	}
}, "/sfPad/x", nil, 57121);
ml = OSCFunc.new({|msg| masterLev=(msg[1].value.pow(2)+mlMin*mlMult) }, "/MasterLev/x", nil, 57121);
density = OSCFunc.new({|msg| waitMult=((msg[1].value.pow(2))*22)+1 }, "/Density/x", nil, 57121);

~sfTask = Task{
	~sfPolyphony.do{|v|
		~sfPolyphonyVars[v] = Task{
			inf.do{
				var node, marker, startPos;
				var file;

				file = [0, 1].wchoose([0, 0.7].normalizeSum);
				// file = rrand(0, ~sfBuf.size-1);
				marker = rrand(0, ~sfMarkers[file].size-1);
				startPos = ~sfMarkers[file][marker];

				( (rrand(0.35, 0.8)*2)*(waitMult.reciprocal) ).wait;
				/*				masterLev.postln;
				waitMult.postln;*/

				s.sendBundle(s.latency, [\s_new, \sparseFilts, -1, 0, ~sfGroup, \bufnum, ~sfBuf[file].bufnum, \rate, rrand(0.75, 1.25), \atk, 0.1, \level, rrand(0.05, 0.3), \sendLev, rrand(0.02, 1), \masterLev, masterLev,\startPos, startPos, \panPos, rrand(-1.0, 1.0)]);
			}
		}.start
	}
}
)

~sfTask.start;
~sfPolyphony.do{|i| ~sfPolyphonyVars[i].stop};