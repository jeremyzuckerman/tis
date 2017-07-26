//need to transpose. = tonal center of FOLLOWER
//have to start voicemass lemur GUI first
//COUNTER: (moved to 'groups, globals'
/*(
fork{
	var occurence=15;
	inf.do{|i|
		"counter: ".post; (occurence*i).asTimeString2.postln;
		occurence.wait;
	}
};
)*/

/*//FIRST (moved to 'groups, globals')
(
var polyphony=3, timeScale = 2;
~saXpose = -4.3;
~saFadeTimeScale=1;

~saVoices = Array.fill(polyphony, {|i| 4*i}); //offsets the nodes to group as follows: nodes 1-4: low voice; nodes 5-8 middle voice; nodes 9-12:high voice

~fadesIn = #[ 45, 67.5, 90, 112.5 ]*~saFadeTimeScale;
~outs = #[0, 2, 3, 1]; //L, RS, LS, R

~sAddSynths = Array.fill(4*polyphony, {s.nextNodeID}); //make node for each synth

s.sendMsg(\g_new, ~sAdditivesGrp=s.nextNodeID, 3, ~group);
)*/

~counter.value; //start counter

(
"simple additives".postln;

//START SIMPLE ADDITIVES
4.do{|i|
	/*var atk;
	atk = rrand(30,60);
	*/
	s.sendBundle(s.latency, [\s_new, \simpleAdditive, ~sAddSynths[i+~saVoices[0]], 0, ~sAdditivesGrp, \centerPitch, 63-24+~saXpose, \masterLev, 0.4, \atk, ~ fadesIn[i], \outBus, ~outs[i], \atk, ~fadesIn[i]]
		, [\s_new, \simpleAdditive, ~sAddSynths[i+~saVoices[1]], 0, ~sAdditivesGrp, \centerPitch, 63-12+~saXpose, \masterLev, 0.8, \atk,  ~fadesIn[i], \outBus, ~outs[i], \atk, ~fadesIn[i]]
		, [\s_new, \simpleAdditive, ~sAddSynths[i+~saVoices[2]], 0, ~sAdditivesGrp, \centerPitch, 63+~saXpose, \masterLev, 0.8, \atk,  ~fadesIn[i], \outBus, ~outs[i], \atk, ~fadesIn[i]]
	);
	}
)

//2: FM for all voices (polyphonic)
s.sendBundle(s.latency, [\n_set, ~sAddSynths[0], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
	, [\n_set, ~sAddSynths[0+~saVoices[1]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
	, [\n_set, ~sAddSynths[0+~saVoices[2]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]);

s.sendBundle(s.latency, [\n_set, ~sAddSynths[1], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
	, [\n_set, ~sAddSynths[1+~saVoices[1]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
	, [\n_set, ~sAddSynths[1+~saVoices[2]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]);

s.sendBundle(s.latency, [\n_set, ~sAddSynths[2], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
	, [\n_set, ~sAddSynths[2+~saVoices[1]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
	, [\n_set, ~sAddSynths[2+~saVoices[2]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]);

s.sendBundle(s.latency, [\n_set, ~sAddSynths[3], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
	, [\n_set, ~sAddSynths[3+~saVoices[1]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
	, [\n_set, ~sAddSynths[3+~saVoices[2]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]);



//FADE OUT
s.sendMsg(\n_set, ~sAdditivesGrp, \gate, 0, \release, 60) //fade out and free

s.sendMsg(\n_set, ~sAdditivesGrp, \afAmount, 0) //amp foll from voice mass


/*//2:
//FM first voices only (monophonic)
s.sendMsg(\n_set, ~sAddSynths[0], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20);//'
s.sendMsg(\n_set, ~sAddSynths[1], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20);//'
s.sendMsg(\n_set, ~sAddSynths[2], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20);//'
s.sendMsg(\n_set, ~sAddSynths[3], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20);//'*/

///////////////////////////////////////////////////////////////////////
(
//adjust levels of high or low octave. octave=0 low notes, octave=1 high notes
var arr, octave=0, nodes;

arr = Array.fill(4, {|i|
	var item;
	switch (octave,
		0, { nodes=i },
		1, {nodes=i+~saVoices[1]},
		2, {nodes=i+~saVoices[2]}
	);
	[\n_set, ~sAddSynths[nodes], \masterLev, 0.3, \mlLag, 0.1];});
s.sendBundle(s.latency,  arr[0], arr[1], arr[2], arr[3]);
)

4.do{|i|
	s.sendMsg(\n_set, ~sAddSynths[i+8], \masterLev, 0, \mlLag, 60)
}


//automated FM:
/*fork{
4.do{|i|
s.sendBundle(s.latency, [\n_set, ~sAddSynths[i], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
, [\n_set, ~sAddSynths[i+4], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]);
20.wait;
}
}*/

/*s.sendMsg(\n_set, ~sAdditivesGrp, \freqModRate, 500, \fmNoiseIndex, 50);
s.sendMsg(\n_set, ~sAdditivesGrp, \fmIndex, 100);
s.sendMsg(\n_set, ~sAdditivesGrp, \fmModRateLag, 0.01);*/

//5:
s.sendMsg(\n_set, ~sAdditivesGrp, \mlLag, 60, \masterLev, 0) //change master level

s.sendMsg(\n_set, ~sAdditivesGrp, \gate, 0, \release, 1) //fade out and free

s.sendMsg(\n_set, ~sAdditivesGrp, \centerpitch, 64, \cpLag, 120) //fade out and free

//suddenly quiet
s.sendMsg(\n_set, ~sAdditivesGrp, \mlLag, 0.1, \masterLev, 0.1) //change master level

//6?:
//AM (not sure if it's effective. rate too slow?)
s.sendMsg(\n_set, ~sAddSynths[0], \amLag, 20, \amRate, 0.05, \amDepth, 0.8);//'
s.sendMsg(\n_set, ~sAddSynths[1], \amLag, 20, \amRate, 0.05, \amDepth, 0.8);//'
s.sendMsg(\n_set, ~sAddSynths[2], \amLag, 20, \amRate, 0.05, \amDepth, 0.8);//'
s.sendMsg(\n_set, ~sAddSynths[3], \amLag, 20, \amRate, 0.05, \amDepth, 0.8);//'


// //change all pitch (monophonic)
// 4.do{|i|
// 	s.sendBundle(s.latency, [\n_set, ~sAddSynth[i], \centerPitch, pch])
// }
