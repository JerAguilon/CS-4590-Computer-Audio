import controlP5.*;
import beads.*;
import java.util.Arrays; 
import java.util.List;
import java.util.ArrayList;

AudioContext ac;
ControlP5 p5;

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

float _F_Fundamental;
int _Harmonic2;
int _Harmonic3;
int _Harmonic4;
int _Harmonic5;
int _Harmonic6;
int _Harmonic7;
int _Harmonic8;
int _Harmonic9;
int _Harmonic10;
boolean isUsingCustom;

List<Slider> customSliders = new ArrayList();


void setup() {
  size(400,470);
  ac = new AudioContext();
  p5 = new ControlP5(this);


  
  masterGainGlide = new Glide(ac, .5, 200);  
  masterGain = new Gain(ac, 1, masterGainGlide);
  ac.out.addInput(masterGain);

  // create a UGen graph to synthesize a square wave from a base/fundamental frequency and 9 odd harmonics with amplitudes = 1/n
  // square wave = base freq. and odd harmonics with intensity decreasing as 1/n
  // square wave = baseFrequency + (1/3)*(baseFrequency*3) + (1/5)*(baseFrequency*5) + ...
  
  p5.addRadioButton("radioButton")
         .setPosition(20,20)
         .setSize(40,20)
         .setColorForeground(color(120))
         .setColorActive(color(255))
         .setColorLabel(color(255))
         .setItemsPerRow(2)
         .setSpacingColumn(80)
         .setSpacingRow(30)
         .addItem("Fundamental",0)
         .addItem("Square",1)
         .addItem("Triangle",2)
         .addItem("Sawtooth",3)
         .addItem("Custom", 4);
  Slider fundamental = p5.addSlider("F_Fundamental")
    .setColorForeground(color(0, 255, 0))
    .setColorActive(color(0, 255, 0))
    .setPosition(240, 10)
    .setSize(20, 150)
    .lock()
    .setLabel("Custom Fundamental Freq")
    .setRange(100, 1000);
  customSliders.add(fundamental);
  
  for (int i = 2; i <= 10; i++) {
    Slider curr = p5.addSlider("Harmonic" + Integer.toString(i))
    .setPosition(20, 200 + (i - 2) * 30)
    .setSize(150, 20)
    .lock()
    .setLabel("Harmonic " + Integer.toString(i) + " Amplitude")
    .setRange(0, 100);
    customSliders.add(curr);
  }

  ac.start();
}

void radioButton(int a) {
  removeAll();
  if (a == 0) {
      addFundamental();
  } else if (a == 1) {
      addSquare();
  } else if (a == 2) {
      addTriangle();
  } else if (a == 3) {
      addSawtooth();
  } else if (a == 4) {
      addCustom();
  }
  isUsingCustom = (a == 4) ? true : false;
  
  if (isUsingCustom) {
    for (Slider s : customSliders) {
      s.unlock();
    }
  } else {
    for (Slider s : customSliders) {
      s.lock();
    }
  }
  
}

void removeAll() {
  masterGain.clearInputConnections();
}

void Harmonic2(int val) {
  _Harmonic2 = val;
  if (isUsingCustom) {
    removeAll();
    addCustom();
  }

}

void Harmonic3(int val) {
  _Harmonic3 = val;
  if (isUsingCustom) {
    removeAll();
    addCustom();
  }
}

void Harmonic4(int val) {
  _Harmonic4 = val;
  if (isUsingCustom) {
    removeAll();
    addCustom();
  }
}

void Harmonic5(int val) {
  _Harmonic5 = val;
  if (isUsingCustom) {
    removeAll();
    addCustom();
  }
}

void Harmonic6(int val) {
  _Harmonic6 = val;
  if (isUsingCustom) {
    removeAll();
    addCustom();
  }
}

void Harmonic7(int val) {
  _Harmonic7 = val;
  if (isUsingCustom) {
    removeAll();
    addCustom();
  }
}
void Harmonic8(int val) {
  _Harmonic8 = val;
  if (isUsingCustom) {
    removeAll();
    addCustom();
  }
}
void Harmonic9(int val) {
  _Harmonic9 = val;
  if (isUsingCustom) {
    removeAll();
    addCustom();
  }
}

void Harmonic10(int val) {
  _Harmonic10 = val;
  if (isUsingCustom) {
    removeAll();
    addCustom();
  }
}

void F_Fundamental(int val) {
  _F_Fundamental = val;
  if (isUsingCustom) {
    removeAll();
    addCustom();
  }
}

float getScalingOfHarmonic(int n) {
  switch(n) {
    case 1: return 1;
    case 2: return ((float) _Harmonic2 / 100.);
    case 3: return ((float) _Harmonic3 / 100.);
    case 4: return ((float) _Harmonic4 / 100.);
    case 5: return ((float) _Harmonic5 / 100.);
    case 6: return ((float) _Harmonic6 / 100.);
    case 7: return ((float) _Harmonic7 / 100.);
    case 8: return ((float) _Harmonic8 / 100.);
    case 9: return ((float) _Harmonic9 / 100.);
    case 10: return ((float) _Harmonic10 / 100.);
  }
  throw new RuntimeException("Should not reach");
}

void addCustom() {
  float sineIntensity = 1.0;
  for( int i = 0, n = 1; i < sineCount; i++, n++) {
    // create the glide that will control this WavePlayer's frequency
    // create an array of Glides in anticipation of connecting them with ControlP5 sliders
    sineFrequency[i] = new Glide(ac, _F_Fundamental * n, 200);
    
    // Create harmonic frequency WavePlayer - i.e. baseFrequency * 3, baseFrequency * 5, ...
    sineTone[i] = new WavePlayer(ac, sineFrequency[i], Buffer.SINE);
    
    // Create gain for each harmonic - i.e. 1/3, 1/5, 1/7, ...
    // For a square wave, we only want odd harmonics, so set all even harmonics to 0 gain/intensity
    sineIntensity = getScalingOfHarmonic(n);
    println(sineIntensity, " * ", baseFrequency * n);
    sineGain[i] = new Gain(ac, 1, sineIntensity); // create the gain object
    sineGain[i].addInput(sineTone[i]); // then connect the waveplayer to the gain
  
    // finally, connect the gain to the master gain
    // masterGain will sum all of the sine waves, additively synthesizing a square wave tone
    masterGain.addInput(sineGain[i]);
  }
}

void addFundamental() {
  Glide sineFrequency = new Glide(ac, baseFrequency, 200);
  WavePlayer wavePlayer = new WavePlayer(ac, sineFrequency, Buffer.SINE);
  
  for (int i = 1; i < customSliders.size(); i++) {
    customSliders.get(i).setValue(0);
  }
  
  Gain gain = new Gain(ac, 1, 1); // create the gain object
  gain.addInput(wavePlayer); // then connect the waveplayer to the gain

  // finally, connect the gain to the master gain
  // masterGain will sum all of the sine waves, additively synthesizing a square wave tone
  masterGain.addInput(gain);
}


void addSquare() {
  float sineIntensity = 1.0;

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
    
    if (i == 0) {
      customSliders.get(i).setValue(baseFrequency);
    } else {
      customSliders.get(i).setValue(sineIntensity * 100);
    }
  
    // finally, connect the gain to the master gain
    // masterGain will sum all of the sine waves, additively synthesizing a square wave tone
    masterGain.addInput(sineGain[i]);
  }
}

void addTriangle() {
  float sineIntensity = 1.0;

  for( int i = 0, n = 1; i < sineCount; i++, n++) {
    // create the glide that will control this WavePlayer's frequency
    // create an array of Glides in anticipation of connecting them with ControlP5 sliders
    sineFrequency[i] = new Glide(ac, baseFrequency * n, 200);
    
    // Create harmonic frequency WavePlayer - i.e. baseFrequency * 3, baseFrequency * 5, ...
    sineTone[i] = new WavePlayer(ac, sineFrequency[i], Buffer.SINE);
    
    // Create gain for each harmonic - i.e. 1/3, 1/5, 1/7, ...
    // For a square wave, we only want odd harmonics, so set all even harmonics to 0 gain/intensity
    sineIntensity = (n % 2 == 1) ? (float) (1.0 / (n * n)) : 0;
    println(sineIntensity, " * ", baseFrequency * n);
    sineGain[i] = new Gain(ac, 1, sineIntensity); // create the gain object
    sineGain[i].addInput(sineTone[i]); // then connect the waveplayer to the gain

    if (i == 0) {
      customSliders.get(i).setValue(baseFrequency);
    } else {
      customSliders.get(i).setValue(sineIntensity * 100);
    }
  
  
    // finally, connect the gain to the master gain
    // masterGain will sum all of the sine waves, additively synthesizing a square wave tone
    masterGain.addInput(sineGain[i]);
  }
}

void addSawtooth() {

  float sineIntensity = 1.0;

  for( int i = 0, n = 1; i < sineCount; i++, n++) {
    // create the glide that will control this WavePlayer's frequency
    // create an array of Glides in anticipation of connecting them with ControlP5 sliders
    sineFrequency[i] = new Glide(ac, baseFrequency * n, 200);
    
    // Create harmonic frequency WavePlayer - i.e. baseFrequency * 3, baseFrequency * 5, ...
    sineTone[i] = new WavePlayer(ac, sineFrequency[i], Buffer.SINE);
    
    // Create gain for each harmonic - i.e. 1/3, 1/5, 1/7, ...
    // For a square wave, we only want odd harmonics, so set all even harmonics to 0 gain/intensity
    sineIntensity = (float) (1.0 / (n));
    println("INTENSITY: " + Float.toString(sineIntensity));
    println(sineIntensity, " * ", baseFrequency * n);
    sineGain[i] = new Gain(ac, 1, sineIntensity); // create the gain object
    sineGain[i].addInput(sineTone[i]); // then connect the waveplayer to the gain
  
    if (i == 0) {
      customSliders.get(i).setValue(baseFrequency);
    } else {
      customSliders.get(i).setValue(sineIntensity * 100);
    }
   
    // finally, connect the gain to the master gain
    // masterGain will sum all of the sine waves, additively synthesizing a square wave tone
    masterGain.addInput(sineGain[i]);
  }
}


void draw() {
  background(1);
}
