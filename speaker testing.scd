(
SynthDef(\pinkNoise, {|out=0|
	Out.ar(out,
		PinkNoise.ar(0.1)
	)
}).send(s);
)

x = Synth(\pinkNoise)
x.set ( \out, 2 ) //use SPL to mute L,R,LS,RS to test sub. can't send audio only to it with current setup

x.free
