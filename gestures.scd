(
var sfs;
var markerDur, marker, nextMarker, lastMarker;
var fileDurSamples, markersFunc;

fork{
	~gestureFiles = [
		"/Volumes/Projects/The Impermanent Sky/TIS Serge/Audio/061317 1 Rand FM 1_ma_1.aif",
		"/Volumes/Projects/The Impermanent Sky/TIS Serge/Audio/061317 1 Rand FM 1_ma_2.aif",
		"/Volumes/Projects/The Impermanent Sky/TIS Serge/Audio/061317 1 Rand FM 1_ma_3.aif",
		"/Volumes/Projects/The Impermanent Sky/TIS Serge/Audio/061317 1 Rand FM 1_ma_4.aif",
		"/Volumes/Projects/The Impermanent Sky/TIS Serge/Audio/061317 1 Rand FM 1_ma_5.aif",
		"/Volumes/Projects/The Impermanent Sky/TIS Serge/Audio/061317 1 Rand FM 1_ma_6.aif",
		"/Volumes/Projects/The Impermanent Sky/TIS Serge/Audio/061317 1 Rand FM 1_ma_7.aif"
	];

	sfs  = Array.fill(~gestureFiles.size, {SoundFile.new});

	~gestureBuffers = Array.fill(~gestureFiles.size, {|i| Buffer.read(s, ~gestureFiles[i])}); //a buffer for each soundfile

	0.4.wait; //WAIT FOR BUFFERS TO LOAD OR WON'T WORK

	~gestureFiles.size.do{|i| sfs[i].openRead(~gestureFiles[i]) };//must openRead the files
	~gestureMarkerLists = Array.fill(~gestureFiles.size, {|i| sfs[i].extractMarkersAiff2(0)}); //0=samples (default), 1=seconds)

	~gestureFileSR=Array.fill(~gestureFiles.size, {|i| ~gestureBuffers[i].sampleRate});

	lastMarker = Array.fill(~gestureFiles.size, {|file| ~gestureMarkerLists[file].last});
	fileDurSamples = Array.fill(~gestureFiles.size, {|file| ~gestureBuffers[file].duration*~gestureFileSR[file]});

	~gestureMarkerDurs=Array.fill(~gestureFiles.size, {|file| Array.fill(~gestureMarkerLists[file].size-1, {|i| nextMarker=~gestureMarkerLists[file][i+1]; marker=~gestureMarkerLists[file][i]; nextMarker-marker})++
		(fileDurSamples[file]-lastMarker[file]) });

	//print:
	~gestureFiles.size.do{|i|
		"file: ".post; ~gestureFiles[i].basename.postln;
		"marker dur(s): ".post; (~gestureMarkerDurs[i]/~gestureFileSR[i]).postcs; //in seconds
	};
};

//SynthDefs
SynthDef(\gestures, {|out=0, bufnum=0, rate=1, startPos=0, panPos=0, gestureLev=1, masterLev =0.5, atk=0.01, dur=1, rel=0.01, curve= -4, send=16, dryLev=1, sendLev=1, gate=1, loop=0, mlLag=0.01, hpCLo=20, hpCutoff=20, lpCLo=20000, lpCutoff=20000, lpRand=0|

	var in, env;

	// lpRand = [0, 1].wchoose([0.8, 0.2]);

	env = Env.asr(atk, 1, rel, curve);
	in = HPF.ar(LPF.ar(PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum)*rate, startPos:startPos, loop:loop, doneAction:2), Rand(lpCLo, lpCutoff)), Rand(hpCLo, hpCutoff));
	in = Mix.ar(in);
	env = EnvGen.kr(env, gate:gate, levelScale:gestureLev, doneAction:2);
	//dry:
	Out.ar(out,
		PanAz.ar(4, in, panPos, dryLev*Lag2UD.kr(masterLev, mlLag))
		*
		env;
	);
	//wet:
	Out.ar(send,
		PanAz.ar(4, in, panPos, sendLev*Lag2UD.kr(masterLev, mlLag))
		*
		env
	);
}).send(s);
)

(
var gestPads, gestPadsMed, gestPadsQuiet, gpAddys, gpAddysMed, gpAddysQuiet, gpModeSw, modeSw=0;
//gesture GUI
~tisAddy = NetAddr.new("192.168.0.2", 8000); //Lemur receives on port 8000

gpModeSw = OSCFunc.new({|msg, time, addr, revPort| modeSw=msg[1];}, "/Switches/x", nil, 57121);

gpAddys = ["/Pads10/x", "/Pads11/x", "/Pads12/x", "/Pads13/x", "/Pads14/x", "/Pads15/x"];
gestPads = Array.fill(gpAddys.size, {|i|
	OSCFunc.new({|msg, time, addr, revPort| if (msg[1]==1){~gFuncTrig.value(0)}{if(modeSw==1){s.sendMsg(\n_set, ~gestureGroup, \gate, 0)}} }, gpAddys[i], nil, 57121);
});

gpAddysMed = ["/Pads16/x", "/Pads17/x", "/Pads82/x", "/Pads19/x", "/Pads20/x", "/Pads21/x"];
gestPadsMed = Array.fill(gpAddysMed.size, {|i|
	OSCFunc.new({|msg, time, addr, revPort| if (msg[1]==1){~gFuncTrig.value(1)}{if(modeSw==1){s.sendMsg(\n_set, ~gestureGroup, \gate, 0)}} }, gpAddysMed[i], nil, 57121);
});

gpAddysQuiet = ["/Pads22/x", "/Pads23/x", "/Pads24/x", "/Pads25/x", "/Pads26/x", "/Pads27/x"];
gestPadsQuiet = Array.fill(gpAddysQuiet.size, {|i|
	OSCFunc.new({|msg, time, addr, revPort| if (msg[1]==1){~gFuncTrig.value(2)}{if(modeSw==1){s.sendMsg(\n_set, ~gestureGroup, \gate, 0)}} }, gpAddysQuiet[i], nil, 57121);
});

~gestureGroup = s.nextNodeID;
s.sendMsg(\g_new, ~gestureGroup, 0, 0); //create a group for the instrument

~gFunc = {|dynamicSw=0|
	fork{
		var node, file, startPos, marker, markerDur;
		var lpRand, lpCLo=20000, lpCutoff=20000, hpRand, hpCutoff=20;
		var atkRand, atkTime=0.01, curve;
		var masterLev=0.5;

		/*		atkRand = [0,1].wchoose([0.8, 0.2]);
		if (atkRand==0){atkTime=0.01; curve=4}{atkTime=2; curve=10};*/

		switch(dynamicSw,
			0, {masterLev=0.75; lpCLo=20000; lpCutoff=20000}, //ff
			1, {masterLev=0.25; lpCLo=4000; lpCutoff=12000}, //mp
			2, {masterLev=0.025; lpCLo=300; lpCutoff=1500} //pp
		);

		lpRand = [0,1].wchoose([0.8, 0.2]);
		if (lpRand==0){lpCutoff=20000}{lpCutoff=300};

		hpRand = [0,1].wchoose([0.8, 0.2]);
		if (hpRand==0){hpCutoff=20}{lpCutoff=2500};

		file = rrand(0, ~gestureFiles.size-1);
		marker = rrand(0, ~gestureMarkerLists[file].size-1).asInteger;
		markerDur = ~gestureMarkerDurs[file][marker];
		startPos = ~gestureMarkerLists[file][marker];

		//marker.postln;startPos.postln;"".postln;
/*		modeSw.postln;*/

		s.sendBundle(s.latency, [\s_new, \gestures, node=s.nextNodeID, 0, ~gestureGroup, \bufnum, ~gestureBuffers[file].bufnum, \panPos, rrand(-1.0, 1.0), \startPos, startPos, \dryLev, rrand(0.1, 1), \sendLev, rrand(0.1, 0.5), \masterLev, masterLev, \hpCutoff, hpCutoff, \lpCLo, lpCLo,\lpCLo, lpCLo, \lpCutoff, lpCutoff, \atk, atkTime, \curve, curve]);

		(markerDur/(~gestureFileSR[file])).wait; //wait till next marker

		if (modeSw==0){
			s.sendMsg(\n_set, node, \gate, 0); //kill it
		"MARKER DUR MODE".postln;
		}{"HOLD MODE".postln};
	}
};

~gFuncTrig = {|dynamicSw=0|
	2.do{
		~gFunc.value(dynamicSw)
	}
}
)

//			s.sendBundle(s.latency, [\s_new, \pb_voiceMass, node=s.nextNodeID, 0, group, \bufnum, ~voiceMassBuffer[file].bufnum, \rate, rateVal, \startPos, startPos, \panPos, rrand(panLo, panHi), \gestureLev, gestureLev, \masterLev, masterLev, \dryLev, rrand(dryLo, dryHi), \sendLev, rrand(sendLo, sendHi), \send, sendBus, \atk, atk, \rel, rel, \curve, curve, \loop, loop]);