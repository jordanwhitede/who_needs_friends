// fair bit of thanks to Alik Rustamoff for inspiring the sampler, and to Eli Fieldstiel and the SC forum for some of the structure

(
~numBufs = 5;
~bufLength = 15;
~bufs = ~numBufs.collect { |i| Buffer.alloc(s, s.sampleRate * ~bufLength, bufnum: i) };
~micBus = Bus.audio(s, 1);
~pointerBus = Bus.audio(s, 1);

SynthDef(\mic, {
	var sig = SoundIn.ar(\in.kr(0));
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\pointer, {
	|buf|
	var phasor = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	Out.ar(\out.kr(0), phasor);
}).add;

SynthDef(\rec, {
	var pointer = In.ar(\pointerIn.kr(0), 1);
	var sig = In.ar(\micIn.kr(0), 1);
	BufWr.ar(sig, \buf.kr(0), pointer);
}).add;

SynthDef(\granular_sampler, {
	|bufnum, tRate = 20, posRate = 1, rate = 1|
	var sustain = ~bufLength - 4;
	var phasor, granSig;
	var bufFrames = BufFrames.kr(bufnum);

	var tRateMod = { SinOsc.ar(\tRateMF.kr(0), Rand(0.0, 2pi)) * \tRateMD.kr(0) };
	var rateMod = { SinOsc.ar(\rateMF.kr(0), Rand(0.0, 2pi))  * \rateMD.kr(0) };
	var offsetMod = { SinOsc.ar(\offsetMF.kr(0), Rand(0.0, 2pi)) * \offsetMod.kr(0) };
	var trig;
//	var env = Env.asr(\atk.kr(1), 1, \rel.kr(1)).ar(Done.freeSelf, \gate.kr(1));
	var env = Env.new([0, 1, 1, 0], [2, ~bufLength, 2]).ar(Done.freeSelf);

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

(
Tdef(\granular_sampler, {
//groups
~micGroup = Group.new;
~pointerGroup = Group.after(~micGroup);
~recGroup = Group.after(~pointerGroup);
~granGroup = Group.after(~recGroup);

// synths

~mic = Synth(\mic, [in: 0, out: ~micBus], ~micGroup);
~pointer = Synth(\pointer, [buf: ~bufs[0], out: ~pointerBus], ~pointerGroup);
~recordBuffers = Synth(\rec, [pointerIn: ~pointerBus, micIn: ~micBus, buf: ~bufs[0]], ~recGroup);

loop {
	~numBufs.do {
		|i|
		~recordBuffers.set(\buf, ~bufs[i]);
		~bufLength.wait;
		Synth(\granular_sampler, [
			buf: ~bufs[i],
			rate: [1, 2, 0.5, 0.25, 1.5].choose * [-1, 1].choose,
			posRate: rrand(0.25, 4) * [-1, 1].choose,
			tRateMF: rrand(0.5),
			tRateMD: rrand(0, 5)
		], ~granGroup);
	};
	1.wait;
};
});
)
