/*
playback back control
TIS 061317 3 Rnd Hi Freq Sparse F GV 1
TIS 0613171 Rnd FM 1-R,L GV 1
061417 1 Mod Waves-R GV 1 F h.d.
*/
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
