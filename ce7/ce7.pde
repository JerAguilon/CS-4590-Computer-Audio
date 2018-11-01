// FFT_01.pde
// This example is based in part on an example included with
// the Beads download originally written by Beads creator
// Ollie Bown. It draws the frequency information for a
// sound on screen.
import beads.*;
import controlP5.*;

import java.util.ArrayList;

ControlP5 p5;

PowerSpectrum ps;
color fore = color(255, 255, 255);
color back = color(0, 0, 0);

boolean usingMic = false;
boolean usingReverb = false;

RadioButton filterMode;
int currentFilterMode;

Slider cutoffFreq;
Slider reverbSlider;

RadioButton micButton;
RadioButton reverbButton;

ArrayList<UGen> filters;

float cutoffFreqVal;
float reverbVal;

void setup() {
      
  size(600, 600);
  p5 = new ControlP5(this); 
  
  filterMode = p5.addRadioButton("filterMode")
         .setPosition(50, 40)
         .setSize(40,20)
         .setColorForeground(color(120))
         .setColorActive(color(255))
         .setColorLabel(color(255))
         .setItemsPerRow(2)
         .setSpacingColumn(80)
         .setSpacingRow(10)
         .addItem("No filter",0)
         .addItem("Low pass filter",1)
         .addItem("High pass filter",2)
         .addItem("Band pass filter",3);
         
  filterMode.activate(0);
         
  cutoffFreq = p5.addSlider("cutoffFrequency")
    .setPosition(350, 40)
    .setSize(150, 20)
    .setRange(0, 100)
    .lock()
    .setLabel("Cut Off Frequency");

  micButton = p5.addRadioButton("useMic")
    .setPosition(50, 145)
    .setSize(40, 20)
   .setColorForeground(color(120))
   .setColorActive(color(255))
   .setColorLabel(color(255))
    .addItem("Use Mic", 0);

  reverbButton = p5.addRadioButton("useReverb")
    .setSize(40, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setPosition(50, 110)
    .addItem("Use Reverb", 0);
    
  reverbSlider = p5.addSlider("reverbSlider")
    .setPosition(350, 110)
    .setSize(150, 20)
    .lock()
    .setLabel("Reverb Slider");    
  ac = new AudioContext();

    // set up a master gain object
    Gain g = new Gain(ac, 2, 0.3);
    ac.out.addInput(g);

    // load up a sample included in code download
    SamplePlayer player = null;
    try {
        // Load up a new SamplePlayer using an included audio
        // file.

        player = getSamplePlayer("techno.wav", false);
        player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
        // connect the SamplePlayer to the master Gain
        g.addInput(player);
    } catch (Exception e) {
        // If there is an error, print the steps that got us to
        // that error.
        e.printStackTrace();
    }
    // In this block of code, we build an analysis chain
    // the ShortFrameSegmenter breaks the audio into short,
    // discrete chunks.
    ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
    sfs.addInput(ac.out);

    // FFT stands for Fast Fourier Transform
    // all you really need to know about the FFT is that it
    // lets you see what frequencies are present in a sound
    // the waveform we usually look at when we see a sound
    // displayed graphically is time domain sound data
    // the FFT transforms that into frequency domain data
    FFT fft = new FFT();
    // connect the FFT object to the ShortFrameSegmenter
    sfs.addListener(fft);

    // the PowerSpectrum pulls the Amplitude information from
    // the FFT calculation (essentially)
    ps = new PowerSpectrum();
    // connect the PowerSpectrum to the FFT
    fft.addListener(ps);
    // list the frame segmenter as a dependent, so that the
    // AudioContext knows when to update it.
    ac.out.addDependent(sfs);
    // start processing audio
    ac.start();
}
    // In the draw routine, we will interpret the FFT results and
    // draw them on screen.

void filterMode(int i) {
  if (i != -1) {
    cutoffFreq.unlock();
  }
  
  if (i == 0 || i == -1) {
    i = 0;
    cutoffFreq.setValue(0);
    cutoffFreq.lock();
    filterMode.activate(0);
  }
  
  UGen oldFilter = filters.get(currentFilterMode);
  currentFilterMode = i;
  UGen newFilter = filters.get(currentFilterMode);
}

void useMic(int i) {
  if (i == 0) {
    usingMic = true;
  } else {
    usingMic = false;
  }
}

void useReverb(int i ) {
  if (i == 0) {
    usingReverb = true;
  } else {
    usingReverb = false;
  }
  
  if (usingReverb) {
    reverbSlider.unlock();
  } else {
    reverbSlider.lock();
    reverbSlider.setValue(0);
  }
}

void cutoffFrequency(float i) {
  println(i);
  cutoffFreqVal = i;
}

void reverbSlider(float i) {
  println(i);
  reverbVal = i;
}

void draw() {
    background(back);
    stroke(fore);
    
    line(0, 95, width, 95);
    line(0, 140, width, 140);

    // The getFeatures() function is a key part of the Beads
    // analysis library. It returns an array of floats
    // how this array of floats is defined (1 dimension, 2
    // dimensions ... etc) is based on the calling unit
    // generator. In this case, the PowerSpectrum returns an
    // array with the power of 256 spectral bands.
    float[] features = ps.getFeatures();

    // if any features are returned
    if (features != null) {
        // for each x coordinate in the Processing window
        for (int x = 0; x < width; x++) {
            // figure out which featureIndex corresponds to this x-
            // position
            int featureIndex = (x * features.length) / width;
            // calculate the bar height for this feature
            int barHeight = (int) (Math.min((int)(features[featureIndex] *
                height), height - 1) * .7);
            // draw a vertical line corresponding to the frequency
            // represented by this x-position
            line(x, height, x, height - barHeight);
        }
    }
}
