//import controlP5.*;
import beads.*;
import java.util.Arrays; 

AudioContext ac;

int sineCount = 10;
float baseFrequency = 440.0;

// Array of Glide UGens for series of harmonic frequencies for each wave type (fundamental sine, square, triangle, sawtooth)
Glide[] sineFrequency = new Glide[sineCount];
// Array of Gain UGens for harmonic frequency series amplitudes (i.e. baseFrequency + (1/3)*(baseFrequency*3) + (1/5)*(baseFrequency*5) + ...)
Gain[] sineGain = new Gain[sineCount];
Gain masterGain;
Glide masterGainGlide;
// Array of sine wave generator UGens - will be summed by masterGain to additively synthesize square, triangle, sawtooth waves
WavePlayer[] sineTone = new WavePlayer[sineCount];

void setup() {
  float sineIntensity = 1.0;
  size(400,400);
  ac = new AudioContext();
  
  masterGainGlide = new Glide(ac, .5, 200);  
  masterGain = new Gain(ac, 1, masterGainGlide);
  ac.out.addInput(masterGain);

  // create a UGen graph to synthesize a square wave from a base/fundamental frequency and 9 odd harmonics with amplitudes = 1/n
  // square wave = base freq. and odd harmonics with intensity decreasing as 1/n
  // square wave = baseFrequency + (1/3)*(baseFrequency*3) + (1/5)*(baseFrequency*5) + ...
  
  for( int i = 0, n = 1; i < sineCount; i++, n++) {
    // create the glide that will control this WavePlayer's frequency
    // create an array of Glides in anticipation of connecting them with ControlP5 sliders
    sineFrequency[i] = new Glide(ac, baseFrequency * n, 200);
    
    // Create harmonic frequency WavePlayer - i.e. baseFrequency * 3, baseFrequency * 5, ...
    sineTone[i] = new WavePlayer(ac, sineFrequency[i], Buffer.SINE);
    
    // Create gain for each harmonic - i.e. 1/3, 1/5, 1/7, ...
    // For a square wave, we only want odd harmonics, so set all even harmonics to 0 gain/intensity
    sineIntensity = (n % 2 == 1) ? (float) (1.0 / n) : 0;
    println(sineIntensity, " * ", baseFrequency * n);
    sineGain[i] = new Gain(ac, 1, sineIntensity); // create the gain object
    sineGain[i].addInput(sineTone[i]); // then connect the waveplayer to the gain
  
    // finally, connect the gain to the master gain
    // masterGain will sum all of the sine waves, additively synthesizing a square wave tone
    masterGain.addInput(sineGain[i]);
  }
  
  ac.start();
}
