/*
WARNING: the wav methods seem to have a limit to the number of markers. if limit exceeded, an empty array is returned!
*/


//make buffer and marker array for each file
(
~waves = [
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassage_Poly1_1.5x.aiff",
	"/Projects/SC GITHUB/tis SOUNDFILES/SergeWaves1_Brassage_PolyDyn_1.5x.aiff" //more intense/dense. fade in more slowly and out more quickly
];

~wavesBuffers = Array.fill(~waves.size, {|i| Buffer.read(s, ~waves[i])}); //a buffer for each soundfile. solves the occasional reciprocal error by preloading buffers
)

(
var wavesSFs;
var markerDur, marker, nextMarker, lastMarker;
var fileDurSamples;

wavesSFs  = Array.fill(~waves.size, {SoundFile.new});

~waves.size.do{|i| wavesSFs[i].openRead(~waves[i]) };//must openRead the files
~wavesMarkers = Array.fill(~waves.size, {|i| wavesSFs[i].extractMarkersAiff2(0)}); //0=samples (default), 1=seconds)

//return 2D array of marker durations for all files

~wavesSR=Array.fill(~waves.size, {|file| ~wavesBuffers[file].sampleRate});
lastMarker = Array.fill(~waves.size, {|file| ~wavesMarkers[file].last});
fileDurSamples = Array.fill(~waves.size, {|file| ~wavesBuffers[file].duration*~wavesSR[file]});

~wavesMarkerDurArray=Array.fill(~waves.size, {|file| Array.fill(~wavesMarkers[file].size-1, {|i| nextMarker=~wavesMarkers[file][i+1]; marker=~wavesMarkers[file][i]; nextMarker-marker})++
	(fileDurSamples[file]-lastMarker[file]) });

~waves.size.do{|i|
	"file: ".post; ~waves[i].basename.postln;
	"marker dur(s): ".post; (~wavesMarkerDurArray[i]/~wavesSR[i]).postcs; //in seconds
}
)

(
SynthDef(\waves, {|out=0, bufnum1=0, bufnum2=1, rate=1, lev1=1, lev2=1, send=16, sendLev=0, gate=0, startPos1=0, startPos2=0, duration1=1, masterLev=1|

	var in1, in2, xfade, env1, pan1, pan2, pos;
	var duration2, output;
	var lpc;
	var in1Env, in2Env, outEnv;

	outEnv = EnvGen.kr(Env.new(#[0, 1, 1, 0], [0.01, duration1-0.02, 0.01]), doneAction:2);

	in1Env = EnvGen.kr(Env.new(#[0, 1, 1, 0], #[0.4, 0.2, 0.4], #[-2, 1, 2]), gate, timeScale: duration1);
	in2Env = EnvGen.kr(Env.new(#[0, 1, 1, 0], #[0.4, 0.2, 0.4], #[2, 1, 2]), gate, timeScale: duration1);

	in1 = PlayBuf.ar(2, bufnum1, BufRateScale.kr(bufnum1)*rate, startPos: startPos1)
	*in1Env;

	in2 = PlayBuf.ar(2, bufnum2, BufRateScale.kr(bufnum2)*rate, startPos: startPos2)
	*
	in2Env;

	//pos = EnvGen.kr(Env.new(#[0, 0.5], duration1, #[1.5]), gate); //pan line
	pos = EnvGen.kr(Env.new(#[0, 0.25, 0.25, 0.5], #[0.4, 0.2, 0.4], #[-1.5, 1, -4]), gate, timeScale:duration1); //pan line

	pan1 = PanAz.ar(4, in1[0]+in2[0], -0.25-pos, lev1);
	pan2 = PanAz.ar(4, in1[1]+in2[1], 0.25+pos, lev2);

	lpc = EnvGen.kr(Env.new(#[8000, 20000, 20000, 8000], #[0.4, 0.2, 0.4], #[1, 1, 1]), gate, timeScale:duration1);

	output = LPF.ar(pan1+pan2, lpc)
	//output = (pan1+pan2)
	*
	outEnv
	*
	masterLev;

	Out.ar(out, output);
	Out.ar(send, output*sendLev);
}).send(s);
)

(
var startPos1, startPos2, duration1, duration2;
var marker=6; //put on Slider
var lev1=1, lev2=1; //make in GUI

startPos1 = ~wavesMarkers[0][marker];
startPos2 = ~wavesMarkers[1][marker];

duration1 = ~wavesMarkerDurArray[0][marker]/~wavesSR[0];
duration2 = ~wavesMarkerDurArray[1][marker]/~wavesSR[1];


x = Synth(\waves, [\startPos1, startPos1, \startPos2, startPos2, \duration1, duration1, \bufnum1, ~wavesBuffers[0], \bufnum2, ~wavesBuffers[1], \gate, 1]);
)






