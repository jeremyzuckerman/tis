(
var window1, w1Flow, button, listView1, outDevVal=0, sampleRate=44100, blockSize=1024;
var listView2, listView3, blockSizes;
var currentSR, currentBS, kill;
var cpuText, cpuVals;
var location=1;

//Functions:
~bootFunc = {|sampleRate=44100, blockSize=1024|

	fork{
		s = Server.local;
		Server.default = s;
		s.latency=0.05;

		~serverOptions = s.options;
		~serverOptions.hardwareBufferSize = blockSize;
		~serverOptions.maxNodes=8192;
		~serverOptions.memSize = 8192;

		//Set number of i/o channels to 32
		~serverOptions.numOutputBusChannels=32;
		~serverOptions.numInputBusChannels=32;

		// Post the number of i/o channels
		~serverOptions.numOutputBusChannels.postln;
		~serverOptions.numInputBusChannels.postln;

		0.1.wait;

		//set the outputs to Ensemble
		~serverOptions.outDevice = "Ensemble Thunderbolt";
		//set the inputs to the audio interface. defaults to this.
		~serverOptions.inDevice = "Ensemble Thunderbolt";
		~serverOptions.sampleRate = sampleRate;

		0.2.wait;

		s.boot;
		/*s.waitForBoot(
		{
		s.reboot;
		}
		);*/
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
	~bootFunc.value;
	s.waitForBoot(
		{
			Server.killAll; s.freeAll;
			~bootFunc.value; //needs to reboot for rear speakers to work for some reasons
			s.waitForBoot(
				{
					Object.readArchive("/Projects/SC GITHUB/tis/tis synthdefs, funcs and sfs 1.9 LAPTOP.scd");

				} //load main file
			);
		};
	);
	//~dlyComp=location.value;
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

//NOT WORKING
/*location = EZListView(window1, 70@60, "Dly Comp.",
[
"Pieter"->{~dlyComp=1}
, "None"->{~dlyComp=0}
]
, initVal:0, labelWidth:50);*/

window1.front;
)

