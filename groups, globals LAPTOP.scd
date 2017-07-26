(
//GROUPS, GLOBALS

//////////////////
//SIMPLE ADDITIVE
var polyphony=3, timeScale = 2;
var cp;

~saXpose = -4.3;
~saFadeTimeScale=1;

~saVoices = Array.fill(polyphony, {|i| 4*i}); //offsets the nodes to group as follows: nodes 1-4: low voice; nodes 5-8 middle voice; nodes 9-12:high voice

~fadesIn = #[ 45, 67.5, 90, 112.5 ]*~saFadeTimeScale;
~outs = #[0, 2, 3, 1]; //L, RS, LS, R

~sAddSynths = Array.fill(4*polyphony, {s.nextNodeID}); //make node for each synth

s.sendMsg(\g_new, ~sAdditivesGrp=s.nextNodeID, 3, ~group);

////////////
//ADDITIVES
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

//////////////
//VOICE MASS
~group = s.nextNodeID;
~xpGroup = s.nextNodeID;

//////
//EGG
~eggNumVoices = 60;
~ppo=0; //pan position offset
~eggTimeScale = 1;

s.sendMsg(\g_new, ~eggAdditivesGrp=s.nextNodeID, 0, 0);
s.sendMsg(\s_new, \eggAM, ~eggAM=s.nextNodeID, 1, ~eggAdditivesGrp);

//////////////////
//GLISSING VOICES
s.sendMsg(\g_new, ~gvGroup1 = s.nextNodeID, 0, 0); //create a group for the instrument
)