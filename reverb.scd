(
SynthDef(\reverb, {
        var sig, fb, freq;
	var env = Env.asr(4, 1, 5).ar(Done.freeSelf, \gate.kr(1));
        sig = SoundIn.ar(0!2);
        sig = sig + LocalIn.ar(2);
        sig = sig + (NHHall.ar(sig, 3) * -10.dbamp);
        fb = sig;
        fb = DelayC.ar(fb, 0.5, [0.3, 0.4] + (SinOsc.ar(0.3, [0, pi]) * 1e-3));
        fb = LPF.ar(fb, 3000);
        fb = HPF.ar(fb, 100);
        fb = fb * -6.dbamp;
        fb = LeakDC.ar(fb);
        LocalOut.ar(fb);
	sig = sig * env;
	Out.ar(\out.kr(0), sig);
}).add;
)



