public class MagicPerc {
    ["Percussion Bubble 001.wav", "Young Chop Hat 4.wav", "Percussion Tom Drum 010.wav", "Percussion Tom Drum 004.wav", "Percussion Tom Drum 005.wav", "Young Chop Hat 5.wav", "Percussion Tom Drum 007.wav", "Young Chop Hat 7.wav", "Percussion Bongo 002 Super Hero.wav", "Percussion Cowbell 004 808.wav", "Young Chop Shake.wav", "Percussion Rimshot 014 808 Rim.wav", "Young Chop Hat 6.wav", "Percussion Tom Drum 006.wav", "Percussion Bongo 002.wav", "Percussion Castanets 002.wav", "Percussion Tom Drum 018 Im Gone.wav", "Percussion Tom Drum 002.wav", "Young Chop Hat 2.wav", "Young Chop Hat 3.wav", "Percussion Tom Drum 003.wav", "Percussion Rimshot 011 808 Rim.wav", "Percussion Bongo 001.wav", "Percussion Castanets 001.wav", "Young Chop Hat 1.wav", "Percussion Tom Drum 001.wav", "Percussion Timpani 001.wav", "Percussion Clave 001 808.wav", "Young Chop Block.wav", "Percussion Rimshot 006 Dist.wav", "Percussion Clap 001 Metal FX.wav", "Young Chop Coins.wav", "Young Chop Triangle.wav", "Percussion Rimshot 012 808 Rim.wav", "Percussion Tom Drum 017 I Be Puttin On.wav", "Percussion Rimshot 008.wav", "Percussion Tom Drum 011 All I Know.wav", "Percussion Bongo 001 Super Hero.wav", "Percussion Tom Drum 020 Where I'm At.wav", "Percussion Tom Drum 012 Boi 1 Da.wav", "Percussion Conga 002 Low.wav", "Percussion Donk 001.wav", "Percussion Clave 002 808.wav", "Percussion Tom Drum 013 Boi 1 Da.wav", "Percussion Tom Drum 014 Boi 1 Da.wav", "Percussion Conga 003 Damp.wav", "Percussion Kalimba 001 Mallet.wav", "Percussion Rimshot 002.wav", "Percussion Clap 005 Amp.wav", "Percussion Bell 003 Agogo High.wav", "Young Chop Tom.wav", "Percussion Clap 002 Metal FX.wav", "Percussion Rimshot 003.wav", "Percussion Rimshot 001.wav", "Percussion Rimshot 010 808 Rim.wav", "Percussion Tom Drum 019 Im Gone.wav", "Young Chop Switch.wav", "Percussion Cowbell 003.wav", "Percussion Rimshot 004.wav", "Percussion Clap 003 FIlter.wav", "Percussion Conga 001 High.wav", "Percussion Rimshot 005.wav", "Percussion Cowbell 002.wav", "Percussion Rimshot 007.wav", "Percussion Clap 006.wav", "Percussion Cowbell 001.wav", "Percussion Clap 004 Mouth.wav", "Percussion Tubular Bell 001.wav", "Percussion Tom Drum 016 Countless.wav", "Young Chop Cowbell.wav", "Percussion Clave 003 808 Reverb.wav", "Young Chop Stick.wav", "Percussion Bell 001.wav", "Percussion Tom Drum 015 Clave Boi Da.wav", "Percussion Rimshot 013 808 Rim.wav", "Percussion Bell 002.wav", "Percussion Tom Drum 008.wav", "Young Chop Hat 8.wav", "Young Chop Hat 9.wav", "Percussion Tom Drum 009.wav", "Young Chop Blocked.wav"] @=> string filenames[];
    filenames.size(10);
    filenames.cap() => int num_files;
    SndBuf percs[num_files];
    int num_samples[num_files];
    Pan2 pans[num_files];

    //Dyno limiter => Dyno outer_world_ducker => dac;
    Dyno limiter;
    limiter.limit();
    //outer_world_ducker.duck();
    //spork ~ this.duck_outside_high_sounds();

    ResonZ res_filt;
    Gain res_gain;
    
    
    .5 => res_gain.gain;
    100 => res_filt.Q;
    HPF high_pass => res_filt => res_gain => limiter;
    2000 => high_pass.freq;
    high_pass => limiter;

    .4 => high_pass.gain;
    BPM b;
    b.sixteenth => dur quantization;

    for (0 => int i; i < percs.cap(); i++) {
        percs[i] => high_pass;
        limiter => pans[i] => dac;


        me.dir()+"audio/HatPerc/" + filenames[i] => string path;
        path => percs[i].read;
        percs[i].samples() => num_samples[i];
        num_samples[i] => percs[i].pos;
    }

    /*
    fun void duck_outside_high_sounds() {
        adc => HPF adc_high_pass;
        2000  => adc_high_pass.freq;
        while (1) {
            0 => float moving_average;
            for (0 => int i; i < 1000; i++) {
                Std.fabs(adc_high_pass.last()) +=> moving_average;
                1::samp=>now;
            }
            10 /=> moving_average;
            moving_average => outer_world_ducker.sideInput;
        }

    }
    */

    fun void set_volume(int track_gain) {
        track_gain => limiter.gain;
    }

    // run concurrently
    fun void random_change_quantization() {
        [b.eighth, b.sixteenth, b.thirtysecond, b.sixtyfourth, b.onetwentyeighth] @=> dur poss_quants[];
        while(1) {
            Math.randomf() => float r;
            if (r < .2) {
                poss_quants[Math.random2(0, poss_quants.cap()-1)] => quantization;
                <<<"Quantization Change", quantization/b.quarter>>>;
            }
            b.eighth => now;
        }
    }
    
    //run concurrently
    fun void random_walk_hpf() {
        while(1) {
            (high_pass.freq() + ((Math.randomf() - .5)*200)) => high_pass.freq;
            if (high_pass.freq() < 800) {
                800.0 => high_pass.freq;
            }
            if (high_pass.freq() > 3000) {
                3000.0 => high_pass.freq;
            }
            b.sixtyfourth => now;
            <<<"High Pass:", high_pass.freq()>>>;
        }
    }

    //run concurrently;
    fun void random_walk_res() {
        while(1) {
            (res_filt.freq() + ((Math.randomf() - .5)*800)) => res_filt.freq;
            if (res_filt.freq() < 800) {
                800.0 => res_filt.freq;
            }
            if (res_filt.freq() > 5000) {
                5000.0 => res_filt.freq;
            }
            b.sixtyfourth => now;
            <<<"Resonance: ", res_filt.freq()>>>;
        }
    }

    fun void play_cycle() {
        for (0 => int i; i < this.percs.cap(); i++) {
            0 => percs[i].pos;
            b.thirtysecond => now;
        }
    }

    fun void play_roll(int length) {
        <<< "rolling" >>>;
        (Math.random2(0, 1)*2 - 1) => int pan_direction;
        for (0 => int i; i < length; i++) {
            Math.random2(0, num_files - 1) => int index;
            i * 1.0 => float i_float;
            0 => percs[index].pos;
            (.5 + .25*(i_float/length)) => percs[index].gain;
            pan_direction * (-1 + (i_float/length)*2) => pans[index].pan;
            b.onetwentyeighth => now;
        }
    }

    fun void random_inf() {
        1 => float beat_counter;
        while (1) {
            //randomly cut out sometimes
            Math.randomf() => float randomness;
            if ((randomness < .9) || (beat_counter % 2.0 == 0)){
                //get index
                Math.random2(0, num_files - 1) => int i;

                //random_pan
                (Math.randomf()*2 - 1)*2 => float p;
                if (p > 1) {
                    1.0 => p;
                }
                if (p < -1) {
                    -1.0 => p;
                }
                <<<p>>>;
                p => pans[i].pan;

                //random gain
                (Math.randomf()*.5 + .3) => percs[i].gain;

                //random rate
                (Math.randomf()*2 + .3) => percs[i].rate;

                // chance of reverse
                (Math.randomf() < .3) => int reverse;

                //strong hit on 2 and 4
                if (beat_counter % 2.0 == 0) {
                    1.5 => percs[i].gain;
                    0 => reverse;
                    0.1 => randomness;
                    1.0 => percs[i].rate;
                    0.0 => pans[i].pan;
                    <<<"now">>>;
                }

                // repeat sometimes
                1 => int num_repetitions;
                if (randomness < .1) {
                    Math.random2(2, 4) => num_repetitions;
                }
                for (0 => int j; j < num_repetitions; j++) {
                    if (reverse) {
                        (num_samples[i] -1) => percs[i].pos;
                        -1*percs[i].rate() => percs[i].rate;
                    }
                    else {
                        0 => percs[i].pos;
                    }
                    quantization/(b.quarter) +=> beat_counter;
                    quantization => now;
                }
            }
            else {
                if (randomness < .99) {
                    quantization/(b.quarter) +=> beat_counter;
                    quantization => now;
                }
                else {
                    play_roll(Math.random2(1, 4)*16);
                }
            }   
        }
    }
}