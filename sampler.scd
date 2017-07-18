/*
playback back control
TIS 061317 3 Rnd Hi Freq Sparse F GV 1
TIS 0613171 Rnd FM 1-R,L GV 1
061417 1 Mod Waves-R GV 1 F h.d.
*/
(
SynthDef(\sampler, {|outBus=0, bufnum=0, lev=1, lpc=20000, atk=0.01, sus=1, rel=0.01, curve=4, gate=1|
	var in, filt, out, quad;
	in = PlayBuf.ar(6, bufnum, 1, startPos:0, loop:0, doneAction:2);
	quad = [in[0], in[1], in[5], in[4]]; //convert from cubase 5.1 layout to SC quad (L,R,Rs,Ls)
	filt = LPF.ar(quad, [lpc+0.1, lpc+0.1, 20000, 20000], lev); //only filters the front channels
	out = filt
	*
	EnvGen.kr(Env.asr(atk, sus, rel, curve), gate, doneAction:2);
	Out.ar(0, out)
}).send(s);

~samplerFiles = [
	"/Volumes/Projects/The Impermanent Sky/tis/soundfiles for SC/TIS 061317 3 Rnd Hi Freq Sparse F GV 1 ed.wav"
	, "/Volumes/Projects/The Impermanent Sky/tis/soundfiles for SC/TIS 061317 1 Rnd FM 1-R,L GV 1 ed.wav"
	, "/Volumes/Projects/The Impermanent Sky/tis/soundfiles for SC/061417 1 Mod Waves-R GV 1 F h.d. ed.wav"
];

~sergeMass = "/Volumes/Projects/The Impermanent Sky/tis/soundfiles for SC/descending_masses_serge quad.wav";

~samplerDurs = Array.newClear(~samplerFiles.size+1);
~samplerBufs = Array.fill(~samplerFiles.size, {|i| var buf; buf = Buffer.read(
	s
	, ~samplerFiles[i]
	//on loading completion:
	, action: {
		~samplerDurs.put(i, buf.duration);
		~samplerDurs[i].postln;
	}
)
})++[ Buffer.read(s, ~sergeMass, action: {|buf|
	~samplerDurs.put(~samplerDurs.size-1, buf.duration);
	~samplerDurs.last.postln;
})
]
)

(
var window, flow, samplerButton, threeDBut, particleWaves, names, killBut, threeDSlider, threeDFiltSlider, rollsSlider, levs, lpcs, sergeButton;

s.sendMsg(\g_new, ~samplerGroup=s.nextNodeID, 1, 0);

window = Window("Glissing Voices", 500@500);
window.view.decorator = flow = FlowLayout(window.view.bounds, 20@20, 40@5);
/*samplerButton = Button(window, 200@50)
        .states_([
	            ["Hieroglyphic Pose", Color.white, Color.blue],
	            ["Into 3D", Color.white, Color.black],
	            ["Slow Rolls", Color.red, Color.white],
	            ["STOP", Color.white, Color.red],
        ])
        .action_({|view|
	            switch(view.value,
		1, {
			s.sendBundle(s.latency, [\s_new, \sampler, ~hiero=s.nextNodeID, 0, ~samplerGroup, \bufnum, ~samplerBufs[0].bufnum])
			//"hiero".postln;
		}
		, 2,  {
			s.sendBundle(s.latency, [\s_new, \sampler, ~threeD=s.nextNodeID, 0, ~samplerGroup, \bufnum, ~samplerBufs[1].bufnum])
			//"3 D".postln;
		}
		, 3,  {
			s.sendBundle(s.latency, [\s_new, \sampler, ~slowRolls=s.nextNodeID, 0, ~samplerGroup, \bufnum, ~samplerBufs[2].bufnum])
			//"waves".postln;
		}
		, 0, {
			s.sendBundle(s.latency, [\n_set, ~samplerGroup, \gate, 0])
		}
	)
        });*/
names = ["Hieroglyphic Pose", "Into 3D", "Slow Rolls"];
levs = #[1, 0, 0];
lpcs = #[20000, 300, 20000];
~samplerNodes = Array.fill(~samplerFiles.size, {s.nextNodeID});
samplerButton = Array.fill(~samplerFiles.size, {|i| Button(window, 200@50).states_([ [names[i], Color.white, Color.blue] ]) });
//actions:
~samplerFiles.size.do{|i|
	samplerButton[i].action = {
		s.sendBundle(s.latency, [\s_new, \sampler, ~samplerNodes[i], 0, ~samplerGroup, \bufnum, ~samplerBufs[i].bufnum, \lev, levs[i], \lpc, lpcs[i]]);
		names[i].postln;
		};
};
killBut = Button(window, 200@50).states_([ ["STOP", Color.white, Color.red] ]);
killBut.action = {
	s.sendBundle(s.latency, [\n_set, ~samplerGroup, \gate, 0])
};

flow.nextLine;
threeDSlider = EZSlider(window, 500@30, "3D Lev", ControlSpec(0.001, 1, \exp, step:0.001, default:0.001),
	{|val| s.sendBundle(s.latency, [\n_set, ~samplerNodes[1], \lev, val.value]) }
);
flow.nextLine;
threeDFiltSlider = EZSlider(window, 500@30, "3D Lowpass", ControlSpec(20, 20000, \exp, 1, 300, "hz"),
	{|val| s.sendBundle(s.latency, [\n_set, ~samplerNodes[1], \lpc, val.value]) }
);
flow.nextLine;
rollsSlider = EZSlider(window, 500@30, "Particle Waves Lev", ControlSpec(0, 1, step:0.001, default:0),
	{|val| s.sendBundle(s.latency, [\n_set, ~samplerNodes[2], \lev, val.value]) }
);
flow.nextLine;
flow.nextLine;
sergeButton = Button(window,200@50).states_([ ["Serge Mass ON", Color.black, Color.white], ["Serge Mass OFF", Color.white, Color.red] ]);
sergeButton.action = { |val| if (val.value==1) {s.sendBundle(s.latency, [\s_new, \sampler, ~sergeNode = s.nextNodeID, 0, 0, \bufnum, ~samplerBufs.last.bufnum, \lev, 1]) }{s.sendBundle(s.latency, [\n_set, ~sergeNode, \gate, 0])} };

window.front;

CmdPeriod.add({window.close})
)
