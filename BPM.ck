public class BPM {
    135.0 => static float BPM;
    (60.0/BPM)::second => dur quarter;
    quarter / 2 => dur eighth;
    quarter/4 => dur sixteenth;
    quarter/3 => dur triplet;
    quarter/8 => dur thirtysecond;
    quarter/16 => dur sixtyfourth;
    quarter/32 => dur onetwentyeighth;
    quarter/6 => dur sixth;
    quarter*2 => dur half;
    quarter*4 => dur whole;

    0.0 => static float count;
    /*while (1) {
        sixteenth => now;
        0.25 => count;
        count % 4 => count;
    }
    */
}
