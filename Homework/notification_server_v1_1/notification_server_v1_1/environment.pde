import beads.*;

//helper functions
AudioContext ac; //needed here because getSamplePlayer() uses it below

UGen getSineWaveUGen(float baseFrequency) {
  Glide sineFrequency = new Glide(ac, baseFrequency, 200);
  UGen wavePlayer = new WavePlayer(ac, sineFrequency, Buffer.SINE);
  Gain gain = new Gain(ac, 1, .5); // create the gain object
  gain.addInput(wavePlayer);
  return gain;
}

Sample getSample(String fileName) {
  return SampleManager.sample(dataPath(fileName)); 
}

SamplePlayer getSamplePlayer(String fileName, Boolean killOnEnd, SamplePlayer.LoopType loopType) {
  SamplePlayer player = null;
  try {
    player = new SamplePlayer(ac, getSample(fileName));
    player.setKillOnEnd(killOnEnd);
    player.setName(fileName);
    player.setLoopType(loopType);
  }
  catch(Exception e) {
    println("Exception while attempting to load sample: " + fileName);
    println(e);
    e.printStackTrace();
    exit();
  }
  
  return player;
}

SamplePlayer getSamplePlayer(String fileName, SamplePlayer.LoopType loopType) {
  return getSamplePlayer(fileName, false, loopType);
}

SamplePlayer getSamplePlayer(Environment e, SamplePlayer.LoopType loopType) {
  return getSamplePlayer(e.getSoundFile(), loopType);
}

SamplePlayer getSamplePlayer(Environment e) {
  return getSamplePlayer(e, SamplePlayer.LoopType.NO_LOOP_FORWARDS);
}

SamplePlayer getSamplePlayer(NotificationSound n) {
  return getSamplePlayer(n.getSoundFile(), true, SamplePlayer.LoopType.NO_LOOP_FORWARDS);
}

public enum Environment {
  PUBLIC_TRANSIT("subway.wav"), JOGGING("jogging.wav"), PARTY("party.mp3"), LECTURING("psychology_lecture_short.mp3");
  
  private final String soundFile;
  
  private Environment(String soundFile) {
    this.soundFile = soundFile;
  }
  
  public String getSoundFile() {
    return this.soundFile;
  }
}


public enum NotificationSound {
  EMAIL_DING("single_ding.wav"),
  EMAIL_TRIPLE_DING("ding_dong.wav"),
  
  TWITTER_CHIRP("chirp.wav"),
  
  MISSED_CALL_DEFAULT("missed_call_default.wav"),
  MISSED_CALL_URGENT("missed_call_urgent.wav"),

  TEXT_DEFAULT_NOTIFICATION("text_notif_default.mp3"),

  VOICEMAIL_CHIME("voicemail.wav");
  
  private final String wavFile;
  
  private NotificationSound(String wavFile) {
    this.wavFile = wavFile;
  }
  
  public String getSoundFile() {
    return this.wavFile;
  }
  
}
