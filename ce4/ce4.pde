import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions

ControlP5 p5;

SamplePlayer music;
Glide musicRateGlide; // control playback rate of music SamplePlayer (i.e. play, FF, Rewind)
double musicLength; // used to store length of music sample in milliseconds
Bead musicEndListener; // used to detect end/beginning of music playback, rewind, FF

SamplePlayer play;
SamplePlayer rewind;
SamplePlayer stop;
SamplePlayer fastforward;
SamplePlayer reset;

//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions 
  p5 = new ControlP5(this);
  
  play = getButtonSamplePlayer("play.wav");
  rewind = getButtonSamplePlayer("rewind.wav");
  stop = getButtonSamplePlayer("stop.wav");
  fastforward = getButtonSamplePlayer("fastforward.wav");
  reset = getButtonSamplePlayer("reset.wav");

  music = getSamplePlayer("intermission.wav", false); // make sure killOnEnd = false
  musicRateGlide = new Glide(ac, 0, 250); // initially, set rate to 0, otherwise, music will play when you start the sketch
  music.setRate(musicRateGlide); // pause music - equivalent to music.pause(true);
  musicLength = music.getSample().getLength(); // store length of music sample in ms
  // create an endListener event handler to detect when the end or beginning of the music sample has been reached
  musicEndListener =  new Bead() {
    public void messageReceived(Bead message) {
        // remove this endListener to prevent its firing over and over due to playback position bugs in Beads
        music.setEndListener(null);
        // Reset playback position to end or beginning of sample to work around Beads bug
        //  where playback position can go past the end points of the sample.
        // if playing or fast-forwarding and the playback head is at the end of the music sample
        if (musicRateGlide.getValue() > 0 && music.getPosition() >= musicLength) {
            musicRateGlide.setValueImmediately(0); // pause music, use setValueImmediately() instead of setValue()
            music.setToEnd(); // reset playback position to the end of the sample, ready to rewind
        }
        // if rewinding and the playback position is at the start of the music sample
        if (musicRateGlide.getValue() < 0 && music.getPosition() <= 0.0) {
            musicRateGlide.setValueImmediately(0); // pause music by setting the playback rate to zero
            music.reset(); // reset playback position to the start of the sample
        }
    }
  };
  p5.addButton("Play")
    .setPosition(50, 80);
    
  p5.addButton("Rewind")
    .setPosition(50, 110);

  p5.addButton("Stop")
    .setPosition(50, 140);

  p5.addButton("FastForward")
    .setPosition(50, 170)
    .setLabel("Fast Forward");
    
  p5.addButton("Reset")
    .setPosition(50, 200);
  ac.out.addInput(music);

  ac.out.addInput(play);
  ac.out.addInput(rewind);
  ac.out.addInput(stop);
  ac.out.addInput(reset);
  ac.out.addInput(fastforward);
  ac.start();
}

public SamplePlayer getButtonSamplePlayer(String fname) {
  return null;
}

// Assuming you have a ControlP5 button called ‘Play’
public void Play(int value)
{
    // if we haven’t reached the end of the tape yet, setEndListener and update playback rate
    if (music.getPosition() < musicLength) {
        music.setEndListener(musicEndListener);
        // play music forward at normal speed
        musicRateGlide.setValue(1);
    }
    // Play your ‘Play’ button sound effect
}
// Create similar button handlers for fast-forward and rewind

public void Stop() {
    musicRateGlide.setValue(0);
}

public void Rewind(int value) {
    music.setEndListener(musicEndListener);
    musicRateGlide.setValue(-2);
}

public void Reset(int value) {
    music.setEndListener(musicEndListener);
    music.setToLoopStart();
    musicRateGlide.setValue(0);
}

public void FastForward(int value) {
    // if we haven’t reached the end of the tape yet, setEndListener and update playback rate
                musicRateGlide.setValueImmediately(0); // pause music by setting the playback rate to zero

    if (music.getPosition() < musicLength) {
        music.setEndListener(musicEndListener);
        // play music forward at normal speed
        musicRateGlide.setValue(2);
    }
    // Play your ‘Play’ button sound effect
}

void draw() {
  background(0);  //fills the canvas with black (0) each frame
}
