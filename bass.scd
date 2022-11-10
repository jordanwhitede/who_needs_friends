(
~makeBass = {
SynthDef(\bass, {
	var atk = rrand(0.001, 4);
	var rel = rrand(0.5, 7);
	var drive = Rand(1, 5);
	var env = Env.perc(atk, rel).ar(Done.freeSelf);
	var ffreq = { LFDNoise3.kr(Rand(0.03, 2)).exprange(1000, 6000) } !2;
	var sig = VarSaw.ar(\freq.kr(50) *.x [1, 2, 3] +.x [0, 1], {rrand(0, 2pi)}!2, {rrand(0.1, 0.9)});
	
	sig = (sig.sum * drive).tanh;
	sig = LPF.ar(sig, ffreq);
	sig = sig * env * \amp.kr(-20.dbamp);
	sig = Splay.ar(sig, 0.75);
	Out.ar(\out.kr(0), sig);
}).add;
};
)

50 *.x [1, 2, 3] +.x [0, 1]

(
Tdef(\bass, {
	loop {
		Synth(\bass, [
			freq: exprand(30, 80),
			amp: rrand(-40, -30).dbamp
		]);	
		rrand(4, 12).wait;
	}
});
)

Tdef(\bass).play

~makeBass.value;
