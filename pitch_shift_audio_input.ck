// Nathan Blair
// Audio Pitch Shifting and Live Sampling
BPM b;

adc => PitShift pitch_shifter;
pitch_shifter => Dyno limiter => dac;

LiSa loop_array[4];



4::b.whole => dur loop_dur;
for (0 => int i; i < loop_array.cap(); i++) {
	pitch_shifter => loop_array[i] => limiter;
	loop_dur => loop_array[i].duration;
	loop_array[i].recRamp(64::ms);


}

1 => limiter.gain;
[0,0,0,0] @=> int off_record_loop_arr[]; //0: track off, 1: track recording, 2: track looping
//loop for 4 measures

fun void live_sample() {
	while (1) {
		for (0 => int i; i < loop_array.cap(); i++) {
			if (off_record_loop_arr[i] == 1) {
				//start recording input
				1 => loop_array[i].record;

				//begin ramping down
				loop_dur => now;

				0 => loop_array[i].record;	
				2 => off_record_loop_arr[i]; //automatically start looping
				
			}
			if (off_record_loop_arr[i] == 0) {
				0 => loop_array[i].loop;
				0 => loop_array[i].play;
			}
			if (off_record_loop_arr[i] == 2) {
				1 => loop_array[i].loop;
				1 => loop_array[i].play;
			}
		}
		2::b.half => now;
	}
}

Hid keyboard_event;
HidMsg msg;

0 => int device;
// open keyboard; or exit if fail to open
if( !keyboard_event.openKeyboard( device ) ) {
	<<< "Can’t open this device!! ", "Sorry." >>>;
	me.exit();
}
// print status of open keyboard Hid
<<< "keyboard '" + keyboard_event.name() + "' ready", "" >>>;


//pitch up and down with w and s
//change tempo with e and d
//toggle on and off with spacebar

false => int effect_active;
1.0 => float range_mult;
1.0 => float tempo_mult;

fun void switch_effect() {
	[84, 89, 85, 73] @=> int track_off_keys[];
	while (1) {
		<<<"switch">>>;
		keyboard_event => now;
		while(keyboard_event.recv(msg)) {
			if(msg.isButtonDown() && (msg.ascii == 32)) {
				1 - effect_active => effect_active;
				<<<"switch effect " + effect_active>>>;
				if (!effect_active) {
					pitch_shifter.shift(1);
				}
			}
			if (msg.isButtonDown() && (msg.ascii == 87)) { //w
				2. *=> range_mult;
				<<<"pitch up">>>;
			}
			if (msg.isButtonDown() && (msg.ascii == 83)) { //s
				.5 *=> range_mult;
				<<<"pitch down">>>;
			}
			if (msg.isButtonDown() && (msg.ascii == 69)) { //e
				.5 *=> tempo_mult;
				<<<"tempo up">>>;
			}
			if (msg.isButtonDown() && (msg.ascii == 68)) { //d
				2 *=> tempo_mult;
				<<<"tempo down">>>;
			}
			for (0 => int i; i < loop_array.cap();i++) {
				if (msg.isButtonDown() && (msg.ascii == 53+i)) { //5
					1 => off_record_loop_arr[i];
					<<<"record">>>;
				}
				if (msg.isButtonDown() && (msg.ascii == track_off_keys[i])) { //t
					if (off_record_loop_arr[i] == 0) {
						2 => off_record_loop_arr[i];
						<<<"start loop">>>;
					}
					else{
						if (off_record_loop_arr[i] == 2) {
							0 => off_record_loop_arr[i];
							<<<"stop loop">>>;
						}
					}
				}
			}
		}
	}
}

spork ~ switch_effect();
spork ~ live_sample();

limiter.limit();
1.0 => pitch_shifter.mix;
1.0 => pitch_shifter.shift;
1.0 => float shift;

while (1) {
	if (effect_active) {
		Math.random2f(0.5, 2) => shift;
	}
	pitch_shifter.shift(range_mult*shift);
	tempo_mult::b.eighth => now;
}

