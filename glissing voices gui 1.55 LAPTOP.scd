//1.55 changed random file selection mode to choose  from only the first three files (not the whole list) and made several other changes
//1.54 fixed ghost nodes issue w PlayBuf doneAction:2
//1.53 made single shot function
//1.52 using group message to stop all and interrupt but still using List of nodes to end each seperately if not stopped or interrupted.
//1.5 added group. added overlap modes and stop all. added sustained envelope to elimate clicks when interrupting or stopping. added atk and rel times in GUI
//1.4 switched to working with serge. added ListView to manually choose sound file. ListView and its functionality automatically change size based on size of sound file array (r). discovered .basename.
//1.3 added density control
//1.2 implemented messaging style for increased efficiency. added a high pass filter. paired the reverb levels with the dynamics and panning.

//synthdefs and buffers (in tis synthdefs... file)

(
var flow, buttons, states;
var listView, listVal=0;
var stop, overlapModes, omVal=0, atkTimeBox, atk=0.03, relTimeBox;
var oscMl, lemurMl=1, lemurLpCut=20000, filterNode;

~gvRel=0.01;

// send to the Lemur: iPad IP address
// ~tisAddy = NetAddr.new("169.254.23.107", 8000); //when using JZ Adhoc network

~tisAddy.sendMsg("/GvLev/x", 0);
~tisAddy.sendMsg("/MasterLev/x", 0);
~tisAddy.sendMsg("/Density/x", 0);

s.sendMsg(\g_new, ~gvGroup1 = s.nextNodeID, 0, 0); //create a group for the instrument
~gvList = List.new; //scope!!!

s.sendMsg(\s_new, \filter, filterNode=s.nextNodeID, 1, ~gvGroup1); //filter at tail of group

// oscMl = OSCFunc.new({|msg| lemurMl=msg[1].value.pow(2); s.sendMsg(\n_set, ~gvGroup, \masterLev, lemurMl) }, "/GvLev/x", nil, 57121);
//oscMl = OSCFunc.new({|msg| lemurLpCut=(msg[1].value.pow(2)*20000)+20; s.sendBundle(s.latency, [\n_set, filterNode, \lpCut, lemurLpCut]) }, "/GvLev/x", nil, 57121);

//var ff, forte, mf, mp, piano, pp;

states = [
	"FF h.d.", "FF m.d.", "FF l.d.", "FF 1",
	"F h.d.", "F m.d.", "F l.d.", "F 1",
	"MF h.d.", "MF m.d.", "MF l.d.", "MF 1",
	"MP h.d.", "MP m.d.","MP l.d.", "MP 1",
	"P h.d.", "P m.d.", "P l.d.", "P 1",
	"PP h.d.", "PP m.d.", "PP l.d.", "PP 1"
];

w = Window("Glissing Voices", Rect(1000, 500, 560, 650));
w.view.decorator = flow = FlowLayout(w.view.bounds, 20@20, 40@5);
buttons = Array.fill(states.size, {|i| Button(w, Rect(0, 0, 100, 50)).states_([ [states[i], Color.black, Color.white] ]); });

//high density actions:
#[0,4,8,12,16,20].do{|i, e|
	buttons[i].action = {~f1.value(e, 0)};
};
//med density actions:
#[1,5,9,13,17,21].do{|i, e|
	buttons[i].action = {~f1.value(e, 1)}
};
//low density actions:
#[2,6,10,14,18,22].do{|i, e|
	buttons[i].action = {~f1.value(e, 2)}
};

//single shot actions:
#[3, 7, 11, 15, 19, 23].do{|i, e|
	buttons[i].action = {~f2.value(e)};
};

flow.nextLine;

overlapModes = ListView(w, 370@40).items_(["overlap", "INTERRUPT!"]).action_({|i| omVal=i.value});
flow.nextLine;

atkTimeBox = EZNumber(w, 150@20, "atk time", ControlSpec(0.01, 60*60, 'lin', 0.01), {|i| atk=i.value});
relTimeBox = EZNumber(w, 150@20, "rel time", ControlSpec(0.01, 60*60, 'lin', 0.01), {|i| ~gvRel=i.value});
flow.nextLine;

//chooses soundfile:
listView = ListView(w, 370@100)
.items_(Array.fill(~gvFiles.size+1, {|i| if(i<~gvFiles.size){~gvFiles[i].basename}{"random"}}) )
.action_({|i| listVal=i.value});

10.do{flow.nextLine};

stop = Button(w, Rect(0, 0, 370, 40)).states_([ ["STOP ALL", Color.black, Color.white] ]);
stop.action = {
	s.sendBundle(s.latency, [\n_set, ~gvGroup1, \atk, atk, \rel, ~gvRel, \gate, 0]);
	//s.sendBundle(s.latency+rel, [\g_freeAll, ~gvGroup1]);
~gvList.clear; //empty the list of nodes
}; //send values to all nodes in group 4
w.front;

CmdPeriod.add{w.close}; //close GUI on command+period

//function
/* ideas:
implement function with startPos at random marker points. use a button or listView to switch between the functions
*/

~f2 = {|dynamicSw=0|
	var pchOffset=1, voices=10, scale, markers, file, pchResolution=0.5, rate, masterLev=1;
	var soundFile, bufArr;
	var sendLev; //moved outside of the voices loop so it's global to each getsure instead of each voices
	var group, node;
	var level, panScale=1, panOffset=0, duration;
	var nodeID;

	if (omVal==0){nil}{
		s.sendBundle(s.latency, [\n_set, ~gvGroup1, \atk, atk, \rel, ~gvRel, \gate, 0]);
		//s.sendBundle(s.latency+~gvRel, [\g_freeAll, ~gvGroup1]);
	~gvList.clear; //empty the list of nodes
}; //release envelopes

//modes to control which soundfile is chosen (changes size automatically depending on ~gvFiles array size (# of soundfiles))
(~gvFiles.size+1).do{|i|
		if (listVal<~gvFiles.size){file=listVal}{file=rrand(2, 4)} //random only choose between the 3-5 files (compositional choice)
};

switch(dynamicSw,
	0, {masterLev = rrand(0.9, 1); sendLev = rrand(0.02, 0.4)}, //ff
	1, {masterLev = rrand(0.7, 0.9); sendLev = rrand(0.1, 0.4)}, //f
	2, {masterLev = rrand(0.5, 0.7); sendLev = rrand(0.2, 0.4)}, //mf
	3, {masterLev = rrand(0.2, 0.5); sendLev =  rrand(0.3, 0.7)}, //mp
	4, {masterLev = rrand(0.07, 0.15); sendLev = rrand(0.6, 0.8)}, //p
	5, {masterLev = rrand(0.05, 0.07); sendLev = rrand(0.8, 1.0)} //pp
);

//Print info:
~gvFiles[file].postln;
"amp: ".post; masterLev.postln;
"send: ".post; sendLev.postln;

soundFile = ~bufArr[file]; //randomly selects a buffer

// pchOffset = Array.fill(voices, {|i| i*pchResolution});
rate = rrand(-3.0, 0.0).midiratio; //scale the full gesture in semitones

level = rrand(0.05, 0.3)*3;
panScale = masterLev;
if (panScale<0.7){panOffset=rrand(0, 1)}{panOffset=0};
duration = soundFile.duration*(rate.reciprocal);

//MESSAGING STYLE:
s.sendBundle(s.latency, [\s_new, \pb_quad_wSends, node=s.nextNodeID, 0, ~gvGroup1, \bufnum, soundFile.bufnum, \rate, rate, \atk, atk, \rel, ~gvRel, \panPos, rrand(-1.0, 1.0)*panScale+panOffset, \level, level*masterLev*lemurMl, \sendLev, sendLev, \lpCut, 20000 /*lemurLpCut*/]);

/*		s.sendBundle(s.latency+duration, [\n_set, 4, \gate, 0]);*/ //this would end all in the group at the end of the shortest instance

//~gvList.add(node); //no longer necessary DT to PlayBuf doneAction
//s.sendBundle(s.latency+duration, [\n_set, node, \gate, 0]); //end each instance seperately. running into issue with nodes being already freed with the stop button and interrupt functions. using doneAction:2 in PlayBuf to free synths when Buffer finishes playing

};

~f1 = {|dynamicSw = 0, densSw = 0|
	var pchOffset=1, voices=10, scale, markers, file, pchResolution=0.5, rate, masterLev=1;
	var soundFile, bufArr;
	var sendLev; //moved outside of the voices loop so it's global to each getsure instead of each voices
	var group, node;

	fork{
		//overlap vs interrupt
		if (omVal==0){nil}{
			s.sendBundle(s.latency, [\n_set, ~gvGroup1, \atk, atk, \rel, ~gvRel, \gate, 0]);
			//s.sendBundle(s.latency+~gvRel, [\g_freeAll, ~gvGroup1]);
		~gvList.clear; //empty the list of nodes
	}; //release envelopes

	//modes to control which soundfile is chosen (changes size automatically depending on ~gvFiles array size (# of soundfiles))
	(~gvFiles.size+1).do{|i|
		if (listVal<~gvFiles.size){file=listVal}{file=rrand(2, 4)} //random only choose between the 3-5 files (compositional choice)
	};

	// voices = rrand(10, 100);
	pchResolution = rrand(0.02, 0.1); //1 = 100 cents, 0.5 = 50 cents, etc

	switch(dynamicSw,
		0, {masterLev = rrand(0.9, 1); sendLev = rrand(0.02, 0.4)}, //ff
		1, {masterLev = rrand(0.7, 0.9); sendLev = rrand(0.1, 0.4)}, //f
		2, {masterLev = rrand(0.5, 0.7); sendLev = rrand(0.2, 0.4)}, //mf
		3, {masterLev = rrand(0.2, 0.5); sendLev =  rrand(0.3, 0.7)}, //mp
		4, {masterLev = rrand(0.07, 0.15); sendLev = rrand(0.6, 0.8)}, //p
		5, {masterLev = rrand(0.05, 0.07); sendLev = rrand(0.8, 1.0)} //pp
	);

	//density divided into ranges:
	switch(densSw,
		0, {voices = rrand(75, 100)}, //high density
		1, {voices = rrand(30, 70)}, //medium density
		2, {voices = rrand(15, 25)} //low density
	);

	//Print info:
	~gvFiles[file].postln;
	"num Voices: ".post; voices.postln;
	"amp: ".post; masterLev.postln;
	"send: ".post; sendLev.postln;

	soundFile = ~bufArr[file]; //randomly selects a buffer

	pchOffset = Array.fill(voices, {|i| i*pchResolution});
	rate = pchOffset+rrand(-3.0, 0.0); //scale the full gesture in semitones

	//group = Group.new;

	// s.sendMsg(\g_new, 4, 0, 0); //create a group for the instrument

	voices.do{|i|
		var level, panScale=1, panOffset=0, duration;
		var nodeID;

		level = rrand(0.05, 0.3);
		panScale = masterLev;
		if (panScale<0.7){panOffset=rrand(0, 1)}{panOffset=0};
		duration = soundFile.duration*(rate[i].midiratio.reciprocal);

		//MESSAGING STYLE:
		s.sendBundle(s.latency, [\s_new, \pb_quad_wSends, node=s.nextNodeID, 0, ~gvGroup1, \bufnum, soundFile.bufnum, \rate, rate[i].midiratio, \atk, atk, \rel, ~gvRel, \panPos, rrand(-1.0, 1.0)*panScale+panOffset, \level, level*masterLev*lemurMl, \sendLev, sendLev, \lpCut, 20000 /*lemurLpCut*/]);

		/*		s.sendBundle(s.latency+duration, [\n_set, 4, \gate, 0]);*/ //this would end all in the group at the end of the shortest instance

		//~gvList.add(node); //no longer necessary DT to PlayBuf doneAction
		//s.sendBundle(s.latency+duration, [\n_set, node, \gate, 0]); //end each instance seperately. running into issue with nodes being already freed with the stop button and interrupt functions. using doneAction:2 in PlayBuf to free synths when Buffer finishes playing

		0.001.wait;
}}
}
)
