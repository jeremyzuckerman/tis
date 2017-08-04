~intAMLDPhases = #[0, pi];
~intAMLDRateRand = Array.fill(2, {rrand(0.9, 1.1)});

~eggIntStreams = 3;
~eggAddSynthsPhases = #[0, 0.5pi, pi];
~eggAddSynthsRateRand = Array.fill(~eggIntStreams, {rrand(0.9, 1.1)});
~eggLVfadeTime = 3;

~eggMIDI = {
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
				~eggRotation.value(~eggRotationsLemur, (60*7)*~eggTimeScale);
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