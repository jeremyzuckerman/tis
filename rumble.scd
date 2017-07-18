(
SynthDef(\lowRumble, {|pch=30, cf=30, cfLag=0.1, amp=0.2, gate=1|
	var in;
	in = RLPF.ar(Saw.ar(Array.fill(4, {pch*rrand(0.99, 1.01)}), 1), Lag.kr(cf, cfLag), 0.5)
	*
	EnvGen.kr(Env.asr(0.01, amp, 0.01), gate, doneAction:2)
}).send(s);
)

x = Synth(\lowRumble);