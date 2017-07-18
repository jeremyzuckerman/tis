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

~group = s.nextNodeID;
~xpGroup = s.nextNodeID;

//lemur GUI
// ~tisAddy = NetAddr.new("169.254.23.107", 8000); //when using JZ Adhoc network
//sends file names to lemur menu. size of menu automatically updates depending on size of file name items (array)
vmFilesBasename = Array.fill(~vmFiles.size, {|i| ~vmFiles[i].basename});
~tisAddy.sendBundle(nil, [\Menu, "@items"]++vmFilesBasename++["random"]);

menuOSC = OSCFunc.new({|msg, time, addr, revPort| listVal = msg[1]}, "/Menu/selection", nil, 57121);

//msg[1] is first breakpoint and msg[2] is next, etc
//can use point1 y value for masterLev

breakpointOSC = OSCFunc.new({|msg, time, addr, revPort|
	lemurAtk=msg[1]*(maxDur*2);
	lemurRel=(msg[2]*(maxDur*2)-lemurAtk)+0.05; //rel min = 0.05s
/*	"lemurAtk: ".post; lemurAtk.postln;
	"lemurRel: ".post; lemurRel.postln;*/
}, "/Breakpoint/x", nil, 57121);//print

breakpointXpOSC = OSCFunc.new({|msg, time, addr, revPort|
	lemurXpAtk=msg[1]*(maxDur*2);
	lemurXpRel=(msg[2]*(maxDur*2)-lemurXpAtk)+0.05; //rel min = 0.05s
//	"lemurXpAtk: ".post; lemurXpAtk.postln;
	//"lemurXpRel: ".post; lemurRel.postln;
}, "/Breakpoint2/x", nil, 57121);//print

//masterlev. only using data from
breakpointY_OSC = OSCFunc.new({|msg, time, addr, revPort| gestureLev = msg[1];
	// "masterLev: ".post; lemurMasterLev.postln;
}, "/Breakpoint/y", nil, 57121);//print

breakpointY_xpOSC = OSCFunc.new({|msg, time, addr, revPort| xpGestureLev = msg[1];
	// "masterLev: ".post; lemurXpMasterLev.postln;
}, "/Breakpoint2/y", nil, 57121);//print

lemurRelOSC = OSCFunc.new({|msg, time, addr, revPort| if (msg[1]==1){s.sendMsg(\n_set, ~group, \rel, lemurRel, \gate, 0); "Release 1".postln;}{nil} }, "/Release/x", nil, 57121);
lemurXpRelOSC = OSCFunc.new({|msg, time, addr, revPort| if (msg[1]==1){s.sendMsg(\n_set, ~xpGroup, \rel, lemurXpRel, \gate, 0); "Release 2".postln;}{nil} }, "/Release2/x", nil, 57121);

lemurMasterLevOSC = OSCFunc.new({|msg, time, addr, revPort|
	s.sendMsg(\n_set, ~group, \masterLev, lemurMasterLev=msg[1])}, "/MasterLevel1/x", nil, 57121);//.pow(2) to make fader output exponential
lemurXpMasterLevOSC = OSCFunc.new({|msg, time, addr, revPort|
	s.sendMsg(\n_set, ~xpGroup, \masterLev, lemurXpMasterLev=msg[1])}, "/MasterLevel2/x", nil, 57121);

densityPosts1 = ["(1)V.High", "(1)High", "(1)Med", "(1)Low"];
densityPosts2 = ["(2)V.High", "(2)High", "(2)Med", "(2)Low"];
pads = ["/Pads/x", "/Pads2/x", "/Pads3/x", "/Pads4/x"];
padsOSC = Array.fill(pads.size, {|i| OSCFunc.new({|msg, time, addr, revPort| if(msg[1]==1)
	{
		~voiceMass.value(i, gestureLev:gestureLev, masterLev: lemurMasterLev, atk:lemurAtk, rel:lemurRel, loop:1, group:~group);
		densityPosts1[i].postln;
	}
	{nil};
}, pads[i], nil, 57121);
});
xpPads = ["/Pads5/x", "/Pads6/x", "/Pads7/x", "/Pads8/x"];
xpPadsOSC = Array.fill(xpPads.size, {|i| OSCFunc.new({|msg, time, addr, revPort| if(msg[1]==1)
	{
		~voiceMass.value(i, gestureLev:xpGestureLev, masterLev:lemurXpMasterLev, atk:lemurXpAtk, rel:lemurXpRel, loop:1, group:~xpGroup, xpose:2);
		densityPosts2[i].postln;
	}
	{nil};
}, xpPads[i], nil, 57121);
});


~voiceMass = {|densSw=2, rateLo=0.495, rateHi=0.505, gestureLev=0.25, masterLev=0.1, dryLo=0.0, dryHi=1, sendLo=0.3, sendHi=0.9, gate=1, sendBus=16, panLo= -1.0, panHi=1.0, atk=30, rel=30, curve= -4, loop=0, xpose=1, group=5|

//	vmList = List.new;

	fork{
		var node, density;

		switch(densSw,
			0, {density = rrand(175, 220)}, //v.high density
			1, {density = rrand(100, 150)}, //high density
			2, {density = rrand(40, 60)}, //med density
			3, {density = rrand(5, 10)} //low density
		);

		s.sendMsg(\g_new, group, 0, 0); //create a group for the instrument

		density.do{|i|
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
			//0.001.wait;
	}}
}
)

//
~voiceMass.value(350, 0.495, 0.505, 0.1, atk:0.1, curve:4, spLo:~voiceMassMarkers[0], spHi:~voiceMassMarkers[~voiceMassMarkers.size-1], loop:1, group:5); //can assign instances to different groups
~voiceMass.value(25, 0.495, 0.505, 0.05, spLo:~voiceMassMarkers[0], spHi:~voiceMassMarkers[~voiceMassMarkers.size-1], loop:1, xpose:2, group:6); //can assign instances to different groups

~voiceMass.value(50, 0.495, 0.505, 0.3, spLo:~voiceMassMarkers[0], spHi:~voiceMassMarkers[~voiceMassMarkers.size-1], loop:1, group:5);
~voiceMass.value(10, 0.495, 0.505, 0.5, spLo:~voiceMassMarkers[0], spHi:~voiceMassMarkers[~voiceMassMarkers.size-1], loop:1, group:5);

s.sendMsg(\n_set, 5, \masterLev, 0.1, \mlLag, 0.1); //change masterLev of low voices
s.sendMsg(\n_set, 6, \masterLev, 0.025, \mlLag, 120); //change masterLev high voices
s.sendMsg(\n_set, ~group, \curve, -4, \rel, 0, \gate, 0);
s.sendBundle(s.latency, [\n_set, 5, \rel, 30, \gate, 0], [\n_set, 6, \rel, 30, \gate, 0])//fade both
s.sendMsg(\n_set, 5, \bufnum, ~voiceMassBuffer[4].bufnum); //change buffer