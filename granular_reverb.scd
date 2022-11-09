// thanks to Alik Rustamoff for a lot of this code

(
SynthDef(\granular_reverb, {
	|tRate = 20, posRate = 1, rate = 1, offset = 0|

	var sig;
	var input;
	var readPos, signal, writePos, grained;
	var bufFrames, buf, bufDur;

	var tRateMod = { SinOsc.ar(\tRateMF.kr(0), Rand(0.0, 2pi)) * \tRateMD.kr(0) };
	var rateMod = { SinOsc.ar(\rateMF.kr(0), Rand(0.0, 2pi))  * \rateMD.kr(0) };
	var offsetMod = { SinOsc.ar(\offsetMF.kr(0), Rand(0.0, 2pi)) * \offsetMod.kr(0) };
	var trig;
	var env = Env.asr(\atk.kr(5), 1, \rel.kr(10)).ar(Done.freeSelf, \gate.kr(1));

	tRate = tRate + tRateMod.dup;
	rate = rate - rateMod.dup;

	bufFrames = 2**16;
	buf = { LocalBuf(bufFrames).clear }!2;
	bufDur = BufDur.kr(buf);

	writePos = Phasor.ar(end: bufFrames);

	trig = Impulse.ar(tRate);

	readPos = writePos - 64 / bufFrames - offset - offsetMod.dup;
	readPos = Wrap.ar(readPos, 0, 1);


	grained = GrainBufJ.ar(
		numChannels: 1,
		loop: 1,
		trigger: trig,
		dur: tRate.reciprocal * \overlap.kr(2, 5),
		sndbuf: buf,
		rate: rate,
		pos: readPos,
		interp: 4,
		pan: 0,
		envbufnum: -1	
	);

	grained = HPF.ar(grained, \grHPF.ar(40));
	grained = LPF.ar(grained, \grLPF.ar(15000));

	//input = In.ar(\in.kr(0), 2) * \inAmp.kr(0.dbamp);
	input = SoundIn.ar([0,0]) * \inAmp.kr(-50.dbamp);

	buf.do { | b, i | 

		BufWr.ar(grained[i] * \feedback.kr(0.3) + input[i], b, writePos)
	};

//	sig = Mix([ grained * \wet.kr(-0.dbamp).lag(3), input * \dry.kr(-0.dbamp) ]) * \outAmp.kr(0.dbamp) * env;

	sig = (grained * \wet.kr(0.dbamp).lag(3) + input * \dry.kr(0.dbamp)) * \outAmp.kr(0.dbamp) * env;
//	sig = Pan2.ar(sig, 0);

	Out.ar(\out.kr(0), sig.tanh);

}).add;

// lfos - sometime in the future, change to busses
Ndef(\tRateMFlfo, { LFNoise2.kr(Rand(0.01, 0.075)).range(0.0, 120) });
Ndef(\tRateMDlfo, { LFNoise2.kr(Rand(0.01, 0.075)).range(0.0, 100) });
Ndef(\offsetMFlfo, { LFNoise2.kr(Rand(0.01, 0.075)).range(0.0, 4000) });
Ndef(\offsetMDlfo, { LFNoise2.kr(Rand(0.01, 0.075)).range(0.0, 0.4) });
Ndef(\rateMFlfo, { LFNoise2.kr(Rand(0.01, 0.075)).range(0, 20.0) });
Ndef(\rateMDlfo, { LFNoise2.kr(Rand(0.01, 0.075)).range(0, 0.3) });
)

(
Tdef(\granular_reverb, {
~granular_reverb = Synth(\granular_reverb, [
	\tRateMF, Ndef(\tRateMFlfo).asMap,
	\tRateMD, Ndef(\tRateMDlfo).asMap,
	\offsetMF, Ndef(\offsetMFlfo).asMap,
	\offsetMD, Ndef(\offsetMDlfo).asMap,
	\rateMF, Ndef(\rateMFlfo).asMap,
	\rateMD, Ndef(\rateMDlfo).asMap
]);
})
);

