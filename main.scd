// s.boot;

// should i use classes somehow instead of Tdefs?


// control structure: 1. Synths/modules/whatever saved in Tdefs. 2. Tdefs selected, triggered (weighted) and stopped/cleared (?) via this control structure


// modules: gran sampler, gran reverb, drum machine, nice reverb (just like, NHHall plus bit of extra delay + feedback). silence also has to be an option. 

(
Routine {

	loop {
		x = [0, 1, 2].choose.postln;

		y = case 
		{ x == 0 } { 10.wait; }
		{ x == 1 } {  
			Tdef(\makeDrums).play;
			Tdef(\microtracker).play; 
			Tdef(\drums).play; 
			10.wait;

			Tdef(\drums).stop;
		}

		{ x == 2 } { 
			Tdef(\granular_reverb).play; 
			10.wait;	
	};
	}

}.play;
)

s.plotTree;
