(
SynthDef(\pinkNoise, {|out=0|
	Out.ar(out,
		PinkNoise.ar(0.1)
	)
}).send(s);
)

x = Synth(\pinkNoise);

(
fork{
	4.do{|i|
		x.set ( \out, i); //use SPL to mute L,R,LS,RS to test sub. can't send audio only to it with current setup
		2.wait;
		i.postln;
	}
};
)

x.free
