//random mode <3
//to do: make default GUI function that either 1) sends OSC to lemur GUI or 2) is built into the lemur GUI
(
//set default values in SC and Lemur!!! make button in Lemur which resest to defaults
var vmWindow, compView1, compView2, vmFlow, compFlow1, compFlow2, listVal=0, states, densButtons, xposeButtons, densActions, xposeActions;
var vmFileList, vmList, vmFilesBasename;
var menuOSC, padsOSC, xpPadsOSC, pads, xpPads;
var lemurAtk=30, lemurRel=30, lemurMasterLev=0.5, maxDur=120, breakpointOSC, lemurMasterLevOSC, lemurRelOSC;
var lemurXpAtk=30, lemurXpRel=30, lemurXpMasterLev=0.5, breakpointXpOSC, lemurXpMasterLevOSC, lemurXpRelOSC;
var breakpointY_OSC, breakpointY_xpOSC;
var gestureLev=0.25, xpGestureLev=0.25;
var densityPosts1, densityPosts2;

"voice mass".postln;

//moved to 'groups, globals
/*s.sendMsg(\g_new, ~group=s.nextNodeID, 0, 0); //very first group (voiceMass)
s.sendMsg(\g_new, ~xpGroup=s.nextNodeID, 3, ~group);*/

//////////////////
//VOICE MASS MIDI (move to 'synthdefs, func...' file???
//menuOSC = OSCFunc.new({|msg, time, addr, revPort| listVal = msg[1]}, "/Menu/selection", nil, 57121);
//ccs 0-3: breakpoint1

MIDIdef.cc(\breakpoint1, {|vel, nn, chan, src|
	switch(nn
		, 0, {lemurAtk = (vel/127)*(maxDur*2)}
		, 1, {lemurRel = ((vel/127)*(maxDur*2)-lemurAtk)+0.05}
		, 2, {gestureLev = (vel/127)}
		, 3, {nil}
	)
});

//ccs 4-7
MIDIdef.cc(\breakpointXp, {|vel, nn|
	switch(nn
		, 4, {lemurXpAtk=(vel/127)*(maxDur*2)} //point1 x
		, 5, {lemurXpRel=((vel/127)*(maxDur*2)-lemurXpAtk)+0.05} //point2 x
		, 6, {xpGestureLev=(vel/127)}
		, 7, {nil}
	)
});

//notes 0-1
MIDIdef.noteOn(\releases, {|vel, nn, chan, src|
	switch(nn
		, 0, {s.sendMsg(\n_set, ~group, \rel, lemurRel, \gate, 0); "Release 1".postln}
		, 1, {s.sendMsg(\n_set, ~xpGroup, \rel, lemurXpRel, \gate, 0); "Release 2".postln}
	)
});

//ccs 8-9
MIDIdef.cc(\masterLevs, {|vel, nn|
	switch(nn
		, 8, {s.sendMsg(\n_set, ~group, \masterLev, lemurMasterLev=(vel/127))}
		, 9, {s.sendMsg(\n_set, ~xpGroup, \masterLev, lemurXpMasterLev=(vel/127))}
	)
});

densityPosts1 = ["(1)V.High", "(1)High", "(1)Med", "(1)Low"];
densityPosts2 = ["(2)V.High", "(2)High", "(2)Med", "(2)Low"];
pads = ["/Pads/x", "/Pads2/x", "/Pads3/x", "/Pads4/x"];
xpPads = ["/Pads5/x", "/Pads6/x", "/Pads7/x", "/Pads8/x"];

//notes 2-5
MIDIdef.noteOn(\pads, {|vel, nn|
	switch(nn
		, 2, {
			~voiceMass.value(0, gestureLev:gestureLev, masterLev: lemurMasterLev, atk:lemurAtk, rel:lemurRel, loop:1, group:~group);
			densityPosts1[0].postln;
		}
		, 3, {
			~voiceMass.value(1, gestureLev:gestureLev, masterLev: lemurMasterLev, atk:lemurAtk, rel:lemurRel, loop:1, group:~group);
			densityPosts1[1].postln;
		}
		, 4, {
			~voiceMass.value(2, gestureLev:gestureLev, masterLev: lemurMasterLev, atk:lemurAtk, rel:lemurRel, loop:1, group:~group);
			densityPosts1[2].postln;
		}
		, 5, {
			~voiceMass.value(3, gestureLev:gestureLev, masterLev: lemurMasterLev, atk:lemurAtk, rel:lemurRel, loop:1, group:~group);
			densityPosts1[3].postln;
		}
	)
});

//notes 6-9
MIDIdef.noteOn(\xpPads, {|vel, nn|
	switch(nn
		, 6, {
			~voiceMass.value(0, gestureLev:xpGestureLev, masterLev:lemurXpMasterLev, atk:lemurXpAtk, rel:lemurXpRel, loop:1, group:~xpGroup, xpose:2);
			densityPosts2[0].postln;
		}
		, 7, {
			~voiceMass.value(1, gestureLev:xpGestureLev, masterLev:lemurXpMasterLev, atk:lemurXpAtk, rel:lemurXpRel, loop:1, group:~xpGroup, xpose:2);
			densityPosts2[1].postln;
		}
		, 8, {
			~voiceMass.value(2, gestureLev:xpGestureLev, masterLev:lemurXpMasterLev, atk:lemurXpAtk, rel:lemurXpRel, loop:1, group:~xpGroup, xpose:2);
			densityPosts2[2].postln;
		}
		, 9, {
			~voiceMass.value(3, gestureLev:xpGestureLev, masterLev:lemurXpMasterLev, atk:lemurXpAtk, rel:lemurXpRel, loop:1, group:~xpGroup, xpose:2);
			densityPosts2[3].postln;
		}
	)
});

~voiceMass = {|densSw=2, rateLo=0.495, rateHi=0.505, gestureLev=0.25, masterLev=0.1, dryLo=0.0, dryHi=1, sendLo=0.3, sendHi=0.9, gate=1, sendBus=16, panLo= -1.0, panHi=1.0, atk=30, rel=30, curve= -4, loop=0, xpose=1, group=5|

//	vmList = List.new;

	fork{
		var node, density;

		switch(densSw,
			0, {density = rrand(100, 150)}, //v.high density
			1, {density = rrand(60, 90)}, //high density
			2, {density = rrand(40, 50)}, //med density
			3, {density = rrand(5, 10)} //low density
		);

		//s.sendMsg(\g_new, group, 0, 0); //create a group for the instrument

		density.do{|i|
			if (s.peakCPU<90){
			var duration, rateVal, file, spLo, spHi, startPos;
			rateVal = rrand(rateLo, rateHi)*xpose;
			if (listVal==~voiceMassBuffer.size){file=rrand(0, listVal-1).asInteger}{file=listVal};
			duration = ~voiceMassBuffer[file].duration*(rateVal.reciprocal);
			spLo = ~voiceMassMarkers[file][0];
			spHi = ~voiceMassMarkers[file][~voiceMassMarkers[file].size-1];
			startPos = rrand(spLo, spHi);

			//info:
			//startPos.postln/; //
			//(~vmFiles[file].basename).postln; //post soundfile name

			s.sendBundle(s.latency, [\s_new, \pb_voiceMass, node=s.nextNodeID, 0, group, \bufnum, ~voiceMassBuffer[file].bufnum, \rate, rateVal, \startPos, startPos, \panPos, rrand(panLo, panHi), \gestureLev, gestureLev, \masterLev, masterLev, \dryLev, rrand(dryLo, dryHi), \sendLev, rrand(sendLo, sendHi), \send, sendBus, \atk, atk, \rel, rel, \curve, curve, \loop, loop]);

			//	s.sendBundle(s.latency+duration, [\n_set, node, \gate, 0]); //kill automatically
			//vmList.add(node);
			0.01.wait; //does this help lighten the load on the interpreter?
			}{"CPU TOO HIGH".postln};
	}}
}
)