// micro-tracker heavily inspired by Nathan Ho

(
//Tdef(\makeDrums, {
~makeDrums = {
SynthDef(\kick, {
	var sweep = rrand(12, 23);
	var freq = exprand(40, 58)  * XLine.kr(sweep, 1, 0.01);
	var drive = rrand(1, 4.0);
	var rel = rrand(0.03, 0.3);
	var env = Env.perc(0.01, rel).ar(Done.freeSelf);
	var sig = SinOsc.ar(freq);
	sig = (sig * drive).tanh;


	sig = sig!2 * env * \amp.kr(-20.dbamp);
	Out.ar(\out.kr(0), sig);

}).add;

SynthDef(\snare, {
	var sweep = rrand(2.0, 5.0);
	var freq = exprand(700, 1200) * XLine.kr(sweep, 1, 0.01);
	var rel = rrand(0.06, 0.25);
	var env = Env.perc(0.01, rel).ar(Done.freeSelf);
	var sig = BPF.ar(Hasher.ar(Sweep.ar), freq, rq: XLine.kr(1, 0.5, 0.01));
	var drive = rrand(1.0, 5.0);
	sig = sig + (SinOsc.ar(freq * 0.25) * env * -10.dbamp);
	sig = (sig * drive).tanh;
	sig = sig!2 * env * \amp.kr(-20.dbamp);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\hat, {
	var rel = rrand(0.1, 0.4);
	var env = Env.perc(0.01, rel).ar(Done.freeSelf);
	var drive = rrand(1.0, 4.0);
	var modSigs = 3.collect { Pulse.ar(exprand(530, 850), width: rrand(0.1, 0.3) )  * rrand(700, 1000)};
	var carSigs = 3.collect { |i| Pulse.ar(exprand(1330, 1850) + modSigs[i], width: rrand(0.7, 0.9) )};
	var sig = (carSigs.sum * drive).wrap(rrand(-0.45, -0.99), rrand(0.45, 0.99));
	sig = sig!2 * env * \amp.kr(-20.dbamp);
	sig = LeakDC.ar(sig);
	sig = Pan2.ar(sig, Rand(-0.8, 0.8));
	Out.ar(\out.kr(0), sig);

}).add;

SynthDef(\glitch, {
	var rel = rrand(0.01, 0.2);
	var drive = rrand(3, 7);
	var env = Env.perc(0.01, rel).ar(Done.freeSelf);
	var sig = SinOsc.ar(ExpRand(300, 2000)) * XLine.kr(Rand(2, 1, 0.01)) * 2000;
	sig = SinOsc.ar(ExpRand(500, 1000) + sig);
	sig = (sig * drive).fold2;
	sig = sig!2 * env * \amp.kr(-20.dbamp);
	sig = LeakDC.ar(sig);
	sig = Pan2.ar(sig, Rand(-0.8, 0.8));
	Out.ar(\out.kr(0), sig);
}).add;
})
)

(
Tdef(\microtracker, {

// microtracker
~bpm = rrand(10, 110).postln;
~subdivision = rrand(3, 9);
~length = rrand(2, 4);
~pattern = ["k" + (~subdivision * ~length - 1).collect { ["k", "s", "h", "g", "."].choose }].asString;

~map = IdentityDictionary[
	$k -> \kick,
	$s -> \snare,
	$h -> \hat,
	$g -> \glitch
];
});

Tdef(\drums, {
	
	loop {
	
	var beat, tatum;
	beat = 60/~bpm;
	tatum = (beat/~subdivision);
	
	if(tatum < 10) { tatum = tatum * 1.2 };
	if(tatum > 30) { tatum = tatum / 1.1 };
	~pattern.do { |character| 
		var synthdef;
		if(~map[character].notNil) {
			synthdef = ~map[character];
			s.makeBundle(s.latency, { Synth(synthdef); });
			tatum.wait;
		} {
		if(character == $.)  {
			tatum.wait;
		}
		}
	};
	};

});
)

(
~makeDrums.value;
Tdef(\microtracker).play;
Tdef(\drums).play;
)

Tdef(\drums).play

~makeDrums.value
