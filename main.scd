s.boot;
s.quit;

//soundcheck
{SinOsc.ar(220 + [0, 1]) * -20.dbamp}.play;

(
s.meter;
s.plotTree;
)


(
Routine {

	loop {
		x = [0, 1, 2, 3, 4, 5].wchoose([0.25, 0.15, 0.25, 0.25, 0.25, 0.12].normalizeSum);

		case 
			{ x == 0 } { rrand(30, 75).wait; }
			{ x == 1 } {  
			~makeDrums.value;
			Tdef(\microtracker).play; 
			Tdef(\drums).play; 
			rrand(80, 280).wait;

			Tdef(\drums).stop;
			Ndef(\liveAmp).clear;
			}

			{ x == 2 } { 
			Tdef(\granular_reverb).play; 
			rrand(120, 280).wait;	
			~granular_reverb.set(\gate, 0);
			}

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
			}

			{ x == 4 } { 
			~reverb = Synth(\reverb);
			rrand(75, 350).wait;
			~reverb.set(\gate, 0);
			}

			{ x == 5 } {
			~makeBass.value;
			Tdef(\bass).play;
			rrand(75, 140).wait;
			Tdef(\bass).stop;
			}
		};

}.play;
)

