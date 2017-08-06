(
~samplerMIDI = {
	MIDIdef.cc(\samplerMIDI, {|val, cc|

		var names, levs, lpcs;

		names = ["Hieroglyphic Pose", "Into 3D", "Slow Rolls"];
		levs = #[1, 0, 0];
		lpcs = #[20000, 300, 20000];

		switch(cc
			, 5, {
				if (val==1){
					//actions:
					s.sendBundle(s.latency, [\s_new, \sampler, ~samplerNodes[0], 0, ~samplerGroup, \bufnum, ~samplerBufs[0].bufnum, \lev, levs[0], \lpc, lpcs[0]]);
					names[0].postln;
				}{
					s.sendMsg(\n_set, ~samplerNodes[0], \gate, 0); //turn off
				};
			}
			, 6, {
				if (val==1){
					s.sendBundle(s.latency, [\s_new, \sampler, ~samplerNodes[1], 0, ~samplerGroup, \bufnum, ~samplerBufs[1].bufnum, \lev, levs[1], \lpc, lpcs[1]]);
					names[1].postln;
				}{
					s.sendMsg(\n_set, ~samplerNodes[1], \gate, 0); //turn off
				};
			}
			, 4, {
				if (val==1){
					s.sendBundle(s.latency, [\s_new, \sampler, ~samplerNodes[2], 0, ~samplerGroup, \bufnum, ~samplerBufs[2].bufnum, \lev, levs[2], \lpc, lpcs[2]]);
					names[2].postln;
				}{
					s.sendMsg(\n_set, ~samplerNodes[2], \gate, 0); //turn off
				};
			}
			, 70, {
				s.sendBundle(s.latency, [\n_set, ~samplerGroup, \gate, 0]); //turn all off
			}
			, 61, {
				var lev;
				lev = (val/127)*2;

				s.sendMsg(\n_set, ~samplerNodes[0], \lev, lev);
			}
			, 9, {
				//into 3D level
				var lev;

				lev = (val/127).pow(2);
				s.sendBundle(s.latency, [\n_set, ~samplerNodes[1], \lev, lev]);
			}
			, 58, {
				//into 3D filter
				var cf;
				cf = ((val/127).pow(2))*19980+20;

				s.sendBundle(s.latency, [\n_set, ~samplerNodes[1], \lpc, cf]);
				//"cf: ".post; cf.postln;
			}
			, 59, {
				//slow rolls level
				var lev;
				lev = ((val/127).pow(2))*0.3;

				s.sendBundle(s.latency, [\n_set, ~samplerNodes[2], \lev, lev]);
				//"slow rolls lev: ".post; lev.postln;
			}
			, 60, {
				var lev;
				lev = (val/127)*2;

				s.sendBundle(s.latency, [\n_set, ~samplerGroup, \masterLev, lev]);
			}
		)
	});
};

~eggMIDI = {
	var rotationScale = 0.5;

	MIDIdef.cc(\eggMIDI, {|val, cc|
		switch(cc
			, 48, {
				if (val==1){
					~eggOpen.value;
				}{
					s.sendMsg(\n_set, ~eggAdditivesGrp, \release, 0.1, \gate, 0); //turn off (in case of accidental start)
					~eggOpenTask.stop;
					"cancelled open.".postln;
				};
			}
			, 54, {
				if (val==1){
					~eggClose.value;
				}{
					~eggCloseTask.stop;
					"cancelled close.".postln;
				};
			}
			, 53, {
				~eggRotationsLemur = (((val/127)*10)-5).round(1);
				"num egg rotations: ".post; ~eggRotationsLemur.postln;
			}
			, 50, {
				if (val==1){
					~eggRotation.value(~eggRotationsLemur, (60*7)*rotationScale);
					fork{
						(60*7)*rotationScale.wait;
						~tisMidi.control(0, 50, 0); //reset lemur
						"rotation complete.".postln;
					};
				}
				{
					~erInfo.stop;
				};
			}
			, 51, {
				//egg internal AM depth
				var depth;
				depth = (val/127);
				s.sendBundle(s.latency, [\n_set, ~eggAdditivesGrp, \intAMdepth, depth, \iamLag, 0.1]);
			}
			, 52, {
				//egg internal AM rate
				~eggLDNodes.size.do{|i|
					var lemRate1, lemRate2;
					lemRate1 = (((val/127).pow(2))*1.9+0.1)*~intAMLDRateRand[0];
					lemRate2 = (((val/127).pow(2))*1.9+0.1)*~intAMLDRateRand[1];

					if (i.even==true){
						s.sendBundle(s.latency, [\n_set, ~eggLDNodes[i], \iamdLag, 0.1, \intAMrate, lemRate1, \iAMphase, ~intAMLDPhases[0]] );
					}
					{
						s.sendBundle(s.latency, [\n_set, ~eggLDNodes[i], \iamdLag, 0.1, \intAMrate, lemRate2, \iAMphase, ~intAMLDPhases[1]] );
					};
				};

				~eggAddSynths.size.do{|i|
					var rates;
					rates = Array.fill(~eggIntStreams, {|i| (((val/127).pow(2))*1.9+0.1)*~eggAddSynthsRateRand[i];});

					switch (i%~eggIntStreams
						, 0, { s.sendBundle(s.latency, [\n_set, ~eggAddSynths[i], \iamdLag, 0.1, \intAMrate, rates[0], \iAMphase, ~eggAddSynthsPhases[0]] )}
						, 1, { s.sendBundle(s.latency, [\n_set, ~eggAddSynths[i], \iamdLag, 0.1, \intAMrate, rates[1], \iAMphase, ~eggAddSynthsPhases[1]] )}
						, 2,  { s.sendBundle(s.latency, [\n_set, ~eggAddSynths[i], \iamdLag, 0.1, \intAMrate, rates[2], \iAMphase, ~eggAddSynthsPhases[2]] )}
					);
				};
			}
			, 55, {
				//last voices fade out time
				var time;
				time = (val/127)*3+1;

				~eggLVfadeTime = time;
			}
			, 49, {
				//fade out last voices
				if (val==1){
					s.sendBundle(s.latency, [\n_set, ~eggAdditivesGrp, \gate, 0, \release, (~eggLVfadeTime*60)*~eggTimeScale]);
					fork{
						120.wait;
						( (~eggLVfadeTime*60)*~eggTimeScale ).wait;
						~tisMidi.control(0, 49, 0); //reset lemur
					};
				}
				{
					nil
				};
			}
			, 62, {
				//reverb
				var send;
				send = (val/127);

				s.sendMsg(\n_set, ~eggAdditivesGrp, \sendLev, send);
			}
		)
	});
};

~bleepMIDI = {
	var bleepPchs, bleepRates, modFreqs, pimRate, pos;

	bleepPchs = [73, 71, 69, 67, 66, 64, 59].reverse-0.3; //low to high (egg pchs)
	modFreqs = #[2102, 3904, 4936, 1500].scramble; //different every performance
	pimRate = #[14.3, 13, 10.5, 7.5].scramble; //different every perf
	pos = #[-0.25, 0.25, 0.75, -0.75].scramble;

	MIDIdef.cc(\bleepMIDI, {|val, cc|
		//var scale=0.1; //SET TO 1 FOR PERFORMANCE!!!!!!!!!!!!!!!

		switch(cc
			, 73, {
				if (val==127){
					s.sendMsg(\s_new, \bleeps, ~bleepNodes[0], 0, ~bleepsGrp, \atk, rrand(60, 120), \gate, 1, \car, bleepPchs[6].midicps, \modulator, modFreqs[0], \pimRate, pimRate[0], \lev, 0.0035, \pmIndex, 1, \modPhase, rrand(0.01, pi), \hpc, 6000, \pos, pos[0]);
				}
				{
					s.sendMsg(\n_set, ~bleepNodes[0], \rel, rrand(60, 120)*2, \gate, 0);
					fork {
						120.wait;
						~tisMidi.control(0, 73, 0); //reset lemur
					};
				};
			}
			, 74, {
				if (val==127){
					s.sendMsg(\s_new, \bleeps, ~bleepNodes[1], 0, ~bleepsGrp, \atk, rrand(60, 120), \gate, 1, \car, bleepPchs[2].midicps, \modulator, modFreqs[1], \pimRate, pimRate[1], \lev, 0.0035, \pmIndex, 1, \modPhase, rrand(0.01, pi), \hpc, 6000, \pos, pos[1]);
				}
				{
					s.sendMsg(\n_set, ~bleepNodes[1], \rel, rrand(60, 120)*2, \gate, 0);
					fork{
						120.wait;
						~tisMidi.control(0, 74, 0); //reset lemur
					};
				};
			}
			, 75, {
				if (val==127){
					s.sendMsg(\s_new, \bleeps, ~bleepNodes[2], 0, ~bleepsGrp, \atk, rrand(60, 120), \gate, 1, \car, bleepPchs[1].midicps, \modulator, modFreqs[2], \pimRate, pimRate[2], \lev, 0.0035, \pmIndex, 1, \modPhase, rrand(0.01, pi), \hpc, 6000, \pos, pos[2]);
				}
				{
					s.sendMsg(\n_set, ~bleepNodes[2], \rel, rrand(60, 120)*2, \gate, 0);
					fork{
						120.wait;
						~tisMidi.control(0, 75, 0); //reset lemur
					};
				};
			}
			, 76, {
				if (val==127){
					s.sendMsg(\s_new, \bleeps, ~bleepNodes[3], 0, ~bleepsGrp, \atk, rrand(60, 120), \gate, 1, \car, bleepPchs[0].midicps, \modulator, modFreqs[3], \pimRate, pimRate[3], \lev, 0.0035, \pmIndex, 1, \modPhase, rrand(0.01, pi), \hpc, 6000, \pos, pos[3]);
				}
				{
					s.sendMsg(\n_set, ~bleepNodes[3], \rel, rrand(60, 120)*2, \gate, 0);
					fork{
						120.wait;
						~tisMidi.control(0, 76, 0); //reset lemur
					};
				};
			}
			, 56, {
				var pmIndex;
				pmIndex = (val/127);

				s.sendMsg(\n_set, ~bleepsGrp, \pmIndex, pmIndex);
			}
			, 57, {
				var level;
				level = (val/127).pow(2)*0.1;

				s.sendMsg(\n_set, ~bleepsGrp, \lev, level);
				"bleep level: ".post; level.postln;
			}
		)
	});
};


/////////
//WAVES
~wavesMIDI = {
	MIDIdef.cc(\wavesMIDI, {|val, cc|
		switch(cc
			, 38, {
				if (val==127){
					~wavesStackerRoutFunc.value //task
				}
				{
					~waveTask.stop //completes any current waves and then stops
				};
			}
			, 37, {
				//moog filter LPC
				var lpc;
				lpc = ((val/127).pow(2))*19980+20; //20-20k
				//s.sendMsg(\n_set, ~wavesFilter, \lpc, lpc);
				~wavesFilter.set(\lpc, lpc);
				//"waves lpc: ".post; lpc.postln;
			}
			, 39, {
				~wavesML = ((val/127).pow(2))*2;
				//~wavesGrp.set(\masterLev, ~wavesML);
				s.sendMsg(\n_set, ~wavesGrp, \masterLev, ~wavesML);
			}
			, 10, {
				var sendLev=0;
				sendLev = (val/127);

				//s.sendMsg(\n_set, ~wavesGrp, \sendLev, sendLev);
				~wavesFilter.set(\sendLev, sendLev);
			}
		)
	});
};

~additivesMIDI = {
	MIDIdef.cc(\simpleAdds, {|val, cc|
		switch(cc
			, 35, {
				if (val==1){
					~counter.start;
				}
				{
					~counter.stop;
					"counter stopped.".postln;
				}
			}
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
					s.sendMsg(\n_set, ~sAdditivesGrp, \release, 180, \gate, 0)
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
			/*			, 26, {
			simpAdd=val/127;
			s.sendMsg(\n_set, ~sAdditivesGrp, \masterLev2, simpAdd);
			"masterLev2: ".post; simpAdd.postln;
			}*/
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
		var relTime = 60;
		switch(nn
			, 24, {
				if (vel==1){
					~s1 = Array.fill(~instances1, {|i| Synth.head(~addInternalGrps[0], \additive1RM, [\out, 100, \masterLev, ~addAmp, \amp, 0.5, \centerPitch, ~cp.choose+~addXPose, \atk, rrand(3.0, 7.0)*~timeScale]) });
					"additive: 63".postln;
				}{
					~addInternalGrps[0].set(\rel, relTime, \gate, 0)
				}
			}
			, 25, {
				if (vel==1){
					~s3 = Array.fill(~instances3, {|i| Synth.head(~addInternalGrps[2], \additive3, [\masterLev, ~addAmp, \centerPitch, 64+~addXPose, \atk, rrand(6.0, 9.0)*~timeScale]) });
					"additive: 64".postln;
				}
				{
					~addInternalGrps[2].set(\rel, relTime, \gate, 0)
				}
			}
			, 27, {
				if (vel==1){
					~s4 = Array.fill(~instances4, {|i| Synth.head(~addInternalGrps[3], \additive4, [\masterLev, ~addAmp, \centerPitch, 68+~addXPose, \atk, rrand(6.0, 9.0)*~timeScale, \panRate, rrand(1/6,1/3), \panStartPos, rrand(-8pi, 8pi)]) });
					"additive: 68".postln;
				}
				{
					~addInternalGrps[3].set(\rel, relTime, \gate, 0)
				}
			}
			, 28, {
				if (vel==1){
					~s5 = Array.fill(~instances5, {|i| Synth.head(~addInternalGrps[4], \additive3, [\masterLev, ~addAmp, \centerPitch, 69+~addXPose, \atk, rrand(6.0, 9.0)*~timeScale, \modDepth, 0.035]) });
					"additive: 69".postln;
				}
				{
					~addInternalGrps[4].set(\rel, relTime, \gate, 0)
				}
			}
			, 29, {
				if (vel==1){
					~s7 = Array.fill(50, {|i| Synth.head(~addInternalGrps[6], \additive3, [\masterLev, ~addAmp, \lev, 0, \centerPitch, rrand(36, 69)+~addXPose, \atk, 0.1, \modDepth, 0.035]) });
					"additive: (36..69)".postln;
				}
				{
					~addInternalGrps[6].set(\rel, relTime, \gate, 0)
				}
			}
		)
	});
};

~spinningSergeMIDI = {
	MIDIdef.cc(\ssOnOff, {|vel, nn|
		switch(nn
			, 12, {
				if (vel.value==1){
					s.sendMsg(\s_new, \spinningSerge, ~ssNode, 0, ~sergeGrp2, \gate, 1, \masterLev, 0);
					//~ssNode = Synth.head(~sergeGrp2, \spinningSerge, [\gate, 1, \masterLev, 0]);
					"spinning serge".postln;
				};
				if (vel.value==0){
					s.sendMsg(\n_set, ~ssNode, \gate, 0);
					//~ssNode.set(\gate, 0);
					"ss stopped".postln;
				}
			}
		)
	});

	MIDIdef.cc(\ssLev, {|vel, nn|
		switch(nn
			, 40, {s.sendMsg(\n_set, ~ssNode, \masterLev, vel/127); vel.postln}
			, 41, {s.sendMsg(\n_set, ~ssNode, \hpCut, (vel/127).pow(2)*4075+25); vel.postln}
		)
	});

	MIDIdef.cc(\sergeMasses, {|val, cc|
		switch(cc
			, 21, {
				"serge on/off: ".post; val.postln;
				if (val==1){
					s.sendBundle(s.latency
						, [\s_new, \sampler, ~sergeNode, 0, ~sergeGrp, \bufnum, ~samplerBufs.last.bufnum, \lev, 1, \rotationRate, 0.1, \rotationsOn, 1]
						//, [\s_new, \ampCircles, ~afc, 0, ~amplitudesGrp] //amplitude circle panning
						//, [\s_new, \ampFrontBack, ~afFB, 0, ~amplitudesGrp] //amplitude front back panning
					);
				}
				{
					s.sendBundle(s.latency, [\n_set, ~sergeNode, \gate, 0]
						//, [\n_set, ~sergeNode, \rotationsOn, 0]
					);
					/*					midi.control(0, 23, 0); //set rotationsOn button to off (lemur)
					midi.control(0, 22, 0); //set rate to 0 (0.1)*/

				}
			}
			, 22, {
				var rate;
				rate = ((val/127)*1.9)+0.1; //0.1 to 2

				"rotation rate: ".post; rate.postln;

				s.sendMsg(\n_set, ~sergeNode, \rotationRate, rate)
			}
			, 23, {
				"rotations on/off: ".post; val.postln;
				if (val==1){
					s.sendMsg(\n_set, ~sergeNode, \rotationsOn, 1)
				}
				{
					s.sendMsg(\n_set, ~sergeNode, \rotationsOn, 0)
				}
			}
			, 42, { //pan depth
				var depth;
				depth = val/127;
				s.sendMsg(\n_set, ~sergeNode, \afAmount, depth);
				"pan depth: ".post; depth.postln;
			}
			, 43, { //circles rate
				var rate;
				rate=(((val/127).pow(2))*4.9)+0.1; //0.1 to 5
				//s.sendMsg(\n_set, ~afc, \panrate, rate);
				~afc.set(\panrate, rate);
				"circles rate: ".post; rate.postln;
			}
			/*			, 44, { //waves rate
			var rate;
			rate=(((val/127).pow(2))*4.95)+0.05; //0.05 to 5
			s.sendMsg(\n_set, ~afFB, \rate, rate);
			"waves rate: ".post; rate.postln;
			}
			, 45, { //FM depth (noise2)
			var depth;
			depth = val/127;
			s.sendMsg(\n_set, ~afc, \fmDepth, depth);
			"FM depth: ".post; depth.postln;
			}
			, 46, { //FM rate multiple)
			var rate;
			rate = ((val/127)*1.5)+0.5; //0.5 to 2 (0.25=1 in Lemur)
			s.sendMsg(\n_set, ~afc, \fmRateMult, rate);
			"FM rate multiple: ".post; rate.postln;
			}*/
			, 11, { //master level
				var lev;
				lev = (val/127)*2;
				s.sendMsg(\n_set, ~sergeGrp, \masterLev, lev);
				"master level: ".post; lev.postln;
			}
			, 36, {
				var sendLev;
				sendLev=(val/127);
				s.sendMsg(\n_set, ~sergeGrp, \sendLev, sendLev)
			}
		)
	})
};
)