import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions

ControlP5 p5;

SamplePlayer buttonSound;

Gain g;
Glide gainGlide;
Glide rateGlide;
Glide cutoffGlide;

BiquadFilter filter1;

//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions 
  p5 = new ControlP5(this);
  
  buttonSound = getSamplePlayer("trumpet.wav");
  ac.out.addInput(buttonSound);
  ac.start();      
  
  gainGlide = new Glide(ac, 0.0, 50);
  g = new Gain(ac, 1, gainGlide);
  rateGlide = new Glide(ac, 1.0, 50);
  cutoffGlide = new Glide(ac, 200.0, 50);
  
  filter1 = new BiquadFilter(ac, BiquadFilter.AP, cutoffGlide, 0.5f);
  
  filter1.addInput(buttonSound);
  ac.start();
  
  p5.addSlider("GainSlider")
    .setPosition(10, 20)
    .setSize(200, 20)
    .setRange(0, 100);   
  p5.addButton("Play Music");
   
  
}


void draw() {
  background(0);  //fills the canvas with black (0) each frame

}
