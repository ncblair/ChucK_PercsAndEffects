SndBuf kick => dac;
me.dir()+"/audio/Chop Kick.wav" => kick.read;
BPM b;
.1 => kick.gain;

0 => int beat;
while (1) {
	if (beat%4 == 0) {
		<<< "-----------D O W N B E A T-----------" >>>;
		.3 => kick.gain;
	}
	else {
		<<< "-----------B E A T-----------" >>>;
		.1 => kick.gain;
	}

	1 +=> beat;
	0 => kick.pos;
    b.quarter => now;
}