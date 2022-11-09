(
SynthDef(\granular_sampler, {
	|bufnum, tRate = 20, posRate = 1, rate = 1|

	var phasor, granSig;
	var bufFrames = BufFrames.kr(bufnum);

	var tRateMod = { SinOsc.ar(\tRateMF.kr(0), Rand(0.0, 2pi)) * \tRateMD.kr(0) };
	var rateMod = { SinOsc.ar(\rateMF.kr(0), Rand(0.0, 2pi))  * \rateMD.kr(0) };
	var offsetMod = { SinOsc.ar(\offsetMF.kr(0), Rand(0.0, 2pi)) * \offsetMod.kr(0) };
	var trig;
	var env = Env.asr(\atk.kr(1), 1, \rel.kr(1)).ar(Done.freeSelf, \gate.kr(1));

	tRate = tRate + tRateMod.dup;
	offsetMod = posRate + offsetMod.dup;
	rate = rate + rateMod.dup;

	trig = Impulse.ar(tRate);

	phasor = Phasor.ar(
		rate: posRate * BufRateScale.kr(bufnum),
		start: \startPos.kr(0.0) * bufFrames,
		end: \endPos.kr(1.0) * bufFrames
	);

	granSig = GrainBufJ.ar(
		numChannels: 1,
		trigger: trig,
		dur: tRate.reciprocal * \overlap.kr(2),
		sndbuf: bufnum,
		rate: rate,
		pos: phasor / bufFrames,
		interp: 2,
		pan: 0,
		envbufnum: -1,
		maxGrains: 512
	);

	granSig = granSig * env * \amp.kr(0.dbamp) * 0.5; // *0.5 because of stereo
	
	Out.ar(\out.kr(0), granSig);

}).add;
)
