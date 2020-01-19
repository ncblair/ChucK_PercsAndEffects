MagicPerc m;
BPM b;
spork ~ m.random_inf();
spork ~ m.random_walk_hpf();
spork ~ m.random_walk_res();
spork ~ m.random_change_quantization();
while (1) {
	//m.play_roll(64);
    //m.play_cycle();
    1::second => now;
}