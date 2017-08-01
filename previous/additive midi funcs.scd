//add release trigger(s?)
//add to synthdefs, funcs, ... scd
(
MIDIdef.cc(\simpleAdds, {|val, cc|
	switch(cc
		, 34, {
			if (val==1){
				var lev;
				lev=0.8;

				"simple additives".postln;

				//START SIMPLE ADDITIVES
				4.do{|i|
					/*var atk;
					atk = rrand(30,60);
					*/
					s.sendBundle(s.latency, [\s_new, \simpleAdditive, ~sAddSynths[i+~saVoices[0]], 0, ~sAdditivesGrp, \centerPitch, 63-24+~saXpose, \masterLev, lev*0.5, \atk, ~ fadesIn[i], \outBus, ~outs[i], \atk, ~fadesIn[i]]
						, [\s_new, \simpleAdditive, ~sAddSynths[i+~saVoices[1]], 0, ~sAdditivesGrp, \centerPitch, 63-12+~saXpose, \masterLev, lev, \atk,  ~fadesIn[i], \outBus, ~outs[i], \atk, ~fadesIn[i]]
						, [\s_new, \simpleAdditive, ~sAddSynths[i+~saVoices[2]], 0, ~sAdditivesGrp, \centerPitch, 63+~saXpose, \masterLev, lev, \atk,  ~fadesIn[i], \outBus, ~outs[i], \atk, ~fadesIn[i]]
					);
				}
			}
			{
				s.sendMsg(\n_set, ~sAdditivesGrp, \rel, 120, \gate, 0)
			}
		}
		, 26, {
			var masterLev2;
			masterLev2=(val/127);

			s.sendMsg(\n_set, ~sAdditivesGrp, \masterLev2, masterLev2)
		}
		, 30, {
			if (val==1){
				"1: FM".postln;
				s.sendBundle(s.latency, [\n_set, ~sAddSynths[0], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
					, [\n_set, ~sAddSynths[0+~saVoices[1]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
					, [\n_set, ~sAddSynths[0+~saVoices[2]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]);
			}
		}
		, 31, {
			if (val==1){
				"2:FM".postln;
				s.sendBundle(s.latency, [\n_set, ~sAddSynths[1], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
					, [\n_set, ~sAddSynths[1+~saVoices[1]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
					, [\n_set, ~sAddSynths[1+~saVoices[2]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]);
			}
		}
		, 32, {
			if (val==1){
				"3:FM".postln;
				s.sendBundle(s.latency, [\n_set, ~sAddSynths[2], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
					, [\n_set, ~sAddSynths[2+~saVoices[1]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
					, [\n_set, ~sAddSynths[2+~saVoices[2]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]);
			}
		}
		, 33, {
			if (val==1){
				"4:FM".postln;
				s.sendBundle(s.latency, [\n_set, ~sAddSynths[3], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
					, [\n_set, ~sAddSynths[3+~saVoices[1]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]
					, [\n_set, ~sAddSynths[3+~saVoices[2]], \fmIndex, 0.025, \fmIndexLag, 60, \fmNoiseIndex, 0.025, \fmNoiseIndexLag, 20]);
			}
		}
	)
});

MIDIdef.cc(\additiveLevs, {|val, cc|
	var add1, add2, add3, add4, add5, master, simpAdd, sendLev, afAmount;

	switch(cc
		, 13, {
			add1=val/127;
			~addInternalGrps[0].set(\lev, add1);
			"add1: ".post; add1.postln;
		}
		, 14, {
			add2=val/127;
			~addInternalGrps[2].set(\lev, add2);
			"add2: ".post; add2.postln;
		}
		, 15, {
			add3=val/127;
			~addInternalGrps[3].set(\lev, add3);
			"add3: ".post; add3.postln;
		}
		, 16, {
			add4=val/127;
			~addInternalGrps[4].set(\lev, add4);
			"add4: ".post; add4.postln;
		}
		, 17, {
			add5=(val/127).pow(2);
			~addInternalGrps[6].set(\lev, add5);
			"add5: ".post; add5.postln;
		}
		, 18, {
			master=(val/127); //0 to 2
			s.sendMsg(\n_set, ~additivesGrp, \masterLev, master);
			"master: ".post; master.postln;
		}
		, 26, {
			simpAdd=val/127;
			s.sendMsg(\n_set, ~sAdditivesGrp, \masterLev2, simpAdd);
			"masterLev2: ".post; simpAdd.postln;
		}
		, 20, {
			sendLev=val/127;
			//s.sendMsg(\n_set, ~additivesGrp, \sendLev, sendLev)
			~flutter.set(\sendLev, sendLev);
		}
		, 19, {
			afAmount=val/127;
			~flutter.set(\afAmount, afAmount);
		}
	)
});

MIDIdef.cc(\additivesGates, {|vel, nn|
	switch(nn
		, 24, {
			if (vel==1){
				~s1 = Array.fill(~instances1, {|i| Synth.head(~addInternalGrps[0], \additive1RM, [\out, 100, \masterLev, ~addAmp, \amp, 0.5, \centerPitch, ~cp.choose+~addXPose, \atk, rrand(3.0, 7.0)*~timeScale]) });
				"additive: 63".postln;
			}{
				~addInternalGrps[0].set(\rel, 30, \gate, 0)
			}
		}
		, 25, {
			if (vel==1){
				~s3 = Array.fill(~instances3, {|i| Synth.head(~addInternalGrps[2], \additive3, [\masterLev, ~addAmp, \centerPitch, 64+~addXPose, \atk, rrand(6.0, 9.0)*~timeScale]) });
				"additive: 64".postln;
			}
			{
				~addInternalGrps[2].set(\rel, 30, \gate, 0)
			}
		}
		, 27, {
			if (vel==1){
				~s4 = Array.fill(~instances4, {|i| Synth.head(~addInternalGrps[3], \additive4, [\masterLev, ~addAmp, \centerPitch, 68+~addXPose, \atk, rrand(6.0, 9.0)*~timeScale, \panRate, rrand(1/6,1/3), \panStartPos, rrand(-8pi, 8pi)]) });
				"additive: 68".postln;
			}
			{
				~addInternalGrps[3].set(\rel, 30, \gate, 0)
			}
		}
		, 28, {
			if (vel==1){
				~s5 = Array.fill(~instances5, {|i| Synth.head(~addInternalGrps[4], \additive3, [\masterLev, ~addAmp, \centerPitch, 69+~addXPose, \atk, rrand(6.0, 9.0)*~timeScale, \modDepth, 0.035]) });
				"additive: 69".postln;
			}
			{
				~addInternalGrps[4].set(\rel, 30, \gate, 0)
			}
		}
		, 29, {
			if (vel==1){
				~s7 = Array.fill(50, {|i| Synth.head(~addInternalGrps[6], \additive3, [\masterLev, ~addAmp, \lev, 0, \centerPitch, rrand(36, 69)+~addXPose, \atk, 0.1, \modDepth, 0.035]) });
				"additive: (36..69)".postln;
			}
			{
				~addInternalGrps[6].set(\rel, 30, \gate, 0)
			}
		}
	)
})
)