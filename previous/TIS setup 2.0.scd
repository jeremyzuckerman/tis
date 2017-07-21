//Uses the internal server. CPU meter in window
(
var window1, w1Flow, button, listView1, outDevVal=1, sampleRate=48000, blockSize=256;
var listView2, listView3, blockSizes;
var currentSR, currentBS, kill;
var cpuText, cpuVals;

//Functions:
~bootFunc = {|outDevVal=1, sampleRate=48000, blockSize=256|
	~outDev=outDevVal; //0 = Ensemble out device,1 = SuperCollider virtual out device

	s = Server.internal;
	Server.default = s;
	s.latency=0.05;
	s.options.hardwareBufferSize = blockSize;
	s.options.maxNodes=4096;
	s.options.memSize = 16384;

	//~tisAddy = NetAddr.new("192.168.0.2", 8000); //Lemur receives on port 8000
	//~tisAddy = NetAddr.new("169.254.14.85", 8000); //when using JZ Adhoc network

	//set up routing w plogue
	fork{

		/*		if (s.serverRunning){Server.killAll;
		"waiting...".postln;
		2.wait;}
		{nil};*/

		/*		Server.killAll;
		"waiting...".postln;
		2.wait;*/

		~serverOptions = s.options;

		//Set number of i/o channels to 32
		~serverOptions.numOutputBusChannels=32;
		~serverOptions.numInputBusChannels=32;

		// Post the number of i/o channels
		~serverOptions.numOutputBusChannels.postln;
		~serverOptions.numInputBusChannels.postln;

		0.5.wait;

		if (outDevVal==1)
		{
			//set the outputs to Loopback's SuperCollider virtual device
			~serverOptions.outDevice = "SuperCollider";
		};
		if (outDevVal==0)
		{
			//set the outputs to Ensemble
			~serverOptions.outDevice = "Ensemble Thunderbolt";
		};
		if (outDevVal==2)
		{
			//set outs to Built-in
			~serverOptions.outDevice = "Built-in Output";
		};

		if (outDevVal==0)
		{
			//set the inputs to the audio interface. defaults to this.
			~serverOptions.inDevice = "Ensemble Thunderbolt";
		};
		if (outDevVal==2)
		{
			~serverOptions.inDevice = "Built-in Microph";
		};

		//sets the samplerate in case it's not the same for both devices (ensemble and supercollider)
		~serverOptions.sampleRate = sampleRate;

		s.boot;
	}
};

/*//Synth Defs:
SynthDef(\monitor, {|monoStSw=0, in1=3, ch1Lev=1, pos1=0, out=0, send=16, dryLev=1, sendLev=0, in2=4, pos2=0, ch2Lev=1|
var input;

if (monoStSw==0){
input = Pan2.ar(AudioIn.ar(in1), pos1, ch1Lev);
}
{
input = [Pan2.ar(AudioIn.ar(in1), pos1, ch1Lev), Pan2.ar(AudioIn.ar(in2), pos2, ch2Lev)]
};

Out.ar(out, input*dryLev); //dry
Out.ar(send, input*sendLev);
}).send(s);*/


blockSizes = Array.fill(8, {|i| 2.pow(5+i)});

window1 = Window("Settings", Rect(0, 1200, 340, 300));
window1.view.decorator = w1Flow = FlowLayout(window1.view.bounds, 20@20, 20@5);

// listView1 = ListView(window1, 150@40).items_(["Out Device: Ensemble", "Out Device: SC"]).action_({|i| outDevVal = i.value});
listView1 = EZListView(window1, 150@60, "Out Device:",
	[
		"Ensemble"->{outDevVal=0}
		, "SuperCollider"->{outDevVal=1}
		, "Built-In"->{outDevVal=2}
	]
	, initVal:1);

button = Button(window1, Rect(0, 0, 120, 50)).states_([ ["Boot", Color.black, Color.white] ]);
button.action = { if(outDevVal==0){~bootFunc.value(0, sampleRate, blockSize); currentSR.value=sampleRate; currentBS.value=blockSize }{~bootFunc.value(1, sampleRate, blockSize); currentSR.value=sampleRate; currentBS.value=blockSize} };
w1Flow.nextLine;
listView2 = EZListView(window1, 150@130, "Sample Rate:",
	[
		"44.1" ->{sampleRate=44100}
		, "48" ->{sampleRate=48000}
		, "88.2" ->{sampleRate=88200}
		, "96" ->{sampleRate=96000}
		, "176.4" ->{sampleRate=176400}
		, "192" ->{sampleRate=192000}
	]
	, initVal:1, labelWidth:80);

listView3 = EZListView(window1, 120@130, "Blocksize:",
	[
		"32"->{blockSize=32}
		, "64"->{blockSize=64}
		, "128"->{blockSize=128}
		, "256"->{blockSize=256}
		, "512"->{blockSize=512}
		, "1024"->{blockSize=1024}
		, "2048"->{blockSize=2048}
		, "4096"->{blockSize=4096}
	]
	, initVal:3, labelWidth: 80);

// EZText(window1, 150@30, "Current SR:", initVal:s.sampleRate.postln);
currentSR = EZNumber(window1, 150@30, "Current SR:", controlSpec: ControlSpec(1, 192000, step:1), initVal:s.sampleRate);
currentBS = EZNumber(window1, 120@30, "Current BS:", controlSpec: ControlSpec(1, 192000, step:1), initVal:s.options.hardwareBufferSize);
w1Flow.nextLine;

kill = Button(window1, 30@30).states_([ ["K", Color.black, Color.white] ]);
kill.action = { Server.killAll };

cpuText = EZNumber.new(window1, 240@30, "CPU", ControlSpec(0, 100, \lin, 0.001, 0), numberWidth:100);
cpuVals = Routine{
	inf.do{
		//"CPU: ".post; s.avgCPU.postln;
		cpuText.value = s.avgCPU;
		1.wait;
	}
};

//how to do this: if server is running then run appclock??
/*if (s.isRunning=true){"test".postln};*/

AppClock.play(cpuVals);

window1.front
)