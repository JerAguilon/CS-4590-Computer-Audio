import beads.*;

//helper functions
AudioContext ac; //needed here because getSamplePlayer() uses it below

Sample getSample(String fileName) {
  return SampleManager.sample(dataPath(fileName)); 
}

SamplePlayer getSamplePlayer(String fileName, Boolean killOnEnd) {
  SamplePlayer player = null;
  try {
    player = new SamplePlayer(ac, getSample(fileName));
    player.setKillOnEnd(killOnEnd);
    player.setName(fileName);
  }
  catch(Exception e) {
    println("Exception while attempting to load sample: " + fileName);
    println(e);
    e.printStackTrace();
    exit();
  }
  
  return player;
}

SamplePlayer getSamplePlayer(String fileName) {
  return getSamplePlayer(fileName, false);
}

SamplePlayer getSamplePlayer(Environment e) {
  return getSamplePlayer(e.getSoundFile());
}

SamplePlayer getSamplePlayer(NotificationSound n) {
  return getSamplePlayer(n.getSoundFile(), true);
}

public enum Environment {
  PUBLIC_TRANSIT(""), JOGGING("jogging.mp3"), PARTY("party.mp3"), LECTURING("");
  
  private final String soundFile;
  
  private Environment(String soundFile) {
    this.soundFile = soundFile;
  }
  
  public String getSoundFile() {
    return this.soundFile;
  }
}


public enum NotificationSound {
  EMAIL_DING(""),
  EMAIL_TRIPLE_DING(""),
  
  TWITTER_CHIRP("chirp.wav"),
  
  PHONE_DEFAULT_RING("phone_ring.wav"),
  PHONE_URGENT_RING(""),

  VOICEMAIL_CLIMBING_BEEPS("");
  
  private final String wavFile;
  
  private NotificationSound(String wavFile) {
    this.wavFile = wavFile;
  }
  
  public String getSoundFile() {
    return this.wavFile;
  }
  
}
