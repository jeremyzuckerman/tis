//4 channels RS, LS, L, R (2, 3, 0, 1)
(
{
	var pb;
	pb = PlayBuf.ar(1, ~bufArr[3].bufnum, BufRateScale.kr(~bufArr[3].bufnum));

	Out.ar(0,
		DelayN.ar(
			PitchShift.ar(pb, 0.2, 0.5, mul:1.5)+(pb*1)
			, 0.2
			, [0.2,0.3,0,0.1]
			, 1
		)
	)
}.play
)

(
//edit file so it loops perfectly!!
//lemur: start/stop, lev, hpCut
SynthDef(\spinningSerge, {|out=0, bufnum=0, atk=0.1, rel=0.1, lev=0, gate=0, hpCut=5000|
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
		EnvGen.kr(Env.asr(atk, lev, rel, [4, -4]), gate, doneAction:2)
	)
}).send(s);
)

x = Synth.new(\spinningSerge, [\lev,1, \gate, 1]);
x.set(\hpCut, 25)
x.free

s.sendMsg(\s_new, \spinningSerge, ~ssNode=s.nextNodeID, 0, ~group, \gate, 1, \lev, 1)
~ssNode.free

s = Server.default
