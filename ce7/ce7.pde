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

SamplePlayer player;
UGen micInput;

RadioButton filterMode;
int currentFilterMode = 0;

Slider cutoffFreq;
Slider reverbSlider;

RadioButton micButton;
RadioButton reverbButton;

float MIN_GLIDE = 100.0;
float MAX_GLIDE = 10000;

ArrayList<Glide> glides = new ArrayList();
ArrayList<UGen> filters = new ArrayList();

Reverb reverb;

float cutoffFreqVal = MIN_GLIDE;

Gain g;

void setup() {

  size(600, 600);
  p5 = new ControlP5(this); 

  filterMode = p5.addRadioButton("filterMode")
    .setPosition(50, 40)
    .setSize(40, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(2)
    .setSpacingColumn(80)
    .setSpacingRow(10)
    .addItem("No filter", 0)
    .addItem("Low pass filter", 1)
    .addItem("High pass filter", 2)
    .addItem("Band pass filter", 3);

  filterMode.activate(0);

  cutoffFreq = p5.addSlider("cutoffFrequency")
    .setPosition(350, 40)
    .setSize(150, 20)
    .setRange(MIN_GLIDE, MAX_GLIDE)
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
    .addItem("Use REverb", 0);

  reverbSlider = p5.addSlider("reverbSlider")
    .setPosition(350, 110)
    .setSize(150, 20)
    .lock()
    .setLabel("ReverbSlider Slider"); 
     
  
  ac = new AudioContext();


  Glide lowPassGlide = new Glide(ac, MIN_GLIDE);
  BiquadFilter lowPassFilter = new BiquadFilter(ac, BiquadFilter.Type.LP, lowPassGlide, .7);
  Glide highPassGlide = new Glide(ac, MIN_GLIDE);
  BiquadFilter highPassFilter = new BiquadFilter(ac, BiquadFilter.Type.HP, highPassGlide, .7);
  
  Glide bandPassGlide = new Glide(ac, MIN_GLIDE);
  BiquadFilter bandPassFilter = new BiquadFilter(ac, BiquadFilter.Type.BP_SKIRT, bandPassGlide, .7);

  
  // set up a master gain object
  g = new Gain(ac, 2, 0.3);
  ac.out.addInput(g);

  // load up a sample included in code download
  player = null;
  try {
    // Load up a new SamplePlayer using an included audio
    // file.

    player = getSamplePlayer("accordian.wav", false);
    player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    // connect the SamplePlayer to the master Gain
    
    g.addInput(player);
  } 
  catch (Exception e) {
    // If there is an error,  the steps that got us to
    // that error.
    e.printStackTrace();
  }
  
  micInput = ac.getAudioInput();
  
  glides.add(null);
  glides.add(lowPassGlide);
  glides.add(highPassGlide);
  glides.add(bandPassGlide);
  
  filters.add(player);
  filters.add(lowPassFilter);
  filters.add(highPassFilter);
  filters.add(bandPassFilter);
  

  for (UGen filter : filters)  {
    filter.addInput(player);
  }
  
  reverb = new Reverb(ac);
  reverb.setSize(0);
  reverb.addInput(player);
    
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

void rebuildUGenGraph() {
  ArrayList<UGen> dependencyList = getUGenList();
  
  println("New UGen Graph: " );
  println(dependencyList);
  
  for (int i = 1; i < dependencyList.size(); i++) {
    dependencyList.get(i).clearInputConnections();
    dependencyList.get(i).addInput(dependencyList.get(i - 1));
  }
}

ArrayList<UGen> getUGenList() {
  ArrayList<UGen> output = new ArrayList();
  
  if (usingMic) {
    output.add(micInput);
  } else {
    output.add(player);
  }
  
  if (usingReverb) {
    output.add(reverb);
  }
  
  if (currentFilterMode != 0) {
    output.add(filters.get(currentFilterMode));
    glides.get(currentFilterMode).setValue(cutoffFreqVal);
  }
  
  output.add(g);
  
  return output;
}

void filterMode(int i) {
  if (i != -1) {
    cutoffFreq.unlock();
  }

  if (i == 0 || i == -1) {
    i = 0;
    cutoffFreq.setValue(MIN_GLIDE);
    cutoffFreq.lock();
    filterMode.activate(0);
  }
  currentFilterMode = i;
  rebuildUGenGraph();
}

void useMic(int i) {
  if (i == 0) {
    usingMic = true;
  } else {
    usingMic = false;
  }
  rebuildUGenGraph();
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
  rebuildUGenGraph();
}

void cutoffFrequency(float i) {
  cutoffFreqVal = i;
  if (filters.size() <= 0) return; // edge case
  
  UGen glide = glides.get(currentFilterMode);
  
  if (glide != null) {
    ((Glide) glide).setValue(i);
  }
}

void reverbSlider(float i) {
  println(reverb);
  if (reverb == null) return; // edge case on setup
  reverb.setSize(i / 100);
}

void draw() {
  background(back);
  stroke(fore);

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
