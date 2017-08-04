(
SynthDef(\bleeps, {|out=0, car=1000, modulator=1100, pmIndex=0.1, modPhase=0, lev=0.1, send=16, sendLev=0, hpc=20, pimRate=6, atk=0.1, rel=0.1, gate=1, pos=0, ppOffset=0, ppoLag=0|
	var pmIndexMod;
	var maxPI=1.75, minPI=1.25;
	var posOffset, in;
	var modulatorMod;

	posOffset = Lag2.kr(ppOffset, ppoLag);
	pmIndexMod = LFPulse.kr(pimRate, 0, LFNoise2.kr(0.1).range(0.01, 1), maxPI, minPI);

	modulatorMod = LFNoise2.kr(0.1).range(0, 100);

	in = 	HPF.ar(
		PMOsc.ar(Lag.kr(car, 0.1), Lag.kr(modulator+modulatorMod, 0.1), (pmIndex+pmIndexMod)*pi, modPhase, lev)/*!2*/
		, hpc);

	Out.ar(0
		, PanAz.ar(4, in, pos+posOffset)
		*
		EnvGen.kr(Env.asr(atk, 1, rel, [4, -4]), gate, doneAction:2)
	)
		//slow AM mod on sendLev?
}).send(s);
)

x = Synth(\bleeps)
x.free

(
MIDIClient.init; //initialize
MIDIIn.connectAll; //connects to all available devices

~bleepPchs = [73, 71, 69, 67, 66, 64, 59].reverse-0.3; //low to high

MIDIdef.cc(\testing, {|val, cc|
	switch(cc
		, 63, {
			var index;
			/*			~carFreq = ((val/127).pow(2))*19980+20; //20 to 20000. exp
			x.set(\car, ~carFreq);*/
			index = ((val/127)*(~bleepPchs.size-1)).asInteger;
			~carFreq = ~bleepPchs[index];

			x.set(\car, ~carFreq.midicps);

			"carFreq: ".post; ~carFreq.postln;
		}
		, 64, {
			~modFreq = ((val/127).pow(2))*19980+20; //20 to 20000. exp
			x.set(\modulator, ~modFreq);

			"modFreq: ".post; ~modFreq.postln;
		}
		, 65, {
			~pmIndex = (val/127); //this good range?
			x.set(\pmIndex, ~pmIndex);

			"pmIndex: ".post; ~pmIndex.postln;
		}
		, 66, {
			~modPhase = (val/127)*pi; //this good range?
			x.set(\modPhase, ~modPhase);

			"modPhase: ".post; ~modPhase.postln;
		}
		, 67, {
			~lev = (val/127).pow(2);
			x.set(\lev, ~lev);

			"lev: ".post; ~lev.postln;
		}
		, 68, {
			~hpc = ((val/127).pow(2))*19980+20; //20 to 20000. exp
			x.set(\hpc, ~hpc);
			"hpc: ".post; ~hpc.postln;
		}
		, 69, {
			~pimRate = (val/127)*15+1;
			x.set(\pimRate, ~pimRate);

			"pimRate: ".post; ~pimRate.postln;
		}
		, 70, {
			~pos = (val/127)*2-1;
			x.set(\pos, ~pos);

			"pos: ".post; ~pos.postln;
		}
		, 71, {
			if (val==127){
				"".postln;
				"carFreq: ".post; ~carFreq.postln;
				"modFreq: ".post; ~modFreq.postln;
				"pmIndex: ".post; ~pmIndex.postln;
				"modPhase: ".post; ~modPhase.postln;
				"lev: ".post; ~lev.postln;
				"hpc: ".post; ~hpc.postln;
				"pimRate: ".post; ~pimRate.postln;
				"pos: ".post; ~pos.postln;
				"".postln;
			}
			{nil}
		}
		, 72, {
			if (val==127){
				x = Synth(\bleeps);
				x.set(\car, ~carFreq, \modulator, ~modFreq, \pmIndex, ~pmIndex, \modPhase, ~modPhase, \lev, ~lev, \hpc, ~hpc);
			}
			{
				x.free
			}
		}
	)
});
)

/*
hooks for bleeps (keep it subtle and simple. don't destroy the deep time)
- pmIndex (controls all 4?)
- level
- fade out? (\rel, 60, \gate, 0)?
- trigger for each of the 4?
*/

/*
pimrate
14.3
13.0
10.5
7.5
*/



