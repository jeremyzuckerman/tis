//TRY TWO VERY SLOW ROTATIONS: one for egg and one for tree
//1.3 adding individual amp mod (slow sines for Tree)
//1.2 adding modulation
/*
- listen to whole thing in time
- add bass √
- trigger the opening of the filter? √
- add amp env mod to exaggerate the rotation
gradually add detail
- individual channel amplitude mod √
- individual FM
- growing density / pch devitation
- flutters in spatial areas (not always all 4 speakers)
- gradually double with more complex waveform (can open up filter on these waveforms) √
- add reverb
*/

//1:
//first low density, then long slow fade in high density, then bass. overlapped entrances
(
var outs, fadesIn;
var lPos, rPos, rsPos, lsPos, posArray;
var ldPos, wait = 90, bassWait=240;
var bassLPos, bassRPos, bassRSPos, bassLSPos, bassPosArray, numBass=16;

"egg".postln;

~eggCounter =	 Routine{
		var occurence=15;
		inf.do{|i|
			"EGG COUNTER: ".post; (occurence*i).asTimeString2.postln;
			occurence.wait;
		}
	};

//moved to 'synthdefs, funcs, ...'
/*~eggNumVoices = 60;
~ppo=0; //pan position offset
~eggTimeScale = 1;

s.sendMsg(\g_new, ~eggAdditivesGrp=s.nextNodeID, 0, 0);
s.sendMsg(\s_new, \eggAM, ~eggAM=s.nextNodeID, 1, ~eggAdditivesGrp);*/

// ldPos = #[0, 1, 2, 3];
ldPos = #[-0.25, 0.25];

lPos = Array.fill(~eggNumVoices/4, {rrand(-0.5, 0)});
rPos = Array.fill(~eggNumVoices/4, {rrand(0, 0.5)});
rsPos = Array.fill(~eggNumVoices/4, {rrand(0.5, 1)});
lsPos = Array.fill(~eggNumVoices/4, {rrand(-0.5, 1)});

posArray = lPos++rPos++rsPos++lsPos;
//posArray.postcs;

//fadesIn = #[30, 45, 60, 75]*~eggTimeScale;
//outs = #[-0.25, 0.75, -0.75, 0.25]; //L, RS, LS, R
//outs = #[-0.25, 0.25, 0.75, -0.75]; //L, R, RS, LS

~eggLDNodes = Array.fill(8, {s.nextNodeID}); //first spatially discrete, low density voices
~eggAddSynths = Array.fill(~eggNumVoices, {s.nextNodeID}); //spatially disbursed, high density voices

	s.sendMsg(\s_new, \eggAM, ~eggAM=s.nextNodeID, 1, ~eggAdditivesGrp); //EGG AM (after egg grp)

fork{
	~eggCounter.play; //start the egg counter

	//LOW DENSITY
	"low density".postln;
	~eggLDNodes.size.do{|i|
		var pchs, atk;
		var lag;
		lag = rrand(60*4, 60*7)*~eggTimeScale;

		pchs = ([73, 71, 69, 67, 66, 64, 59]-0.3).wchoose([1, 3, 1, 1, 1, 1, 3].normalizeSum);
		atk = rrand(60, 60*2)*~eggTimeScale;

		s.sendMsg(\s_new, \eggAdditive, ~eggLDNodes[i], 0, ~eggAdditivesGrp, \centerPitch, pchs+rrand(-0.2, 0.2), \masterLev, 0.2, \panPos, ldPos.wrapAt(i), \atk, atk, \lpC, 12000, \lpRise, lag, \lpEGate, 1); //opens filter
	};

	(wait*~eggTimeScale).wait; //WAIT

	//HIGH DENSITY
	"high density".postln;
	~eggNumVoices.do{|i|
		var cp, atk, pchs;
		var lag;
		lag = (rrand(60*4, 60*8)*~eggTimeScale)-wait;

		pchs = ([73, 71, 69, 67, 66, 64, 59]-0.3).wchoose([1, 3, 1, 1, 1, 1, 3].normalizeSum);
		atk = rrand(60*3, 60*6)*~eggTimeScale;

		s.sendMsg(\s_new, \eggAdditive, ~eggAddSynths[i], 0, ~eggAdditivesGrp, \centerPitch, pchs+rrand(-0.2, 0.2), \masterLev, 0.2, \panPos, posArray[i], \atk, atk, \lpC, 12000, \lpRise, lag, \lpEGate, 1) //opens filter
	};

	(bassWait*~eggTimeScale).wait;
/*	s.sendMsg(\n_set, ~eggAdditivesGrp, \wetDry, 0.7, \wdLag, (60*5)*~eggTimeScale); //fade in AM*/

	//BASS
	~eggBassNodes = Array.fill(numBass, {s.nextNodeID}); //bass nodes

	bassLPos = Array.fill(numBass/4, {rrand(-0.5, 0)});
	bassRPos = Array.fill(numBass/4, {rrand(0, 0.5)});
	bassRSPos = Array.fill(numBass/4, {rrand(0.5, 1)});
	bassLSPos = Array.fill(numBass/4, {rrand(-0.5, 1)});

	bassPosArray = bassLPos++bassRPos++bassRSPos++bassLSPos;

	"bass".postln;
	numBass.do{|i|
		var pch, atk, lag;

		pch = (59-24)+rrand(-0.2, 0.2);
		atk = rrand(60*2, 60*3)*~eggTimeScale;
		lag = rrand(60*2.5, 60*4)*~eggTimeScale;

		s.sendMsg(\s_new, \eggAdditive, ~eggBassNodes[i], 0, ~eggAdditivesGrp, \centerPitch, pch, \masterLev, 0.2, \panPos, bassPosArray[i], \atk, atk, \lpC, 8000, \lpEGate, 1, \lpRise, lag);
	};
	(60*4).wait;
	"fully open".postln;
}
)

//2: rotate clockwise
~eggRotation.value(1, (60*7)*~eggTimeScale);

//3: START VOICE MASS a couple min before it feels like it needs more (around 5 min?)

(//4:
//little before tree
//fade in internal sine wave AM
"fading in sine wave AM...".postln;
~intAMfade.value(0.5, (60*3)*~eggTimeScale); //fade in internal sine wave AM
)

//rotate counterclockwise (at peak)
~eggRotation.value(-1, (60*7)*~eggTimeScale);

(
//5:
~eggClose.value; //execute

fork{
	(60*8).wait;
	~eggCounter.stop;
};
)

(
//when??
//fade out internal sine wave AM
"fading out sine wave AM...".postln;
~intAMfade.value(0, (60*3)*~eggTimeScale); //fade out internal sine wave AM
)

/*//7: fade out noise AM
s.sendMsg(\n_set, ~eggAdditivesGrp, \wetDry, 1, \wdLag, (60*3)*~eggTimeScale); //fade out AM*/

//8: bring in Serge 032315)

//9: fade out last voices of Egg
s.sendBundle(s.latency, [\n_set, ~eggAdditivesGrp, \gate, 0, \release, 120*~eggTimeScale]);

(
~eggNumVoices.do{|i|
	s.sendMsg(\n_set, ~eggAddSynths[i], \masterLev, 0, \mlLag, 120)
}
)

// //not noticeable much:
// (
// var modDepth=0;
// s.sendMsg(\n_set, ~eggAdditivesGrp, \modDepth, modDepth)
// )

//~eggOpen.value; //execute

/*(
var outs, fadesIn;

fadesIn = #[30, 45, 60, 75]*~eggTimeScale;
outs = #[0, 2, 3, 1]; //L, RS, LS, R

~sAddSynthsLow = Array.fill(~eggNumVoices, {s.nextNodeID}); //make node for each synth

/*s.sendMsg(\g_new, ~sAdditivesGrp=s.nextNodeID, 0, 0);*/

~eggNumVoices.do{|i|
var cp, atk;
cp = ([ 54, 55, 56, 58, 59, 60, 62, 69, 69 ])+0.4.wchoose([5, 10, 5, 5, 1, 2, 10, 10, 10].normalizeSum);
atk = rrand(60, 60*6);
/*	s.sendMsg(\s_new, \simpleAdditive, ~sAddSynths[i], 0, ~sAdditivesGrp, \centerPitch, cp*rrand(0.99, 1.01), \masterLev, 0.2, \outBus, outs.wrapAt(i), \atk, fadesIn.wrapAt(i));*/
s.sendMsg(\s_new, \eggAdditive, ~eggAddSynths[i], 0, ~eggAdditivesGrp, \centerPitch, cp*rrand(0.99, 1.01), \masterLev, 0.2, \panPos, outs.wrapAt(i), \atk, atk);
}
)*/

//MOD (??)
~eggNumVoices.do{|i|
	s.sendMsg(\n_set, ~eggAddSynths[i], \fmIndex, 0.025, \fmIndexLag, rrand(60, 60*4), \fmNoiseIndex, 0.025, \fmNoiseIndexLag, rrand(60, 60*4))
}

s.sendMsg(\n_set, ~eggAdditivesGrp, \gate, 0, \rel, 60)

/*
PanAz discrete outs (with width of 2!!):
-0.25 = L (0)
0.25 = R (1)
0.75 = RS (2)
1.25 = LS (3)
*/