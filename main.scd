s.boot;
s.quit;

(
s.meter;
s.plotTree;
)


(
Routine {

	loop {
		x = [0, 1, 2, 3].wchoose([0.25, 0.15, 0.3, 0.3].normalizeSum);

		case 
			{ x == 0 } { 10.wait; }
			{ x == 1 } {  
			~makeDrums.value;
			Tdef(\microtracker).play; 
			Tdef(\drums).play; 
			10.wait;

			Tdef(\drums).stop;
			}

			{ x == 2 } { 
			Tdef(\granular_reverb).play; 
			rrand(120, 290).wait;	
			~granular_reverb.set(\gate, 0);
			};

			{ x == 3 } {
			// this is pretty sloppy, maybe cleanup
			Tdef(\granular_sampler).play;
			rrand(120, 380).wait;
			Tdef(\granular_sampler).stop;
			~mic.free;
			~pointer.free;
			~recordBuffers.free;
			~micGroup.free; 
			~recGroup.free;
			~pointerGroup.free; 
			~granGroup.free;
			};

		};

}.play;
)
