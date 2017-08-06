(
//WHY DO I HAVE TO BOOT, KILL AND THEN REBOOT TO GET THE BACK SPEAKERS????
var window1, w1Flow, button, listView1, outDevVal=0, sampleRate=44100, blockSize=1024;
var listView2, listView3, blockSizes;
var currentSR, currentBS, kill;
var cpuText, cpuVals;
var location;

//Functions:
~bootFunc = {|outDevVal=0, sampleRate=44100, blockSize=1024|
	~outDev=outDevVal; //0 = Ensemble out device,1 = SuperCollider virtual out device

	fork{
	s = Server.local;
	Server.default = s;
	s.latency=0.05;
	s.options.hardwareBufferSize = blockSize;
	s.options.maxNodes=8192;
	s.options.memSize = 8192;

	//~tisAddy = NetAddr.new("192.168.0.2", 8000); //Lemur receives on port 8000
	//~tisAddy = NetAddr.new("169.254.14.85", 8000); //when using JZ Adhoc network

	//set up routing w plogue

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
/*		if (outDevVal==2)
		{
			//set outs to Built-in
			~serverOptions.outDevice = "Built-in Output";
		};*/

		if (outDevVal==0)
		{
			//set the inputs to the audio interface. defaults to this.
			~serverOptions.inDevice = "Ensemble Thunderbolt";
		};
/*		if (outDevVal==2)
		{
			~serverOptions.inDevice = "Built-in Microph";
		};*/

		//sets the samplerate in case it's not the same for both devices (ensemble and supercollider)
		~serverOptions.sampleRate = sampleRate;

		s.boot;
	}
};

blockSizes = Array.fill(8, {|i| 2.pow(5+i)});

window1 = Window("Settings", Rect(0, 1200, 340, 380));
window1.view.decorator = w1Flow = FlowLayout(window1.view.bounds, 20@20, 20@5);

listView1 = EZListView(window1, 150@60, "Out Device:",
	[
		"Ensemble"->{outDevVal=0}
		//, "SuperCollider"->{outDevVal=1}
		//, "Built-In"->{outDevVal=2}
	]
	, initVal:0);

button = Button(window1, Rect(0, 0, 120, 50)).states_([ ["Boot", Color.black, Color.white] ]);
button.action = {
	if(outDevVal==0){~bootFunc.value(0, sampleRate, blockSize); currentSR.value=sampleRate; currentBS.value=blockSize }
	{~bootFunc.value(1, sampleRate, blockSize); currentSR.value=sampleRate; currentBS.value=blockSize};
s.waitForBoot(
		{ Object.readArchive("/Projects/SC GITHUB/tis/tis synthdefs, funcs and sfs 1.75 LAPTOP.scd"); } //load main file
	)
};
w1Flow.nextLine;
listView2 = EZListView(window1, 150@130, "Sample Rate:",
	[
		"44.1" ->{sampleRate=44100}
/*		, "48" ->{sampleRate=48000}
		, "88.2" ->{sampleRate=88200}
		, "96" ->{sampleRate=96000}
		, "176.4" ->{sampleRate=176400}
		, "192" ->{sampleRate=192000}*/
	]
	, initVal:0, labelWidth:80);

listView3 = EZListView(window1, 120@130, "Blocksize:",
	[
/*		"32"->{blockSize=32}
		, "64"->{blockSize=64}
		, "128"->{blockSize=128}
		, "256"->{blockSize=256}
		, "512"->{blockSize=512},*/
		 "1024"->{blockSize=1024}
/*		, "2048"->{blockSize=2048}
		, "4096"->{blockSize=4096}*/
	]
	, initVal:0, labelWidth: 80);

currentSR = EZNumber(window1, 150@30, "Current SR:", controlSpec: ControlSpec(1, 192000, step:1), initVal:s.sampleRate);
currentBS = EZNumber(window1, 120@30, "Current BS:", controlSpec: ControlSpec(1, 192000, step:1), initVal:s.options.hardwareBufferSize);
w1Flow.nextLine;

kill = Button(window1, 30@30).states_([ ["K", Color.black, Color.white] ]);
kill.action = { Server.killAll; s.freeAll; };
w1Flow.nextLine;

location = EZListView(window1, 70@60, "Dly Comp.",
	[
		"Pieter"->(~dlyComp=1)
		, "None"->(~dlyComp=0)
	]
	, initVal:0, labelWidth:50);

window1.front;
)