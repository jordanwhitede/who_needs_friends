// micro-tracker heavily inspired by Nathan Ho
// to do - compressor!

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


	sig = sig!2 * env * \amp.kr(-20.dbamp) * \liveAmp.kr(0.dbamp);
	Out.ar(\out.kr(0), sig);

}).add;

SynthDef(\snare, {
	var sweep = rrand(2.0, 5.0);
	var freq = exprand(800, 1200) * XLine.kr(sweep, 1, 0.01);
	var rel = rrand(0.06, 0.25);
	var env = Env.perc(0.01, rel).ar(Done.freeSelf);
	var sig = BPF.ar(Hasher.ar(Sweep.ar), freq, rq: XLine.kr(1, 0.5, 0.01));
	var drive = rrand(1.0, 5.0);
	sig = sig + (SinOsc.ar(freq * 0.25) * env * -10.dbamp);
	sig = (sig * drive).tanh;
	sig = sig!2 * env * \amp.kr(-20.dbamp) * \liveAmp.kr(0.dbamp);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\hat, {
	var rel = rrand(0.1, 0.4);
	var env = Env.perc(0.01, rel).ar(Done.freeSelf);
	var drive = rrand(1.0, 4.0);
	var modSigs = 3.collect { Pulse.ar(exprand(630, 850), width: rrand(0.1, 0.4) )  * rrand(800, 1000)};
	var carSigs = 3.collect { |i| Pulse.ar(exprand(1030, 1850) + modSigs[i], width: rrand(0.6, 0.9) )};
	var sig = (carSigs.sum * drive).fold2; //.wrap(rrand(-0.75, -0.99), rrand(0.75, 0.99));
	sig = BPF.ar(sig, exprand(2800, 4000) * XLine.kr(3, 1, 0.01), rq: XLine.kr(1, 0.7, 0.01));
	sig = sig * env * \amp.kr(-20.dbamp) * \liveAmp.kr(0.dbamp);
	sig = LeakDC.ar(sig);
	sig = Pan2.ar(sig, Rand(-0.8, 0.8));
	Out.ar(\out.kr(0), sig);

}).add;

SynthDef(\glitch, {
	var rel = rrand(0.01, 0.2);
	var drive = Rand(2, 7);
	var env = Env.perc(0.01, rel).ar(Done.freeSelf);
	var sig = SinOsc.ar(ExpRand(300, 2000)) * XLine.kr(Rand(2, 1, 0.01)) * 1000;
	sig = SinOsc.ar(ExpRand(500, 1000) + sig);
	sig = (sig * drive).fold2;
	sig = sig!2 * env * \amp.kr(-40.dbamp) * \liveAmp.kr(0.dbamp);
	sig = LeakDC.ar(sig);
	sig = Pan2.ar(sig, Rand(-0.8, 0.8));
	Out.ar(\out.kr(0), sig);
}).add;
})
)

(
Tdef(\microtracker, {

// microtracker
~bpm = rrand(60, 80).postln;
~subdivision = rrand(4, 9);
~length = rrand(2, 4);
~pattern = ["k" + (~subdivision * ~length - 1).collect { ["k", "s", "h", "g", "."].wchoose([0.2, 0.2, 0.15, 0.15, 0.23].normalizeSum) }].asString;

~map = IdentityDictionary[
	$k -> \kick,
	$s -> \snare,
	$h -> \hat,
	$g -> \glitch
];
});

Tdef(\drums, {
	
	Ndef(\liveAmp, {XLine.kr(-30.dbamp, 0.dbamp, 15)});

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
			s.makeBundle(s.latency, { Synth(synthdef, [liveAmp: Ndef(\liveAmp).asMap]); });
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
