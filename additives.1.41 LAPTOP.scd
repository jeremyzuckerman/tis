//transpose based on simple additive transposition value
/*(
//FIRST!!! (moved to 'groups, globals')
var cp;

//ADDITIVES Globals
~addAmp = 0.4;
~timeScale = 20; //scales the attack time to 20 for the performance

~instances1 = 1;
~instances2 = 8;
~instances3 = 6;
~instances4 = 20;
~instances5 = 8;
~instances6 = 20;

~addXPose = -4.3;

cp = Array.fill(4, 63);

~additivesGrp=Group.new; //master Additives group
~addInternalGrps = Array.fill(8, {Group.new(~additivesGrp, \addToHead)}); //groups for each voice

~flutter = Synth.tail(~additivesGrp, \flutter, [\direct, 1, \deviation, 0.001]);//deviation can only be set at init. deviation 0<=x<1
)*/

//~cp = Array.fill(4, 63);

~timeScale = 20; //scales the attack time to 20 for the performance

//////////
//LAYERS:
//1
~s1 = Array.fill(~instances1, {|i| Synth.head(~addInternalGrps[0], \additive1RM, [\out, 100, \masterLev, ~addAmp, \amp, 0.5, \centerPitch, ~cp.choose+~addXPose, \atk, rrand(3.0, 7.0)*~timeScale]) });

//4
~s4 = Array.fill(~instances4, {|i| Synth.head(~addInternalGrps[3], \additive4, [\masterLev, ~addAmp, \centerPitch, 68+~addXPose, \atk, rrand(6.0, 7.0)*~timeScale, \panRate, rrand(1/6,1/3), \panStartPos, rrand(-8pi, 8pi)]) });

//3
~s5 = Array.fill(~instances5, {|i| Synth.head(~addInternalGrps[4], \additive3, [\masterLev, ~addAmp, \centerPitch, 69+~addXPose, \atk, rrand(3.0, 7.0)*~timeScale, \modDepth, 0.035]) });

//2
~s3 = Array.fill(~instances3, {|i| Synth.head(~addInternalGrps[2], \additive3, [\masterLev, ~addAmp, \centerPitch, 64+~addXPose, \atk, rrand(3.0, 7.0)*~timeScale]) });

//5
~s7 = Array.fill(50, {|i| Synth.head(~addInternalGrps[6], \additive3, [\masterLev, 0.5, \centerPitch, rrand(36, 69)+~addXPose, \atk, rrand(3.0, 7.0)*~timeScale, \modDepth, 0.035]) });

//6 VOICE MASS SET
~s6 = Array.fill(~instances6, {|i|
	var pch = ([73, 71, 69, 67, 66, 64, 59]-0.3).wchoose([1, 3, 1, 1, 1, 1, 3].normalizeSum);
	Synth.head(~addInternalGrps[5], \additive3, [\masterLev, ~addAmp, \centerPitch, pch, \atk, rrand(6.0, 7.0)*~timeScale, \modDepth, 0.01])
}
);

//7 (START WITH THIS???)
//precursor to voicemass. VOICEMASS MUST BE GOING WITH MASTERLEV AT ZERO
~s8 = Synth.head(~addInternalGrps[7], \follower, [\atk, 3.0*~timeScale, \lev, 0.8, \band1Lev, 1.25, \band2Lev, 0.1, \band3Lev, 0.005, \band4Lev, 0.001]);


//////////////////////////
//FADE OUT ALL ADDITIVES:
~additivesGrp.set(\rel, 45, \gate, 0);
~additivesGrp.set(\rel, 1, \gate, 0); //fade out fast

//FADE OUT SIMPLE ADDITIVE:
s.sendMsg(\n_set, ~sAdditivesGrp, \gate, 0, \release, 30) //fade out and free


~flutter.set(\afAmount, 1, \afAtk, 0.04, \afRel, 0.04); //amp foll from Voice Mass
s.sendMsg(\n_set, ~sAdditivesGrp, \afAmount, 1, \afAtk, 0.04, \afRel, 0.04); //SIMPLE ADDITIVE: amp foll from voice mass

//TRANSITION:
//fade out all but ~s1 (first group) & ~s6 (voice mass pitches group)
[2,4,3,6].do{|i|
~addInternalGrps[i].set(\rel, 30, \gate, 0);
};

//FADE OUT PITCH FOLLOWER
~s8.set(\gate, 0, \rel, 60); //fade out follower

//fade out additives w voice mass pitches (~s6)
~addInternalGrps[5].set(\rel, 60, \gate, 0);


//fade out 1st group (~s1)
~addInternalGrps[0].set(\rel, 60, \gate, 0);

/////////////////////////////////
///////////OTHER SHIT///////////

//tweaking pitch follower
~s8.set(\band3Lev, 0.1)
~s8.set(\lag, 0.01)
~s8.set(\lev, 0.8)
~s8.set(\gate, 0, \rel, 60)
~s8.set(\band1Lev, 1.25);
~s8.set(\band2Lev, 0.4);
~s8.set(\band3Lev, 0.01);
~s8.set(\band4Lev, 0.0);

~s1.size.do{|i| ~s1[i].set(\direct, 0, \directLag, 120)}; //AM wet/dry
~additivesGrp.set(\gate, 0, \rel, 0.1) //quickly kill additives


//FLUTTER:
~flutter.set(\direct, 0, \directLag, 60); //0 = flutter 100%, 1 = dry 100%
~flutter.set(\tremRate, 0.2, \tremRateLag, 30); //change trem rate
~flutter.set(\pulseShape, 0.01, \psLag, 60); //change trem shape
~flutter.set(\pulseWidth, 0.5, \pwLag, 120, \tremRateScale, 0.1, \trs, 60);
~flutter.set(\pulseWidth, 0.5, \pwLag, 30, \pulseShape, 0.1, \psLag, 30);

~s1.size.do{|i| ~s1[i].set(\rmLag, 0.01)};
~s1.size.do{|i| ~s1[i].set(\rmRateLag, 60, \rmRate, 100)}

~s1.size.do{|i| ~s1[i].set(\gate, 0, \rel, 1)};
~s2.size.do{|i| ~s2[i].set(\gate, 0, \rel, 1)};
~s3.size.do{|i| ~s3[i].set(\gate, 0, \rel, 1)};
~s4.size.do{|i| ~s4[i].set(\gate, 0, \rel, 1)};
~s5.size.do{|i| ~s5[i].set(\gate, 0, \rel, 1)};
~s6.size.do{|i| ~s6[i].set(\gate, 0, \rel, 1)};
~s7.size.do{|i| ~s7[i].set(\gate, 0, \rel, 1)};
~s8.size.do{|i| ~s8[i].set(\gate, 0, \rel, 1)};

~additivesGrp.set(\masterLev, 0);
~additivesGrp.set(\gate, 0);

~s7.set(\baseModRate, 0.1, \lag, 30); //musical parameters
~s7.set(\floor, 0, \floorLag, 0.1); //" (depth of the AM, lag)
~s7.set(\modNoiseRate, 0.2); //testing the rate of the LFDNoise3 that modulates the LFPulse freq for the AM
~s7.set(\baseModRate, 1)
~s7.set(\modCurve, -50)
~s7.set(\direct, 0, \directLag, 1)
~s7.set(\direct, 0.2, \directLag, 1)
~s7.set(\masterLev, 2)

(
g=Group.new;

//more instances of \additive4 (line)
~s1 = Array.fill(~instances1, {|i| Synth.head(g, \additive1, [\centerPitch, 63, \atk, rrand(0.1, 5)]) }); //array of 5 instances
~s2 = Array.fill(~instances2, {|i| Synth.head(g, \additive2, [\centerPitch, 63, \atk, rrand(0.1, 5)]) });
~s3 = Array.fill(~instances3, {|i| Synth.head(g, \additive3, [\centerPitch, 64, \atk, rrand(0.1, 5)]) });
~s4 = Array.fill(~instances4, {|i| Synth.head(g, \additive4, [\centerPitch, 68, \atk, rrand(0.1, 5), \panRate, rrand(1/6,1/3), \panStartPos, rrand(-8pi, 8pi)]) });
~s5 = Array.fill(~instances5, {|i| Synth.head(g, \additive4, [\centerPitch, 69, \atk, rrand(0.1, 5), \modDepth, 0.035, \panRate, rrand(1/6,1/3), \panStartPos, rrand(-8pi, 8pi)]) });
~s6 = Array.fill(~instances6, {|i| Synth.head(g, \additive4, [\centerPitch, rrand(68, 70), \atk, rrand(0.1, 5), \modDepth, 0.035, \panRate, rrand(1/6,1/3), \panStartPos, rrand(-8pi, 8pi)]) });

)
~s7.set(\baseModRate, 5, \lag, 5); //musical parameters


~instances1.do{|i|~s1[i].release}; //release each instance
~instances2.do{|i|~s2[i].release}; //release each instance
~instances3.do{|i|~s3[i].release}; //release each instance
~instances4.do{|i|~s4[i].release}; //release each instance
~instances5.do{|i|~s5[i].release}; //release each instance
~instances6.do{|i|~s6[i].release}; //release each instance

/*
experiment with imposing enveloping on 'additives' (gestural and textural)
experiment with tonal chords (with some microtonality)
write down all time varying parameters and plan a long, complex gesture (length of entire piece?)

build tool to process vocals
start simple: triggering
*/
