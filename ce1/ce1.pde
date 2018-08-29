import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions

ControlP5 p5;

SamplePlayer buttonSound;

Gain g;
Reverb r;
Glide gainGlide;

//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions 
  p5 = new ControlP5(this);
  
  buttonSound = getSamplePlayer("trumpet.wav");
  
  gainGlide = new Glide(ac, 0, 0);
  g = new Gain(ac, 1, gainGlide);
  g.addInput(buttonSound);

  r = new Reverb(ac);
  r.setLateReverbLevel(0);
  r.addInput(g);
  ac.out.addInput(r);

  p5.addSlider("GainSlider")
    .setPosition(240, 10)
    .setSize(20, 200)
    .setValue(50)
    .setRange(0, 100);
  p5.addSlider("ReverbSlider")
    .setPosition(170, 10)
    .setSize(20, 200)
    .setValue(0)
    .setRange(0, 100);
  p5.addButton("PlayMusic")
    .setSize(150, 80)
    .setPosition(10, 60);
  ac.start();
}

void GainSlider(int val) {
  gainGlide.setValue(((float) val) / 20);
}

void ReverbSlider(int val) {
  r.pause(false);
  r.setLateReverbLevel(((float) val) / 20);

}

void PlayMusic() {
  buttonSound.reset();
}

void draw() {
  background(0);  //fills the canvas with black (0) each frame
}
