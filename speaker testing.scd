(
SynthDef(\sine, {|out=0|
	Out.ar(out,
		PinkNoise.ar(0.1)
	)
}).send(s);
)

x = Synth(\sine)
x.set(\out,2)
x.free
