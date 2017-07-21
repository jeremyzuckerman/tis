//testing GITHUB
(
//4:
var cp;

//ADDITIVES Globals
~addAmp = 0.4;
~timeScale = 20; //scales the attack time to 20 for the performance

~instances1=20;
~instances2 = 8;
~instances3 = 6;
~instances4 = 20;
~instances5 = 8;
~instances6 = 20;

cp = [63];

~additivesGrp=Group.new; //master Additives group
~addInternalGrps = Array.fill(8, {Group.new(~additivesGrp, \addToHead)}); //groups for each voice

//MAKE A SEQUENCE USING FORK TO ADD EACH ARRAY  GRADUALLY (or perform manually)
~s1 = Array.fill(~instances1, {|i| Synth.head(~addInternalGrps[0], \additive1RM, [\out, 100, \masterLev, ~addAmp, \amp, 0.5, \cp, cp.choose, \atk, rrand(3.0, 7.0)*~timeScale]) });
~flutter = Synth.tail(~additivesGrp, \flutter, [\direct, 1, \deviation, 0.001]);//deviation can only be set at init. deviation 0<=x<1
)

//LAYERS:
/*~s2 = Array.fill(~instances2, {|i| Synth.head(~addInternalGrps[1], \additive2, [\masterLev, ~addAmp, \centerPitch, 63, \atk, rrand(3.0, 7.0)*~timeScale]) });*/

~s3 = Array.fill(~instances3, {|i| Synth.head(~addInternalGrps[2], \additive3, [\masterLev, ~addAmp, \centerPitch, 64, \atk, rrand(3.0, 7.0)*~timeScale]) });

~s5 = Array.fill(~instances5, {|i| Synth.head(~addInternalGrps[4], \additive3, [\masterLev, ~addAmp, \centerPitch, 69, \atk, rrand(3.0, 7.0)*~timeScale, \modDepth, 0.035]) });

~s4 = Array.fill(~instances4, {|i| Synth.head(~addInternalGrps[3], \additive4, [\masterLev, ~addAmp, \centerPitch, 68, \atk, rrand(6.0, 7.0)*~timeScale, \panRate, rrand(1/6,1/3), \panStartPos, rrand(-8pi, 8pi)]) });

~s7 = Array.fill(50, {|i| Synth.head(~addInternalGrps[6], \additive3, [\masterLev, 0.5, \centerPitch, rrand(36, 69), \atk, rrand(3.0, 7.0)*~timeScale, \modDepth, 0.035]) });

/*~s6 = Array.fill(~instances6, {|i| Synth.head(~addInternalGrps[5], \additive3, [\masterLev, ~addAmp, \centerPitch, rrand(68, 60), \atk, rrand(6.0, 7.0)*~timeScale, \modDepth, 0.035]) });*/


// ~s8 = Array.fill(5, {|i| Synth.head(~addInternalGrps[7], \additive3, [\masterLev, 0.5, \centerPitch, [62,63,65,67,70].choose, \atk, rrand(1.0, 4.0)*~timeScale, \modDepth, 0.035]) });


//////////////////////////
//FADE OUT ALL ADDITIVES:
~additivesGrp.set(\rel, 30, \gate, 0);

//fade out all but 1st group (~s1)
7.do{|i|
~addInternalGrps[i+1].set(\rel, 30, \gate, 0);
};

//fade out 1st group
~addInternalGrps[0].set(\rel, 30, \gate, 0);

/////////////////////////////////
///////////OTHER SHIT///////////

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
