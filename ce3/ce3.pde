import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions

private static final int BIQUAD_FILTER = 500;

SamplePlayer backgroundMusic;
SamplePlayer v1;
SamplePlayer v2;

ControlP5 p5;

Glide gainGlide;
float gainAmount;
Gain gain;

Glide duckGainGlide;
float duckGainAmount;
Gain duckGain;

BiquadFilter filter;
Glide filterGlide;

//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions 
  p5 = new ControlP5(this);
  
  backgroundMusic = getBackground("intermission.wav");
  v1 = getVoiceover("voice1.wav");
  v2 = getVoiceover("voice2.wav");
  
  gainGlide = new Glide(ac, 0, 100);
  gain = new Gain(ac, 1, gainGlide);
 
  duckGainGlide = new Glide(ac, 1, 800);
  duckGain = new Gain(ac, 1, duckGainGlide);
  
  filterGlide = new Glide(ac, 1, 800);
  filter = new BiquadFilter(ac, BiquadFilter.Type.HP, filterGlide, .7);
  
  filter.addInput(backgroundMusic);
  duckGain.addInput(filter);
  gain.addInput(duckGain);
  gain.addInput(v1);
  gain.addInput(v2);
  
  p5.addSlider("GainSlider")
    .setPosition(50, 10)
    .setSize(150, 20)
    .setValue(50)
    .setRange(0, 100)
    .setLabel("Master Gain");

  p5.addButton("voice1")
    .setPosition(50, 80)
    .setLabel("Voice 1");
    
  p5.addButton("voice2")
    .setPosition(50, 120)
    .setLabel("Voice 2");
  
  ac.out.addInput(gain);
  ac.start();
}

void play(SamplePlayer sp) {
  sp.setToLoopStart();
  sp.start();
}

void voice1() {
  v2.pause(true);
  play(v1);
  duckGainGlide.setValue(.4);
  filterGlide.setValue(BIQUAD_FILTER);
}

void voice2() {
  v1.pause(true);
  play(v2);
  duckGainGlide.setValue(.4);
  filterGlide.setValue(BIQUAD_FILTER);
}

void GainSlider(int val) {
  gainGlide.setValue(((float) val) / 100);
}

SamplePlayer getBackground(String fname) {
  SamplePlayer b = getSamplePlayer(fname);
  b.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  return b;
}

SamplePlayer getVoiceover(String fname) {
  final SamplePlayer voiceover = getSamplePlayer(fname);
  voiceover.pause(true);
  voiceover.setEndListener(
    new Bead() {
      public void messageReceived(Bead m) {
        voiceover.pause(true);
        voiceover.setToLoopStart();
        filterGlide.setValue(isTalking() ? BIQUAD_FILTER : 1);
        duckGainGlide.setValue(1.0);
      }
    }
  );
  return voiceover;
}

boolean isTalking() {
  return !v1.isPaused() || !v2.isPaused();
}


void draw() {
  background(0);  //fills the canvas with black (0) each frame
}
